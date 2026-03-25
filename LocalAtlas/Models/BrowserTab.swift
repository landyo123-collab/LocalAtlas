import Combine
import Foundation

/// One browser tab stores its state and metadata.
final class BrowserTab: ObservableObject, Identifiable {
    let id = UUID()

    @Published var title: String = "New Tab"
    @Published var urlString: String
    @Published var progress: Double = 0
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    /// Cached readable extraction for sidebar actions.
    @Published var extractedTextCache: String = ""

    init(initialURL: String = "about:blank") {
        self.urlString = initialURL
    }
}
