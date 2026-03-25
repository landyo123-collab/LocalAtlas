import Combine
import Foundation

@MainActor
final class AtlasSettings: ObservableObject {
    @Published var useRemoteBackend: Bool {
        didSet { UserDefaults.standard.set(useRemoteBackend, forKey: Keys.useRemoteBackend) }
    }

    @Published var backendBaseURL: String {
        didSet { UserDefaults.standard.set(backendBaseURL, forKey: Keys.backendBaseURL) }
    }

    @Published var searchEngineBaseURL: String {
        didSet { UserDefaults.standard.set(searchEngineBaseURL, forKey: Keys.searchEngineBaseURL) }
    }

    private enum Keys {
        static let useRemoteBackend = "useRemoteBackend"
        static let backendBaseURL = "backendBaseURL"
        static let searchEngineBaseURL = "searchEngineBaseURL"
    }

    init() {
        self.useRemoteBackend = UserDefaults.standard.bool(forKey: Keys.useRemoteBackend)
        self.backendBaseURL = UserDefaults.standard.string(forKey: Keys.backendBaseURL) ?? "http://localhost:3000"
        self.searchEngineBaseURL = UserDefaults.standard.string(forKey: Keys.searchEngineBaseURL) ?? Constants.defaultSearchEngineBase
    }
}
