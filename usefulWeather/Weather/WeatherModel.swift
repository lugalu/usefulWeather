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
        
        await Task { @MainActor in locationAuthorizationStatus = authorizationStatus }.value
        
        let weather = try await downloadAndDecode()
        let cloIndex = try await self.calculateClothing(weatherData: weather) ?? 1
        let clothes = getClothing(cloIndex).filter({ !$0.isEmpty })
        
        await Task{ @MainActor in
            self.weatherData = weather
            self.recommendedClothing = clothes
        }.value
    }
    
    func downloadAndDecode() async throws -> WeatherData {
        let (latitude, longitude) = try await getLatitudeAndLongitude()
        let data = try await networkingService.downloadData(from: .currentLocation(latitude: latitude, longitude: longitude))
        let json = try decoderService.decode(data, class: WeatherJSON.self)
        let weather = WeatherMapper.map(from: json)
        return weather
    }
    
    func getLatitudeAndLongitude() async throws -> (String,String) {
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
        return checkForAuth(self.locationAuthorizationStatus)
    }
    
    func didAuthHappen() -> Bool {
        return locationAuthorizationStatus != .notDetermined
    }
    

    
    func calculateClothing(weatherData: WeatherData) async throws -> Double? {
        guard var airTemperature = weatherData.temperature.real,
              var airVelocity = weatherData.wind.speed
        else {
            return nil
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
        
        //then we calculate the base insulation Of Clothes
        var baseInsulation = 5.55 * (skinTemperature - airTemperature) * bodySurfaceArea
        var baseInsulationDenominator = metabolicRate - (0.58 * evaporationLoss) + (0.83 * weight)
        baseInsulationDenominator = baseInsulationDenominator != 0 ? baseInsulationDenominator : 1
        
        baseInsulation /= baseInsulationDenominator
        
        //Finally this is the result, we use baseInsulation - insulationOfAir
        let result = baseInsulation - insulationOfAir
        return result
    }
    
    func getClothing(_ index: Double) -> [String] {
        let clothingCategoriesCollection: [[Double: String]] = [
            [
                0.06 : "Shirt",
                0.09 : "T-Shirt",
                0.15: "Light blouse with long sleeves",
                0.2: "Light shirt with long sleeves",
                0.25: "Normal with long sleeves",
                0.3: "Flannel shirt with long sleeves",
                0.34: "Shirt with long sleeves and turtleneck"
            ],
            [
                0.06: "Shorts",
                0.11: "Walking shorts",
                0.2: "Light trousers",
                0.25: "Trousers",
                0.28: "Flannel trousers / Overalls"
            ],
            [
                0: "Socks, if needed",
                0.02: "Socks",
                0.05: "Thick ankle socks",
                0.1: "Thick long socks"
            ],
            [
                0: "Sandals,slippers, or shoes",
                0.02: "Thin soled shoes",
                0.04: "Thick soled shoes",
                0.05: "Boots"
            ],
            [
                0.12: "Sleeveless vest",
                0.13: "Vest",
                0.25: "Summer Jacket",
                0.26: "Thin Sweater",
                0.3: "Smock",
                0.35: "Jacket",
                0.37: "Thick Sweater",
                0.55: "Down Jacket",
                0.6: "Coat",
                0.7: "Parka"
            ],
        ]
        
        let averageUnderwearIndex = 0.04
        let indexTarget = 1.0
        let indexOffset = index > indexTarget ? (indexTarget + averageUnderwearIndex) : 0
        
        var index = index - indexOffset
        var clothes: [String] = []
        for category in clothingCategoriesCollection {
            let categoryResult = findPieceOfClothingFor(index, dict: category)
            index = categoryResult.0
            clothes.append(categoryResult.1)
        }
        
        return clothes
    }
    
    private func findPieceOfClothingFor(_ index: Double, dict: [Double: String]) -> (Double, String) {
        var index = index
        for key in dict.keys.sorted(by: >) {
            if index >= key {
                index -= key
                return (index, dict[key] ?? "error")
            }
        }
        return (index, "")
    }
    
}
