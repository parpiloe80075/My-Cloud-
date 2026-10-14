"use client";

import { useState } from "react";
import { Copy, Sparkles } from "lucide-react";

const kinds = ["Lesson plan", "Quiz questions", "Worksheet", "Study guide", "School notice", "Short summary"];

export default function AiStudio() {
  const [kind, setKind] = useState(kinds[0]);
  const [level, setLevel] = useState("");
  const [subject, setSubject] = useState("");
  const [topic, setTopic] = useState("");
  const [instructions, setInstructions] = useState("");
  const [draft, setDraft] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  async function generate(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault(); setBusy(true); setError(""); setDraft("");
    try {
      const response = await fetch("/api/ai/materials", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ kind, level, subject, topic, instructions }) });
      const result = await response.json() as { text?: string; error?: string };
      if (!response.ok) throw new Error(result.error || "Could not generate a draft.");
      setDraft(result.text || "");
    } catch (problem) { setError(problem instanceof Error ? problem.message : "Could not generate a draft."); }
    finally { setBusy(false); }
  }
  async function copyDraft() { await navigator.clipboard.writeText(draft); }
  return <div className="studio-layout">
    <form className="studio-form" onSubmit={generate}>
      <label>What do you need?
        <select value={kind} onChange={event => setKind(event.target.value)}>{kinds.map(item => <option key={item}>{item}</option>)}</select>
      </label>
      <div className="studio-fields"><label>Class or level<input required maxLength={100} value={level} onChange={event => setLevel(event.target.value)} placeholder="e.g. Primary 5" /></label><label>Subject<input required maxLength={100} value={subject} onChange={event => setSubject(event.target.value)} placeholder="e.g. Basic Science" /></label></div>
      <label>Topic<input required maxLength={180} value={topic} onChange={event => setTopic(event.target.value)} placeholder="What should the material cover?" /></label>
      <label>Extra instructions <span className="studio-optional">Optional</span><textarea maxLength={1200} rows={4} value={instructions} onChange={event => setInstructions(event.target.value)} placeholder="Tone, length, learning goals or other context" /></label>
      <p className="studio-privacy">Do not enter student names, grades, contact details or other personal information.</p>
      {error && <p className="studio-error" role="alert">{error}</p>}
      <button className="workspace-button" disabled={busy}>{busy ? "Preparing draft..." : <><Sparkles size={17}/> Generate draft</>}</button>
    </form>
    <section className="studio-output" aria-live="polite"><header><div><span className="workspace-kicker">AI GENERATED DRAFT</span><h2>Your material</h2></div>{draft && <button type="button" className="studio-copy" onClick={copyDraft}><Copy size={16}/> Copy</button>}</header>{draft ? <pre>{draft}</pre> : <div className="studio-placeholder"><Sparkles size={24}/><p>Your draft will appear here. Review and edit it before using it in class.</p></div>}</section>
  </div>;
}
