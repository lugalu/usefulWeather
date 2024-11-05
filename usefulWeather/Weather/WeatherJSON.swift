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

#if DEBUG
let exampleJSON = """
{
   "coord": {
      "lon": 7.367,
      "lat": 45.133
   },
   "weather": [
      {
         "id": 501,
         "main": "Rain",
         "description": "moderate rain",
         "icon": "10d"
      }
   ],
   "base": "stations",
   "main": {
      "temp": 284.2,
      "feels_like": 282.93,
      "temp_min": 283.06,
      "temp_max": 286.82,
      "pressure": 1021,
      "humidity": 60,
      "sea_level": 1021,
      "grnd_level": 910
   },
   "visibility": 10000,
   "wind": {
      "speed": 4.09,
      "deg": 121,
      "gust": 3.47
   },
   "rain": {
      "1h": 2.73
   },
   "clouds": {
      "all": 83
   },
   "dt": 1726660758,
   "sys": {
      "type": 1,
      "id": 6736,
      "country": "IT",
      "sunrise": 1726636384,
      "sunset": 1726680975
   },
   "timezone": 7200,
   "id": 3165523,
   "name": "Province of Turin",
   "cod": 200
}
                        
"""
#endif
