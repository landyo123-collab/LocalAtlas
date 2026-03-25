import Foundation
import Combine

struct ManagedLocalServer {
    let id: String
    let label: String
    let defaultPath: String
    let healthURL: URL
    let workdirKey: String
}

@MainActor
final class LocalServerManager: ObservableObject {
    @Published var proxyRunning = false
    @Published var proxyStatusMessage = "Stopped"

    private var proxyProcess: Process?
    private var healthTask: Task<Void, Never>?

    private let proxyServer = ManagedLocalServer(
        id: "proxy",
        label: "Groq Proxy",
        defaultPath: "./proxy",
        healthURL: URL(string: "http://127.0.0.1:4000/health")!,
        workdirKey: "localServer.proxy.workdir"
    )

    init() {
        healthTask = Task { await monitorHealth() }
    }

    func startProxy() {
        launch(server: proxyServer) { [weak self] running in
            self?.proxyRunning = running
            self?.proxyStatusMessage = running ? "Running" : "Stopped"
        }
    }

    func stopProxy() {
        terminate(server: proxyServer) { [weak self] running in
            self?.proxyRunning = running
            self?.proxyStatusMessage = running ? "Stopping" : "Stopped"
        }
    }

    private func launch(server: ManagedLocalServer, update: @escaping (Bool) -> Void) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["node", "src/server.js"]
        let serverWorkdir = proxyWorkdir()
        process.currentDirectoryURL = URL(fileURLWithPath: serverWorkdir)

        let pipe = Pipe()
        process.standardError = pipe
        process.standardOutput = pipe

        do {
            try process.run()
            update(true)
            proxyProcess = process
        } catch {
            update(false)
        }
    }

    private func terminate(server: ManagedLocalServer, update: @escaping (Bool) -> Void) {
        proxyProcess?.terminate()
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            if self?.proxyProcess?.isRunning == true {
                self?.proxyProcess?.interrupt()
            }
            Task { @MainActor in
                update(false)
            }
        }
    }

    func proxyWorkdir() -> String {
        UserDefaults.standard.string(forKey: proxyServer.workdirKey) ?? proxyServer.defaultPath
    }

    func updateProxyWorkdir(_ value: String) {
        UserDefaults.standard.setValue(value, forKey: proxyServer.workdirKey)
    }

    private func monitorHealth() async {
        while !Task.isCancelled {
            await ping(proxyServer, assign: { [weak self] alive in
                self?.proxyRunning = alive
                self?.proxyStatusMessage = alive ? "Running" : "Stopped"
            })
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }
    }

    private func ping(_ server: ManagedLocalServer, assign: @escaping (Bool) -> Void) async {
        var request = URLRequest(url: server.healthURL)
        request.timeoutInterval = 1.5
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any], dict["ok"] as? Bool == true {
                    assign(true)
                    return
                }
            }
        } catch {
            // ignore
        }
        assign(false)
    }
}
