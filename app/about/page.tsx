import type { Metadata } from "next";
import Link from "next/link";
import { ArrowRight, GraduationCap, Menu, UsersRound, Lightbulb, ShieldCheck, Sparkles } from "lucide-react";
import "../site.css";
import "./about.css";
import SiteFooter from "@/components/site-footer";

export const metadata: Metadata = {
  title: "About SatGold Cloud | Digital School Management",
  description: "Learn about SatGold Cloud, a school management platform being developed to connect school owners, teachers, students and parents through organised digital workflows.",
};

const principles = [
  [Lightbulb, "Our Purpose", <>Our purpose is to make digital school management more approachable by bringing school administration and academic processes into a connected environment.<br/><br/>We want school owners to have a clearer view of their operations, teachers to have better organised academic workflows, students to access relevant learning information and parents to stay connected with their children's school experience.</>],
  [UsersRound, "Our Approach", <>We believe useful school technology should be clear, practical and built around the needs of the people who use it.<br/><br/>That means supporting different school roles, allowing academic structures to reflect the needs of individual institutions and treating student information with care.<br/><br/>We also believe technology should support human judgement rather than replace the educators and school leaders responsible for important decisions.</>],
] as const;

export default function AboutPage() {
  return <main className="about-page">
    <header className="nav"><Link href="/" className="brand"><span className="wordmark">satgold<span className="brand-light">cloud</span></span></Link><nav><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/how-it-works">How it works</Link><Link href="/portal">School portal</Link><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link></nav><div className="nav-actions"><Link className="signin" href="/login">Log in</Link><Link className="button button-dark button-small" href="/register">Register Your School <ArrowRight size={16}/></Link></div><details className="mobile-menu"><summary><Menu/></summary><div><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/how-it-works">How it works</Link><Link href="/portal">School portal</Link><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link><Link href="/login">Log in</Link></div></details></header>

    <section className="about-hero"><div className="content-kicker">ABOUT SATGOLD CLOUD</div><h1>About SatGold Cloud</h1><p>Technology should make school life easier</p><div className="about-hero-mark"><GraduationCap size={52}/></div></section>
    <section className="about-intro"><p>Schools play an important role in shaping the future. Behind every lesson, examination and report card are people working to help students learn and grow.</p><p>Yet school administration can involve repeated paperwork, scattered records and time consuming coordination. These challenges can take attention away from the work that matters most.</p><p>SatGold Cloud is being developed to help schools move towards a more connected and organised way of working.</p></section>
    <section className="about-principles">{principles.map(([Icon,title,body])=><article key={title}><span className="about-icon"><Icon size={22}/></span><h2>{title}</h2><div>{body}</div></article>)}</section>
    <section className="about-future"><span className="about-icon"><ShieldCheck size={22}/></span><div><div className="content-kicker">BUILDING FOR THE FUTURE OF EDUCATION</div><h2>Building for the Future of Education</h2><p>SatGold Cloud is being developed with a focus on school administration, academic organisation, reporting, communication and AI assisted academic support.</p><p>Features are being introduced and refined over time. We aim to communicate clearly about what is available and what remains under development.</p></div></section>
    <section className="about-cta"><span className="about-icon"><Sparkles size={22}/></span><div className="content-kicker">A MORE CONNECTED FUTURE FOR SCHOOLS</div><h2>A More Connected Future for Schools</h2><p>We invite school owners, administrators and educators to explore SatGold Cloud, share their needs and follow the development of a more organised digital school experience.</p><Link href="/features" className="button button-dark">Explore SatGold Cloud <ArrowRight size={16}/></Link></section>
    <SiteFooter/>
  </main>;
}
