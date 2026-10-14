import type { Metadata } from "next";
import Link from "next/link";
import { ArrowRight, BookOpen, GraduationCap, Menu, MessageSquareText, ShieldCheck, UsersRound, ClipboardCheck } from "lucide-react";
import "../site.css";
import "./owner-workspace.css";
import SiteFooter from "@/components/site-footer";

export const metadata: Metadata = {
  title: "School Owner Dashboard | SatGold Cloud School Management",
  description: "Learn how the SatGold Cloud school owner workspace is designed to help school leaders organise academic settings, oversee users and coordinate school operations.",
};

const responsibilities = [
  [BookOpen, "Organise Your Academic Structure", "Prepare the academic session, terms or semesters, classes, subjects and grading rules that reflect your school's requirements."],
  [UsersRound, "Manage Your School Community", "Organise authorised staff and student accounts and coordinate the information needed to connect families with the school."],
  [ClipboardCheck, "Support Academic Oversight", "Help establish a structured process for assessments, results and report preparation. Academic records should be reviewed and approved by authorised school personnel before they are published."],
  [MessageSquareText, "Coordinate School Communication", "Prepare school notices and updates for the appropriate audience, based on the communication features enabled for your workspace."],
  [ShieldCheck, "Keep Responsibilities Clear", "Role based access helps establish which actions different users are allowed to perform. Proper configuration and testing are essential before a school begins managing real student information."],
] as const;

export default function OwnerWorkspacePage() {
  return <main className="owner-page">
    <header className="nav"><Link href="/" className="brand"><span className="wordmark">satgold<span className="brand-light">cloud</span></span></Link><nav><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/how-it-works">How it works</Link><Link href="/portal">School portal</Link><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link></nav><div className="nav-actions"><Link className="signin" href="/login">Log in</Link><Link className="button button-dark button-small" href="/register">Register Your School <ArrowRight size={16}/></Link></div><details className="mobile-menu"><summary><Menu/></summary><div><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/how-it-works">How it works</Link><Link href="/portal">School portal</Link><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link><Link href="/login">Log in</Link></div></details></header>
    <section className="owner-hero"><div className="content-kicker">SCHOOL OWNER WORKSPACE</div><h1>A Clearer View of Your School</h1><p>School management begins with better organisation</p><div className="owner-hero-mark"><GraduationCap size={54}/></div></section>
    <section className="owner-intro"><p>School owners and proprietors are responsible for more than the day to day running of a school. They need to establish academic structures, coordinate staff, maintain oversight and ensure that important processes are handled responsibly.</p><p>The SatGold Cloud owner workspace is designed to bring supported school management responsibilities together in one place.</p></section>
    <section className="owner-responsibilities">{responsibilities.map(([Icon,title,description],index)=><article className="owner-card" key={title}><div className="owner-card-icon"><Icon size={21}/></div><span>0{index+1}</span><h2>{title}</h2><p>{description}</p></article>)}</section>
    <section className="owner-summary"><div className="content-kicker">DESIGNED TO SUPPORT SCHOOL LEADERSHIP</div><h2>Designed to Support School Leadership</h2><p>SatGold Cloud aims to help school leaders bring important processes together, reduce unnecessary administrative repetition and create a more organised foundation for academic management.</p><div className="owner-actions"><Link href="/register" className="button button-dark">Register Your School <ArrowRight size={16}/></Link><Link href="/pricing" className="button owner-outline">View Pricing <ArrowRight size={16}/></Link></div></section>
    <SiteFooter/>
  </main>;
}
