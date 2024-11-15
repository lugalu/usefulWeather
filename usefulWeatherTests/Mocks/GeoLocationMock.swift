//Created by Lugalu on 15/11/24.

import Foundation
import CoreLocation
@testable import usefulWeather

class GeoLocationMock: GeoLocationInterface {
    var currentLocation: CLLocation { CLLocation(latitude: 0.4, longitude: 0.4)}
    
    var authorizationStatus: CLAuthorizationStatus { return .authorizedAlways }
    
    func checkAuthorization() {
        return
    }
    
    
}
