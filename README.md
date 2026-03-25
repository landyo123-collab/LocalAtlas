# Local Atlas

A local-first macOS SwiftUI application for browsing, reading, and noting from web pages with AI-assisted semantic actions.

**One-sentence pitch:** Extract, read, and annotate web content with offline-first architecture and optional local LLM integration.

---

## What it does

Local Atlas is a productivity tool that lets you:
- **Browse pages locally** — macOS native WebKit browser in a sidebar-driven interface
- **Extract readable text** — automatic text extraction optimized for reading
- **Take smart notes** — save passages with context-aware memory
- **Use AI actions** — optional Groq LLM integration via local proxy for semantic queries, summaries, and context analysis
- **Build memory** — persistent note database with search and retrieval

The app works completely offline for browsing, reading, and note-taking. AI features require a running local proxy server.

---

## Key Features

- **Offline-first architecture** — all core functionality works without network
- **Secure credential storage** — API keys stored in macOS Keychain, never in plaintext
- **Local LLM proxy** — included Node.js server bridges to Groq's OpenAI-compatible API
- **Sidebar-driven UI** — memory, settings, and server controls in collapsible panels
- **SwiftUI native** — macOS 13+ with native look and feel
- **No external dependencies** — uses only standard macOS frameworks (WebKit, Keychain, UserDefaults)

---

## Architecture

```
LocalAtlas/
├── LocalAtlas/                          # Main SwiftUI app
│   ├── LocalAtlasApp.swift             # App entry point
│   ├── Models/                         # Data structures (Note, Conversation, BrowserTab)
│   ├── Views/                          # SwiftUI views (Browser, Memory, Settings, Sidebar)
│   ├── ViewModels/                     # State management (MemoryViewModel, TabManager)
│   ├── Services/                       # Business logic (LocalServerManager, KeychainStore, etc.)
│   ├── UI/                             # Theming and styles (AtlasTheme, AtlasCosmicBackground)
│   └── Assets.xcassets                 # Icons, colors, images
├── LocalAtlas.xcodeproj                # Xcode project configuration
└── proxy/                              # Node.js Groq proxy server
    ├── src/                            # Proxy source (Express server)
    ├── package.json                    # Node dependencies
    └── README.md                        # Proxy documentation
```

**Key services:**
- **LocalServerManager** — manages local proxy process lifecycle
- **KeychainStore** — secure credential storage
- **AtlasAIClient** — communicates with proxy server for LLM calls
- **JSONStore** — persistent note and conversation storage

---

## How to Run

### macOS App

1. **Clone and open in Xcode:**
   ```bash
   git clone https://github.com/landyo123-collab/LocalAtlas.git
   cd LocalAtlas
   open LocalAtlas.xcodeproj
   ```

2. **Build and run:**
   - Select the **LocalAtlas** scheme
   - Press ⌘R to build and run
   - Xcode will launch the app on macOS 13+

3. **Configure:**
   - Open **Settings** (⌘,) in the app
   - Enter your **Backend Base URL** and **API Key** (optional, only for remote backends)
   - Configure **Search Engine Base URL** (e.g., DuckDuckGo)

### Groq Proxy Server

The proxy is optional but required for AI features.

1. **Install dependencies:**
   ```bash
   cd proxy
   npm install
   ```

2. **Set up environment:**
   ```bash
   cp .env.example .env
   # Edit .env and add your Groq API key
   # GROQ_API_KEY=your_key_here
   ```

3. **Start the server:**
   ```bash
   npm start
   ```
   The server listens on `http://127.0.0.1:4000`

4. **From the app:**
   - Go to Settings → Local Servers → Groq Proxy
   - Click **Start**
   - Verify status shows "Running" (green)

---

## Configuration

### App Settings

| Setting | Default | Purpose |
|---------|---------|---------|
| Use Remote Backend | OFF | Toggle between local-only and remote backend mode |
| Backend Base URL | (empty) | REST API endpoint for custom backends |
| API Key | (Keychain) | Credentials for backend, stored securely |
| Search Engine Base URL | (empty) | Custom search engine integration |

All settings are persisted in UserDefaults.

### Proxy Configuration

The proxy reads from `.env`:
```bash
GROQ_API_KEY=gsk_...          # Required: Groq API key
PORT=4000                      # Optional: server port (default 4000)
NODE_ENV=production            # Optional: environment
```

---

## Current Status & Limitations

### What works:
- ✅ Web browsing and tab management
- ✅ Text extraction from pages
- ✅ Note-taking and memory storage
- ✅ Settings UI and local server control
- ✅ Keychain-based credential storage
- ✅ Groq proxy integration (when running)

### Limitations:
- The app currently lacks advanced retrieval ranking and semantic search
- No full-text indexing or embedding support (designed for local-first but not implemented)
- Proxy server is minimal — no caching, rate limiting, or error recovery
- No dark mode (uses light theme only)
- Minimal test coverage

---

## Why Local-First Matters

Local Atlas demonstrates a pragmatic approach to AI integration:
- **No cloud lock-in** — your notes and browsing stay on your machine
- **Privacy-first** — only explicit API calls leave your computer
- **Works offline** — reading and note-taking don't require internet
- **Faster iteration** — local proxy avoids cloud latency
- **Auditable** — you control what data is sent where

This is a real local-first developer tool, not a toy browser wrapper.

---

## Secrets & Security

- **API keys** are stored in macOS Keychain, never in source code or config files
- **No hardcoded credentials** anywhere in the repository
- The proxy accepts only localhost requests (CORS limited to 127.0.0.1)
- `.env` files are `.gitignore`'d and should never be committed

---

## Development

### Building from source

```bash
xcode-select --install  # Install Xcode command-line tools
open LocalAtlas.xcodeproj
```

### Project structure

- **Xcode 15+** with Swift 5.9+
- **Target OS:** macOS 13.0+
- **No external Swift packages** — only system frameworks
- **Configuration via XcodeGen** (optional)

---

## Screenshots

*Coming soon — add real app screenshots here*

---

## License

MIT License — See LICENSE file for details.

---

## Future Ideas

- Semantic search over saved notes
- Multi-tab context awareness
- Custom prompt templates
- Offline embedding support
- macOS app sandbox hardening
- SwiftData migration (from JSON storage)
- End-to-end encrypted sync

---

## Feedback & Contributions

This is a portfolio project. Feel free to fork and adapt for your own use.
