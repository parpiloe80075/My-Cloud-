import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase-server";
import SiteFooter from "@/components/site-footer";
import { ArrowLeft, FileText } from "lucide-react";
import "../../workspace.css";

export const metadata: Metadata = { title: "Student Progress Reports | SatGold Cloud", description: "Review student progress reports available to your school account." };

type Report = { id: string; week_start: string; status: string; answers: Record<string, string>; review_comment: string | null; student_profiles: { student_code: string } | { student_code: string }[] | null; school_classes: { name: string } | { name: string }[] | null };

export default async function ProgressReportsPage() {
  const supabase = await createClient();
  if (!supabase) redirect("/login?setup=supabase");
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: membership } = await supabase.from("school_memberships").select("role,school_id,schools(name)").eq("user_id", user.id).eq("status", "active").maybeSingle();
  if (!membership || !["owner", "administrator", "teacher"].includes(membership.role)) redirect("/login?error=school-access");
  const { data, error } = await supabase.from("student_weekly_reports").select("id,week_start,status,answers,review_comment,student_profiles(student_code),school_classes(name)").eq("school_id", membership.school_id).order("week_start", { ascending: false }).limit(50);
  const reports = (data || []) as unknown as Report[];
  const school = Array.isArray(membership.schools) ? membership.schools[0] : membership.schools as {name:string}|null;
  const displayValue = (row: Report, key: string) => typeof row.answers?.[key] === "string" ? row.answers[key] : "";
  return <main className="workspace-page">
    <header className="workspace-nav"><Link href={membership.role === "teacher" ? "/teacher/home" : "/school/dashboard"} className="workspace-back"><ArrowLeft size={17}/> Workspace</Link><span>SatGold Cloud</span><form action="/auth/signout" method="post"><button className="workspace-signout">Sign out</button></form></header>
    <section className="workspace-wrap"><div className="workspace-heading"><span className="workspace-icon"><FileText/></span><div><span className="workspace-kicker">ACADEMIC REPORTING</span><h1>Student progress reports</h1><p>{school?.name || "School workspace"} · Reports visible to your account</p></div></div>
      {error ? <div className="workspace-empty"><h2>Reports are not available</h2><p>The report data could not be loaded for this account. Check your school access or contact your administrator.</p></div> : reports.length ? <div className="report-list">{reports.map(row => {
        const student = Array.isArray(row.student_profiles) ? row.student_profiles[0] : row.student_profiles;
        const schoolClass = Array.isArray(row.school_classes) ? row.school_classes[0] : row.school_classes;
        return <article className="report-card" key={row.id}><div className="report-card-top"><div><span className="workspace-kicker">{schoolClass?.name || "Class"}</span><h2>Student {student?.student_code || "record"}</h2><p>Week starting {new Date(`${row.week_start}T00:00:00`).toLocaleDateString("en-NG", {day:"numeric",month:"long",year:"numeric"})}</p></div><span className={`report-status status-${row.status}`}>{row.status}</span></div>
          {displayValue(row,"participation") && <div><h3>Participation</h3><p>{displayValue(row,"participation")}</p></div>}
          {displayValue(row,"strengths") && <div><h3>Progress and strengths</h3><p>{displayValue(row,"strengths")}</p></div>}
          {displayValue(row,"support") && <div><h3>Support and next steps</h3><p>{displayValue(row,"support")}</p></div>}
          {row.review_comment && <div className="report-review"><b>Reviewer note</b><p>{row.review_comment}</p></div>}
        </article>;
      })}</div> : <div className="workspace-empty"><h2>No progress reports yet</h2><p>Reports will appear here after they are created for your classes and made available to your account.</p></div>}
      <SiteFooter />
    </section>
  </main>;
}
