//Created by Lugalu on 31/10/24.

import SwiftUI
import SwiftData

//TODO: Make a true Database service, in order to test things out!
class ServiceLocator: ObservableObject, Observable {
    private let networkService: NetworkInterface
    private let decoderService: DecoderService
    private let databaseService: DatabaseInterface
    private let geolocationService: GeoLocationInterface
    private let healthService: HealthInterface?
    
    init(networkService: NetworkInterface,
         decoderService: DecoderService,
         databaseContainer: DatabaseInterface,
         geolocationService: GeoLocationInterface,
         healthService: HealthInterface?
    ) {
        self.networkService = networkService
        self.decoderService = decoderService
        self.databaseService = databaseContainer
        self.geolocationService = geolocationService
        self.healthService = healthService
    }
    
    func getNetworkService() -> NetworkInterface { return networkService }
    
    func getDecoderService() -> DecoderService { return decoderService }
    
    func getDatabaseService() -> DatabaseInterface { return databaseService }
    
    func getGeoLocationService() -> GeoLocationInterface { return geolocationService }
    
    func getHealthService() -> HealthInterface? { return healthService }
    
}
