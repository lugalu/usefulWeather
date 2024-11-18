//Created by Lugalu on 27/10/24.

import SwiftUI
import SwiftData

struct Weather: View {
    @EnvironmentObject var model: WeatherModel
    
    var body: some View {
        VStack{
            if model.checkForAuth()  {
                
                if model.weatherData != nil {
                    WeatherInformation(weather: $model.weatherData)
                    Divider()
                    clothingInfo()
                }else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(3, anchor: .center)
                }
                
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

        if model.weatherData != nil && !model.recommendedClothing.isEmpty {
            Text("The following clothes are recomendations based on the weather and the information stored on your health.*")
            
            VStack(alignment: .leading){
                ForEach(model.recommendedClothing, id: \.self) { clothe in
                    Text("- \(clothe)")
                }
            }
            
            Text("*If Health is authorized, otherwise average values based on reasearch.")
            Text("These are not fashion advice, usem them as guides for what to wear.")
        } else {
            Text("Calculating Clothing")
        }
    }
    
}
