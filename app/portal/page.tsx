import type { Metadata } from "next";
import Link from "next/link";
import { ArrowRight, GraduationCap, UsersRound, BookOpen, ClipboardList, LockKeyhole } from "lucide-react";
import SiteFooter from "@/components/site-footer";
import "../site.css";
import "./portal.css";

export const metadata: Metadata = {
  title: "School Portal for Students, Teachers and Parents | SatGold Cloud",
  description: "Discover the SatGold Cloud school portal concept for connecting school administrators, teachers, students and parents through role based access.",
};

const roles = [
  [GraduationCap, "For School Administrators", "Organise school information, coordinate authorised users and oversee the academic processes supported by the platform."],
  [BookOpen, "For Teachers", "Support teaching and academic responsibilities through the tools made available for assessments, student progress and reporting."],
  [ClipboardList, "For Students", "Access the school information and academic tools assigned to your student account when the relevant features are enabled."],
  [UsersRound, "For Parents", "Stay connected with the school through the information and updates made available to your parent account."],
] as const;

export default function SchoolPortal() {
  return <main className="portal-page">
    <header className="portal-nav"><Link href="/" className="brand"><span className="wordmark">satgold<span className="brand-light">cloud</span></span></Link><Link href="/" className="portal-back">Back to home</Link></header>
    <section className="portal-hero"><div className="portal-copy"><span className="eyebrow">SCHOOL PORTAL</span><h1>One School Portal.<br/><em>Different Ways to Stay Connected.</em></h1><h2>The right school information for the right people</h2><p>A school community works best when everyone understands their responsibilities and can access the information relevant to them.</p><p>SatGold Cloud is designed to bring school administrators, teachers, students and parents into a connected digital environment, with each user working through an appropriate role based workspace.</p></div><div className="portal-photo" role="img" aria-label="Students and teacher sharing a classroom learning experience"/> </section>
    <section className="portal-role-section"><div className="content-kicker">A WORKSPACE FOR EVERY ROLE</div><div className="portal-role-grid">{roles.map(([Icon,title,description])=><article className="portal-role-card" key={title}><span><Icon size={21}/></span><h2>{title}</h2><p>{description}</p></article>)}</div></section>
    <section className="portal-access"><div className="portal-access-icon"><LockKeyhole size={25}/></div><div><div className="content-kicker">ACCESS YOUR SCHOOL ACCOUNT</div><h2>Access Your School Account</h2><p>Use the official sign in option provided by your school or the SatGold Cloud platform. Follow your school's account instructions and keep your login details private.</p><p>If you have trouble accessing your account, contact your school administrator or the support team for assistance.</p></div></section>
    <section className="portal-closing"><div className="content-kicker">A MORE CONNECTED SCHOOL COMMUNITY</div><h2>A More Connected School Community</h2><p>SatGold Cloud aims to make school information more organised and accessible while respecting the permissions assigned to each role.</p><div className="portal-actions"><Link href="/login" className="button button-dark"><LockKeyhole size={17}/> Sign In <ArrowRight size={16}/></Link><Link href="/register" className="button portal-register">Register Your School <ArrowRight size={16}/></Link></div></section>
    <SiteFooter/>
  </main>;
}
