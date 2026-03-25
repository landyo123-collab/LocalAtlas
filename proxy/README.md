# LocalAtlas Groq Proxy

This simple proxy exposes `/atlas/respond` for LocalAtlas and forwards requests to Groq's OpenAI-compatible chat endpoint.

## Setup

1. Copy `.env.example` to `.env` and add your Groq API key:
   ```bash
   cp .env.example .env
   # edit .env and set GROQ_API_KEY
   ```
2. Install dependencies:
   ```bash
   npm install
   ```

## Running

```bash
npm start
```

The server listens on `PORT` (default 4000). It exposes:

- `GET /health` → `{ ok: true }`
- `POST /atlas/respond` → forwards to Groq chat completions with `llama-3.1-8b-instant` and returns `{ text }`

All requests are limited to localhost (CORS) and truncated for safety.
