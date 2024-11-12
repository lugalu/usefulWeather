//Created by Lugalu on 11/11/24.

import Foundation

protocol HealthService {
    func checkAuthorization() async throws
    func getWeight() async throws -> Double?
    func getHeight() async throws -> Double?
    func getMetabolicRate() async throws -> Double?
    func getBodyTemperature() async throws -> Double?
}

/*
 protocol GeoLocationInterface {
     var currentLocation: CLLocation { get async throws }
     var authorizationStatus: CLAuthorizationStatus { get async }
     func checkAuthorization()
 }
 */
