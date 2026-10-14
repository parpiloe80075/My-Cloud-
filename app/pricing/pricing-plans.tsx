"use client";

import { useState } from "react";
import Link from "next/link";
import { ArrowRight } from "lucide-react";

const plans = [
  { name: "Starter Plan", termPrice: 23000, description: "An entry level subscription option for schools looking for an organised starting point for digital school management.", review: "Review the features included in this plan before subscribing to make sure they meet your school's needs.", action: "Choose Starter" },
  { name: "School Plan", termPrice: 50000, description: "An expanded subscription option for schools that need a broader set of school management capabilities.", review: "Review the published plan details to understand the included features, user allowances and any usage limits before subscribing.", action: "Explore This Plan" },
];
const naira = new Intl.NumberFormat("en-NG", { maximumFractionDigits: 0 });

export default function PricingPlans() {
  const [period, setPeriod] = useState<"term" | "session">("term");
  const multiplier = period === "session" ? 3 : 1;
  return <>
    <div className="pricing-period" role="group" aria-label="Choose pricing period">
      <button type="button" aria-pressed={period === "term"} className={period === "term" ? "active" : ""} onClick={() => setPeriod("term")}>Per term</button>
      <button type="button" aria-pressed={period === "session"} className={period === "session" ? "active" : ""} onClick={() => setPeriod("session")}>Per session</button>
    </div>
    <p className="pricing-period-note">Session pricing is calculated as three academic terms.</p>
    <section className="pricing-plan-grid" aria-label="Subscription plans">
      {plans.map((plan, index) => <article className={`pricing-plan ${index === 0 ? "pricing-plan-primary" : ""}`} key={plan.name}>
        <span className="pricing-plan-index">0{index + 1}</span><h2>{plan.name}</h2>
        <h3>NGN {naira.format(plan.termPrice * multiplier)} <small>per {period}</small></h3>
        <p>{plan.description}</p><p>{plan.review}</p>
        <Link className={index === 0 ? "button button-dark" : "button pricing-outline"} href="/register">{plan.action} <ArrowRight size={16}/></Link>
      </article>)}
      <article className="pricing-plan pricing-custom"><span className="pricing-plan-index">03</span><h2>Custom Plan</h2><h3>Let's discuss your requirements</h3><p>Some schools need additional configuration or a more tailored digital presence. Contact the SatGold Cloud team to discuss your requirements, including school website options, custom domain needs and other supported custom services.</p><p>Custom services, pricing and delivery timelines are subject to confirmation.</p><Link className="button pricing-outline" href="/contact">Contact Our Team <ArrowRight size={16}/></Link></article>
    </section>
  </>;
}
