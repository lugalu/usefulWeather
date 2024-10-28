//Created by Lugalu on 28/10/24.

import Foundation

enum Endpoints {
    case temperatureMap
    case precipitationMap
    case cloudMap
    case currentLocation(String) //TODO: Check documentation for the needed data!
}

protocol NetworkInterface {
  
    func downloadData(from: Endpoints)
}

extension NetworkInterface {

}

class NetworkService {
    
}
