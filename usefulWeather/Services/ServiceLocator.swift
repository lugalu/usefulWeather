//Created by Lugalu on 31/10/24.

import SwiftUI
import SwiftData


class ServiceLocator: ObservableObject, Observable {
    private let networkService: NetworkInterface
    private let decoderService: DecoderService
    private let databaseService: ModelContainer
    
    init(networkService: NetworkInterface, decoderService: DecoderService, databaseContainer: ModelContainer) {
        self.networkService = networkService
        self.decoderService = decoderService
        self.databaseService = databaseContainer
    }
    
    func getNetworkService() -> NetworkInterface { return networkService }
    
    func getDecoderService() -> DecoderService { return decoderService }
    
    func getDatabaseService() -> ModelContainer { return databaseService }
    
}
