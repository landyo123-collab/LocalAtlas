import Foundation

struct AtlasAIRequest: Codable {
    var action: String
    var url: String
    var title: String
    var extractedText: String
    var openTabs: [String]
    var userMessage: String?
}

struct AtlasAIResponse: Codable {
    var text: String
}

@MainActor
final class AtlasAIClient {
    private func stub(action: String,
                      url: String,
                      title: String,
                      extractedText: String,
                      openTabs: [String],
                      userMessage: String?) -> String {

        let safeTitle = title.isEmpty ? "(untitled)" : title
        let safeMessage = userMessage ?? ""
        switch action {
        case "summarize":
            return "[LOCAL] STUB SUMMARY for \(safeTitle)\n\nURL: \(url)\n\nExtract length: \(extractedText.count) chars.\n\n(Enable Remote Backend in Settings to get real responses.)"
        case "claims":
            return "[LOCAL] STUB CLAIMS+SOURCES for \(safeTitle)\n\n• Claim: This is a placeholder.\n• Source: \(url)\n\n(Enable Remote Backend in Settings.)"
        case "flashcards":
            return "[LOCAL] STUB FLASHCARDS for \(safeTitle)\n\nQ: What is this page about?\nA: (stub)\n\nQ: Key term?\nA: (stub)"
        case "compare":
            return "[LOCAL] STUB COMPARE TABS\n\nOpen tabs:\n- " + openTabs.joined(separator: "\n- ")
        case "chat":
            return "[LOCAL] STUB CHAT\n\nYou said: \(safeMessage)\n\nContext title: \(safeTitle)\nExtract length: \(extractedText.count)"
        default:
            return "[LOCAL] STUB: Unknown action \(action)."
        }
    }

    func respond(settings: AtlasSettings,
                 action: String,
                 url: String,
                 title: String,
                 extractedText: String,
                 openTabs: [String],
                 userMessage: String?) async -> String {

        if !settings.useRemoteBackend {
            return stub(action: action,
                        url: url,
                        title: title,
                        extractedText: extractedText,
                        openTabs: openTabs,
                        userMessage: userMessage)
        }

        let base = settings.backendBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let endpoint = URL(string: base + "/atlas/respond") else {
            return "[PROXY] Remote backend URL is invalid."
        }

        let reqBody = AtlasAIRequest(action: action,
                                     url: url,
                                     title: title,
                                     extractedText: extractedText,
                                     openTabs: openTabs,
                                     userMessage: userMessage)

        do {
            var req = URLRequest(url: endpoint, timeoutInterval: 25)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONEncoder().encode(reqBody)

            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else {
                return "[PROXY] Remote backend error: no HTTP response."
            }
            if !(200..<300).contains(http.statusCode) {
                let raw = String(data: data, encoding: .utf8) ?? "(no body)"
                return "[PROXY] Remote backend error (HTTP \(http.statusCode)). Body:\n\(raw)"
            }
            let decoded = try JSONDecoder().decode(AtlasAIResponse.self, from: data)
            return decoded.text
        } catch {
            return "[PROXY] Remote backend request failed: \(error.localizedDescription)"
        }
    }
}
