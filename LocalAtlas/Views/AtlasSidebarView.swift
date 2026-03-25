import SwiftUI
import WebKit

struct AtlasSidebarView: View {
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var settings: AtlasSettings
    @EnvironmentObject var webViewStore: WebViewStore
    @StateObject var vm = AtlasSidebarViewModel()

    @State private var chatInput: String = ""
    @State private var tagsInput: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Atlas")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AtlasTheme.textPrimary)

            Divider()

            if let tab = tabManager.selectedTab {
                let currentWebView = webViewStore.webView(for: tab)
                HStack {
                    Button("Extract Readable Text") {
                        Task { await vm.extractReadableText(from: tab, webView: currentWebView) }
                    }
                    .buttonStyle(AtlasPrimaryButtonStyle())
                    .disabled(vm.isWorking)

                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Button("Summarize page") {
                        Task { await vm.runAction(settings: settings, action: "summarize", tab: tab, allTabs: tabManager.tabs) }
                    }
                    .buttonStyle(AtlasSecondaryButtonStyle())

                    Button("Key claims + sources") {
                        Task { await vm.runAction(settings: settings, action: "claims", tab: tab, allTabs: tabManager.tabs) }
                    }
                    .buttonStyle(AtlasSecondaryButtonStyle())

                    Button("Make flashcards") {
                        Task { await vm.runAction(settings: settings, action: "flashcards", tab: tab, allTabs: tabManager.tabs) }
                    }
                    .buttonStyle(AtlasSecondaryButtonStyle())

                    Button("Compare tabs") {
                        Task { await vm.runAction(settings: settings, action: "compare", tab: tab, allTabs: tabManager.tabs) }
                    }
                    .buttonStyle(AtlasSecondaryButtonStyle())
                }
                .disabled(vm.isWorking)

                Divider()

                Text("Ask about this page")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AtlasTheme.textPrimary)

                HStack {
                    TextField("Type a question…", text: $chatInput)
                        .textFieldStyle(AtlasTextFieldStyle())

                    Button("Send") {
                        let msg = chatInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !msg.isEmpty else { return }
                        chatInput = ""
                        Task { await vm.runAction(settings: settings, action: "chat", tab: tab, allTabs: tabManager.tabs, userMessage: msg) }
                    }
                    .buttonStyle(AtlasPrimaryButtonStyle())
                    .disabled(vm.isWorking)
                }

                Divider()

                Text("Save current output as note")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AtlasTheme.textPrimary)

                TextField("Tags (comma separated)", text: $tagsInput)
                    .textFieldStyle(AtlasTextFieldStyle())

                Button("Save Note") {
                    let tags = tagsInput
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    let msg = vm.saveNoteFromCurrent(tab: tab, summary: vm.outputText, tags: tags)
                    vm.outputText = msg + "\n\n" + vm.outputText
                }
                .buttonStyle(AtlasPrimaryButtonStyle())

                Divider()

                ScrollView {
                    Text(vm.outputText.isEmpty ? "Output will appear here." : vm.outputText)
                        .font(.system(size: 12))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                Text("No tab selected.")
                    .foregroundColor(AtlasTheme.textSecondary)
            }

            Spacer()
        }
        .atlasPanel()
        .onDisappear {
            vm.persistConversation(vm.activeConversation)
        }
    }
}
