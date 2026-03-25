import SwiftUI
import AppKit

struct SettingsView: View {
    @EnvironmentObject var settings: AtlasSettings
    @EnvironmentObject var serverManager: LocalServerManager
    @State private var apiKeyDraft: String = ""
    @State private var proxyPath: String = ""

    private let keychain = KeychainStore()

    var body: some View {
        ZStack {
            AtlasCosmicBackground()
            VStack(alignment: .leading, spacing: 12) {
                Text("Settings")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AtlasTheme.textPrimary)

                Toggle("Use Remote Backend", isOn: $settings.useRemoteBackend)
                    .toggleStyle(.switch)

                GroupBox(label: Text("Backend")) {
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Backend Base URL", text: $settings.backendBaseURL)
                            .textFieldStyle(AtlasTextFieldStyle())

                        HStack {
                            SecureField("API Key (stored in Keychain)", text: $apiKeyDraft)
                                .textFieldStyle(AtlasTextFieldStyle())

                            Button("Save Key") {
                                do {
                                    try keychain.setString(apiKeyDraft, account: "backend_api_key")
                                    apiKeyDraft = ""
                                } catch {
                                }
                            }
                            .buttonStyle(AtlasPrimaryButtonStyle())
                        }
                    }
                    .padding(6)
                }

                GroupBox(label: Text("Search")) {
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Search Engine Base URL", text: $settings.searchEngineBaseURL)
                            .textFieldStyle(AtlasTextFieldStyle())
                        Text("Example: https://duckduckgo.com/?q=")
                            .font(.system(size: 11))
                            .foregroundColor(AtlasTheme.textSecondary)
                    }
                    .padding(6)
                }

                Divider()

                Text("Local Servers")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AtlasTheme.textPrimary)

                serverRow(
                    title: "Groq Proxy",
                    running: serverManager.proxyRunning,
                    status: serverManager.proxyStatusMessage,
                    openURL: URL(string: "http://127.0.0.1:4000/health")!,
                    startAction: { serverManager.startProxy() },
                    stopAction: { serverManager.stopProxy() },
                    pathBinding: $proxyPath,
                    applyPath: { serverManager.updateProxyWorkdir($0) }
                )

                Spacer()
            }
            .atlasPanel()
            .padding(24)
            .onAppear {
                apiKeyDraft = ""
                proxyPath = serverManager.proxyWorkdir()
            }
        }
    }

    @ViewBuilder
    private func serverRow(title: String,
                           running: Bool,
                           status: String,
                           openURL: URL,
                           startAction: @escaping () -> Void,
                           stopAction: @escaping () -> Void,
                           pathBinding: Binding<String>,
                           applyPath: @escaping (String) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AtlasTheme.textPrimary)
                Spacer()
                Text(status)
                    .font(.system(size: 12))
                    .foregroundColor(running ? .green : AtlasTheme.textSecondary)
            }

            HStack(spacing: 8) {
                Button(running ? "Stop" : "Start") {
                    if running { stopAction() } else { startAction() }
                }
                .buttonStyle(AtlasSecondaryButtonStyle())

                Button("Open") {
                    NSWorkspace.shared.open(openURL)
                }
                .buttonStyle(AtlasSecondaryButtonStyle())
            }

            TextField("Workdir", text: pathBinding, onCommit: { applyPath(pathBinding.wrappedValue) })
                .textFieldStyle(AtlasTextFieldStyle())
        }
        .padding(.vertical, 4)
    }
}
