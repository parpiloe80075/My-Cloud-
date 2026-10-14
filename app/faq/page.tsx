import type { Metadata } from "next";
import Link from "next/link";
import { ArrowRight, GraduationCap, Menu } from "lucide-react";
import "../site.css";
import "./faq.css";
import SiteFooter from "@/components/site-footer";

export const metadata: Metadata = {
  title: "Frequently Asked Questions | SatGold Cloud",
  description: "Find answers about SatGold Cloud registration, school setup, subscriptions, account access, platform features and support for Nigerian schools.",
};

const questions = [
  ["What is SatGold Cloud?", "SatGold Cloud is a school management platform being developed to connect school owners, teachers, students, staff and parents through organised digital school workflows."],
  ["Who can use SatGold Cloud?", "The platform is intended for schools and their authorised communities, including school owners, administrators, teachers, students and parents. Access depends on the accounts and features available."],
  ["How do I register my school?", "Visit the school registration page and follow the instructions provided. Enter accurate information and review the trial and subscription terms before completing registration."],
  ["Is there a free trial?", "Eligible newly registered schools can receive a two month trial. Confirm the eligibility requirements and trial conditions shown during registration."],
  ["How much does SatGold Cloud cost?", "The listed subscription options are NGN 23,000 per term for the Starter Plan and NGN 50,000 per term for the second listed plan. Custom requirements can be discussed with the support team. Check the pricing page for the latest confirmed details."],
  ["Does SatGold Cloud support different user roles?", "The platform is designed around role based workspaces for school owners, administrators, teachers, students and parents. The available actions depend on the role and the features currently enabled."],
  ["Can teachers manage assessments and results?", "Assessment and result management are part of the platform's intended capabilities. Check the current feature availability before relying on these workflows for a live academic session."],
  ["Does SatGold Cloud use artificial intelligence?", "AI assisted academic support is part of the platform's planned direction. Availability depends on whether the relevant integration has been configured and enabled. AI generated material should be reviewed by a qualified educator before use."],
  ["Can parents access school information?", "Parent access is part of the intended platform experience. The information a parent can see depends on the enabled features, account configuration and permissions."],
  ["How do I get help with my account?", <>Email <a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a> or call <a href="tel:09138836682">09138836682</a> or <a href="tel:07081495536">07081495536</a>. Do not send your password to support.</>],
  ["Is it safe to upload real student records?", "Only use the production service after the school has confirmed that the necessary security controls, access permissions, data handling arrangements and applicable agreements are in place. Do not upload sensitive student records to a development environment."],
  ["Where can I find the latest subscription information?", <>Visit the <Link href="/pricing">pricing page</Link> and review the subscription terms shown during registration. Confirm the current plan features and payment conditions before making a payment.</>],
] as const;

export default function FAQPage() {
  return <main className="faq-page">
    <header className="nav"><Link href="/" className="brand"><span className="wordmark">satgold<span className="brand-light">cloud</span></span></Link><nav><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/how-it-works">How it works</Link><Link href="/portal">School portal</Link><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link></nav><div className="nav-actions"><Link className="signin" href="/login">Log in</Link><Link className="button button-dark button-small" href="/register">Register Your School <ArrowRight size={16}/></Link></div><details className="mobile-menu"><summary><Menu/></summary><div><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/how-it-works">How it works</Link><Link href="/portal">School portal</Link><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link><Link href="/login">Log in</Link></div></details></header>
    <section className="faq-page-hero"><div className="content-kicker">HELP AND INFORMATION</div><h1>Frequently Asked Questions</h1></section>
    <section className="faq-page-content"><div className="faq-page-list">{questions.map(([question,answer])=><details key={question}><summary>{question}<span>+</span></summary><div className="faq-page-answer"><p>{answer}</p></div></details>)}</div></section>
    <SiteFooter/>
  </main>;
}
