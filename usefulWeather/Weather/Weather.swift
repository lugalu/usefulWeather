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
                weatherView()
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
    private func weatherView() -> some View {
        
        if let temperature = model.weatherData?.temperature.real {
            Text(self.getFormattedTemperature(temperature))
                .font(.system(size: 72))
        }
        
        HStack {
            if let minTemperature = model.weatherData?.temperature.min {
                Text("Min: " + self.getFormattedTemperature(minTemperature))
            }
            
            if let maxTemperature = model.weatherData?.temperature.max {
                Text("Max: " + self.getFormattedTemperature(maxTemperature))
            }
        }
        HStack {
            
            if let feelsLike = model.weatherData?.temperature.feelsLike {
                Text("FeelsLike: " + self.getFormattedTemperature(feelsLike))
            }
            
            if let pressure = model.weatherData?.temperature.pressure,
            let string = self.getFormattedPressure(pressure) {
                Text("Pressure: " + string )
            }
        }
        
        HStack {
            if let humidity = model.weatherData?.temperature.humidity,
                let string = self.getFormattedPercent(humidity) {
                Text("Humidity: " + string)
            }
            
            if let rain = model.weatherData?.rainAmount,
                let string = self.getFormattedMilimeters(rain) {
                Text("Precipitation: " + string)
            }
            
            if let snow = model.weatherData?.snowAmount,
                let string = self.getFormattedMilimeters(snow){
                Text("Snow: " + string)
            }
        }
        
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
    
    func getFormattedTemperature(_ temperature: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        let temperatureUnit = Measurement<UnitTemperature>(value: temperature, unit: .kelvin)
        return formatter.string(from: temperatureUnit)
    }
    
    func getFormattedPercent(_ integer: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.multiplier = 1
        formatter.maximumFractionDigits = 2
        let nsNumber = NSNumber(value: integer)
        return formatter.string(from: nsNumber)
    }
    
    func getFormattedPressure(_ pressure: Int) -> String? {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        let pressure =  Measurement<UnitPressure>(value: Double(pressure), unit: .hectopascals)
        return formatter.string(from: pressure)
    }
    
    func getFormattedMilimeters(_ number: Double) -> String? {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 2

        let formattedMilimeters =  Measurement<UnitLength>(value: number, unit: .millimeters)
        return formatter.string(from: formattedMilimeters)

    }
}

#Preview {
    Weather()
}
