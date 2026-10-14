import Link from "next/link";
import { GraduationCap, Sparkles } from "lucide-react";
import "./site-footer.css";

export default function SiteFooter() {
  return <footer className="site-footer">
    <div className="site-footer-main">
      <div className="site-footer-brand">
        <Link href="/" className="brand"><span className="brand-icon"><GraduationCap size={22}/></span><span>satgold<span className="brand-light">cloud</span></span></Link>
        <p>One cloud for the people who make schools matter.</p>
        <span className="site-footer-tag"><Sparkles size={14}/> AI powered school management</span>
      </div>
      <div><b>Platform</b><Link href="/#features">Features</Link><Link href="/#how">How it works</Link><Link href="/portal">School portal</Link><Link href="/school/dashboard">Owner workspace</Link></div>
      <div><b>Get started</b><Link href="/login">Log in</Link><Link href="/register">Register your school</Link><Link href="/#pricing">Pricing</Link></div>
      <div><b>Help &amp; support</b><a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a><a href="tel:09138836682">09138836682</a><a href="tel:07081495536">07081495536</a></div>
      <div><b>Legal</b><Link href="/privacy">Privacy policy</Link><Link href="/terms">Terms of service</Link><Link href="/terms#acceptable-use">Acceptable use</Link><Link href="/terms#billing">Billing terms</Link></div>
    </div>
    <div className="site-footer-bottom"><span>© {new Date().getFullYear()} SatGold Cloud. Made for better school days.</span><span>Nigeria · Built for every classroom</span></div>
  </footer>;
}
