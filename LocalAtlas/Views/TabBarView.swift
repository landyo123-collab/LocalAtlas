import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var tabManager: TabManager
    var onClose: ((UUID) -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tabManager.tabs) { tab in
                    HStack(spacing: 6) {
                        Text(tab.title.isEmpty ? "New Tab" : tab.title)
                            .lineLimit(1)
                            .font(.system(size: 12, weight: .medium))

                        Button {
                            onClose?(tab.id)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 8)
                    .background(tabManager.selectedTabID == tab.id ? Color.gray.opacity(0.25) : Color.clear)
                    .cornerRadius(6)
                    .onTapGesture {
                        tabManager.selectTab(id: tab.id)
                    }
                }

                Button {
                    tabManager.newTab()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
            .padding(6)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}
