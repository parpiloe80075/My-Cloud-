import Link from "next/link";
import { ArrowRight, GraduationCap, LockKeyhole, UserPlus } from "lucide-react";
import SiteFooter from "@/components/site-footer";
import "./portal.css";

export default function SchoolPortal() {
  return <main className="portal-page">
    <header className="portal-nav"><Link href="/" className="brand"><span className="brand-icon"><GraduationCap size={22}/></span><span>satgold<span className="brand-light">cloud</span></span></Link><Link href="/" className="portal-back">Back to home</Link></header>
    <section className="portal-hero"><div className="portal-copy"><span className="eyebrow">YOUR SCHOOL, ONE CONNECTED SPACE</span><h1>A calmer way to run your <em>school day.</em></h1><p>Sign in to your school workspace or create a secure account for your school. Your academic setup and school details stay connected from the start.</p><div className="portal-actions"><Link href="/login" className="button button-dark"><LockKeyhole size={17}/> School log in <ArrowRight size={16}/></Link><Link href="/register" className="button portal-register"><UserPlus size={17}/> Register your school</Link></div><div className="portal-note">Secure owner access · School setup · Academic workspace</div></div><div className="portal-photo" role="img" aria-label="Teacher and students learning together in a classroom"><span>Built around better school days</span></div></section>
    <section className="portal-choices"><article><span className="portal-number">01</span><h2>Already have a school account?</h2><p>Continue to your owner workspace using the email and password you registered with.</p><Link href="/login">Go to school login <ArrowRight size={15}/></Link></article><article><span className="portal-number">02</span><h2>Setting up your school?</h2><p>Create the owner account, add your school details and begin your academic setup.</p><Link href="/register">Start school registration <ArrowRight size={15}/></Link></article></section>
    <div className="portal-help">Need a hand getting started? <a href="mailto:support.satgoldcloud@gmail.com">Contact school support</a></div>
    <SiteFooter/>
  </main>;
}
