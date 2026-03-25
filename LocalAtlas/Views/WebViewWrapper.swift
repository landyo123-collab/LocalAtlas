import SwiftUI
import WebKit

struct WebViewWrapper: NSViewRepresentable {
    @ObservedObject var tab: BrowserTab
    @ObservedObject var tabManager: TabManager
    let webViewStore: WebViewStore
    var onDidFinishNavigation: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(tab: tab, tabManager: tabManager, onDidFinishNavigation: onDidFinishNavigation)
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = webViewStore.webView(for: tab)
        webView.navigationDelegate = context.coordinator
        if webView.value(forKey: "estimatedProgress") == nil {
            // no need; will observe regardless
        }
        webView.addObserver(context.coordinator,
                            forKeyPath: "estimatedProgress",
                            options: .new,
                            context: nil)
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.navigationDelegate = context.coordinator
    }

    static func dismantleNSView(_ nsView: WKWebView, coordinator: Coordinator) {
        nsView.removeObserver(coordinator, forKeyPath: "estimatedProgress")
        nsView.navigationDelegate = nil
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var tab: BrowserTab
        let tabManager: TabManager
        let onDidFinishNavigation: (() -> Void)?

        init(tab: BrowserTab, tabManager: TabManager, onDidFinishNavigation: (() -> Void)?) {
            self.tab = tab
            self.tabManager = tabManager
            self.onDidFinishNavigation = onDidFinishNavigation
        }

        override func observeValue(forKeyPath keyPath: String?,
                                   of object: Any?,
                                   change: [NSKeyValueChangeKey : Any]?,
                                   context: UnsafeMutableRawPointer?) {
            guard keyPath == "estimatedProgress",
                  let webView = object as? WKWebView else { return }

            DispatchQueue.main.async {
                self.tab.progress = webView.estimatedProgress
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.tab.isLoading = true
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.tab.isLoading = false
                self.tab.title = webView.title?.isEmpty == false ? (webView.title ?? "") : "Untitled"
                if let url = webView.url?.absoluteString {
                    self.tab.urlString = url
                }
                self.tab.canGoBack = webView.canGoBack
                self.tab.canGoForward = webView.canGoForward
                self.onDidFinishNavigation?()
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.tab.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.tab.isLoading = false
            }
        }
    }
}
