import SwiftUI

struct NoteDetailView: View {
    let note: AtlasNote

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(note.title.isEmpty ? "(untitled)" : note.title)
                .font(.system(size: 18, weight: .bold))

            Text(note.url)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .textSelection(.enabled)

            if !note.tags.isEmpty {
                Text("Tags: " + note.tags.joined(separator: ", "))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Divider()

            ScrollView {
                Text(note.summary)
                    .textSelection(.enabled)
                    .font(.system(size: 13))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()
        }
        .padding(12)
    }
}
