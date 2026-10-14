import type { Metadata } from "next";
import Link from "next/link";
import { ArrowRight, CalendarDays, GraduationCap, Menu, UsersRound, ClipboardList } from "lucide-react";
import "../site.css";
import "./how-it-works.css";
import SiteFooter from "@/components/site-footer";

export const metadata: Metadata = {
  title: "How SatGold Cloud Works | School Management Setup",
  description: "Learn how SatGold Cloud is designed to help schools organise academic calendars, configure school records, onboard users and manage academic activities.",
};

const steps = [
  ["01", GraduationCap, "Step 1. Register Your School", "Begin with your school's identity", "Create your school registration and provide the requested information, including your school name and contact details. This information establishes the foundation for your school's workspace."],
  ["02", CalendarDays, "Step 2. Configure Your Academic Calendar", "Set up the school year to match your schedule", "Choose the academic session and organise your terms or semesters, breaks, assessment periods and important dates. Configure the academic structure and grading rules appropriate for your school."],
  ["03", UsersRound, "Step 3. Organise Your School Community", "Bring authorised users into the system", "Prepare the records for your administrators, teachers, students and parents. Assign the appropriate roles and connect parent accounts with the relevant students according to the available account management features."],
  ["04", ClipboardList, "Step 4. Prepare for Academic Activities", "Connect school administration with teaching and learning", "Once the required features are configured and available, authorised users can work with academic records, assessments, results and school communications according to their assigned permissions."],
] as const;

export default function HowItWorksPage() {
  return <main className="how-page">
    <header className="nav"><Link href="/" className="brand"><span className="brand-icon"><GraduationCap size={22}/></span><span>satgold<span className="brand-light">cloud</span></span></Link><nav><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/how-it-works">How it works</Link><Link href="/portal">School portal</Link><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link><Link href="/faq">FAQs</Link></nav><div className="nav-actions"><Link className="signin" href="/login">Log in</Link><Link className="button button-dark button-small" href="/register">Register Your School <ArrowRight size={16}/></Link></div><details className="mobile-menu"><summary><Menu/></summary><div><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/portal">School portal</Link><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link><Link href="/faq">FAQs</Link><Link href="/login">Log in</Link><Link href="/register">Register Your School</Link></div></details></header>

    <section className="how-page-hero"><div className="content-kicker">HOW IT WORKS</div><h1>Getting Started With SatGold Cloud</h1><p>A clearer path to digital school management</p></section>
    <section className="how-page-intro"><p>Every school has its own structure, academic calendar and way of working. SatGold Cloud is designed to help schools organise these details in a structured workspace, making it easier to move from separate manual processes towards connected digital administration.</p></section>
    <section className="how-page-steps">{steps.map(([number,Icon,title,subtitle,body])=><article className="how-page-step" key={number}><div className="how-step-icon"><Icon size={22}/></div><div className="how-step-copy"><span>{number}</span><h2>{title}</h2><h3>{subtitle}</h3><p>{body}</p></div></article>)}</section>
    <section className="how-page-support"><article><div className="content-kicker">A WORKSPACE FOR EVERY ROLE</div><h2>A Workspace for Every Role</h2><p>School owners need oversight. Teachers need tools for academic work. Students need access to their learning information. Parents need a convenient way to stay informed.</p><p>SatGold Cloud is designed to support these different responsibilities through role based workspaces rather than expecting everyone to use the same dashboard.</p></article><article><div className="content-kicker">BUILT AROUND YOUR SCHOOL</div><h2>Built Around the Way Schools Operate</h2><p>From the start of a new academic session to the preparation of termly results, school processes work better when information is organised and responsibilities are clear.</p><p>SatGold Cloud aims to support that organisation while allowing each school to configure its academic structure around its needs.</p></article></section>
    <section className="how-page-cta"><h2>Ready to take the next step?</h2><p>Start your school registration and explore the available setup options. Eligible new schools can explore the platform through the advertised two month trial, subject to the terms shown during registration.</p><Link href="/register" className="button button-dark">Register Your School <ArrowRight size={16}/></Link></section>
    <SiteFooter/>
  </main>;
}
