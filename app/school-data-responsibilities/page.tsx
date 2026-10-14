import type { Metadata } from "next";
import Link from "next/link";
import "../terms/terms.css";
import SiteFooter from "@/components/site-footer";

export const metadata: Metadata = {
  title: "School Data Processing and Responsibilities | SatGold Cloud",
  description: "Understand the responsibilities schools and SatGold Cloud share when handling school records and personal information.",
};

export default function SchoolDataResponsibilities() {
  return <main className="legal-page">
    <Link href="/" className="brand">← SatGold Cloud</Link>
    <article>
      <div className="eyebrow">SCHOOL INFORMATION</div>
      <h1>School Data Processing and Responsibilities</h1>
      <p className="legal-updated"><strong>Last updated:</strong> October 14, 2026</p>

      <h2>Working Together to Handle School Information Responsibly</h2>
      <p>School information deserves careful handling. Academic records, contact details, account information and student reports should only be accessed and used for appropriate purposes.</p>
      <p>SatGold Cloud is designed to support school administration through digital tools. Schools that use these tools also have responsibilities for the information they provide, the people they authorise and the way records are used.</p>
      <p>This page explains the principles that guide those responsibilities. It should be read alongside our <Link href="/privacy">Privacy Policy</Link>, <Link href="/terms">Terms of Service</Link> and any separate data processing agreement signed by the school.</p>

      <h2>1. Responsibilities of the School</h2>
      <p>The school is responsible for ensuring that information uploaded to SatGold Cloud is collected and used lawfully.</p>
      <p>This includes determining what information is needed, ensuring that appropriate notices or permissions are provided, keeping records accurate and deciding which school personnel should have access.</p>
      <p>The school should also establish appropriate internal procedures for student record corrections, parent enquiries, academic approvals, account removal and the handling of confidential information.</p>

      <h2>2. Responsibilities of SatGold Cloud</h2>
      <p>SatGold Cloud is responsible for the activities it undertakes in providing and maintaining its services, in accordance with applicable law and the relevant customer agreement.</p>
      <p>Depending on the actual service arrangement, these activities may include hosting and organising school information, maintaining user access, providing technical support and processing information according to the agreed service.</p>
      <p>The precise legal roles of SatGold Cloud and the school depend on who determines the purpose and means of each processing activity. Those roles should be documented rather than assumed.</p>

      <h2>3. Access to School Records</h2>
      <p>School records should be available only to authorised users who need the information for their assigned responsibilities.</p>
      <p>School administrators should review account permissions regularly and remove access when it is no longer appropriate.</p>
      <p>Users must not attempt to access another school's records or information belonging to another person without proper authorisation.</p>

      <h2>4. Student Information</h2>
      <p>Schools should take particular care when handling information about children.</p>
      <p>Only the information needed for legitimate educational and administrative purposes should be provided. Access should be restricted appropriately, and records should not be disclosed publicly without a valid reason and the necessary authority.</p>
      <p>Schools should explain relevant privacy practices to parents, guardians, students and staff in language they can understand.</p>

      <h2>5. Accuracy and Corrections</h2>
      <p>Schools are responsible for reviewing the accuracy of the records they maintain.</p>
      <p>If a student profile, result, report card or other record contains an error, an authorised person should investigate and correct it through the appropriate process.</p>
      <p>Academic records should not be changed by unauthorised users, and important changes should be handled according to the school's record keeping procedures.</p>

      <h2>6. Data Security</h2>
      <p>Protecting school information requires cooperation between the school, its users and the technology providers involved.</p>
      <p>Schools should use appropriate account controls, protect login credentials, train staff on responsible data handling and report suspected security incidents promptly.</p>
      <p>SatGold Cloud should implement and maintain safeguards appropriate to the actual service and the risks involved. Any specific security commitments should be documented and verified before they are promised to schools.</p>

      <h2>7. Third Party Providers</h2>
      <p>The platform may rely on external providers for hosting, database services, email delivery, AI assistance or other functions.</p>
      <p>Where these providers process school information, the relevant arrangements should explain what information is involved, why it is processed and what safeguards apply.</p>
      <p>Schools should receive appropriate information about material service providers and relevant changes to those arrangements.</p>

      <h2>8. AI Assisted Processing</h2>
      <p>If a school uses an AI assisted feature, it should understand what information the feature receives and how the relevant provider handles it.</p>
      <p>Schools and users should avoid submitting confidential student information unless the feature is authorised for that purpose and appropriate safeguards are in place.</p>
      <p>AI generated content should be reviewed by a qualified person before it is used for important educational or administrative decisions.</p>

      <h2>9. Data Requests</h2>
      <p>Requests to access, correct, export or delete personal information should be handled through an appropriate process.</p>
      <p>A request may need to be reviewed by the school, SatGold Cloud or both, depending on the type of information, the parties' responsibilities and applicable law.</p>
      <p>Identity and authority may need to be verified before information is disclosed or changed.</p>
      <p>Some records may be subject to legal retention requirements or other lawful restrictions.</p>

      <h2>10. Retention and Account Closure</h2>
      <p>Schools should understand what happens to their information when a subscription expires, an account is closed or a school stops using the service.</p>
      <p>The applicable agreement should explain available export options, the relevant retention period, deletion arrangements and any information that must be retained for legal or security purposes.</p>
      <p>Do not assume that closing an account immediately removes every stored record.</p>

      <h2>11. Reporting a Concern</h2>
      <p>If you believe school information has been accessed, disclosed or changed without authorisation, report the concern promptly.</p>
      <p>Contact your school administrator or SatGold Cloud support at <a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a>.</p>
      <p>Include a clear description of the concern, but do not send passwords or unnecessary sensitive student information.</p>

      <h2>12. Separate Data Processing Agreement</h2>
      <p>Depending on the services provided and the parties' legal responsibilities, a school may need a separate Data Processing Agreement.</p>
      <p>That agreement should define the processing instructions, categories of information, responsibilities, security measures, approved service providers, assistance with data requests, breach reporting, retention and deletion arrangements.</p>
      <p>Contact SatGold Cloud to discuss the appropriate agreement for your school.</p>

      <h2>13. Contact Us</h2>
      <p>For questions about school information handling, contact:</p>
      <p>Email: <a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a></p>
      <p>Phone: <a href="tel:09138836682">09138836682</a> or <a href="tel:07081495536">07081495536</a></p>
      <p>We believe responsible school technology depends on clear communication, appropriate access and a shared commitment to protecting the people behind the records.</p>
    </article>
    <SiteFooter />
  </main>;
}
