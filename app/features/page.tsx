import type { Metadata } from "next";
import Link from "next/link";
import { ArrowRight, Bell, BookOpen, BrainCircuit, CalendarDays, ClipboardList, FileText, GraduationCap, Menu, MonitorPlay, ShieldCheck, UsersRound } from "lucide-react";
import "../site.css";
import "./features.css";
import SiteFooter from "@/components/site-footer";

export const metadata: Metadata = {
  title: "School Management Software Features | SatGold Cloud",
  description: "Explore SatGold Cloud school management software for academic records, computer based tests, student reports, school communication and AI assisted academic work.",
};

const features = [
  [BookOpen, "School Administration", "Keep your school organised from one place", "Give your school a structured way to manage essential information about students, teachers, staff and families. Keep important records organised and make information easier for authorised users to access when needed."],
  [CalendarDays, "Academic Calendar and School Setup", "Build your academic year around your school", "Set up your academic sessions, terms or semesters, holidays, assessment periods and other important school dates. Organise classes, subjects and grading rules to reflect the way your institution operates."],
  [MonitorPlay, "Computer Based Tests", "Bring assessments into a digital learning environment", "Support online assessments through a computer based testing system designed for school examinations and practice tests. Where enabled, teachers can prepare questions, manage assessment attempts and review objective answers more efficiently."],
  [ClipboardList, "Results and Report Cards", "Make academic reporting clearer and more organised", "Help teachers prepare assessment records and academic results for review. Establish grading rules, check scores and support the preparation of student report cards for authorised approval and publication."],
  [FileText, "Student Progress Reports", "See more than examination scores", "Academic progress includes classroom performance, participation and observations from teachers. SatGold Cloud is designed to bring relevant academic information and teacher feedback together to support a clearer understanding of each student's progress."],
  [UsersRound, "Teacher and Staff Workspace", "Give educators a more organised way to work", "Support teachers with a structured workspace for academic responsibilities, assessments and reporting. Help school administrators coordinate staff activities and keep important academic tasks connected."],
  [UsersRound, "Parent and Student Access", "Keep families connected to school life", "Provide a dedicated digital experience for students and parents, with access determined by the features available and the permissions assigned to each account. The aim is to make relevant school information easier to access and understand."],
  [BrainCircuit, "AI Assisted Academic Support", "Make everyday academic work more manageable", "AI assistance can help educators with selected academic tasks, such as preparing lesson ideas, organising teaching resources and developing first drafts. Teachers remain responsible for reviewing and adapting all AI generated material before using it."],
  [Bell, "School Communication", "Share important information with the right audience", "Help school administrators communicate notices and updates to the relevant groups within the school community. Appropriate access controls should determine which announcements are visible to staff, parents and students."],
  [ShieldCheck, "Privacy and Access Control", "Give every user an appropriate level of access", "Different school roles require different permissions. SatGold Cloud is being designed around role based access and separation between school workspaces. These protections must be properly configured and verified before real school records are uploaded."],
] as const;

export default function FeaturesPage() {
  return <main className="features-page">
    <header className="nav"><Link href="/" className="brand"><span className="brand-icon"><GraduationCap size={22}/></span><span>satgold<span className="brand-light">cloud</span></span></Link><nav><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/how-it-works">How it works</Link><Link href="/portal">School portal</Link><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link><Link href="/faq">FAQs</Link></nav><div className="nav-actions"><Link className="signin" href="/login">Log in</Link><Link className="button button-dark button-small" href="/register">Register Your School <ArrowRight size={16}/></Link></div><details className="mobile-menu"><summary><Menu/></summary><div><Link href="/how-it-works">How it works</Link><Link href="/portal">School portal</Link><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link><Link href="/faq">FAQs</Link><Link href="/login">Log in</Link><Link href="/register">Register Your School</Link></div></details></header>
    <section className="feature-page-hero"><div className="content-kicker">SATGOLD CLOUD FEATURES</div><h1>Everything Your School Needs to Work Better</h1><p className="feature-page-subtitle">One connected platform for school management and academic progress</p></section>
    <section className="feature-page-intro"><p>Running a school involves much more than teaching lessons. It means keeping accurate records, supporting teachers, communicating with families, managing assessments and making sure every academic term runs smoothly.</p><p>SatGold Cloud is designed to bring these responsibilities together in one organised digital environment. Our goal is to help school owners, administrators, teachers, students and parents spend less time dealing with disconnected processes and more time focusing on education.</p></section>
    <section className="feature-page-grid" aria-label="School management features">{features.map(([Icon,title,subtitle,description],index)=><article className="feature-page-card" key={title}><span className="feature-page-icon"><Icon size={21}/></span><span className="feature-page-index">{String(index+1).padStart(2,"0")}</span><h2>{title}</h2><h3>{subtitle}</h3><p>{description}</p></article>)}</section>
    <section className="feature-page-cta"><div className="content-kicker">GET STARTED</div><h2>A better organised school starts here</h2><p>Give your school a clearer path towards digital administration and connected academic processes.</p><p>Register your school to learn more about SatGold Cloud and its available features.</p><Link href="/register" className="button button-dark">Register Your School <ArrowRight size={16}/></Link></section>
    <SiteFooter/>
  </main>;
}
