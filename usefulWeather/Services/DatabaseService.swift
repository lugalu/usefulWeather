//Created by Lugalu on 21/11/24.

import SwiftData

protocol DatabaseInterface {
    func fetchWeatherCache() async throws -> WeatherData?
    func insertNewWeatherCache(_ weather: WeatherData) async throws
}

@MainActor
class DatabaseService: DatabaseInterface {
    
    private var container: ModelContainer = {
        let schema = Schema([
            WeatherData.self,
            Temperature.self,
            Wind.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    private lazy var context =  {
        return container.mainContext
    }()
    
    func fetchAllWeather() async throws -> [WeatherData] {
        let descriptor = FetchDescriptor<WeatherData>()
        let result = try context.fetch(descriptor)
 
        return result
    }
    
    @MainActor
    func fetchWeatherCache() async throws -> WeatherData? {
        return try await fetchAllWeather().first
    }
    
    func clearWeatherCache() throws {
        try context.delete(model: WeatherData.self)
        try context.delete(model: Temperature.self)
        try context.delete(model: Wind.self)
    }

    @MainActor
    func insertNewWeatherCache(_ weather: WeatherData) async throws {
        try clearWeatherCache()
        context.insert(weather)
        try context.save()
    }
}
