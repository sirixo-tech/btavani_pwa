import { ensureSchema, hasDatabase } from "@/lib/db";

export const dynamic = "force-dynamic";

export async function POST(request: Request) {
  const adminToken = process.env.ADMIN_SEED_TOKEN;
  if (adminToken && request.headers.get("authorization") !== `Bearer ${adminToken}`) {
    return Response.json({ error: "Unauthorized" }, { status: 401 });
  }

  if (!hasDatabase()) {
    return Response.json({ ok: true, mode: "local-seed" });
  }

  await ensureSchema();
  return Response.json({ ok: true, mode: "postgres" });
}
