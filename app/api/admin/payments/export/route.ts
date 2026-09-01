import { NextResponse } from "next/server";
import { getDashboardData } from "@/lib/repository";
import { requireAdmin } from "@/lib/auth";

export const dynamic = "force-dynamic";

export async function GET() {
  try {
    await requireAdmin();
  } catch (e) {
    return new NextResponse("Unauthorized", { status: 401 });
  }

  const data = await getDashboardData();
  const headers = [
    "Receipt Number",
    "Resident Name",
    "Amount",
    "Block",
    "Flat Number",
    "Mobile",
    "Status",
    "Payment Date"
  ];
  const rows = data.payments.map((p) => [
    p.receiptNumber || "",
    p.residentName.replace(/,/g, ""),
    p.amount,
    p.blockName.replace(/,/g, ""),
    p.flatNumber.replace(/,/g, ""),
    p.phone.replace(/,/g, ""),
    p.status,
    p.createdAt
  ]);

  const csv = [
    headers.join(","),
    ...rows.map(row => row.join(","))
  ].join("\n");

  return new NextResponse(csv, {
    headers: {
      "Content-Type": "text/csv",
      "Content-Disposition": "attachment; filename=\"payments.csv\""
    }
  });
}
