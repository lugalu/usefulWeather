//Created by Lugalu on 29/10/24.

import Foundation

struct EndpointBuilder {
    private static let urlScheme = "https"
    
    private init() {}
    
    static func buildEndpoint(for endpoint: Endpoints) throws -> URLRequest {
        var components: URLComponents
        if case .currentLocation(let latitude, let longitude) = endpoint {
            components = try buildLocationComponents(latitude, longitude)
        } else {
            components = try buildMapComponents(from: endpoint)
        }
        
        guard let url = components.url else { throw NetworkErrors.malformedURL }
        return URLRequest(url: url)
    }
    
    private static func buildMapComponents(from endpoint: Endpoints) throws -> URLComponents {
        let urlHost = "tile.openweathermap.org"
        let mapPath = try "/map/" +  getMapLayer(for: endpoint) + "/0/0/0.png"
        
        var components = URLComponents()
        components.scheme = urlScheme
        components.host = urlHost
        components.path = mapPath
        components.queryItems = [ URLQueryItem(name: "appid", value: try getAPIKey()) ]
        
        return components
    }
    
    private static func getMapLayer(for endpoint: Endpoints) throws -> String {
        return switch endpoint {
        case .temperatureMap:
            "temp_new"
        case .precipitationMap:
            "precipitation_new"
        case .cloudMap:
            "clouds_new"
        default:
            throw NetworkErrors.unknowError
        }
    }
    
    
    private static func buildLocationComponents(_ latitude: String, _ longitude: String) throws -> URLComponents {
        let urlHost = "api.openweathermap.org"
        let urlPath = "/data/2.5/weather"
        var components = URLComponents()
        components.scheme = urlScheme
        components.path = urlPath
        components.host = urlHost
        
        let queryItems = [
            URLQueryItem(name: "lat", value: latitude),
            URLQueryItem(name: "lon", value: longitude),
            URLQueryItem(name: "appid", value: try getAPIKey() )
        ]
        
        components.queryItems = queryItems
        
        return components
    }
    
    private static func getAPIKey() throws -> String {
        guard let key = Bundle.main.infoDictionary?["API_KEY"] as? String, !key.isEmpty else {
            throw NetworkErrors.missingAPIKey
        }
        return key
    }
    
}
