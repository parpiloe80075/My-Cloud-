import type { Metadata } from "next";
import Link from "next/link";
import "./privacy.css";
import SiteFooter from "@/components/site-footer";

export const metadata: Metadata = {
  title: "Privacy Policy | SatGold Cloud",
  description: "Read how SatGold Cloud is intended to collect, use and protect personal information when people visit the website, register an account or use school management services.",
};

export default function Privacy() {
  return <main className="legal-page">
    <Link href="/" className="brand">← SatGold Cloud</Link>
    <article>
      <div className="eyebrow">YOUR INFORMATION</div>
      <h1>Privacy Policy</h1>
      <p className="legal-updated"><strong>Last updated:</strong> October 14, 2026</p>

      <h2>Your Privacy Matters to Us</h2>
      <p>At SatGold Cloud, we understand that information entrusted to a school is personal and important. School records can contain details about students, parents, teachers and other members of a school community. We believe that this information should be handled responsibly and only for appropriate purposes.</p>
      <p>This Privacy Policy explains how SatGold Cloud collects, uses, stores, shares and manages personal information when you visit our website, register an account or use our school management services.</p>
      <p>Please read this policy carefully. If you are a school owner or administrator, you are also responsible for making sure your school's use of the platform follows applicable privacy requirements.</p>

      <h2>1. Who We Are</h2>
      <p>SatGold Cloud provides digital tools intended to support school administration, academic organisation, communication and related school activities.</p>
      <p>For questions about this policy or the handling of personal information, contact us at:</p>
      <p><strong>Email:</strong> <a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a></p>
      <p><strong>Phone:</strong> <a href="tel:09138836682">09138836682</a> or <a href="tel:07081495536">07081495536</a></p>
      <p><strong>Service website:</strong> <a href="https://satgoldcloud-gold.vercel.app/">https://satgoldcloud-gold.vercel.app/</a></p>
      <p>The legal name and registered address of the business responsible for SatGold Cloud should be added here before this policy is published.</p>

      <h2>2. Information We May Collect</h2>
      <p>The information we collect depends on how you interact with SatGold Cloud and which services are available to you.</p>
      <h3>Account and Contact Information</h3>
      <p>When a school or individual registers or contacts us, we may collect information such as names, email addresses, telephone numbers, school names and account details.</p>
      <h3>School Information</h3>
      <p>A school may provide information about its identity, academic structure, classes, subjects, staff, students, parents and authorised administrators.</p>
      <h3>Academic Information</h3>
      <p>Where the relevant features are enabled, information may include class assignments, assessment records, examination scores, grades, report cards, teacher feedback and other school related records.</p>
      <h3>Account and Technical Information</h3>
      <p>When you use our services, technical records may be generated, such as login activity, timestamps, browser information, device information, error reports and security logs, depending on the systems we operate.</p>
      <h3>Support and Communication Records</h3>
      <p>If you contact our team, we may keep your message and the information needed to respond to your request or resolve an issue.</p>
      <h3>Subscription Information</h3>
      <p>If subscriptions or payments are enabled, we may process information needed to manage plans, payment status, invoices and account billing. Payment card or bank details should only be handled by the appropriate payment provider or system actually used for the transaction.</p>
      <p>We aim to collect only information that is relevant to the purpose for which it is needed.</p>

      <h2>3. How We Use Information</h2>
      <p>Depending on the services available and the lawful basis that applies, information may be used to:</p>
      <ol>
        <li>Create and manage school and user accounts.</li>
        <li>Configure academic sessions, terms, classes and school settings.</li>
        <li>Support authorised school administration and academic activities.</li>
        <li>Manage assessments, results and report preparation where enabled.</li>
        <li>Connect parent accounts with the appropriate student records.</li>
        <li>Send account notices, school announcements and service communications.</li>
        <li>Respond to support requests and investigate technical problems.</li>
        <li>Manage subscriptions and payments where available.</li>
        <li>Protect accounts, investigate suspected misuse and maintain service reliability.</li>
        <li>Meet applicable legal obligations.</li>
        <li>Improve the service using appropriate and proportionate analysis.</li>
      </ol>
      <p>We do not intend to use personal information for purposes that are incompatible with the reason it was collected.</p>

      <h2>4. Our Legal Reasons for Processing Information</h2>
      <p>Applicable privacy law may allow personal information to be processed for different lawful reasons, depending on the circumstances. These can include performing a contract, complying with a legal obligation, protecting legitimate interests or obtaining valid consent where required.</p>
      <p>The appropriate legal reason depends on the type of information, the purpose of processing and the relationship between the parties.</p>
      <p>Where consent is the basis for processing, it should be requested clearly and can be withdrawn where the law allows. Withdrawing consent does not make earlier lawful processing unlawful, and some information may need to be retained for legal or administrative reasons.</p>

      <h2>5. Student and Children's Information</h2>
      <p>We recognise that student records deserve particular care, especially when they relate to children.</p>
      <p>Schools should only upload information they are authorised to provide and should ensure that appropriate notices, permissions and legal requirements are addressed.</p>
      <p>SatGold Cloud should only make student information available to people who are authorised to access it for legitimate school purposes. Users should not share student records publicly or use them for unrelated activities.</p>
      <p>Parents or guardians who have questions about a child's information may contact the relevant school or contact SatGold Cloud for guidance on the appropriate request process.</p>

      <h2>6. How We Share Information</h2>
      <p>We do not sell personal information as a product.</p>
      <p>Information may be shared when necessary for the operation of the service, including with:</p>
      <p><strong>The relevant school:</strong> School administrators and authorised personnel may access records according to their responsibilities and permissions.</p>
      <p><strong>Service providers:</strong> Hosting providers, database providers, email delivery services, AI service providers and other vendors may process information where they are actually integrated into the service and the processing is necessary.</p>
      <p><strong>Legal and regulatory authorities:</strong> Information may be disclosed where required by applicable law or through a valid legal process.</p>
      <p><strong>Business changes:</strong> If the business undergoes a merger, restructuring or transfer, relevant information may be handled as permitted by law and subject to appropriate safeguards.</p>
      <p>We should not disclose personal information to a third party for an unrelated purpose without an appropriate legal basis.</p>

      <h2>7. Third Party Services</h2>
      <p>SatGold Cloud may rely on third party technology to operate parts of the platform. Depending on the current configuration, this may include hosting, databases, email delivery, analytics, AI services or payment processing.</p>
      <p>These providers may have their own privacy terms. Their access to information should be limited to what is necessary for the services they provide and governed by appropriate contractual and security arrangements.</p>
      <p>Before publishing this policy, SatGold Cloud should identify the providers actually in use and explain the types of information shared with them.</p>

      <h2>8. AI Assisted Features</h2>
      <p>Where AI assisted features are enabled, information entered into those features may be processed by the relevant AI provider to generate a response.</p>
      <p>Users should avoid entering unnecessary personal information, confidential student records or sensitive details into AI tools.</p>
      <p>AI generated content may contain errors and should be reviewed by a qualified person before it is used for teaching, assessment, student reporting or other important decisions.</p>
      <p>SatGold Cloud should disclose the relevant AI provider and its data handling arrangements before enabling features that send personal information to an external AI service.</p>

      <h2>9. How Long We Keep Information</h2>
      <p>We keep personal information only for as long as reasonably necessary for the purpose for which it was collected, subject to applicable legal, contractual and record keeping requirements.</p>
      <p>Retention periods may differ for account information, academic records, support messages, security logs and billing records.</p>
      <p>When information is no longer required, it should be deleted, securely destroyed or deidentified where appropriate, unless the law requires it to be retained.</p>
      <p>School owners should understand how records are handled when a subscription ends or a school leaves the platform. The applicable export, retention and deletion arrangements should be communicated clearly.</p>

      <h2>10. How We Protect Information</h2>
      <p>We recognise the importance of protecting information from unauthorised access, loss, alteration, disclosure or destruction.</p>
      <p>Appropriate safeguards should be selected according to the risks and the systems used. These may include access controls, secure authentication, appropriate encryption, software updates, monitoring and backup procedures.</p>
      <p>No online service can promise that every security incident will be prevented. If a personal data breach occurs, SatGold Cloud will handle it in accordance with applicable legal requirements and its incident response procedures.</p>
      <p>This policy describes intended responsibilities. Specific security measures should only be listed as implemented after they have been verified.</p>

      <h2>11. Your Privacy Rights</h2>
      <p>Depending on the applicable law and circumstances, you may have rights to:</p>
      <ol>
        <li>Receive information about how your personal information is used.</li>
        <li>Request access to personal information about you.</li>
        <li>Ask for inaccurate information to be corrected.</li>
        <li>Request deletion of information where the law permits.</li>
        <li>Object to or request restrictions on certain processing.</li>
        <li>Withdraw consent where processing relies on consent.</li>
        <li>Request a portable copy of certain information where applicable.</li>
        <li>Raise a complaint with the relevant data protection authority.</li>
      </ol>
      <p>These rights may be subject to legal exceptions. For example, certain records may need to be retained to meet legal obligations or resolve a dispute.</p>
      <p>To make a privacy request, email <a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a>. We may need to verify your identity or authority before responding.</p>
      <p>If the information concerns a student, we may need to coordinate with the school responsible for the record.</p>

      <h2>12. International Data Processing</h2>
      <p>Some technology providers may process information in countries outside Nigeria. Where this occurs, SatGold Cloud should identify the relevant arrangements and apply the safeguards required by applicable law.</p>
      <p>The countries involved and the safeguards used should be confirmed before this section is treated as a complete description of the platform's practices.</p>

      <h2 id="cookies">13. Cookies and Similar Technologies</h2>
      <p>The website may use cookies or similar technologies to support essential functions, remember preferences, understand website performance or provide other features.</p>
      <p>The actual cookies used depend on the website configuration. Where consent is required for optional cookies, the website should provide an appropriate way to manage those choices.</p>
      <p>For more information, read our <Link href="/cookies">Cookie Policy</Link>.</p>

      <h2>14. Links to Other Websites</h2>
      <p>Our website or service may contain links to third party websites. Those websites operate under their own privacy practices, and we encourage users to read their policies before providing information.</p>

      <h2>15. Changes to This Policy</h2>
      <p>We may update this Privacy Policy when the platform, our practices or applicable legal requirements change.</p>
      <p>The latest version will be published on this page with an updated date. Where a change requires additional notice or consent, we will take the steps required by applicable law.</p>

      <h2>16. Contact Us</h2>
      <p>If you have questions about this policy, want to exercise a privacy right or have a concern about the handling of personal information, contact:</p>
      <p><strong>SatGold Cloud Support</strong></p>
      <p>Email: <a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a></p>
      <p>Phone: <a href="tel:09138836682">09138836682</a> or <a href="tel:07081495536">07081495536</a></p>
      <p>We will review your request and explain the appropriate next steps.</p>
      <p>Your trust matters to us. We aim to handle personal information carefully, explain our practices clearly and improve our approach as the platform develops.</p>
    </article>
    <SiteFooter/>
  </main>;
}
