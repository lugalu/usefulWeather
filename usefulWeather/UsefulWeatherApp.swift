//Created by Lugalu on 27/10/24.

import SwiftUI
import SwiftData

@main
struct UsefulWeatherApp: App {
    
    var locator = ServiceLocator(networkService: NetworkService(), decoderService: DecoderService(), databaseContainer: Self.makeContainer())
    
    static func makeContainer() -> ModelContainer {
        let schema = Schema([
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    

    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            NavigationSplitView {
                TemperatureView()
                    .navigationSplitViewColumnWidth(min:200, ideal: 300, max: 400)

            }detail: {
                EarthView()
            }

            #else
            TabView {
                TemperatureView()
                    .tabItem { Label("Info", systemImage: "thermometer.variable.and.figure.circle") }
                
                EarthView()
                    .tabItem { Label("3D View", systemImage: "globe") }
                
            }
            #endif
        }
        .environment(locator)
    }
}
