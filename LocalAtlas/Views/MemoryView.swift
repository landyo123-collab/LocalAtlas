import SwiftUI

struct MemoryView: View {
    @StateObject var vm = MemoryViewModel()

    var body: some View {
        ZStack {
            AtlasCosmicBackground()
            VStack(alignment: .leading, spacing: 10) {
                Text("Memory")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AtlasTheme.textPrimary)

                HStack {
                    TextField("Search notes…", text: $vm.search)
                        .textFieldStyle(AtlasTextFieldStyle())
                    Button("Reload") {
                        vm.load()
                    }
                    .buttonStyle(AtlasSecondaryButtonStyle())
                }

                List(vm.filteredNotes) { note in
                    NavigationLink(destination: NoteDetailView(note: note)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title.isEmpty ? "(untitled)" : note.title)
                                .font(.system(size: 14, weight: .semibold))
                            Text(note.url)
                                .font(.system(size: 11))
                                .foregroundColor(AtlasTheme.textSecondary)
                            Text(note.summary.prefix(140) + (note.summary.count > 140 ? "…" : ""))
                                .font(.system(size: 12))
                                .foregroundColor(AtlasTheme.textSecondary)
                        }
                    }
                }
            }
            .atlasPanel()
            .padding(24)
        }
        .onAppear { vm.load() }
    }
}
