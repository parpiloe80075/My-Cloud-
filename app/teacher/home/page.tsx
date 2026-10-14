import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase-server";
import SiteFooter from "@/components/site-footer";
import { ArrowRight, BookOpen, CalendarDays, ClipboardCheck, FileText, UserRound, Sparkles } from "lucide-react";
import "../../workspace.css";

export const metadata: Metadata = { title: "Teacher Workspace | SatGold Cloud", description: "Access your teaching workspace, class activities and student progress reports." };

export default async function TeacherHome() {
  const supabase = await createClient();
  if (!supabase) redirect("/login?setup=supabase");
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: membership } = await supabase.from("school_memberships").select("id,role,school_id,schools(name)").eq("user_id", user.id).eq("status", "active").maybeSingle();
  if (!membership || membership.role !== "teacher") redirect("/login?error=school-access");
  const school = Array.isArray(membership.schools) ? membership.schools[0] : membership.schools as {name:string}|null;
  const { data: staffProfile } = await supabase.from("staff_profiles").select("id").eq("school_id", membership.school_id).eq("membership_id", membership.id).maybeSingle();
  const { count: assignmentCount } = staffProfile ? await supabase.from("teacher_assignments").select("id", { count: "exact", head: true }).eq("school_id", membership.school_id).eq("staff_id", staffProfile.id) : { count: 0 };
  const tools = [
    [BookOpen, "My classes", "See the classes and subjects connected to your role.", "/features#tool-6"],
    [ClipboardCheck, "Assessments", "Prepare and review academic work assigned to you.", "/features#tool-3"],
    [FileText, "Progress reports", "Review weekly student observations and report status.", "/assessments/progress-reports"],
    [CalendarDays, "School calendar", "Keep track of key school dates.", "/features#tool-2"],
    [Sparkles, "AI materials", "Draft lesson plans, quizzes and study materials for educator review.", "/school/dashboard/ai-studio"],
  ] as const;
  return <main className="workspace-page">
    <header className="workspace-nav"><Link href="/profile" className="workspace-back"><UserRound size={17}/> My profile</Link><span>SatGold Cloud</span><form action="/auth/signout" method="post"><button className="workspace-signout">Sign out</button></form></header>
    <section className="workspace-wrap"><div className="workspace-heading"><span className="workspace-icon"><BookOpen/></span><div><span className="workspace-kicker">TEACHER WORKSPACE</span><h1>Welcome, {String(user.user_metadata.full_name || "Teacher").split(" ")[0]}</h1><p>{school?.name || "School workspace"} Â· Your teaching overview</p></div></div>
      <div className="workspace-metrics"><article><span>Assigned classes and subjects</span><strong>{assignmentCount ?? 0}</strong></article><article><span>Account</span><strong>Active</strong></article></div>
      <div className="workspace-tools-heading"><div><span className="workspace-kicker">YOUR WORKSPACE</span><h2>Teaching tools</h2></div></div>
      <div className="workspace-tools">{tools.map(([Icon,title,description,href])=><Link href={href} className="workspace-tool" key={title}><span><Icon size={20}/></span><div><h3>{title}</h3><p>{description}</p></div><ArrowRight size={17}/></Link>)}</div>
      <SiteFooter />
    </section>
  </main>;
}
