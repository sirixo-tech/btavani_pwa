import { createHmac, timingSafeEqual } from "node:crypto";
import { cookies } from "next/headers";

const cookieName = "btavani_admin";

function secret() {
  return process.env.ADMIN_SESSION_SECRET || "local-dev-session-secret";
}

function sign(value: string) {
  return createHmac("sha256", secret()).update(value).digest("hex");
}

export async function createAdminSession() {
  const issuedAt = Date.now().toString();
  const token = `${issuedAt}.${sign(issuedAt)}`;
  const store = await cookies();

  store.set(cookieName, token, {
    httpOnly: true,
    sameSite: "lax",
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: 60 * 60 * 12,
  });
}

export async function clearAdminSession() {
  const store = await cookies();
  store.delete(cookieName);
}

export async function isAdminAuthenticated() {
  const store = await cookies();
  const token = store.get(cookieName)?.value;
  if (!token) return false;

  const [issuedAt, signature] = token.split(".");
  if (!issuedAt || !signature) return false;

  const age = Date.now() - Number(issuedAt);
  if (!Number.isFinite(age) || age > 1000 * 60 * 60 * 12) return false;

  const expected = sign(issuedAt);
  const a = Buffer.from(signature);
  const b = Buffer.from(expected);
  return a.length === b.length && timingSafeEqual(a, b);
}

export async function requireAdmin() {
  if (!(await isAdminAuthenticated())) {
    throw new Error("Unauthorized admin action");
  }
}

export function isValidAdminPassword(value: string) {
  const configured = process.env.ADMIN_PASSWORD || "admin123";
  const a = Buffer.from(value);
  const b = Buffer.from(configured);
  return a.length === b.length && timingSafeEqual(a, b);
}

export function hasConfiguredAdminPassword() {
  return Boolean(process.env.ADMIN_PASSWORD);
}
