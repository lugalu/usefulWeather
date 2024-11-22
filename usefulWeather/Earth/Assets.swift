//Created by Lugalu on 28/10/24.

import SwiftUI



final class Assets {
    private init(){}
#if os(macOS)
    static let earthColorMap = NSImage(named: "earth_diffuse")
    static let earthLightMap = NSImage (data: NSDataAsset(name: "earth_specular")!.data)
    static let earthHeightMap = NSImage(data:  NSDataAsset(name: "earth_normal")!.data)
#else
    static let earthColorMap = UIImage(named: "earth_diffuse")
    static let earthLightMap = UIImage (data: NSDataAsset(name: "earth_specular")!.data)
    static let earthHeightMap = UIImage(data:  NSDataAsset(name: "earth_normal")!.data)
#endif    
}

