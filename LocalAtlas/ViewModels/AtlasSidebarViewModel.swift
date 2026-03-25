import Combine
import Foundation
import WebKit

@MainActor
final class AtlasSidebarViewModel: ObservableObject {
    @Published var extractedText: String = ""
    @Published var outputText: String = ""
    @Published var isWorking: Bool = false

    @Published var activeConversation: AtlasConversation = AtlasConversation(title: "This Page")

    private let aiClient = AtlasAIClient()
    private let store = JSONStore()

    func extractReadableText(from tab: BrowserTab, webView: WKWebView?) async {
        guard let webView else {
            outputText = "Unable to access browser content."
            return
        }

        isWorking = true
        defer { isWorking = false }

        let js = """
        (function() {
          function textOf(node) {
            if (!node) return "";
            return node.innerText || node.textContent || "";
          }
          var t = textOf(document.body);
          t = t.replace(/\\s+/g, ' ').trim();
          return t;
        })();
        """

        do {
            let result = try await webView.evaluateJavaScript(js)
            if let s = result as? String {
                extractedText = s
                tab.extractedTextCache = s
                outputText = "Extracted \(s.count) characters."
            } else {
                outputText = "Failed to extract text."
            }
        } catch {
            outputText = "JS extraction error: \(error.localizedDescription)"
        }
    }

    func runAction(settings: AtlasSettings, action: String, tab: BrowserTab, allTabs: [BrowserTab], userMessage: String? = nil) async {
        isWorking = true
        defer { isWorking = false }

        let url = tab.urlString
        let title = tab.title
        let extract = tab.extractedTextCache
        let openTitles = allTabs.map { $0.title.isEmpty ? "New Tab" : $0.title }

        let response = await aiClient.respond(settings: settings,
                                             action: action,
                                             url: url,
                                             title: title,
                                             extractedText: extract,
                                             openTabs: openTitles,
                                             userMessage: userMessage)

        outputText = response

        if action == "chat", let msg = userMessage, !msg.isEmpty {
            activeConversation.messages.append(ChatMessage(role: .user, text: msg))
            activeConversation.messages.append(ChatMessage(role: .assistant, text: response))
        } else {
            activeConversation.messages.append(ChatMessage(role: .assistant, text: response))
        }
    }

    func saveNoteFromCurrent(tab: BrowserTab, summary: String, tags: [String]) -> String {
        do {
            let url = tab.urlString
            let title = tab.title
            let note = AtlasNote(url: url, title: title, summary: summary, tags: tags)

            let fileURL = try AppPaths.notesFileURL()
            var notes: [AtlasNote] = store.load(from: fileURL, defaultValue: [])
            notes.insert(note, at: 0)
            try store.save(notes, to: fileURL)
            return "Saved note."
        } catch {
            return "Save note failed: \(error.localizedDescription)"
        }
    }

    func loadConversations() -> [AtlasConversation] {
        do {
            let url = try AppPaths.conversationsFileURL()
            return store.load(from: url, defaultValue: [])
        } catch {
            return []
        }
    }

    func persistConversation(_ convo: AtlasConversation) {
        do {
            let url = try AppPaths.conversationsFileURL()
            var convos: [AtlasConversation] = store.load(from: url, defaultValue: [])
            if let idx = convos.firstIndex(where: { $0.id == convo.id }) {
                convos[idx] = convo
            } else {
                convos.insert(convo, at: 0)
            }
            try store.save(convos, to: url)
        } catch {
            // best-effort
        }
    }
}
