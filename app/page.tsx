import Link from "next/link";
import "./site.css";
import "./home-overrides.css";
import SiteFooter from "@/components/site-footer";
import { ArrowRight, BrainCircuit, BookOpen, Bell, ClipboardList, FileText, GraduationCap, Menu, MonitorPlay, UsersRound, Settings, } from "lucide-react";

const features = [
  [Settings, "School Administration and Control", "Set up school information, academic sessions and user access from a central workspace."],
  [UsersRound, "Student and Staff Management", "Keep student, staff, class and family records organised and up to date."],
  [MonitorPlay, "Online CBT Examinations", "Prepare class assessments, manage attempts and review submissions in one place."],
  [ClipboardList, "Student Results and Report Cards", "Record assessment scores, review results and prepare reports for approval."],
  [UsersRound, "Parent and Student Portals", "Give families and students access to relevant published school information."],
  [BrainCircuit, "AI Powered School Assistance", "Use configured AI tools to draft questions, lesson materials and school communications."],
  [FileText, "Weekly Student Reports", "Record student progress and share approved teacher observations with families."],
  [Bell, "School Notifications and Communication", "Send school updates and important dates to the appropriate groups."],
] as const;

const steps = [
  ["01", "Register Your School", "Create your school workspace and enter its basic details."],
  ["02", "Configure Academics", "Set up sessions, terms, classes, subjects and grading."],
  ["03", "Invite Your Community", "Add authorised staff, students and parent accounts."],
  ["04", "Manage School Activities", "Use your role based workspace to coordinate daily work."],
] as const;

const portals = [
  ["School Owners and Administrators", "Manage school settings, users, academic activity and reporting."],
  ["Teachers", "Work with assigned classes, assessments and student progress."],
  ["Students", "View assigned learning tools, published results and feedback."],
  ["Parents", "Follow linked students' published results, reports and notices."],
  ["Non Teaching Staff", "Access the administrative tasks assigned by school leadership."],
] as const;

const benefits = [
  ["Centralised School Management", "Keep essential operations together in one workspace."],
  ["Clearer Academic Oversight", "Review assessment and reporting progress."],
  ["Better Organised Records", "Maintain school records for authorised users."],
  ["More Efficient Communication", "Share updates with the right school groups."],
  ["Flexible Academic Configuration", "Set up your school's sessions and grading rules."],
  ["Access From Different Devices", "Use the web platform on computers, tablets and phones."],
] as const;

const plans = [
  ["Starter Package", "NGN 23,000 per term", "A practical starting point for schools looking to manage their essential administrative and academic activities through one connected platform."],
  ["Professional Package", "NGN 50,000 per term", "An expanded package for schools that require additional capabilities and higher configured usage limits."],
  ["Custom Package", "Talk to our team", "Contact our support team for a package tailored to your school's specific requirements, including eligible website, branding and custom domain options."],
] as const;

const faqs = [
  ["What is SatGold Cloud?", "A school management platform for administration, academics, reporting and school communication."],
  ["Who can use SatGold Cloud?", "School owners, administrators, teachers, staff, students and parents with authorised accounts."],
  ["Can I manage my school online?", "Yes. SatGold Cloud is designed as a web based platform that allows authorised users to access supported school management features through compatible devices with an internet connection."],
  ["Can teachers create online examinations?", "Teachers can prepare assessments for assigned classes where the feature is enabled."],
  ["Can parents view their children's results?", "Parents can see published records linked to their accounts."],
  ["Can my school customise its grading system?", "SatGold Cloud supports configurable assessment categories and grading rules so schools can organise calculations according to their academic structure and requirements."],
  ["Does SatGold Cloud provide AI assistance?", "Yes. The platform includes AI assisted functionality designed to support selected teaching and administrative tasks. Available capabilities depend on the configured features and applicable subscription limits."],
  ["How much does SatGold Cloud cost?", "The published Starter package costs NGN 23,000 per term, while the Professional package costs NGN 50,000 per term. A Custom package is available for schools that need tailored arrangements. Eligible new schools can also access a two month free trial."],
  ["How do I register my school?", "Visit the registration page, provide your school information, complete the required setup steps and configure your academic environment to get started."],
] as const;

export default function Home() {
  return <main>
    <header className="nav"><Link href="/" className="brand"><span className="wordmark">satgold<span className="brand-light">cloud</span></span></Link><nav><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/how-it-works">How it works</Link><a href="#portals">Portals</a><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link><Link href="/faq">FAQs</Link></nav><div className="nav-actions"><Link className="signin" href="/login">Log in</Link><Link className="button button-dark button-small" href="/register">Register Your School <ArrowRight size={16}/></Link></div><details className="mobile-menu"><summary><Menu/></summary><div><Link href="/features">Features</Link><Link href="/about">About Us</Link><Link href="/how-it-works">How it works</Link><a href="#portals">Portals</a><Link href="/pricing">Pricing</Link><Link href="/contact">Contact</Link><Link href="/faq">FAQs</Link><Link href="/login">Log in</Link><Link href="/register">Register Your School</Link></div></details></header>

    <section className="hero"><div className="hero-copy"><div className="eyebrow"><span className="eyebrow-dot"/> SCHOOL MANAGEMENT SOFTWARE IN NIGERIA</div><h1>Manage Your School<br/>Smarter With SatGold Cloud</h1><p>Organise school records, academic work and communication in one place. SatGold Cloud connects school leaders, teachers, students and families through role based tools.</p><div className="hero-ctas"><Link href="/register" className="button button-dark">Register Your School <ArrowRight size={17}/></Link><Link href="/features" className="text-link">Explore Our Features <span>↓</span></Link></div><div className="trust"><span>One platform for your whole school.</span></div></div><div className="hero-dashboard-art" aria-hidden="true"><div className="hero-art-card"><span>School overview</span><b><BookOpen size={18}/> Academic records</b><i/><i/><i/></div><div className="hero-art-orbit"><GraduationCap size={48}/></div><div className="hero-art-card hero-art-side"><span>School community</span><b><UsersRound size={18}/> Connected portals</b><i/><i/></div></div></section>

    <section className="intro-section" id="about"><div className="content-kicker">ABOUT SATGOLD CLOUD</div><h2>Everything Your School Needs in One Place</h2><p>SatGold Cloud brings school administration, academic activities and communication into one organised workspace for school leaders, teachers, students and parents.</p><p>Manage classes, assessments, results and school records with role based access from compatible devices.</p></section>

    <div className="home-photo-strip" aria-label="School learning and community photographs"><div role="img" aria-label="Teacher supporting students during a classroom lesson"/><div role="img" aria-label="Students learning together at school"/><div role="img" aria-label="Students taking part in a school activity"/></div>

    <section className="features-section" id="features"><div className="section-head"><div><div className="eyebrow">SCHOOL MANAGEMENT FEATURES</div><h2>Powerful School Management Tools<br/><em>for Everyday Success</em></h2></div><p>From administration to academic reporting, SatGold Cloud helps bring essential school activities into one connected digital environment.</p></div><div className="feature-grid">{features.map(([Icon,title,desc])=><article className="feature" key={title}><span className="feature-icon"><Icon size={21}/></span><h3>{title}</h3><p>{desc}</p></article>)}</div></section>

    <section className="how-section" id="how"><div className="how-title"><div className="eyebrow">A GOOD PLACE TO START</div><h2>Get Your School Started in<br/><em>Four Simple Steps</em></h2><p>Setting up a digital school management system should not feel complicated. SatGold Cloud guides your school through a structured registration and setup process.</p><Link href="/register" className="button button-light">Create Your School Account <ArrowRight size={16}/></Link></div><div className="steps">{steps.map(([n,t,d])=><div className="step" key={n}><span>{n}</span><div><h3>{t}</h3><p>{d}</p></div><ArrowRight size={17}/></div>)}</div><p className="how-closing">Start building a more organised school environment with SatGold Cloud.</p></section>

    <section className="portals-section" id="portals"><div className="content-kicker">DEDICATED PORTALS</div><h2>One Platform Designed for Every Member of Your School</h2><p className="content-lead">Every member of a school has different responsibilities. SatGold Cloud provides separate portals designed around the information and tasks relevant to each user.</p><div className="portal-grid">{portals.map(([title,desc],i)=><article className="portal-card" key={title}><span>0{i+1}</span><h3>{title}</h3><p>{desc}</p></article>)}</div></section>

    <section className="ai-section"><div className="ai-mark"><BrainCircuit size={32}/></div><div><div className="content-kicker">AI POWERED EDUCATION</div><h2>Useful AI Support for Everyday School Work</h2><p>Use AI assistance to draft lesson ideas, assessment questions, school notices and concise academic summaries where the feature is configured.</p><p>Educators stay in control: review AI generated material for accuracy and suitability before using it or sharing it with students and families.</p></div></section>

    <section className="benefits-section"><div className="content-kicker">FOR SCHOOL OWNERS</div><h2>More Control for School Owners.<br/>Better Organisation for Everyone.</h2><p className="content-lead">Bring school records, people, academic work and communication together in a role based workspace.</p><div className="benefit-grid">{benefits.map(([title,desc],i)=><article key={title}><span>0{i+1}</span><h3>{title}</h3><p>{desc}</p></article>)}</div></section>

    <section className="reporting-section"><div><div className="content-kicker">RESULTS AND ACADEMIC REPORTING</div><h2>Clear, Reviewable Academic Reports</h2></div><div><p>Teachers can prepare assessment records and submit them for authorised review. School leaders can approve or return results before publication.</p><p>Published results and reports are available to linked students and parents according to school permissions.</p></div></section>

    <section className="why-section"><div className="content-kicker">WHY CHOOSE SATGOLD CLOUD</div><h2>A Practical Digital Foundation for Your School</h2><p>Bring administration, academic records, reporting and communication together in one web based platform.</p><p>Role based workspaces help each member of your school community focus on relevant tasks, with school leaders overseeing access and academic processes.</p></section>

    <section className="pricing" id="pricing"><div className="content-kicker">PRICING INTRODUCTION</div><h2>Choose a Plan That Fits Your School</h2><p className="content-lead">Compare plans and choose the package that fits your school.</p><p>Eligible new schools can explore the platform with a two month trial.</p><div className="plan-grid">{plans.map(([title,price,desc])=><article key={title}><h3>{title}</h3><strong>{price}</strong><p>{desc}</p>{title==="Custom Package"&&<a href="mailto:support.satgoldcloud@gmail.com">Contact support</a>}</article>)}</div><p className="pricing-note">Eligible newly registered schools receive a two month free trial. Package features, usage limits and subscription conditions are subject to the published plan details.</p><a href="#pricing" className="button button-dark">View Plans and Pricing <ArrowRight size={16}/></a></section>

    <section className="faq-section" id="faq"><div className="content-kicker">FREQUENTLY ASKED QUESTIONS</div><h2>Answers for Your School</h2><div className="faq-list">{faqs.map(([question,answer])=><details key={question}><summary>{question}<span>+</span></summary><p>{answer}</p></details>)}</div></section>

    <section className="final-cta"><div className="content-kicker">GET STARTED WITH SATGOLD CLOUD</div><h2>Give Your School a Smarter Way to Work</h2><p>Bring your school records, teaching and communication together in one organised workspace.</p><div><Link href="/register" className="button button-dark">Register Your School <ArrowRight size={16}/></Link><a href="mailto:support.satgoldcloud@gmail.com" className="text-link">Contact Our Support Team</a></div></section>

    <SiteFooter/>
  </main>;
}
