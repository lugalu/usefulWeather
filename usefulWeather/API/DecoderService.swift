//Created by Lugalu on 29/10/24.

import SwiftUI


struct DecoderService {
    private init(){}
    
    static func decode<T:Decodable>(_ data: Data, class: T) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    static func decodeImage(_ data: Data) -> CIImage? {
        return  CIImage(data: data)

    }
   
}
