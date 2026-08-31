import { createClient, type RedisClientType } from "redis";

let redis: RedisClientType | null = null;
let redisReady: Promise<RedisClientType | null> | null = null;

async function getRedis() {
  if (!process.env.REDIS_URL) return null;

  if (!redis) {
    redis = createClient({ url: process.env.REDIS_URL });
    redis.on("error", (error) => {
      console.error("Redis cache error", error);
    });
  }

  if (!redisReady) {
    redisReady = redis.connect().then(() => redis);
  }

  return redisReady;
}

export async function getCachedJson<T>(key: string) {
  const client = await getRedis();
  if (!client) return null;

  const cached = await client.get(key);
  return cached ? (JSON.parse(cached) as T) : null;
}

export async function setCachedJson(key: string, value: unknown, ttlSeconds = 60) {
  const client = await getRedis();
  if (!client) return;

  await client.set(key, JSON.stringify(value), { EX: ttlSeconds });
}

export async function clearMobileCache() {
  const client = await getRedis();
  if (!client) return;

  const keys = await client.keys("mobile:*");
  if (keys.length > 0) {
    await client.del(keys);
  }
}
