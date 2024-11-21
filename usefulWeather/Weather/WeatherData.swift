//Created by Lugalu on 05/11/24.

import SwiftData
import SwiftUI

@Model
class WeatherData {
    @Attribute(.unique) private(set) var timestamp: Date = Date()
    private(set) var cityName: String?
    private(set) var icon: String
    private(set) var type: String?
    private(set) var visibility: Int?
    private(set) var clouds: Int?
    private(set) var rainAmount: Double?
    private(set) var snowAmount: Double?
    
    @Relationship(.unique) private(set) var temperature: Temperature
    @Relationship(.unique) private(set) var wind: Wind
    
    
    @Transient var iconColor: Color {
        return switch icon {
        case "sun.min.fill":
                .teal
            
        case "cloud.sun.fill":
                .teal
            
        case "cloud.fill", "cloud":
                .gray
            
        case "cloud.drizzle.fill", "cloud.rain.fill", "cloud.snow.fill":
                .cyan
            
        case "cloud.bolt.fill":
                .red
            
        case "cloud.fog.fill":
                .white
            
        default:
                .gray
        }
    }
    
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
}

@Model
class Wind {
    private(set) var speed: Double?
    private(set) var degree: Int?
    private(set) var gust: Double?
    
    init(speed: Double?, degree: Int?, gust: Double?) {
        self.speed = speed
        self.degree = degree
        self.gust = gust
    }
}

@Model
class Temperature {
    private(set) var real: Double?
    private(set) var min: Double?
    private(set) var max: Double?
    private(set) var feelsLike: Double?
    private(set) var pressure: Int?
    private(set) var humidity: Int?
    
    init(real: Double?, min: Double?, max: Double?, feelsLike: Double?, pressure: Int?, humidity: Int?) {
        self.real = real
        self.min = min
        self.max = max
        self.feelsLike = feelsLike
        self.pressure = pressure
        self.humidity = humidity
    }
}




struct WeatherMapper {
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
        let temperature = Temperature(real: real, min: min, max: max, feelsLike: feelslike, pressure: pressure, humidity: humidity)
        
        //wind conversion
        let speed = json.wind?.speed
        let degree = json.wind?.deg
        let gust = json.wind?.gust
        let wind = Wind(speed: speed, degree: degree, gust: gust)
        
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



