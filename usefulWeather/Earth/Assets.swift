//Created by Lugalu on 28/10/24.

import SwiftUI



final class Assets {
    private init(){}
#if os(macOS)
    static let earthColorMap = NSImage(named: "earth_diffuse")
    static let earthLightMap = NSImage (data: NSDataAsset(name: "earth_specular")!.data)
    static let earthHeightMap = NSImage(named: "earth_height")
    static let earthLandOutline = NSImage(named: "country_outline")
    static let earthContinentalBoundaries = NSImage(named: "continentalBoundaries")
    static let earthCountriesOutline = NSImage(named: "inlandBoundaries")
    static let earthSnowCover = NSImage(named: "snowCover")
    static let earthLightEmission = NSImage(named: "earth_nightLights")
#else
    static let earthColorMap = UIImage(named: "earth_diffuse")
    static let earthLightMap = UIImage (data: NSDataAsset(name: "earth_specular")!.data)
    static let earthHeightMap = UIImage(named: "earth_height")
    static let earthCountryOutline = UIImage(named: "country_outline")
    static let earthLandOutline = UIImage(named: "country_outline")
    static let earthContinentalBoundaries = UIImage(named: "continentalBoundaries")
    static let earthCountriesOutline = UIImage(named: "inlandBoundaries")
    static let earthSnowCover = UIImage(named: "snowCover")
    static let earthLightEmission = UIImage(named: "earth_nightLights")

#endif
}

