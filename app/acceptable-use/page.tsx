import type { Metadata } from "next";
import Link from "next/link";
import "./acceptable-use.css";
import SiteFooter from "@/components/site-footer";

export const metadata: Metadata = {
  title: "Acceptable Use Policy | SatGold Cloud",
  description: "Read the rules for using SatGold Cloud responsibly, protecting school information and supporting a safe school community.",
};

export default function AcceptableUse() {
  return <main className="legal-page">
    <Link href="/" className="brand">← SatGold Cloud</Link>
    <article>
      <div className="eyebrow">PLATFORM INFORMATION</div>
      <h1>Acceptable Use Policy</h1>
      <p className="legal-updated"><strong>Last updated:</strong> October 14, 2026</p>

      <h2>Using SatGold Cloud Responsibly</h2>
      <p>SatGold Cloud is designed to support schools and the people who help them learn, teach and operate. Every user has a role in keeping the platform useful, respectful and safe.</p>
      <p>This policy explains the behaviour expected from anyone who accesses SatGold Cloud, including school owners, administrators, teachers, students, parents and other authorised users.</p>
      <p>By using the platform, you agree to follow this policy and any additional rules established by your school.</p>

      <h2>1. Respect Other People's Accounts</h2>
      <p>Use only accounts you are authorised to access.</p>
      <p>Do not guess, steal, share or misuse another person's password or passcode. Do not attempt to enter another student's, parent's, teacher's or administrator's account without permission.</p>
      <p>If you discover an account access problem or a possible security weakness, report it to the appropriate school administrator or SatGold Cloud support.</p>

      <h2>2. Protect Student and School Information</h2>
      <p>School records must be treated with care.</p>
      <p>Do not publish, download, copy, forward or disclose student information unless you are authorised to do so for a legitimate purpose.</p>
      <p>Do not use school records to embarrass, threaten, harass or discriminate against a student or another member of the school community.</p>
      <p>Parents should access only information they are authorised to see. Teachers and school staff must follow the permissions and confidentiality rules that apply to their responsibilities.</p>

      <h2>3. Use Accurate Information</h2>
      <p>Users should provide accurate information when creating accounts, maintaining school records or completing academic activities.</p>
      <p>Do not deliberately falsify student details, attendance information, assessment scores, grades, report cards or school announcements.</p>
      <p>If you discover an error, report it through the appropriate school process so that an authorised person can review and correct it.</p>

      <h2>4. Maintain Academic Integrity</h2>
      <p>Assessments and academic records should reflect genuine student work and authorised teacher decisions.</p>
      <p>Users must not attempt to alter results without permission, impersonate another student during an assessment, interfere with examination processes or distribute confidential assessment materials without authorisation.</p>
      <p>Teachers and administrators should review results and reports before approving or publishing them.</p>

      <h2>5. Use AI Responsibly</h2>
      <p>Where AI assisted features are available, use them to support learning and teaching rather than to mislead others.</p>
      <p>Review AI generated content for accuracy, relevance, fairness and age appropriateness before using it.</p>
      <p>Do not submit unnecessary confidential student information to an AI feature. Do not use AI tools to generate harmful, discriminatory or deceptive material.</p>
      <p>AI generated responses should not be treated as final academic decisions without appropriate human review.</p>

      <h2>6. Do Not Disrupt the Platform</h2>
      <p>Users must not knowingly introduce malware, attempt unauthorised security testing, overload the service, interfere with other users or bypass technical restrictions.</p>
      <p>Do not attempt to gain access to internal systems, private records, administrative functions or another school's workspace without explicit authorisation.</p>
      <p>Security testing should only be performed with written permission from the party responsible for the system.</p>

      <h2>7. Do Not Misuse Communications</h2>
      <p>School announcements, messages and other communication tools should be used for appropriate school related purposes.</p>
      <p>Do not send threats, abusive messages, fraudulent offers, unsolicited promotional messages or content that violates another person's rights.</p>
      <p>Do not impersonate SatGold Cloud, a school official, a parent or another user.</p>

      <h2>8. Respect Intellectual Property</h2>
      <p>Do not upload or distribute content that you do not have the right to use.</p>
      <p>Respect copyright, privacy, confidentiality and other legal rights when sharing teaching materials, photographs, documents, assessments or other content.</p>

      <h2>9. Report Problems</h2>
      <p>If you encounter suspected account misuse, inappropriate content, unauthorised disclosure or a technical security issue, report it promptly.</p>
      <p>Contact your school administrator or email <a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a>.</p>
      <p>Please include enough information to help us understand the concern, but do not send unnecessary student records, passwords or other sensitive details in your report.</p>

      <h2>10. What Happens When This Policy Is Violated?</h2>
      <p>Depending on the seriousness of the issue, a school or SatGold Cloud may take proportionate action, including requesting that the behaviour stop, restricting access, suspending an account or referring a matter to the appropriate authority where required.</p>
      <p>Where appropriate and legally permitted, the affected user or school may be given an opportunity to explain the situation or resolve the issue.</p>
      <p>Serious incidents involving threats, unlawful access, fraud or risks to students may require more immediate action.</p>

      <h2>11. School Responsibilities</h2>
      <p>Schools are responsible for explaining relevant usage rules to their staff and students, assigning suitable permissions and responding to misuse within their community.</p>
      <p>SatGold Cloud may provide tools to support these responsibilities, but the school should not assume that software replaces its own supervision and safeguarding procedures.</p>

      <h2>12. Updates to This Policy</h2>
      <p>We may update this policy as the platform develops or our requirements change. The current version will be published on this page.</p>

      <h2>13. Contact Us</h2>
      <p>For questions or reports concerning this policy, contact:</p>
      <p>Email: <a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a></p>
      <p>Phone: <a href="tel:09138836682">09138836682</a> or <a href="tel:07081495536">07081495536</a></p>
      <p>Thank you for helping make SatGold Cloud a more responsible and respectful place for school communities.</p>
    </article>
    <SiteFooter />
  </main>;
}
