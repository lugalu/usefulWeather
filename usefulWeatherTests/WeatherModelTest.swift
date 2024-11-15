//Created by Lugalu on 15/11/24.

import Testing
import XCTest
import Foundation
import SwiftData
@testable import usefulWeather

//TODO: make a mock Database Service!
fileprivate func makeContainer() -> ModelContainer {
    let schema = Schema([
        //WeatherData.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}



struct WeatherModelTest {
    let locator = ServiceLocator(networkService: MockNetwork(),
                                 decoderService: DecoderService(),
                                 databaseContainer: makeContainer(),
                                 geolocationService: GeoLocationMock(),
                                 healthService: HealthMock())
    lazy var sut = WeatherModel(locator: locator)
    
    @Test mutating func testGeoAuthenticationLogic() {
        #expect(!sut.checkForAuth())
        sut.locationAuthorizationStatus = .authorizedAlways
        #expect(sut.checkForAuth())
    }
    
    
    @Test mutating func testWeatherDataAndClothingStrings() async throws {
        try await sut.fetchWeather()
        #expect(sut.weatherData != nil)
        #expect(!sut.recommendedClothing.isEmpty)
    }
    
   
    @Test mutating func testCloIndexCalculation() async throws {
        let weather = try await sut.downloadAndDecode()
        let result = try await sut.calculateClothing(weatherData: weather)
        #expect(result != nil)
        XCTAssertEqual(result!, 2.17, accuracy: 0.2)
    }
}
