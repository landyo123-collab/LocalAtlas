import Combine
import Foundation

@MainActor
final class TabManager: ObservableObject {
    @Published var tabs: [BrowserTab] = []
    @Published var selectedTabID: UUID

    init() {
        let first = BrowserTab(initialURL: "https://duckduckgo.com")
        self.tabs = [first]
        self.selectedTabID = first.id
    }

    var selectedTab: BrowserTab? {
        get { tabs.first(where: { $0.id == selectedTabID }) }
        set {
            guard let tab = newValue else { return }
            if let index = tabs.firstIndex(where: { $0.id == tab.id }) {
                tabs[index] = tab
            } else {
                tabs.append(tab)
            }
            selectedTabID = tab.id
        }
    }

    func newTab(initialURL: String = "https://duckduckgo.com") {
        let tab = BrowserTab(initialURL: initialURL)
        tabs.append(tab)
        selectedTabID = tab.id
    }

    func closeTab(id: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        tabs.remove(at: index)

        if tabs.isEmpty {
            let replacement = BrowserTab(initialURL: "https://duckduckgo.com")
            tabs = [replacement]
            selectedTabID = replacement.id
            return
        }

        if selectedTabID == id {
            let newIndex = min(index, tabs.count - 1)
            selectedTabID = tabs[newIndex].id
        }
    }

    func selectTab(id: UUID) {
        guard tabs.contains(where: { $0.id == id }) else { return }
        selectedTabID = id
    }

    func updateSelectedURL(_ url: String) {
        guard let tab = selectedTab else { return }
        tab.urlString = url
    }
}
