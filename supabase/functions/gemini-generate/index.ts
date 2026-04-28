/**
 * Supabase Edge Function: gemini-generate
 *
 * Small server-side Gemini proxy for non-triage text (telemetry summaries, witness questions).
 * Clients never hold Gemini keys.
 *
 * Secret required:
 * - GEMINI_API_KEY
 */
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

type ReqBody = {
  prompt?: string;
  model?: string;
  temperature?: number;
  max_output_tokens?: number;
};

function json(status: number, body: unknown) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json; charset=utf-8" },
  });
}

function extractGeminiText(decoded: Record<string, unknown>): string {
  const candidates = decoded["candidates"];
  if (!Array.isArray(candidates) || candidates.length === 0) return "";
  const first = candidates[0] as Record<string, unknown>;
  const content = first?.["content"] as Record<string, unknown> | undefined;
  const parts = content?.["parts"] as unknown[] | undefined;
  if (!Array.isArray(parts)) return "";
  let out = "";
  for (const p of parts) {
    if (p && typeof p === "object" && typeof (p as any)["text"] === "string") {
      out += String((p as any)["text"]);
    }
  }
  return out;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return json(405, { error: "method_not_allowed" });
  }

  const apiKey = Deno.env.get("GEMINI_API_KEY")?.trim();
  if (!apiKey) {
    return json(500, { error: "server_misconfigured", detail: "Missing GEMINI_API_KEY" });
  }

  let body: ReqBody;
  try {
    body = (await req.json()) as ReqBody;
  } catch {
    return json(400, { error: "invalid_json" });
  }

  const prompt = String(body.prompt ?? "").slice(0, 6000);
  if (!prompt) return json(400, { error: "missing_prompt" });

  const model = String(body.model ?? "gemini-2.0-flash").trim() || "gemini-2.0-flash";
  const temperature = typeof body.temperature === "number" ? body.temperature : 0.3;
  const maxOutputTokens =
    typeof body.max_output_tokens === "number" ? body.max_output_tokens : 256;

  const uri = new URL(`https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`);
  uri.searchParams.set("key", apiKey);

  const geminiReq = {
    contents: [{ parts: [{ text: prompt }] }],
    generationConfig: { temperature, maxOutputTokens },
  };

  try {
    const res = await fetch(uri.toString(), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(geminiReq),
    });
    const text = await res.text();
    if (!res.ok) {
      return json(502, { error: "gemini_http_error", status: res.status, body: text.slice(0, 1000) });
    }
    const decoded = JSON.parse(text) as Record<string, unknown>;
    const out = extractGeminiText(decoded).trim();
    return json(200, { text: out });
  } catch (e) {
    return json(502, { error: "gemini_fetch_failed", detail: String(e) });
  }
});

