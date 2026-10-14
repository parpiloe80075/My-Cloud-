import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = { title: "SatGold Cloud | School Management Software in Nigeria", description: "Manage your school with SatGold Cloud, an AI powered school management system for student records, teachers, CBT exams, results, parent portals and school administration." };
export default function RootLayout({children}:{children:React.ReactNode}) { return <html lang="en"><body>{children}</body></html>; }
