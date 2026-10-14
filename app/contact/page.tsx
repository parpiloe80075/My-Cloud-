import type { Metadata } from "next";
import Link from "next/link";
import { ArrowRight, GraduationCap, Mail, Menu, Phone } from "lucide-react";
import "../site.css";
import "./contact.css";
import SiteFooter from "@/components/site-footer";
import ContactForm from "./contact-form";

export const metadata: Metadata = {
  title: "Contact SatGold Cloud | School Software Support Nigeria",
  description: "Contact SatGold Cloud for school management software enquiries, registration assistance, subscription questions and information about available services.",
};

export default function ContactPage() {
  return <main className="contact-page">
    <header className="nav"><Link href="/" className="brand"><span className="brand-icon"><GraduationCap size={22}/></span><span>satgold<span className="brand-light">cloud</span></span></Link><nav><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/how-it-works">How it works</Link><Link href="/portal">School portal</Link><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link></nav><div className="nav-actions"><Link className="signin" href="/login">Log in</Link><Link className="button button-dark button-small" href="/register">Register Your School <ArrowRight size={16}/></Link></div><details className="mobile-menu"><summary><Menu/></summary><div><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/how-it-works">How it works</Link><Link href="/portal">School portal</Link><Link href="/pricing">Pricing</Link><Link href="/login">Log in</Link><Link href="/register">Register Your School</Link></div></details></header>

    <section className="contact-hero"><div className="content-kicker">CONTACT SATGOLD CLOUD</div><h1>We Are Here to Help</h1><p>Let's talk about your school's needs</p></section>
    <section className="contact-intro"><p>Choosing a school management platform is an important decision. Whether you are exploring SatGold Cloud for the first time, need help with registration or want to discuss a custom requirement, our team welcomes your enquiry.</p><p>Tell us a little about your school and what you would like to achieve. We will help you understand the available options and the next steps.</p></section>
    <section className="contact-layout"><aside className="contact-info"><div className="content-kicker">CONTACT INFORMATION</div><h2>How Can We Help You?</h2><p>Contact us about school registration, account access, available features, subscription information, technical enquiries or custom service requests.</p><p>For faster assistance, include your school name, the best way to reach you and a short explanation of your enquiry. Please do not send passwords or sensitive student information through the contact form.</p><div className="contact-method"><span><Mail size={19}/></span><div><b>Email</b><a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a></div></div><div className="contact-method"><span><Phone size={19}/></span><div><b>Phone</b><a href="tel:09138836682">09138836682</a><a href="tel:07081495536">07081495536</a></div></div></aside><section className="contact-form-card"><div className="content-kicker">SEND US A MESSAGE</div><ContactForm/></section></section>
    <section className="contact-bottom"><h2>Your School. Your Goals. A Better Way Forward.</h2><p>We look forward to learning about your school and helping you understand whether SatGold Cloud is the right fit for your needs.</p></section>
    <SiteFooter/>
  </main>;
}
