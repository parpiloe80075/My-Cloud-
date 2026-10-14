import type { Metadata } from "next";
import Link from "next/link";
import "../terms/terms.css";
import SiteFooter from "@/components/site-footer";

export const metadata: Metadata = {
  title: "Subscription, Billing and Refund Policy | SatGold Cloud",
  description: "Review SatGold Cloud subscription plans, trial access, billing, online payment providers, cancellations and refund enquiries.",
};

export default function SubscriptionPolicy() {
  return <main className="legal-page">
    <Link href="/" className="brand">← SatGold Cloud</Link>
    <article>
      <div className="eyebrow">SUBSCRIPTIONS AND PAYMENTS</div>
      <h1>Subscription, Billing and Refund Policy</h1>
      <p className="legal-updated"><strong>Last updated:</strong> October 14, 2026</p>

      <h2>Clear Pricing. Clear Expectations.</h2>
      <p>We want schools to understand what they are paying for before committing to a SatGold Cloud subscription.</p>
      <p>This policy explains the basic approach to subscription plans, trial access, payments, cancellations and refund enquiries. The specific terms displayed during registration or payment should be read together with this policy.</p>

      <h2>1. Available Subscription Plans</h2>
      <p>SatGold Cloud advertises the following subscription options:</p>
      <p><strong>Starter Plan</strong></p><p>NGN 23,000 per academic term.</p>
      <p><strong>School Plan</strong></p><p>NGN 50,000 per academic term. Confirm the official plan name and included features before publication.</p>
      <p><strong>Custom Plan</strong></p><p>Schools with additional requirements can contact our team to discuss available custom services and receive a quotation.</p>
      <p>The final price, applicable taxes if any, included features, usage limits and other conditions should be confirmed before a subscription is purchased.</p>

      <h2>2. Trial Access</h2>
      <p>Eligible newly registered schools may receive a two month trial, subject to the terms communicated during registration.</p>
      <p>Trial access is intended to help schools evaluate the service before choosing a paid subscription.</p>
      <p>The trial does not guarantee access to every feature or custom service. Any limitations should be explained before the school begins using the trial.</p>
      <p>Before the trial ends, the school should review the available plans and decide whether to subscribe.</p>
      <p><strong>Trial conversion:</strong> [Explain whether the trial ends automatically, requires a manual payment or converts to a paid plan. Do not publish until confirmed.]</p>

      <h2>3. Billing Period</h2>
      <p>The advertised Starter and School Plan prices are charged per academic term, rather than per month.</p>
      <p>The applicable term dates, subscription start date and renewal arrangements should be displayed clearly when the school subscribes.</p>
      <p>If a custom service uses a different billing arrangement, that arrangement should be included in the quotation or service agreement.</p>

      <h2>4. Payment Methods</h2>
      <p>Payments are made online through the payment provider or providers presented during the payment process. Available payment options depend on the provider used for the transaction.</p>
      <p>Online payments may also be subject to the selected provider's terms and security procedures. SatGold Cloud does not ask users to send passwords, one time verification codes or other account security credentials to complete a payment.</p>
      <p>Only use payment instructions provided through an official SatGold Cloud channel.</p>

      <h2>5. Payment Confirmation</h2>
      <p>A subscription should be treated as paid only when the payment has been confirmed through the applicable payment process.</p>
      <p>If your payment appears successful but your subscription has not been activated, contact support with the transaction reference, date and amount. Do not send full payment card details or account passwords.</p>
      <p>We will review the information and explain the next steps.</p>

      <h2>6. Renewals</h2>
      <p>The renewal process depends on the subscription arrangement shown at the time of purchase.</p>
      <p><strong>Renewal arrangement:</strong> [State whether subscriptions renew manually or automatically, when renewal is due and how renewal reminders are provided.]</p>
      <p>If automatic renewal is introduced, the renewal price, timing and cancellation process must be clearly disclosed before the user agrees to it.</p>

      <h2>7. Cancellation</h2>
      <p>A school may request cancellation through the available account settings or by contacting support.</p>
      <p><strong>Cancellation deadline:</strong> [Insert the deadline, if applicable.]</p>
      <p><strong>Effect of cancellation:</strong> [Explain when access ends and whether the school can continue using the service until the end of the paid term.]</p>
      <p>Cancellation should not be described as a deletion of school records. Data export, retention and deletion are governed by the applicable data handling arrangements and Privacy Policy.</p>

      <h2>8. Refund Requests</h2>
      <p>We understand that billing concerns can occur, and we encourage schools to contact us if a payment appears incorrect or a service has not been provided as agreed.</p>
      <p>Refund eligibility depends on the circumstances, the subscription agreement and applicable law.</p>
      <p><strong>Refund rules:</strong> [Insert the confirmed rules for duplicate payments, failed transactions, accidental payments, cancellation, service interruption and other eligible situations.]</p>
      <p>Where a refund is approved, the method and estimated processing time should be communicated to the school.</p>
      <p>Nothing in this policy removes a refund or other right that cannot lawfully be excluded.</p>

      <h2>9. Pricing Changes</h2>
      <p>If subscription prices or plan features change, the updated details will be published or communicated through an appropriate channel.</p>
      <p>Any price change affecting an existing paid subscription will be handled in accordance with the agreement and applicable law.</p>
      <p>Schools should review the plan information before starting a new subscription or renewal.</p>

      <h2>10. Custom Services</h2>
      <p>Custom services may include additional configuration, school website development, custom domain arrangements or other work confirmed by the SatGold Cloud team.</p>
      <p>Custom work should begin only after the scope, price, delivery expectations, payment schedule and any refund conditions have been agreed in writing.</p>
      <p>A request for a custom service does not guarantee that the service is available or included in a standard subscription.</p>

      <h2>11. Contact for Billing Questions</h2>
      <p>For subscription or payment enquiries, contact:</p>
      <p>Email: <a href="mailto:support.satgoldcloud@gmail.com">support.satgoldcloud@gmail.com</a></p>
      <p>Phone: <a href="tel:09138836682">09138836682</a> or <a href="tel:07081495536">07081495536</a></p>
      <p>Please provide your school name, subscription plan and transaction reference where relevant. Do not send passwords or complete payment card details.</p>
      <p>We aim to explain billing decisions clearly and help schools resolve genuine payment concerns as fairly as possible.</p>
    </article>
    <SiteFooter />
  </main>;
}
