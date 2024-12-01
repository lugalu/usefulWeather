//Created by Lugalu on 27/10/24.

import SwiftUI
import SwiftData

struct Weather: View {
    @EnvironmentObject var model: WeatherModel
    
    var body: some View {
        ScrollView(.vertical){
            if model.checkForAuth() {
                if model.weatherData != nil {
                    WeatherInformation(weather: $model.weatherData)
                        .padding(.bottom,8)
                    clothingInfo()
                }
            } else {
                errorView()
                    .redacted(reason: model.didAuthHappen() ? [] : .placeholder )

            }
        }
        .padding(.horizontal)
        .overlay(alignment: .center){
            if model.checkForAuth() && model.weatherData == nil {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(3, anchor: .center)
            }
        }
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
            Text("Recommended clothes")
                .font(.system(size: 26))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            VStack(alignment: .leading) {
                ForEach(model.recommendedClothing, id: \.self) { clothe in
                    Text(clothe)
                    Divider()
                }
            }
            
        } else {
            Text("Error calculating Clothing")
        }
    }
    
}
