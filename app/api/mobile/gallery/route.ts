import { saveCmsEntry } from "@/lib/repository";
import crypto from "crypto";

export const dynamic = "force-dynamic";

function authorizeWrite(request: Request) {
  const token = process.env.MOBILE_API_TOKEN;
  if (!token) return true;
  return request.headers.get("authorization") === `Bearer ${token}`;
}

export async function POST(request: Request) {
  if (!authorizeWrite(request)) {
    return Response.json({ error: "Unauthorized" }, { status: 401 });
  }

  let imageUrl = "";

  if (request.headers.get("content-type")?.includes("multipart/form-data")) {
    const formData = await request.formData();
    for (const [key, value] of formData.entries()) {
      if (key === "image" && value instanceof File) {
        const buffer = await value.arrayBuffer();
        const base64 = Buffer.from(buffer).toString("base64");
        imageUrl = `data:${value.type};base64,${base64}`;
      }
    }
  }

  if (!imageUrl) {
    return Response.json({ error: "No image provided" }, { status: 400 });
  }

  const id = crypto.randomUUID();

  const entry = await saveCmsEntry({
    id,
    section: "gallery",
    title: "User Uploaded Image",
    subtitle: "Pending Approval",
    body: "",
    label: "",
    color: "gray",
    startsAt: "",
    venue: "",
    imageUrl,
    isPublished: false,
    sortOrder: 0,
  });

  return Response.json({ entry }, { status: 201 });
}
