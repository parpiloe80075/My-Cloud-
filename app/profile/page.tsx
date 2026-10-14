import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase-server";
import SiteFooter from "@/components/site-footer";
import ProfileForm from "@/components/profile-form";
import { ArrowLeft, UserRound } from "lucide-react";
import "../workspace.css";

export const metadata: Metadata = { title: "My Profile | SatGold Cloud", description: "View and update your SatGold Cloud account profile." };

export default async function ProfilePage() {
  const supabase = await createClient();
  if (!supabase) redirect("/login?setup=supabase");
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: membership } = await supabase.from("school_memberships").select("role,schools(name)").eq("user_id", user.id).eq("status", "active").maybeSingle();
  if (!membership) redirect("/login?error=school-access");
  const school = Array.isArray(membership.schools) ? membership.schools[0] : membership.schools as {name:string}|null;
  return <main className="workspace-page">
    <header className="workspace-nav"><Link href={membership.role === "teacher" ? "/teacher/home" : "/school/dashboard"} className="workspace-back"><ArrowLeft size={17}/> Workspace</Link><span>SatGold Cloud</span><form action="/auth/signout" method="post"><button className="workspace-signout">Sign out</button></form></header>
    <section className="workspace-wrap"><div className="workspace-heading"><span className="workspace-icon"><UserRound/></span><div><span className="workspace-kicker">ACCOUNT SETTINGS</span><h1>My profile</h1><p>Keep your account details current for your school community.</p></div></div>
      <article className="workspace-card"><h2>Profile details</h2><p className="workspace-muted">{school?.name || "School workspace"}</p><ProfileForm initialName={String(user.user_metadata.full_name || "")} initialPhone={String(user.user_metadata.phone || "")} email={user.email || ""}/></article>
      <SiteFooter />
    </section>
  </main>;
}
