import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import crypto from "crypto";

const envPath = new URL("../.env", import.meta.url).pathname;
dotenv.config({ path: envPath });

const app = express();
const PORT = Number(process.env.PORT || 4000);

const GROQ_MODEL = (process.env.GROQ_MODEL || "llama-3.1-8b-instant").trim();
const GROQ_TEMPERATURE = Number(process.env.GROQ_TEMPERATURE || 0.4);
const GROQ_MAX_TOKENS = Number(process.env.GROQ_MAX_TOKENS || 700);

function keyFingerprint(key) {
  if (!key) return { present: false };
  const raw = String(key);
  const trimmed = raw.trim();
  const hash = crypto.createHash("sha256").update(trimmed, "utf8").digest("hex");
  return {
    present: true,
    rawLength: raw.length,
    trimmedLength: trimmed.length,
    startsWith: trimmed.slice(0, 6),
    endsWith: trimmed.slice(-4),
    sha256: hash,
    hasQuotes:
      (trimmed.startsWith('"') && trimmed.endsWith('"')) ||
      (trimmed.startsWith("'") && trimmed.endsWith("'")),
  };
}

function keyDiagnostics() {
  return keyFingerprint(process.env.GROQ_API_KEY || "");
}

function truncateText(s, maxChars) {
  if (!s) return "";
  if (s.length <= maxChars) return s;
  return s.slice(0, maxChars) + `\n\n[TRUNCATED to ${maxChars} chars]`;
}

function buildSystemPrompt(action) {
  switch (action) {
    case "summarize":
      return "Summarize the page concisely, then give 5 bullet points of key takeaways.";
    case "claims":
      return "List key claims from the provided text. For each claim, include a 'Source:' line citing the provided URL (no browsing).";
    case "flashcards":
      return "Create 6 flashcards (Q/A) that teach the page content. Keep answers short.";
    case "compare":
      return "Compare the open tab titles. Infer only from titles and provided context. Do not browse.";
    case "chat":
      return "Answer the user's question using ONLY the provided page context. If missing, say what's missing.";
    default:
      return "Be helpful and concise.";
  }
}

function getTrimmedKey() {
  return String(process.env.GROQ_API_KEY || "").trim();
}

async function callGroqChat(payload, requestLabel) {
  const trimmedKey = getTrimmedKey();
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 25000);

  console.log(`[${requestLabel}] Using key length=${trimmedKey.length} prefix=${trimmedKey.slice(0, 6)} suffix=${trimmedKey.slice(-4)} sha256=${keyFingerprint(trimmedKey).sha256}`);

  const resp = await fetch("https://api.groq.com/openai/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${trimmedKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
    signal: controller.signal,
  }).finally(() => clearTimeout(timeout));

  const raw = await resp.text();
  if (!resp.ok) {
    console.error(`[${requestLabel}] Groq upstream error:`, resp.status, raw);
    return { ok: false, status: resp.status, raw };
  }
  return { ok: true, status: resp.status, raw };
}

app.use(express.json({ limit: "1mb" }));
app.use(
  cors({
    origin(origin, cb) {
      if (!origin) return cb(null, true);
      const ok =
        origin.startsWith("http://localhost") || origin.startsWith("http://127.0.0.1");
      return ok ? cb(null, true) : cb(new Error("CORS blocked"), false);
    },
  })
);

app.get("/health", (_req, res) => res.json({ ok: true }));

app.get("/debug/env", (_req, res) => {
  const fp = keyDiagnostics();
  res.json({
    ok: true,
    port: PORT,
    model: GROQ_MODEL,
    temperature: GROQ_TEMPERATURE,
    maxTokens: GROQ_MAX_TOKENS,
    keyFingerprint: fp,
  });
});

app.get("/debug/config", (_req, res) => {
  const fp = keyDiagnostics();
  res.json({
    ok: true,
    model: GROQ_MODEL,
    temperature: GROQ_TEMPERATURE,
    maxTokens: GROQ_MAX_TOKENS,
    keyFingerprint: fp,
  });
});

app.get("/debug/ping_groq", async (_req, res) => {
  if (!getTrimmedKey()) {
    return res.status(500).json({ ok: false, error: "Missing GROQ_API_KEY" });
  }

  const payload = {
    model: "llama-3.1-8b-instant",
    messages: [{ role: "user", content: "Reply with the word: ping" }],
    temperature: 0,
    max_tokens: 10,
  };

  const r = await callGroqChat(payload, "ping_groq");
  if (!r.ok) {
    return res.status(502).json({
      ok: false,
      upstreamStatus: r.status,
      upstreamBody: r.raw,
      keyDiag: keyDiagnostics(),
    });
  }

  try {
    const data = JSON.parse(r.raw);
    const text = data?.choices?.[0]?.message?.content ?? "";
    return res.json({ ok: true, text });
  } catch {
    return res.status(502).json({ ok: false, error: "Non-JSON response from Groq", raw: r.raw });
  }
});

app.get("/debug/echo_key_fp", (_req, res) => {
  res.json({ ok: true, keyFingerprint: keyDiagnostics() });
});

app.post("/atlas/respond", async (req, res) => {
  const reqID = `req_${Date.now()}_${Math.random().toString(16).slice(2)}`;
  try {
    const trimmedKey = getTrimmedKey();
    const fp = keyFingerprint(trimmedKey);
    if (!fp.present || fp.trimmedLength < 20) {
      return res.status(500).json({
        text: "Proxy misconfigured: GROQ_API_KEY missing/too short. Put it in .env and restart.",
      });
    }

    const {
      action,
      url = "",
      title = "",
      extractedText = "",
      openTabs = [],
      userMessage = null,
    } = req.body || {};

    const safeAction = typeof action === "string" ? action : "chat";
    const safeURL = String(url || "");
    const safeTitle = String(title || "");
    const safeTabs = Array.isArray(openTabs) ? openTabs.map(String).slice(0, 30) : [];
    const safeUserMsg = userMessage == null ? "" : String(userMessage);

    const contextText = truncateText(String(extractedText || ""), 20000);

    const messages = [
      { role: "system", content: buildSystemPrompt(safeAction) },
      {
        role: "user",
        content:
          `URL: ${safeURL}\n` +
          `TITLE: ${safeTitle}\n` +
          `OPEN_TABS: ${safeTabs.join(" | ")}\n\n` +
          `PAGE_TEXT:\n${contextText}\n\n` +
          (safeAction === "chat" ? `USER_QUESTION:\n${safeUserMsg}\n` : ""),
      },
    ];

    const payload = {
      model: GROQ_MODEL,
      messages,
      temperature: Number.isFinite(GROQ_TEMPERATURE) ? GROQ_TEMPERATURE : 0.4,
      max_tokens: Number.isFinite(GROQ_MAX_TOKENS) ? GROQ_MAX_TOKENS : 700,
    };

    console.log(`[${reqID}] action=${safeAction} url=${safeURL}`);

    const r = await callGroqChat(payload, reqID);
    if (!r.ok) {
      return res.status(502).json({
        text: `Groq upstream error (HTTP ${r.status}).\n${r.raw}`,
      });
    }

    let data;
    try {
      data = JSON.parse(r.raw);
    } catch {
      return res.status(502).json({ text: "Groq returned non-JSON response." });
    }

    const text = data?.choices?.[0]?.message?.content ?? data?.choices?.[0]?.text ?? "";
    return res.json({ text: text || "(empty response)" });
  } catch (err) {
    const msg =
      err?.name === "AbortError"
        ? "Request timed out contacting Groq."
        : (err?.message || String(err));
    console.error(`[${reqID}] Proxy error:`, msg);
    return res.status(502).json({ text: `Proxy error: ${msg}` });
  }
});

app.listen(PORT, () => {
  console.log(`LocalAtlas Groq proxy listening on http://localhost:${PORT}`);
  console.log("Key fingerprint:", keyDiagnostics());
});
