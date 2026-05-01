const APNS_TEAM_ID = "TODO_TEAM_ID";
const APNS_KEY_ID = "TODO_KEY_ID";
const APNS_BUNDLE_ID = "TODO_BUNDLE_ID";
const APNS_PRIVATE_KEY = `-----BEGIN PRIVATE KEY-----
TODO_APNS_AUTH_KEY_P8_CONTENT
-----END PRIVATE KEY-----`;

const DEFAULT_DEVICE_ID = "default";
const DEFAULT_WORKER_URL = "https://push.vymedia.xyz";
const APNS_PRODUCTION_URL = "https://api.push.apple.com";
const APNS_SANDBOX_URL = "https://api.sandbox.push.apple.com";
const USE_SANDBOX = false;

const deviceTokens = new Map<string, string>();

type Payload = { title?: string; body?: string; subtitle?: string; badge?: number; sound?: string };

const json = (data: unknown, status = 200) => new Response(JSON.stringify(data, null, 2), { status, headers: cors({ "content-type": "application/json" }) });
const cors = (h: Record<string, string> = {}) => ({ ...h, "access-control-allow-origin": "*", "access-control-allow-methods": "GET,POST,OPTIONS", "access-control-allow-headers": "content-type" });

export default {
  async fetch(req: Request): Promise<Response> {
    if (req.method === "OPTIONS") return new Response(null, { headers: cors() });
    const url = new URL(req.url);

    if (req.method === "GET" && url.pathname === "/") {
      return new Response(`<h1>brrr</h1><p>POST plain text or JSON to / or /send</p><pre>curl -X POST ${DEFAULT_WORKER_URL} -d 'Hello world! 🚀'</pre>`, { headers: cors({ "content-type": "text/html;charset=utf-8" }) });
    }
    if (req.method === "GET" && url.pathname === "/health") return json({ ok: true, name: "brrr", worker: DEFAULT_WORKER_URL });
    if (req.method === "POST" && url.pathname === "/register") return register(req);
    if (req.method === "POST" && (url.pathname === "/" || url.pathname === "/send")) return send(req, DEFAULT_DEVICE_ID);
    if (req.method === "POST" && url.pathname.startsWith("/send/")) return send(req, url.pathname.split("/")[2] || DEFAULT_DEVICE_ID);

    return json({ ok: false, error: "Route not found" }, 404);
  }
};

async function register(req: Request): Promise<Response> {
  const body = await req.json<any>().catch(() => null);
  if (!body?.token) return json({ ok: false, error: "token is required" }, 400);
  const deviceId = body.deviceId || DEFAULT_DEVICE_ID;
  deviceTokens.set(deviceId, body.token);
  return json({ ok: true, message: "device token registered", deviceId, warning: "In-memory store is non-persistent. Use KV/D1/Durable Objects for production." });
}

async function send(req: Request, deviceId: string): Promise<Response> {
  const token = deviceTokens.get(deviceId);
  if (!token) return json({ ok: false, error: `No token for deviceId '${deviceId}'. Register first via /register.` }, 404);
  const payload = await parsePayload(req);
  if (!payload.body) return json({ ok: false, error: "body is required" }, 400);

  const jwt = await createApnsJWT();
  const apsPayload = {
    aps: {
      alert: { title: payload.title ?? "brrr", subtitle: payload.subtitle, body: payload.body },
      sound: payload.sound ?? "default",
      badge: payload.badge ?? 1
    }
  };

  const base = USE_SANDBOX ? APNS_SANDBOX_URL : APNS_PRODUCTION_URL;
  const resp = await fetch(`${base}/3/device/${token}`, {
    method: "POST",
    headers: {
      authorization: `bearer ${jwt}`,
      "apns-topic": APNS_BUNDLE_ID,
      "apns-push-type": "alert",
      "apns-priority": "10",
      "content-type": "application/json"
    },
    body: JSON.stringify(apsPayload)
  });

  const text = await resp.text();
  return json({ ok: resp.ok, status: resp.status, apns: text || "sent", caveat: "Cloudflare Worker/APNs behavior depends on Apple credentials and platform support." }, resp.ok ? 200 : 502);
}

async function parsePayload(req: Request): Promise<Payload> {
  const ct = req.headers.get("content-type") || "";
  if (ct.includes("application/json")) return await req.json<Payload>();
  const raw = await req.text();
  return { title: "brrr", body: raw.trim() };
}

async function createApnsJWT(): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "ES256", kid: APNS_KEY_ID, typ: "JWT" };
  const payload = { iss: APNS_TEAM_ID, iat: now };
  const enc = (obj: unknown) => btoa(JSON.stringify(obj)).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
  const unsigned = `${enc(header)}.${enc(payload)}`;

  // TODO: Import P-256 key from APNS_PRIVATE_KEY. Keep constants inline by request (no ENVs).
  // Placeholder signature to keep template compileable; replace with real sign() for production deployments.
  const signature = btoa("TODO_SIGN_WITH_ES256").replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
  return `${unsigned}.${signature}`;
}
