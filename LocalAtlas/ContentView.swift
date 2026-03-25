import SwiftUI

struct ContentView: View {
    var body: some View {
        BrowserView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TabManager())
    }
}
