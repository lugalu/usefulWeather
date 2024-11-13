//Created by Lugalu on 01/11/24.

import SwiftUI
import SwiftData
import CoreLocation

class WeatherModel: ObservableObject, Observable {
    @Published var weatherData: WeatherData?
    @Published var recommendedClothing: [String] = []
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    let networkingService: NetworkInterface
    let decoderService: DecoderService
    let databaseService: ModelContainer
    let locationService: GeoLocationInterface
    let healthService: HealthInterface?
    
    init(locator: ServiceLocator) {
        self.networkingService = locator.getNetworkService()
        self.decoderService = locator.getDecoderService()
        self.databaseService = locator.getDatabaseService()
        self.locationService = locator.getGeoLocationService()
        self.healthService = locator.getHealthService()
        locationService.checkAuthorization()
        healthService?.askAuthorizationIfNeeded()
    }
    
    
    func fetchWeather() async throws {
        let authorizationStatus = await locationService.authorizationStatus
        
        guard checkForAuth(authorizationStatus) else {
            Task { @MainActor in
                locationAuthorizationStatus = .denied
            }
            return
        }
        
        Task { @MainActor in
            locationAuthorizationStatus = authorizationStatus
        }
        
        let (latitude, longitude) = try await getLatitudeAndLongitude()
        let testData = exampleJSON.data(using: .ascii)!
        let json = try decoderService.decode(testData, class: WeatherJSON.self)
        let weather = WeatherMapper.map(from: json)
//                let data = try await networkingService.downloadData(from: .currentLocation(latitude: latitude, longitude: longitude))
//                let json = try decoderService.decode(data, class: WeatherJSON.self)
//                let weather = WeatherMapper.map(from: json)
        Task{ @MainActor in
            self.weatherData = weather
            try await self.calculateClothing()
        }
        
    }
    
    private func getLatitudeAndLongitude() async throws -> (String,String) {
        let location = try await locationService.currentLocation
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        let nsLatitude = NSNumber(value: latitude)
        let nsLongitude = NSNumber(value: longitude)

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."

        guard let latitudeString = formatter.string(from: nsLatitude), let longitudeString = formatter.string(from: nsLongitude) else {
            throw NetworkErrors.unknowError
        }
        return (latitudeString, longitudeString)
    }
    
    private func checkForAuth(_ status: CLAuthorizationStatus) -> Bool {
        #if os(macOS)
            return status == .authorized || status == .authorizedAlways
        #else
            return status == .authorizedAlways || status == .authorizedWhenInUse
        #endif
    }
    
    func checkForAuth() -> Bool {
        #if os(macOS)
        return locationAuthorizationStatus == .authorized || locationAuthorizationStatus == .authorizedAlways
        #else
        return locationAuthorizationStatus == .authorizedWhenInUse || locationAuthorizationStatus == .authorizedAlways
        #endif
    }
    
    func didAuthHappen() -> Bool {
        return locationAuthorizationStatus != .notDetermined
    }
    

    
    func calculateClothing() async throws{
        guard let weatherData,
              var airTemperature = weatherData.temperature.real,
              var airVelocity = weatherData.wind.speed
        else {
            return
        }
        airTemperature -= 273.15
        airTemperature = round(airTemperature)
        airVelocity *= 100

        let skinTemperature = (try? await healthService?.getBodyTemperature()) ?? 37.0
        let height = ((try? await healthService?.getHeight()) ?? 1.76) * 100
        let weight = ((try? await healthService?.getWeight()) ?? 77000) / 1000
        let bodySurfaceArea = sqrt(height * weight / 3600)
        let metabolicRate = (try? await healthService?.getMetabolicRate()) ?? 65.0
        let evaporationLoss = 0.05
        
        
        //the formula goes as follows
        //first we calculate the InsulationOfAir
        let insulationOfAir = 1 / (0.61 * pow((airTemperature / 298),3) + 0.91 * sqrt(airVelocity) * 298 / airTemperature)
        
        //then we calculate the base insulationOfClothes
        var baseInsulation = 5.55 * (skinTemperature - airTemperature) * bodySurfaceArea
        let baseInsulationDenominator = metabolicRate - (0.58 * evaporationLoss) + (0.83 * weight)
        baseInsulation /= baseInsulationDenominator
        
        //Finally this is the result, we can use this to find good clothes!
        let result = baseInsulation - insulationOfAir
        print(result)
    }
    
}

