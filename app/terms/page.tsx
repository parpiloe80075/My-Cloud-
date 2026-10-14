import type { Metadata } from "next";
import Link from "next/link";
import "./terms.css";
import SiteFooter from "@/components/site-footer";

export const metadata: Metadata = {
  title: "Terms of Service | SatGold Cloud",
  description: "Review the terms that apply when you visit the SatGold Cloud website, create an account or use our school management services.",
};

export default function Terms() {
  return <main className="legal-page">
    <Link href="/" className="brand">← SatGold Cloud</Link>
    <article>
      <div className="eyebrow">PLATFORM INFORMATION</div>
      <h1>Terms of Service</h1>
      <p className="legal-updated"><strong>Last updated:</strong> October 14, 2026</p>

      <h2>Welcome to SatGold Cloud</h2>
      <p>SatGold Cloud is being developed to help schools organise administration, academic activities, communication and related processes through digital tools.</p>
      <p>These Terms of Service explain the rules that apply when you visit our website, create an account or use our services.</p>
      <p>By using SatGold Cloud, you agree to these terms. If you are using the platform on behalf of a school or organisation, you confirm that you are authorised to act for that organisation.</p>
      <p>If you do not agree with these terms, do not use the service.</p>

      <h2>1. About SatGold Cloud</h2>
      <p>SatGold Cloud provides online tools intended to support school administration and academic organisation. Depending on the current release, features may include school setup, user management, academic records, assessments, reporting, communication and AI assisted academic support.</p>
      <p>Not every feature described on the website will necessarily be available in every account or release. We will make reasonable efforts to communicate important limitations and changes.</p>
      <p>The legal name and registered address of the business providing the service should be added here before publication.</p>

      <h2>2. Who May Use the Platform</h2>
      <p>School owners, authorised administrators, teachers, students, parents and other approved users may access the platform where the relevant account type and features are available.</p>
      <p>Users must provide accurate information when required and keep their account details up to date.</p>
      <p>Where a user is a child or otherwise requires an authorised adult to act on their behalf, the school and relevant parent or guardian must ensure that the account is created and used appropriately under applicable law.</p>

      <h2>3. School Accounts and Responsibilities</h2>
      <p>A school registering with SatGold Cloud is responsible for providing accurate school information and ensuring that the person registering has the necessary authority.</p>
      <p>The school is responsible for managing its authorised users, assigning appropriate permissions, reviewing records and ensuring that staff use the platform for legitimate school purposes.</p>
      <p>School administrators must take reasonable care when creating accounts, assigning access, connecting parents to student records and removing access when a user no longer needs it.</p>
      <p>The school must not upload information that it has no lawful authority to provide.</p>

      <h2>4. Account Security</h2>
      <p>Users are responsible for keeping their login details confidential and using their accounts appropriately.</p>
      <p>Do not share passwords, passcodes or account recovery details with unauthorised people. If you believe someone has accessed your account without permission, notify your school administrator or contact SatGold Cloud support promptly.</p>
      <p>SatGold Cloud may restrict or suspend access where reasonably necessary to protect users, investigate suspected misuse or address a security risk.</p>
      <p>Users should sign out on shared devices and avoid storing account credentials where other people can access them.</p>

      <h2>5. School Records and Academic Decisions</h2>
      <p>SatGold Cloud provides tools to help schools organise information. The school remains responsible for the accuracy, completeness and appropriate use of its academic and administrative records.</p>
      <p>Teachers and authorised school officials must review assessments, grades, comments and report cards before relying on or publishing them.</p>
      <p>The platform does not replace the professional judgement of teachers, school leaders or other qualified personnel.</p>
      <p>Schools should maintain appropriate procedures for checking results, correcting errors, approving reports and responding to questions about student records.</p>

      <h2>6. AI Assisted Features</h2>
      <p>Where AI features are available, they are intended to assist with selected tasks rather than replace human judgement.</p>
      <p>AI generated responses may be incomplete, inaccurate or unsuitable for a particular educational context. Users must review the output before relying on it.</p>
      <p>Do not treat AI output as the sole basis for important decisions about a student's academic standing, discipline, wellbeing or future opportunities.</p>
      <p>Users should avoid entering confidential information into AI features unless the relevant feature is approved for that information and its data handling arrangements are understood.</p>

      <h2 id="acceptable-use">7. Acceptable Use</h2>
      <p>You agree to use SatGold Cloud lawfully and responsibly.</p>
      <p>You must not attempt to access another person's account without permission, bypass access controls, interfere with platform operations, upload malicious code, misuse personal information or use the service to harass, deceive or harm others.</p>
      <p>You must not copy, scrape, reverse engineer or exploit the service in a way that violates applicable law or another party's rights, except where such activity cannot lawfully be restricted.</p>
      <p>Additional rules are set out in our Acceptable Use Policy.</p>

      <h2 id="billing">8. Subscriptions, Fees and Trials</h2>
      <p>SatGold Cloud may offer paid plans, trial periods or custom services.</p>
      <p>The prices, billing periods, included features and conditions shown at the time of purchase or registration apply to the relevant subscription, subject to applicable law and the terms presented during checkout.</p>
      <p>The advertised two month trial is available only to eligible schools and is subject to the conditions communicated during registration.</p>
      <p>A trial does not guarantee that every platform feature is available. Schools should review the current feature list before relying on the service for essential academic operations.</p>
      <p>Details about payment, cancellation and refunds are explained in our Subscription, Billing and Refund Policy.</p>

      <h2>9. Service Availability and Changes</h2>
      <p>We aim to make SatGold Cloud useful and dependable, but we cannot promise that the service will always be available without interruption or error.</p>
      <p>Maintenance, software updates, third party outages, network problems, security incidents and other circumstances may affect availability.</p>
      <p>We may introduce, change, suspend or discontinue features where reasonably necessary for maintenance, security, legal compliance or product development. Where a change materially affects a paid service, we will provide notice where required by law or the applicable subscription terms.</p>
      <p>We will not use this section to remove rights that cannot legally be excluded.</p>

      <h2>10. Third Party Services</h2>
      <p>Some features may depend on services provided by other companies, such as hosting, databases, email delivery, AI services or payment providers.</p>
      <p>The availability of those features may depend on the third party's service and terms. Where appropriate, users may also need to comply with the relevant third party conditions.</p>
      <p>SatGold Cloud should identify important third party dependencies before users rely on them for essential school operations.</p>

      <h2>11. Ownership and Intellectual Property</h2>
      <p>SatGold Cloud and its licensors retain their rights in the platform, branding, software, website design, documentation and original content, except where rights are expressly granted.</p>
      <p>Subject to these terms, users receive permission to access and use the service for its intended purpose during the period in which they are authorised to use it.</p>
      <p>Schools retain the rights they have in their own records and content. By submitting information to the platform, a school authorises the processing necessary to provide the service and fulfil the school's instructions, subject to applicable law and the <Link href="/privacy">Privacy Policy</Link>.</p>
      <p>Users must not represent SatGold Cloud's branding or content as their own without permission.</p>

      <h2>12. Privacy and Personal Information</h2>
      <p>Our <Link href="/privacy">Privacy Policy</Link> explains how personal information is handled.</p>
      <p>Schools must ensure they have the appropriate authority and lawful basis to provide student, parent, staff and other personal information to the platform.</p>
      <p>Both SatGold Cloud and its customers should meet the privacy and security responsibilities that apply to their respective roles under applicable law and any relevant agreement.</p>

      <h2>13. Suspension and Account Closure</h2>
      <p>We may suspend or restrict an account where necessary to address a security threat, suspected unlawful activity, serious misuse, nonpayment or another material breach of these terms.</p>
      <p>Where appropriate and legally permitted, we will provide notice and an opportunity to resolve the issue.</p>
      <p>A school may request account closure through the available account settings or by contacting support. The handling of its records after closure will follow the applicable retention, export and deletion arrangements, the Privacy Policy and legal obligations.</p>
      <p>Closing an account does not automatically remove records that must lawfully be retained.</p>

      <h2>14. Disclaimers</h2>
      <p>SatGold Cloud is intended to support school administration. It does not guarantee improved academic performance, error free records, uninterrupted availability or any particular business outcome.</p>
      <p>Schools must evaluate whether the current service meets their needs and maintain appropriate alternative procedures for essential activities where necessary.</p>
      <p>Nothing in these terms excludes a consumer or other legal right that cannot lawfully be excluded.</p>

      <h2>15. Limitation of Liability</h2>
      <p>To the extent permitted by applicable law, SatGold Cloud will not be responsible for losses arising from misuse of the platform, inaccurate information supplied by users, unauthorised sharing of credentials, failures of third party services or interruptions beyond its reasonable control.</p>
      <p>This provision does not exclude or limit liability where such exclusion or limitation is prohibited by law, including liability that cannot lawfully be restricted.</p>
      <p>Any further limitation of liability must be reviewed and tailored to the business, the service and applicable Nigerian law before publication.</p>

      <h2>16. Changes to These Terms</h2>
      <p>We may update these terms as the platform develops or legal requirements change.</p>
      <p>The latest version will appear on this page with its updated date. If a change materially affects existing users, we will provide notice where appropriate or legally required.</p>
      <p>Continued use after an effective change will be subject to the updated terms to the extent permitted by law.</p>

      <h2>17. Governing Law and Disputes</h2>
      <p>These terms are intended to operate under the laws of the Federal Republic of Nigeria, subject to any mandatory legal protections that apply.</p>
      <p>If a concern arises, please contact us first so we can try to resolve it fairly. Nothing in this section prevents a user from exercising a legal right or approaching a competent authority or court.</p>

      <h2>18. Contact Us</h2>
      <p>For questions about these terms, contact:</p>
      <p><strong>SatGold Cloud Support</strong></p>
      <p>Email: <a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a></p>
      <p>Phone: <a href="tel:09138836682">09138836682</a> or <a href="tel:07081495536">07081495536</a></p>
      <p>We want schools and their communities to understand the service, use it responsibly and know where to turn when they need assistance.</p>
    </article>
    <SiteFooter/>
  </main>;
}
