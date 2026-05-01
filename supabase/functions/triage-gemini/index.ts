/**
 * Supabase Edge Function: triage-gemini
 *
 * Server-side Gemini triage so mobile clients never hold Gemini API keys.
 *
 * Requires Supabase secret:
 * - GEMINI_API_KEY
 *
 * Invoke from Flutter (anon session ok):
 *   Supabase.instance.client.functions.invoke('triage-gemini', body: {...})
 */
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

type ReqBody = {
  schema?: string;
  transcript?: string;
  location?: string;
  severity_hint?: number;
  language_code?: string;
};

function json(status: number, body: unknown) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json; charset=utf-8" },
  });
}

function buildPrompt(input: {
  transcript: string;
  location: string;
  severityHint: number;
  languageCode: string;
}) {
  const langHint =
    input.languageCode === "en"
      ? "User may write in English or Indian languages (Hindi, Tamil, etc.)."
      : `Prefer reasoning and JSON field values appropriate for language code: ${input.languageCode}. User text may be mixed English and regional languages.`;

  return `You are an emergency triage assistant for RoadSOS (road crashes).
Respond with ONLY valid JSON (no markdown), one object:
{
  "severity_level": <int 1-5>,
  "required_services": <array of strings from: ambulance, police, fire_department, rescue, towing, puncture_shop, showroom>,
  "first_aid_focus": <short string for first-aid lookup>,
  "thinking_summary": <one sentence reasoning>
}
Rules: If unsure, bias toward higher severity. GPS: ${input.location}. Accelerometer hint (1-5): ${input.severityHint}.
${langHint}
User situation text: "${input.transcript}"`;
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

function extractFirstJsonObject(raw: string): Record<string, unknown> {
  let text = (raw ?? "").trim();
  if (!text) throw new Error("empty_model_output");

  if (text.startsWith("```")) {
    const firstNl = text.indexOf("\n");
    if (firstNl >= 0) text = text.substring(firstNl + 1);
    const fenceEnd = text.lastIndexOf("```");
    if (fenceEnd >= 0) text = text.substring(0, fenceEnd);
    text = text.trim();
  }

  if (text.startsWith("{") && text.endsWith("}")) {
    const decoded = JSON.parse(text);
    if (decoded && typeof decoded === "object" && !Array.isArray(decoded)) {
      return decoded as Record<string, unknown>;
    }
  }

  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start < 0 || end <= start) throw new Error("no_json_object");
  const snippet = text.substring(start, end + 1);
  const decoded = JSON.parse(snippet);
  if (!decoded || typeof decoded !== "object" || Array.isArray(decoded)) {
    throw new Error("json_not_object");
  }
  return decoded as Record<string, unknown>;
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

  const transcript = String(body.transcript ?? "").slice(0, 1400);
  const location = String(body.location ?? "");
  const severityHint = Number.isFinite(body.severity_hint as number)
    ? Math.max(1, Math.min(5, Number(body.severity_hint)))
    : 3;
  const languageCode = String(body.language_code ?? "en").slice(0, 8);

  const prompt = buildPrompt({ transcript, location, severityHint, languageCode });

  const uri = new URL("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent");
  uri.searchParams.set("key", apiKey);

  const geminiReq = {
    contents: [{ parts: [{ text: prompt }] }],
    generationConfig: { temperature: 0.2, maxOutputTokens: 512 },
  };

  let geminiJson: Record<string, unknown>;
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
    geminiJson = JSON.parse(text) as Record<string, unknown>;
  } catch (e) {
    return json(502, { error: "gemini_fetch_failed", detail: String(e) });
  }

  try {
    const rawText = extractGeminiText(geminiJson);
    const payload = extractFirstJsonObject(rawText);
    return json(200, payload);
  } catch (e) {
    return json(502, { error: "gemini_parse_failed", detail: String(e) });
  }
});

