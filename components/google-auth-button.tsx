"use client";

import { useState } from "react";
import { createClient } from "@/lib/supabase-browser";

export default function GoogleAuthButton({ beforeStart, label = "Continue with Google" }: { beforeStart?: () => void; label?: string }) {
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  async function start() {
    setError(""); setBusy(true);
    try {
      beforeStart?.();
      const supabase = createClient();
      const { error: authError } = await supabase.auth.signInWithOAuth({
        provider: "google",
        options: { redirectTo: `${window.location.origin}/auth/callback` },
      });
      if (authError) throw authError;
    } catch (problem) {
      setError(problem instanceof Error ? problem.message : "Google sign in could not be started.");
      setBusy(false);
    }
  }
  return <div className="google-auth-wrap"><button className="google-auth-button" type="button" onClick={start} disabled={busy}>
    <svg aria-hidden="true" viewBox="0 0 48 48" width="20" height="20"><path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5Z"/><path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94a11.1 11.1 0 0 1-4.8 7.28l7.73 6C44.38 38.1 46.98 31.95 46.98 24.55Z"/><path fill="#FBBC05" d="M10.53 28.59a14.4 14.4 0 0 1 0-9.18l-7.98-6.19a23.9 23.9 0 0 0 0 21.56l7.98-6.19Z"/><path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.9-5.7l-7.73-6c-2.14 1.44-4.88 2.3-8.17 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48Z"/></svg>
    {busy ? "Connecting to Google…" : label}
  </button>{error && <p className="google-auth-error" role="alert">{error}</p>}</div>;
}
