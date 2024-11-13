//Created by Lugalu on 11/11/24.

import HealthKit

protocol HealthInterface {
    func askAuthorizationIfNeeded()
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

class HealthService: HealthInterface {
    var healthStore: HKHealthStore
    init?(){
        guard HealthService.isHealthKitAvailable() else { return nil }
        self.healthStore = HKHealthStore()
    }
    
    static func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    private func requestAuthorization() {
        let readObjects: Set<HKObjectType> = [
            HKQuantityType(.bodyTemperature),
            HKQuantityType(.bodyMass),
            HKQuantityType(.height),
            HKQuantityType(.basalEnergyBurned)
        ]
        healthStore.requestAuthorization(toShare: nil, read: readObjects, completion: {_,_ in})
    }
    
    func askAuthorizationIfNeeded() {
        switch healthStore.authorizationStatus(for: HKQuantityType(.bodyTemperature)) {
        case .notDetermined:
            requestAuthorization()
        default:
            return
        }
    }
    
    func getWeight() async throws -> Double? {
        let type = HKQuantityType(.bodyMass)
        let query = HKSampleQueryDescriptor(predicates: [.quantitySample(type: type)],
                                            sortDescriptors: [SortDescriptor(\.endDate, order: .forward)])
        return try await query.result(for: healthStore).first?.quantity.doubleValue(for: .gram())
    }
    
    func getHeight() async throws -> Double? {
        let type = HKQuantityType(.height)
        let query = HKSampleQueryDescriptor(predicates: [.quantitySample(type: type)],
                                            sortDescriptors: [SortDescriptor(\.endDate, order: .forward)])
        
        return try await query.result(for: healthStore).first?.quantity.doubleValue(for: .meter())
    }
    
    func getMetabolicRate() async throws -> Double? {
        let type = HKQuantityType(.basalEnergyBurned)
        let query = HKSampleQueryDescriptor(predicates: [.quantitySample(type: type)],
                                            sortDescriptors: [SortDescriptor(\.endDate, order: .forward)])
        let result = try await query.result(for: healthStore)
        return result.reduce(0, { $0 + $1.quantity.doubleValue(for: .kilocalorie())}) / Double(result.count)
    }
    
    func getBodyTemperature() async throws -> Double? {
        let type = HKQuantityType(.bodyTemperature)
        let query = HKSampleQueryDescriptor(predicates: [.quantitySample(type: type)],
                                            sortDescriptors: [SortDescriptor(\.endDate, order: .forward)])
        
        return try await query.result(for: healthStore).first?.quantity.doubleValue(for: .degreeCelsius())
    }
    
    
}
