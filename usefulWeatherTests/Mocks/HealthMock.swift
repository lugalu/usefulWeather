//Created by Lugalu on 15/11/24.

import Foundation
@testable import usefulWeather


class HealthMock: HealthInterface {
    func askAuthorizationIfNeeded() {
        return
    }
    
    func getWeight() async throws -> Double? {
        return nil
    }
    
    func getHeight() async throws -> Double? {
        return nil
    }
    
    func getMetabolicRate() async throws -> Double? {
        return nil
    }
    
    func getBodyTemperature() async throws -> Double? {
        return nil
    }
    
    
}
