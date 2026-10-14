import Link from "next/link";
import { GraduationCap, Sparkles } from "lucide-react";
import "./site-footer.css";

export default function SiteFooter() {
  return <footer className="site-footer">
    <div className="site-footer-main">
      <div className="site-footer-brand">
        <Link href="/" className="brand"><span className="wordmark">satgold<span className="brand-light">cloud</span></span></Link>
        <p>AI powered school management software designed to connect school owners, administrators, teachers, students and parents through one organised digital platform.</p>
        <span className="site-footer-tag"><Sparkles size={14}/> AI powered school management</span>
      </div>
      <div><b>Platform</b><Link href="/features">School Management</Link><Link href="/owner-workspace">Owner Workspace</Link><Link href="/#portals">Teacher Portal</Link><Link href="/#portals">Student Portal</Link><Link href="/#portals">Parent Portal</Link><Link href="/features">CBT Examinations</Link><Link href="/features">Results and Report Cards</Link><Link href="/features">AI Assisted Tools</Link></div>
      <div><b>Company</b><Link href="/about">About SatGold Cloud</Link><Link href="/features">Features</Link><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link><Link href="/faq">Frequently Asked Questions</Link></div>
      <div><b>Support</b><a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a><a href="tel:09138836682">09138836682</a><a href="tel:07081495536">07081495536</a></div>
      <div><b>Legal</b><Link href="/privacy">Privacy Policy</Link><Link href="/cookies">Cookie Policy</Link><Link href="/school-data-responsibilities">School Data Processing and Responsibilities</Link><Link href="/terms">Terms of Service</Link><Link href="/acceptable-use">Acceptable Use Policy</Link><Link href="/subscription-policy">Subscription, Billing and Refund Policy</Link><Link href="/privacy">Data Protection</Link></div>
    </div>
    <div className="site-footer-bottom"><span>Copyright 2026 SatGold Cloud. All rights reserved.</span></div>
  </footer>;
}
