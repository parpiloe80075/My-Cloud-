import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = { title: "SatGold Cloud — One Cloud. Every Classroom.", description: "Secure, AI-powered school management for Nigerian schools." };
export default function RootLayout({children}:{children:React.ReactNode}) { return <html lang="en"><body>{children}</body></html>; }
