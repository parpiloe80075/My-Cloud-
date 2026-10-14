import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase-server";
import SiteFooter from "@/components/site-footer";
import { ArrowLeft, Sparkles } from "lucide-react";
import AiStudio from "./ai-studio";
import "../../../workspace.css";
import "./ai-studio.css";

export const metadata: Metadata = { title: "AI Materials Studio | SatGold Cloud", description: "Create draft lesson plans, quiz questions, worksheets, study guides and school notices with educator reviewed AI assistance." };

export default async function AiStudioPage() {
  const supabase = await createClient();
  if (!supabase) redirect("/login?setup=supabase");
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: membership } = await supabase.from("school_memberships").select("role").eq("user_id", user.id).eq("status", "active").maybeSingle();
  if (!membership || !["owner", "administrator", "teacher"].includes(membership.role)) redirect("/login?error=school-access");
  return <main className="workspace-page">
    <header className="workspace-nav"><Link href={membership.role === "teacher" ? "/teacher/home" : "/school/dashboard"} className="workspace-back"><ArrowLeft size={17}/> Workspace</Link><span>SatGold Cloud</span><form action="/auth/signout" method="post"><button className="workspace-signout">Sign out</button></form></header>
    <section className="workspace-wrap"><div className="workspace-heading"><span className="workspace-icon"><Sparkles/></span><div><span className="workspace-kicker">TEACHING AND SCHOOL WORK</span><h1>AI materials studio</h1><p>Make concise drafts for educators to review and adapt.</p></div></div>
      <AiStudio />
      <SiteFooter />
    </section>
  </main>;
}
