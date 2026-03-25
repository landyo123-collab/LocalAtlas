import Combine
import Foundation

@MainActor
final class MemoryViewModel: ObservableObject {
    @Published var notes: [AtlasNote] = []
    @Published var search: String = ""

    private let store = JSONStore()

    func load() {
        do {
            let url = try AppPaths.notesFileURL()
            notes = store.load(from: url, defaultValue: [])
        } catch {
            notes = []
        }
    }

    var filteredNotes: [AtlasNote] {
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return notes }
        return notes.filter { n in
            n.title.lowercased().contains(q) ||
            n.url.lowercased().contains(q) ||
            n.summary.lowercased().contains(q) ||
            n.tags.joined(separator: " ").lowercased().contains(q)
        }
    }
}
