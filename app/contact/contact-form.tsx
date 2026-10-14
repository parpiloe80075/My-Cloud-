"use client";

import { useState, type FormEvent } from "react";
import { ArrowRight } from "lucide-react";

export default function ContactForm() {
  const [error, setError] = useState("");

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError("");
    const data = new FormData(event.currentTarget);
    const name = String(data.get("name") ?? "").trim();
    const school = String(data.get("school") ?? "").trim();
    const email = String(data.get("email") ?? "").trim();
    const subject = String(data.get("subject") ?? "").trim();
    const message = String(data.get("message") ?? "").trim();
    if (!name || !email || !subject || !message) {
      setError("Complete the required fields before sending your enquiry.");
      return;
    }
    const body = [`Name: ${name}`, `School: ${school || "Not provided"}`, `Email: ${email}`, "", message].join("\n");
    window.location.href = `mailto:support.satgoldcloud@gmail.com?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
  }

  return <form className="contact-form" onSubmit={submit}>
    <label className="contact-field"><span>Full name</span><input name="name" autoComplete="name" required placeholder="Enter your name."/></label>
    <label className="contact-field"><span>School name</span><input name="school" autoComplete="organization" placeholder="Enter your school's name, if applicable."/></label>
    <label className="contact-field"><span>Email address</span><input name="email" type="email" autoComplete="email" required placeholder="Enter an email address where we can reach you."/></label>
    <label className="contact-field"><span>Subject</span><select name="subject" required defaultValue=""><option value="" disabled>Choose the reason for your enquiry.</option><option>School registration</option><option>Account access</option><option>Available features</option><option>Subscription information</option><option>Technical enquiry</option><option>Custom service request</option><option>Other</option></select></label>
    <label className="contact-field contact-field-wide"><span>Message</span><textarea name="message" required rows={5} placeholder="Tell us how we can assist you."/></label>
    {error&&<p className="contact-error" role="alert">{error}</p>}
    <div className="contact-submit-row"><button className="button button-dark" type="submit">Send Enquiry <ArrowRight size={16}/></button></div>
  </form>;
}
