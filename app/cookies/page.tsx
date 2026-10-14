import type { Metadata } from "next";
import Link from "next/link";
import "../terms/terms.css";
import SiteFooter from "@/components/site-footer";

export const metadata: Metadata = {
  title: "Cookie Policy | SatGold Cloud",
  description: "Learn how SatGold Cloud may use cookies and similar technologies, why they may be used and how you can manage your preferences.",
};

export default function CookiePolicy() {
  return <main className="legal-page">
    <Link href="/" className="brand">← SatGold Cloud</Link>
    <article>
      <div className="eyebrow">WEBSITE INFORMATION</div>
      <h1>Cookie Policy</h1>
      <p className="legal-updated"><strong>Last updated:</strong> October 14, 2026</p>

      <h2>A Clear Explanation of Cookies</h2>
      <p>When you visit a website, small files called cookies may be stored on your device. They can help a website remember information, maintain a session, improve functionality or understand how visitors use its pages.</p>
      <p>SatGold Cloud aims to use these technologies responsibly and to explain their purpose in a way that is easy to understand.</p>
      <p>This policy explains what cookies are, why they may be used and how you can manage them.</p>

      <h2>1. What Are Cookies?</h2>
      <p>Cookies are small text files that a website may store in your browser. Similar technologies can perform related functions, such as remembering preferences or collecting technical information about how a website operates.</p>
      <p>Some cookies are necessary for a website to provide a function you have requested. Others may be used for optional purposes, such as analytics or advertising, if those services are implemented.</p>

      <h2>2. Why We May Use Cookies</h2>
      <p>Depending on the website configuration, SatGold Cloud may use cookies or similar technologies for the following purposes.</p>
      <h3>Essential Website Functions</h3>
      <p>These technologies may support core website functions, account sessions, security and other features required to provide a service you have requested.</p>
      <h3>Preferences</h3>
      <p>Some technologies may remember settings or preferences to make later visits more convenient.</p>
      <h3>Website Analytics</h3>
      <p>If analytics tools are enabled, they may help us understand which pages are visited, identify technical problems and improve the website experience.</p>
      <h3>Additional Services</h3>
      <p>If optional features such as embedded media, advertising or other third party tools are introduced, they may use their own cookies or similar technologies. Their purposes should be explained before they are enabled where required by law.</p>

      <h2>3. Cookies Used by Third Party Services</h2>
      <p>Some features may rely on external service providers. If a provider places cookies or collects information through the website, that processing may also be governed by the provider's own privacy information.</p>
      <p>The specific providers and technologies used by SatGold Cloud should be listed here after the live website has been checked.</p>

      <h2>4. Managing Your Cookie Preferences</h2>
      <p>You can manage or remove cookies through your browser settings. Depending on your browser, you may be able to block all cookies, block selected cookies or delete existing cookies.</p>
      <p>Blocking essential cookies may prevent some website functions from working correctly.</p>
      <p>Where applicable law requires consent for optional cookies, SatGold Cloud should provide a suitable consent mechanism that allows visitors to make and change their choices.</p>

      <h2>5. How Long Cookies Remain</h2>
      <p>Some cookies are temporary and expire when you close your browser. Others may remain on your device for a longer period or until you delete them.</p>
      <p>The duration depends on the purpose and configuration of each cookie. A cookie inventory should be maintained to record the actual name, purpose, provider and duration of each cookie used on the website.</p>

      <h2>6. Changes to This Policy</h2>
      <p>We may update this Cookie Policy if our website technologies or legal requirements change.</p>
      <p>The latest version will be available on this page with the updated date.</p>

      <h2>7. Contact Us</h2>
      <p>If you have questions about cookies or how information is collected through our website, contact:</p>
      <p>Email: <a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a></p>
      <p>Phone: <a href="tel:09138836682">09138836682</a> or <a href="tel:07081495536">07081495536</a></p>
      <p>We want visitors to understand how our website works and have appropriate choices about optional technologies.</p>
    </article>
    <SiteFooter />
  </main>;
}
