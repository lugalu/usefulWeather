//Created by Lugalu on 29/10/24.

import Foundation

enum Endpoints: Equatable {
    case temperatureMap
    case precipitationMap
    case cloudMap
    case currentLocation(latitude: String, longitude: String)
}

enum NetworkErrors: LocalizedError {
    case malformedURL
    case missingAPIKey
    case unknowError
}
