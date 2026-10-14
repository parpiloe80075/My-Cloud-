import type { ReactNode } from "react";

type FormFieldProps = {
  label: string;
  children: ReactNode;
  wide?: boolean;
};

export default function FormField({ label, children, wide = false }: FormFieldProps) {
  return <label className={`field ${wide ? "wide" : ""}`}>
    <span>{label}</span>
    {children}
  </label>;
}
