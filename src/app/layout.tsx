import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { AuthProvider } from "../../lib/auth-context";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "CertBloom - Texas Teacher Certification Prep with Purpose",
  description: "Adaptive TExES preparation designed specifically for Texas educators. Combining intelligent learning with mindful practice. Join 5,000+ teachers who passed with CertBloom.",
  keywords: "TExES prep, Texas teacher certification, EC-6, ELA 4-8, teacher test prep, adaptive learning, mindful education",
  openGraph: {
    title: "CertBloom - Texas Teacher Certification Prep with Purpose",
    description: "Adaptive TExES preparation that honors both mind and spirit. 94% pass rate, 15min daily study.",
    url: "https://certbloom.com",
    siteName: "CertBloom",
    type: "website",
    images: [
      {
        url: "/certbloom-logo.svg",
        width: 800,
        height: 600,
        alt: "CertBloom - Texas Teacher Certification Prep",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "CertBloom - Texas Teacher Certification Prep with Purpose",
    description: "Adaptive TExES preparation that honors both mind and spirit. 94% pass rate, 15min daily study.",
    images: ["/certbloom-logo.svg"],
  },
  icons: {
    icon: "/certbloom-logo.svg",
    shortcut: "/certbloom-logo.svg",
    apple: "/certbloom-logo.svg",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
