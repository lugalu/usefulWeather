//Created by Lugalu on 27/10/24.

import SwiftUI
import SwiftData

@main
struct UsefulWeatherApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var preferredColumn =
        NavigationSplitViewColumn.detail

    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            TabView {
                TemperatureView()
                    .tabItem { Label("Info", systemImage: "thermometer.variable.and.figure.circle") }
                
                EarthView()
                    .tabItem { Label("3D View", systemImage: "globe") }
            }
            #else
            NavigationSplitView(preferredCompactColumn: $preferredColumn) {
                TemperatureView()
                    .navigationSplitViewColumnWidth(min:200, ideal: 300, max: 400)
            }detail: {
                EarthView()
            }
            #endif
        }
        .modelContainer(sharedModelContainer)
    }
}
