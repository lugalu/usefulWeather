//Created by Lugalu on 27/10/24.

import SwiftUI
import SwiftData

#if os(iOS)
import UIKit
#endif

struct Weather: View {
    @EnvironmentObject var model: WeatherModel
    @State private var contents = ["socks and sandals", "warm clothes", "the will of a god"]
    
    var body: some View {
        VStack{
            if model.checkForAuth()  {
                WeatherInformation(weather: $model.weatherData)
                    .redacted(reason: model.weatherData == nil ? .placeholder : [])
                clothingInfo()
                    .redacted(reason: model.weatherData == nil ? .placeholder : [])

                
                
            } else {
                errorView()
                    .redacted(reason: model.didAuthHappen() ? [] : .placeholder )

            }
        }
        .padding(.horizontal)
        .task {
            do {
                try await model.fetchWeather()
            } catch {
                //TODO: did error!
                print("oops", error.localizedDescription)
            }
        }
        .redacted(reason: model.didAuthHappen() ? [] : .invalidated )

    }
    
    @ViewBuilder
    private func errorView() -> some View {
        Text("the app is currently not authorized to get your location, unfortunately without it this app can't really show you the weather.")
        
        #if os(macOS)
        Text("You can change this behaviour in the system settings")
        #else
        Button(action: {
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }){
            Text("Open Settings")
        }
        .buttonStyle(BorderedButtonStyle())
        #endif
    }
    
    @ViewBuilder
    private func clothingInfo() -> some View {
        Divider()
        
        Text("Based on current weather and your provided info:")
        
        HStack(alignment: .top){
            Image(systemName: "figure.stand")
                .resizable()
                .scaledToFit()
            
            VStack{
                Text("We recommend the following")

                ForEach(contents.indices, id: \.self) { idx in
                    Text("- \(contents[idx])")
                }
            }
        }
    }
    
}



#Preview {
    Weather()
}
