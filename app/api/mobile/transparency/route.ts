import { getTransparencyData } from "@/lib/repository";

export const dynamic = "force-dynamic";

export async function GET() {
  const data = await getTransparencyData();
  return Response.json(data, { status: 200 });
}
