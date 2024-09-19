import SwiftUI

struct ContentView: View {
    @State private var selectedTab:BottomBarSelectedTab = .workout
    var body: some View {
        VStack {
            Spacer()
            BottomBar(selectedTab: $selectedTab)
        }
        .onAppear(){
            SettingsView.applyTheme(theme: UserDefaultsUtils.shared.getTheme())
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
