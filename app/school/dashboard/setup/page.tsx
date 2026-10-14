import Link from "next/link";
import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase-server";
import SiteFooter from "@/components/site-footer";
import "./setup.css";

async function getOwner() {
  const supabase = await createClient();
  if (!supabase) redirect("/login?setup=supabase");
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: membership } = await supabase.from("school_memberships").select("role,school_id").eq("user_id", user.id).eq("status", "active").maybeSingle();
  if (!membership || membership.role !== "owner") redirect("/login?error=school-access");
  return { supabase, schoolId: membership.school_id };
}

async function addClass(formData: FormData) {
  "use server";
  const name = String(formData.get("name") || "").trim().slice(0, 80);
  const arm = String(formData.get("arm") || "").trim().slice(0, 40);
  if (!name) redirect("/school/dashboard/setup?error=class");
  const { supabase, schoolId } = await getOwner();
  const { error } = await supabase.from("school_classes").insert({ school_id: schoolId, name, arm: arm || null });
  revalidatePath("/school/dashboard/setup");
  revalidatePath("/school/dashboard");
  redirect(`/school/dashboard/setup?${error ? "error=class" : "saved=class"}`);
}

async function addSubject(formData: FormData) {
  "use server";
  const name = String(formData.get("name") || "").trim().slice(0, 80);
  if (!name) redirect("/school/dashboard/setup?error=subject");
  const { supabase, schoolId } = await getOwner();
  const { error } = await supabase.from("school_subjects").insert({ school_id: schoolId, name });
  revalidatePath("/school/dashboard/setup");
  revalidatePath("/school/dashboard");
  redirect(`/school/dashboard/setup?${error ? "error=subject" : "saved=subject"}`);
}

export default async function SchoolSetup({ searchParams }: { searchParams: Promise<{ error?: string; saved?: string }> }) {
  const [{ supabase, schoolId }, params] = await Promise.all([getOwner(), searchParams]);
  const [{ data: classes }, { data: subjects }] = await Promise.all([
    supabase.from("school_classes").select("id,name,arm").eq("school_id", schoolId).order("name"),
    supabase.from("school_subjects").select("id,name").eq("school_id", schoolId).order("name"),
  ]);
  const message = params.error ? "Could not save that entry. Check whether it already exists and try again." : params.saved ? "Saved successfully." : "";
  return <main className="setup-page"><header className="setup-nav"><Link href="/school/dashboard" className="setup-wordmark">satgold<span>cloud</span></Link><Link href="/school/dashboard" className="setup-back">← Dashboard</Link></header><section className="setup-main"><span className="setup-kicker">SCHOOL WORKSPACE</span><h1>School setup</h1><p className="setup-lead">Organise the classes and subjects your school teaches. Changes are saved to this school workspace.</p>{message && <p className={params.error ? "setup-message error" : "setup-message"} role="status">{message}</p>}<div className="setup-grid"><section className="setup-card"><div className="setup-card-heading"><div><span className="setup-kicker">ACADEMIC STRUCTURE</span><h2>Classes</h2></div><strong>{classes?.length ?? 0}</strong></div><form action={addClass} className="setup-form"><label>Class name<input name="name" maxLength={80} placeholder="e.g. Primary 4" required /></label><label>Arm <span className="setup-optional">optional</span><input name="arm" maxLength={40} placeholder="e.g. Blue" /></label><button type="submit">Add class</button></form><ul className="setup-list">{classes?.map(item => <li key={item.id}><span>{item.name}{item.arm ? ` · ${item.arm}` : ""}</span><small>Active</small></li>)}{!classes?.length && <li className="setup-empty">No classes added yet.</li>}</ul></section><section className="setup-card"><div className="setup-card-heading"><div><span className="setup-kicker">TEACHING PROGRAMME</span><h2>Subjects</h2></div><strong>{subjects?.length ?? 0}</strong></div><form action={addSubject} className="setup-form"><label>Subject name<input name="name" maxLength={80} placeholder="e.g. Mathematics" required /></label><button type="submit">Add subject</button></form><ul className="setup-list">{subjects?.map(item => <li key={item.id}><span>{item.name}</span><small>Active</small></li>)}{!subjects?.length && <li className="setup-empty">No subjects added yet.</li>}</ul></section></div><p className="setup-hint">To avoid removing academic records by mistake, edits and deletions are managed by an authorised administrator.</p></section><SiteFooter /></main>;
}
