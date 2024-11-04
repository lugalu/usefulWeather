//Created by Lugalu on 01/11/24.

import SwiftUI
import SwiftData
import CoreLocation

class WeatherModel: ObservableObject, Observable {
    @Published var weatherData: WeatherData?
    @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    let networkingService: NetworkInterface
    let decoderService: DecoderService
    let databaseService: ModelContainer
    let locationService: GeoLocationInterface
    
    init(locator: ServiceLocator) {
        self.networkingService = locator.getNetworkService()
        self.decoderService = locator.getDecoderService()
        self.databaseService = locator.getDatabaseService()
        self.locationService = locator.getGeoLocationService()
        locationService.checkAuthorization()
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
        
        
        let location = try await locationService.currentLocation
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        let nsLatitude = NSNumber(value: latitude)
        let nsLongitude = NSNumber(value: longitude)

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."

        guard let latitudeString = formatter.string(from: nsLatitude), let longitudeString = formatter.string(from: nsLongitude) else {
            fatalError("Handle this!")
        }

        //        let data = try await networkingService.downloadData(from: .currentLocation(latitude: latitudeString, longitude: longitudeString))
        //        let json = try decoderService.decode(data, class: WeatherJSON.self)
        //        let weather = WeatherMapper.map(from: json)
        //        Task{ @MainActor in
        //            self.weatherData = weather
        //        }
    }
    
    private func checkForAuth(_ status: CLAuthorizationStatus) -> Bool {
        #if os(macOS)
            return status == .authorized || status == .authorizedAlways
        #else
            return status == .authorizedAlways || status == .authorizedWhenInUse
        #endif
    }
    
}


fileprivate struct WeatherMapper {
    private init() {}

    
    static func map(from json: WeatherJSON) -> WeatherData {
        let cityName = json.name
        let icon = iconToSystem(json.weather.first?.icon)
        let type = json.weather.first?.description
        let visibility = json.visibility
        let clouds = json.clouds?.all
        let rain = json.rain?.oneHour
        let snow = json.snow?.oneHour
        
        //temperature conversion
        let real = json.main?.temp
        let min  = json.main?.tempMin
        let max = json.main?.tempMax
        let feelslike = json.main?.feelsLike
        let pressure = json.main?.pressure
        let humidity = json.main?.humidity
        let temperature = WeatherData.Temperature(real: real, min: min, max: max, feelsLike: feelslike, pressure: pressure, humidity: humidity)
        
        //wind conversion
        let speed = json.wind?.speed
        let degree = json.wind?.deg
        let gust = json.wind?.gust
        let wind = WeatherData.Wind(speed: speed, degree: degree, gust: gust)
        
        return WeatherData(cityName: cityName, icon: icon, type: type, visibility: visibility, clouds: clouds, rain: rain, snow: snow, temperature: temperature, wind: wind)
    }
    
    
    private static func iconToSystem(_ iconName: String?) -> String {
        let iconDict: [Int: String] = [
            1: "sun.min.fill",
            2: "cloud.sun.fill",
            3: "cloud.fill",
            4: "cloud",
            9: "cloud.drizzle.fill",
            10: "cloud.rain.fill",
            11: "cloud.bolt.fill",
            13: "cloud.snow.fill",
            50: "cloud.fog.fill"
        ]
        
        guard var iconName = iconName, !iconName.isEmpty else { return "x.circle" }
        iconName.removeLast()
        guard let iconNum = Int(iconName), let systemIcon = iconDict[iconNum] else { return "x.circle" }
        return systemIcon
    }
}

@Model
class WeatherData {
    let cityName: String?
    let icon: String
    let type: String?
    let visibility: Int?
    let clouds: Int?
    let rainAmount: Double?
    let snowAmount: Double?
    
    let temperature: Temperature
    let wind: Wind
    
    init(cityName: String?, icon: String, type: String?, visibility: Int?, clouds: Int?, rain: Double?, snow: Double?, temperature: Temperature, wind: Wind) {
        self.cityName = cityName
        self.icon = icon
        self.type = type
        self.visibility = visibility
        self.clouds = clouds
        self.rainAmount = rain
        self.snowAmount = snow
        self.temperature = temperature
        self.wind = wind
    }
    
    @Model
    class Wind {
        let speed: Double?
        let degree: Int?
        let gust: Double?
        
        init(speed: Double?, degree: Int?, gust: Double?) {
            self.speed = speed
            self.degree = degree
            self.gust = gust
        }
    }

    @Model
    class Temperature {
        let real: Double?
        let min: Double?
        let max: Double?
        let feelsLike: Double?
        let pressure: Int?
        let humidity: Int?
        
        init(real: Double?, min: Double?, max: Double?, feelsLike: Double?, pressure: Int?, humidity: Int?) {
            self.real = real
            self.min = min
            self.max = max
            self.feelsLike = feelsLike
            self.pressure = pressure
            self.humidity = humidity
        }
    }

   
}


