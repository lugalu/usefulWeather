//Created by Lugalu on 05/11/24.

import SwiftData
import SwiftUI

class WeatherData {
    let cityName: String?
    let icon: String
    let iconColor: Color?
    let type: String?
    let visibility: Int?
    let clouds: Int?
    let rainAmount: Double?
    let snowAmount: Double?
    
    let temperature: Temperature
    let wind: Wind
    
    init(cityName: String?, icon: String, iconColor: Color?, type: String?, visibility: Int?, clouds: Int?, rain: Double?, snow: Double?, temperature: Temperature, wind: Wind) {
        self.cityName = cityName
        self.icon = icon
        self.iconColor = iconColor
        self.type = type
        self.visibility = visibility
        self.clouds = clouds
        self.rainAmount = rain
        self.snowAmount = snow
        self.temperature = temperature
        self.wind = wind
    }
    
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

struct WeatherMapper {
    private init() {}

    
    static func map(from json: WeatherJSON) -> WeatherData {
        let cityName = json.name
        let (icon,iconColor) = iconToSystem(json.weather.first?.icon)
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
        
        return WeatherData(cityName: cityName, icon: icon, iconColor: iconColor, type: type, visibility: visibility, clouds: clouds, rain: rain, snow: snow, temperature: temperature, wind: wind)
    }
    
    
    private static func iconToSystem(_ iconName: String?) -> (String, Color) {
        let iconDict: [Int: (String, Color)] = [
            1: ("sun.min.fill", .teal),
            2: ("cloud.sun.fill", .teal),
            3: ("cloud.fill", .gray),
            4: ("cloud", .gray),
            9: ("cloud.drizzle.fill", .cyan),
            10: ("cloud.rain.fill", .cyan),
            11: ("cloud.bolt.fill", .red),
            13: ("cloud.snow.fill", .cyan),
            50: ("cloud.fog.fill", .white)
        ]
        
        guard var iconName = iconName, !iconName.isEmpty else { return ("x.circle",.gray) }
        iconName.removeLast()
        guard let iconNum = Int(iconName), let systemIcon = iconDict[iconNum] else { return ("x.circle", .gray) }
        return systemIcon
    }
}



