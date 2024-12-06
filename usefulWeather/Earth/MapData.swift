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
    
    private func resize(_ image: NSImage?) -> NSImage? {
        guard let image else { return nil }
        
        let size = image.size
        let targetSize = CGSize(width: 2048, height: 1024)
        
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine new size based on aspect ratio
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // Create a new NSImage with the target size
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        
        // Draw the original image into the new size
        let rect = CGRect(origin: .zero, size: newSize)
        image.draw(in: rect, from: .zero, operation: .copy, fraction: 1.0)
        
        newImage.unlockFocus()
        return newImage
    }
    
    func getTemperatureMap() -> NSImage? {
        guard let temperatureMap else { return nil }
        return resize(dataToMap(temperatureMap))
    }
    
    func getCloudMap() -> NSImage? {
        guard let cloudMap else { return nil }
        return resize(dataToMap(cloudMap))
    }
    
    func getRainMap() -> NSImage? {
        guard let cloudMap else { return nil }
        return resize(dataToMap(cloudMap))
    }
    
    #else
    private func dataToMap(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
    
    
    private func resize(_ image: UIImage?) -> UIImage? {
        guard let image else { return nil }
        
        let size = image.size
        let targetSize = CGSize(width: 2048, height: 1024)
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func getTemperatureMap() -> UIImage? {
        guard let temperatureMap else { return nil }
        return resize(dataToMap(temperatureMap))
    }
    
    func getCloudMap() -> UIImage? {
        guard let cloudMap else { return nil }
        return resize(dataToMap(cloudMap))
    }
    
    func getRainMap() -> UIImage? {
        guard let cloudMap else { return nil }
        return resize(dataToMap(rainMap))
    }
    #endif

    
}


