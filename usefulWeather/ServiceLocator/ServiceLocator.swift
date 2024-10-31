//Created by Lugalu on 31/10/24.

import Foundation


class ServiceLocator: ObservableObject, Observable {
    private let networkService: NetworkInterface
    private let decoderService: DecoderService
    
    init(networkService: NetworkInterface, decoderService: DecoderService) {
        self.networkService = networkService
        self.decoderService = decoderService
    }
    
    func getNetworkService() -> NetworkInterface { return networkService }
    func getDecoderService() -> DecoderService { return decoderService }
    
}
