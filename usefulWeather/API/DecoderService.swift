//Created by Lugalu on 29/10/24.

import SwiftUI


protocol DecoderInterface{
    func decode<T:Decodable>(_ data: Data, class: T) throws -> T
    func decodeImage(_ data: Data) -> CIImage?
}

struct DecoderService: DecoderInterface {
    
    func decode<T:Decodable>(_ data: Data, class: T) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    func decodeImage(_ data: Data) -> CIImage? {
        return  CIImage(data: data)

    }
   
}
