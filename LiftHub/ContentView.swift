import SwiftUI

struct ContentView: View {
    @State private var selectedTab:BottomBarSelectedTab = .workout
    var body: some View {
        VStack {
            Spacer()
            BottomBar(selectedTab: $selectedTab)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
