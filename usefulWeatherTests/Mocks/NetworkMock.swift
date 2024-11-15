//Created by Lugalu on 15/11/24.

import Foundation
@testable import usefulWeather

class MockNetwork: NetworkInterface {
    func downloadData(from: usefulWeather.Endpoints) async throws -> Data {
        if case .currentLocation( _, _) = from {
            return exampleJSON.data(using: .ascii)!
        } else {
            return Data()
        }
    }
}
