import Combine
import Foundation
import WebKit

@MainActor
final class WebViewStore: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    private var webViews: [UUID: WKWebView] = [:]

    func webView(for tab: BrowserTab) -> WKWebView {
        if let existing = webViews[tab.id] {
            return existing
        }
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        let webView = WKWebView(frame: .zero, configuration: config)
        if let url = URL(string: tab.urlString) {
            webView.load(URLRequest(url: url))
        }
        webViews[tab.id] = webView
        return webView
    }

    func remove(tabID: UUID) {
        guard let webView = webViews.removeValue(forKey: tabID) else { return }
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
}
