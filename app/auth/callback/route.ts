import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

type CookieToSet = {
  name: string;
  value: string;
  options: CookieOptions;
};

export async function GET(request: NextRequest) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");

  if (
    code &&
    process.env.NEXT_PUBLIC_SUPABASE_URL &&
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
  ) {
    const response = NextResponse.redirect(`${origin}/school/dashboard`);
    const client = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
      {
        cookies: {
          getAll: () => request.cookies.getAll(),
          setAll(cookies: CookieToSet[]) {
            cookies.forEach(({ name, value, options }) =>
              response.cookies.set(name, value, options),
            );
          },
        },
      },
    );

    const { error } = await client.auth.exchangeCodeForSession(code);
    if (!error) {
      const { data: { user } } = await client.auth.getUser();
      if (user) {
        const { data: membership } = await client.from("school_memberships").select("role").eq("user_id", user.id).eq("status", "active").maybeSingle();
        response.headers.set("location", `${origin}${membership?.role === "teacher" ? "/teacher/home" : "/school/dashboard"}`);
      }
      return response;
    }
  }

  return NextResponse.redirect(`${origin}/login?error=confirmation`);
}
