//Created by Lugalu on 02/12/24.

import SwiftData
import SwiftUI

@Model
class MapData {
    @Attribute(.unique) private(set) var timestamp: Date = Date()
    private(set) var temperatureMap: Data?
    private(set) var cloudMap: Data?
    private(set) var rainMap: Data?

    init(temperatureMap: Data? = nil, cloudMap: Data? = nil, rainMap: Data? = nil) {
        self.temperatureMap = temperatureMap
        self.cloudMap = cloudMap
        self.rainMap = rainMap
    }
    
    #if os(macOS)
    
    private func dataToMap(_ data: Data) -> NSImage? {
        return NSImage(data: data)
    }
    
    func getTemperatureMap() -> NSImage? {
        guard let temperatureMap else { return nil }
        return dataToMap(temperatureMap)
    }
    
    func getCloudMap() -> NSImage? {
        guard let cloudMap else { return nil }
        return dataToMap(cloudMap)
    }
    
    func getRainMap() -> NSImage? {
        guard let cloudMap else { return nil }
        return dataToMap(cloudMap)
    }
    
    #else
    private func dataToMap(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
    
    func getTemperatureMap() -> UIImage? {
        guard let temperatureMap else { return nil }
        return dataToMap(temperatureMap)
    }
    
    func getCloudMap() -> UIImage? {
        guard let cloudMap else { return nil }
        return dataToMap(cloudMap)
    }
    
    func getRainMap() -> UIImage? {
        guard let cloudMap else { return nil }
        return dataToMap(cloudMap)
    }
    #endif
    
}


