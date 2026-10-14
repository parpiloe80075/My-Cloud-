import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase-server";

const allowedKinds = new Set(["Lesson plan", "Quiz questions", "Worksheet", "Study guide", "School notice", "Short summary"]);

export async function POST(request: Request) {
  const supabase = await createClient();
  if (!supabase) return NextResponse.json({ error: "School sign in is not configured." }, { status: 503 });
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: "Sign in to use the AI materials studio." }, { status: 401 });
  const { data: membership } = await supabase.from("school_memberships").select("role").eq("user_id", user.id).eq("status", "active").maybeSingle();
  if (!membership || !["owner", "administrator", "teacher"].includes(membership.role)) {
    return NextResponse.json({ error: "Your school account does not have access to this tool." }, { status: 403 });
  }
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey || apiKey === "your-gemini-api-key") {
    return NextResponse.json({ error: "AI materials are not configured yet. Add a valid GEMINI_API_KEY to the server environment." }, { status: 503 });
  }

  let body: { kind?: unknown; level?: unknown; subject?: unknown; topic?: unknown; instructions?: unknown };
  try { body = await request.json(); } catch { return NextResponse.json({ error: "Enter the material details and try again." }, { status: 400 }); }
  const kind = typeof body.kind === "string" ? body.kind.trim() : "";
  const level = typeof body.level === "string" ? body.level.trim() : "";
  const subject = typeof body.subject === "string" ? body.subject.trim() : "";
  const topic = typeof body.topic === "string" ? body.topic.trim() : "";
  const instructions = typeof body.instructions === "string" ? body.instructions.trim().slice(0, 1200) : "";
  if (!allowedKinds.has(kind) || !level || !subject || !topic || level.length > 100 || subject.length > 100 || topic.length > 180) {
    return NextResponse.json({ error: "Choose a material type and enter a class level, subject and topic." }, { status: 400 });
  }

  try {
    const response = await fetch("https://generativelanguage.googleapis.com/v1beta/interactions", {
      method: "POST",
      headers: { "Content-Type": "application/json", "x-goog-api-key": apiKey },
      body: JSON.stringify({
        model: "gemini-flash-latest",
        system_instruction: "You are an education assistant creating concise classroom materials for Nigerian schools. Use clear age-appropriate language, align examples to the stated subject and level, avoid inventing official curriculum claims, and never request or include identifiable student data. For summaries, preserve the source meaning and flag uncertainty. Return a useful, structured draft with headings and bullets where appropriate.",
        input: `Create a ${kind} for ${level}, subject: ${subject}, topic: ${topic}.${instructions ? ` Additional instructions: ${instructions}` : ""} Keep it concise and ready for an educator to review.`,
        generation_config: { max_output_tokens: 1400, thinking_level: "low" },
      }),
      signal: AbortSignal.timeout(45000),
    });
    const result = await response.json() as { steps?: Array<{ type?: string; content?: Array<{ type?: string; text?: string }> }>; error?: { message?: string } };
    if (!response.ok) {
      console.error("Gemini material generation failed", response.status, result.error?.message || "provider error");
      return NextResponse.json({ error: "The AI provider could not create this material. Check the server AI configuration and try again." }, { status: 502 });
    }
    const text = (result.steps || []).filter(step => step.type === "model_output").flatMap(step => step.content || []).filter(part => part.type === "text").map(part => part.text || "").join("\n").trim();
    if (!text) return NextResponse.json({ error: "The AI provider returned an empty draft. Try adding more detail to the topic." }, { status: 502 });
    return NextResponse.json({ text });
  } catch (error) {
    console.error("Gemini request failed", error instanceof Error ? error.message : "unknown error");
    return NextResponse.json({ error: "Could not reach the AI provider. Please try again." }, { status: 502 });
  }
}
