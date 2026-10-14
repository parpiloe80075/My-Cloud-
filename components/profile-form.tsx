"use client";

import { useState } from "react";
import { createClient } from "@/lib/supabase-browser";

export default function ProfileForm({ initialName, initialPhone, email }: { initialName: string; initialPhone: string; email: string }) {
  const [name, setName] = useState(initialName);
  const [phone, setPhone] = useState(initialPhone);
  const [message, setMessage] = useState("");
  const [saving, setSaving] = useState(false);
  async function save(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSaving(true); setMessage("");
    try {
      const supabase = createClient();
      const { error } = await supabase.auth.updateUser({ data: { full_name: name.trim(), phone: phone.trim() } });
      if (error) throw error;
      setMessage("Profile saved.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Could not save your profile.");
    } finally { setSaving(false); }
  }
  return <form className="profile-form" onSubmit={save}>
    <label>Full name<input required autoComplete="name" value={name} onChange={event => setName(event.target.value)} /></label>
    <label>Email address<input type="email" value={email} readOnly /></label>
    <label>Phone number<input autoComplete="tel" value={phone} onChange={event => setPhone(event.target.value)} /></label>
    {message && <p className="profile-feedback" role="status">{message}</p>}
    <button className="workspace-button" type="submit" disabled={saving}>{saving ? "Saving…" : "Save profile"}</button>
  </form>;
}
