import type { Metadata } from "next";
import Link from "next/link";
import { ArrowRight, GraduationCap, Menu, Check } from "lucide-react";
import "../site.css";
import "./pricing.css";
import SiteFooter from "@/components/site-footer";

export const metadata: Metadata = {
  title: "SatGold Cloud Pricing | Affordable School Management Software",
  description: "Explore SatGold Cloud school management software pricing for Nigerian schools. Compare school subscription options, review the two month trial and contact us about custom requirements.",
};

const plans = [
  { name: "Starter Plan", price: "â‚¦23,000 per term", description: "An entry level subscription option for schools looking for an organised starting point for digital school management.", review: "Review the features included in this plan before subscribing to make sure they meet your school's needs.", action: "Choose Starter" },
  { name: "School Plan", price: "â‚¦50,000 per term", description: "An expanded subscription option for schools that need a broader set of school management capabilities.", review: "Review the published plan details to understand the included features, user allowances and any usage limits before subscribing.", action: "Explore This Plan" },
];

const faqs = [
  ["Is there a free trial?", "Eligible newly registered schools can receive a two month trial. Check the terms displayed during registration for eligibility and conditions."],
  ["Are the prices charged per month?", "The listed Starter and School Plan prices are per academic term, not per month."],
  ["Can I request a custom solution?", "Yes. Contact our team to discuss your requirements and confirm which custom services are available."],
  ["Are all advertised features available immediately?", "Feature availability depends on the current state of the platform and the selected plan. Confirm the current feature list before making a subscription decision."],
  ["How can I get help choosing a plan?", <>Email <a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a> or call <a href="tel:09138836682">09138836682</a> or <a href="tel:07081495536">07081495536</a>.</>],
] as const;

export default function PricingPage() {
  return <main className="pricing-page">
    <header className="nav"><Link href="/" className="brand"><span className="brand-icon"><GraduationCap size={22}/></span><span>satgold<span className="brand-light">cloud</span></span></Link><nav><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/how-it-works">How it works</Link><Link href="/portal">School portal</Link><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link><Link href="/faq">FAQs</Link></nav><div className="nav-actions"><Link className="signin" href="/login">Log in</Link><Link className="button button-dark button-small" href="/register">Register Your School <ArrowRight size={16}/></Link></div><details className="mobile-menu"><summary><Menu/></summary><div><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/how-it-works">How it works</Link><Link href="/portal">School portal</Link><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link><Link href="/login">Log in</Link><Link href="/register">Register Your School</Link></div></details></header>

    <section className="pricing-page-hero"><div className="content-kicker">SATGOLD CLOUD PRICING</div><h1>Simple Pricing for Better School Management</h1><p>Choose a plan that fits your school</p></section>
    <section className="pricing-page-intro"><p>Every school deserves the opportunity to organise its administration and improve the way it works. SatGold Cloud offers subscription options designed to help schools explore digital school management and choose a plan that suits their requirements.</p><p>Newly registered eligible schools can receive a two month trial. Please review the registration terms to confirm eligibility and the features available during your trial.</p></section>
    <section className="pricing-plan-grid" aria-label="Subscription plans">{plans.map((plan,index)=><article className={`pricing-plan ${index===0?"pricing-plan-primary":""}`} key={plan.name}><span className="pricing-plan-index">0{index+1}</span><h2>{plan.name}</h2><h3>{plan.price}</h3><p>{plan.description}</p><p>{plan.review}</p><Link className={index===0?"button button-dark":"button pricing-outline"} href="/register">{plan.action} <ArrowRight size={16}/></Link></article>)}<article className="pricing-plan pricing-custom"><span className="pricing-plan-index">03</span><h2>Custom Plan</h2><h3>Let's discuss your requirements</h3><p>Some schools need additional configuration or a more tailored digital presence. Contact the SatGold Cloud team to discuss your requirements, including school website options, custom domain needs and other supported custom services.</p><p>Custom services, pricing and delivery timelines are subject to confirmation.</p><a className="button pricing-outline" href="/contact">Contact Our Team <ArrowRight size={16}/></a></article></section>

    <section className="pricing-consider"><div className="pricing-consider-icon"><Check size={20}/></div><div><div className="content-kicker">CHOOSE WITH CONFIDENCE</div><h2>What Should You Consider Before Choosing?</h2><p>Consider the number of students and staff in your school, the academic processes you need to manage, the features currently available and any additional requirements your institution may have.</p><p>Our goal is to help you choose an option based on your school's actual needs.</p></div></section>

    <section className="pricing-faq"><div className="content-kicker">FREQUENTLY ASKED PRICING QUESTIONS</div><h2>Plan and Trial Details</h2><div className="pricing-faq-list">{faqs.map(([question,answer])=><details key={question}><summary>{question}<span>+</span></summary><p>{answer}</p></details>)}</div></section>

    <section className="pricing-page-cta"><h2>Take the next step</h2><p>Find the subscription option that suits your school and review the details before registering.</p><p>Start your school registration today.</p><Link href="/register" className="button button-dark">Register Your School <ArrowRight size={16}/></Link></section>
    <SiteFooter/>
  </main>;
}
