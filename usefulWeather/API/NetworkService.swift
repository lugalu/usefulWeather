//Created by Lugalu on 28/10/24.

import Foundation

protocol NetworkInterface {
  
    func downloadData(from: Endpoints) async throws -> Data
}

class NetworkService: NetworkInterface {
    private let API_ENDPOINT = "https://tile.openweathermap.org"
    
    func downloadData(from endpoint: Endpoints) async throws -> Data {
        let request = try EndpointBuilder.buildEndpoint(for: endpoint)
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
   
}



