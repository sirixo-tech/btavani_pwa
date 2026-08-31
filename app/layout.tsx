import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "BT AVANI Admin Dashboard",
  description: "Operations dashboard for Avani Ganesh Utsav 2026",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en" className="h-full antialiased">
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
