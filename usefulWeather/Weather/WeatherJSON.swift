//Created by Lugalu on 01/11/24.

import Foundation

struct WeatherJSON: Decodable {
    let weather: [Weather]
    let main: Main?
    let visibility: Int?
    let wind: WindJSON?
    let rain: RainJSON?
    let snow: RainJSON?
    let clouds: Clouds?
    let name: String?
    
    struct Weather: Decodable {
        let description: String?
        let icon: String?
    }
    
    struct Main: Decodable {
        let temp: Double?
        let feelsLike: Double?
        let tempMin: Double?
        let tempMax: Double?
        let pressure: Int?
        let humidity: Int?
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure
            case humidity
        }
    }
    
    struct WindJSON: Decodable {
        let speed: Double?
        let deg: Int?
        let gust: Double?
    }
    
    struct RainJSON: Decodable {
        let oneHour: Double?
        
        enum CodingKeys: String, CodingKey {
            case oneHour = "1h"
        }
    }
    
    struct Clouds: Decodable {
        let all: Int?
    }
}

