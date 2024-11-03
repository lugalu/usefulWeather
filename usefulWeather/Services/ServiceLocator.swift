//Created by Lugalu on 31/10/24.

import SwiftUI
import SwiftData


class ServiceLocator: ObservableObject, Observable {
    private let networkService: NetworkInterface
    private let decoderService: DecoderService
    private let databaseService: ModelContainer
    private let geolocationService: GeoLocationInterface
    
    init(networkService: NetworkInterface,
         decoderService: DecoderService,
         databaseContainer: ModelContainer,
         geolocationService: GeoLocationInterface ) {
        self.networkService = networkService
        self.decoderService = decoderService
        self.databaseService = databaseContainer
        self.geolocationService = geolocationService
    }
    
    func getNetworkService() -> NetworkInterface { return networkService }
    
    func getDecoderService() -> DecoderService { return decoderService }
    
    func getDatabaseService() -> ModelContainer { return databaseService }
    
    func getGeoLocationService() -> GeoLocationInterface { return geolocationService }
    
}
