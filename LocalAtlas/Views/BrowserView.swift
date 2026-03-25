import SwiftUI
import WebKit

struct BrowserView: View {
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var settings: AtlasSettings

    @StateObject private var webViewStore = WebViewStore()
    @State private var addressInput: String = ""
    @State private var showSidebar: Bool = true
    @State private var showSettings: Bool = false
    @State private var showMemory: Bool = false

    private var selectedTab: BrowserTab? {
        tabManager.selectedTab
    }

    private var selectedWebView: WKWebView? {
        guard let tab = selectedTab else { return nil }
        return webViewStore.webView(for: tab)
    }

    var body: some View {
        ZStack {
            AtlasCosmicBackground()
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    TabBarView(onClose: { id in
                        webViewStore.remove(tabID: id)
                        tabManager.closeTab(id: id)
                    })

                    Spacer()

                    Button {
                        showMemory = true
                    } label: {
                        Image(systemName: "tray.full")
                    }
                    .buttonStyle(AtlasPrimaryButtonStyle())
                    .help("Memory")

                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .buttonStyle(AtlasPrimaryButtonStyle())
                    .help("Settings")

                    Button {
                        showSidebar.toggle()
                    } label: {
                        Image(systemName: showSidebar ? "sidebar.right" : "sidebar.right")
                    }
                    .buttonStyle(AtlasSecondaryButtonStyle())
                    .help("Toggle Atlas Sidebar")
                }
                .padding([.horizontal, .top], 10)

                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack(spacing: 8) {
                            Button(action: { selectedWebView?.goBack() }) {
                                Image(systemName: "chevron.left")
                            }
                            .buttonStyle(AtlasSecondaryButtonStyle())
                            .disabled(!(selectedTab?.canGoBack ?? false))

                            Button(action: { selectedWebView?.goForward() }) {
                                Image(systemName: "chevron.right")
                            }
                            .buttonStyle(AtlasSecondaryButtonStyle())
                            .disabled(!(selectedTab?.canGoForward ?? false))

                            Button {
                                guard let tab = selectedTab else { return }
                                if tab.isLoading {
                                    selectedWebView?.stopLoading()
                                } else {
                                    selectedWebView?.reload()
                                }
                            } label: {
                                Image(systemName: (selectedTab?.isLoading ?? false) ? "xmark" : "arrow.clockwise")
                            }
                            .buttonStyle(AtlasSecondaryButtonStyle())

                            TextField("Enter URL or search", text: $addressInput)
                                .textFieldStyle(AtlasTextFieldStyle())
                                .onSubmit { load(addressInput) }

                            if let tab = selectedTab {
                                Text(tab.title)
                                    .lineLimit(1)
                                    .font(.system(size: 12))
                                    .foregroundColor(AtlasTheme.textSecondary)
                            }
                        }
                        .padding(8)

                        if let tab = selectedTab {
                            ProgressView(value: tab.progress)
                                .progressViewStyle(.linear)
                                .opacity(tab.isLoading ? 1 : 0)
                                .frame(height: 2)
                                .padding(.horizontal, 8)

                            WebViewWrapper(tab: tab,
                                           tabManager: tabManager,
                                           webViewStore: webViewStore) {
                                addressInput = tab.urlString
                            }
                            .id(tab.id)
                        } else {
                            Text("No tab selected")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .atlasPanel()
                    .padding(.horizontal, 12)

                    if showSidebar {
                        Divider()
                        AtlasSidebarView()
                            .environmentObject(webViewStore)
                            .frame(minWidth: 340, idealWidth: 380, maxWidth: 460)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            if let tab = selectedTab {
                addressInput = tab.urlString
            }
        }
        .onChange(of: tabManager.selectedTabID) { _ in
            addressInput = tabManager.selectedTab?.urlString ?? ""
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(settings)
        }
        .sheet(isPresented: $showMemory) {
            NavigationView {
                MemoryView()
            }
        }
    }

    private func load(_ raw: String) {
        guard let tab = selectedTab else { return }

        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        if !text.contains("://") {
            if text.contains(" ") || !text.contains(".") {
                let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                text = settings.searchEngineBaseURL + encoded
            } else {
                text = "http://\(text)"
            }
        }

        guard let url = URL(string: text) else { return }
        selectedWebView?.load(URLRequest(url: url))
        tabManager.updateSelectedURL(text)
        addressInput = text
    }
}
