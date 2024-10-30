import SwiftUI

struct ContentView: View {
    @State private var selectedTab:BottomBarSelectedTab = .workout
    var body: some View {
        VStack {
            BottomBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard) // To avoid shifting due to keyboard presence
        .onAppear(){
            UserDefaults.standard.register(defaults: [Constants.IS_WORKOUT_SAVED_KEY: true])
            SettingsView.applyTheme(theme: UserDefaultsUtils.shared.getTheme())
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
