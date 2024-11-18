//Created by Lugalu on 07/11/24.

import SwiftUI

struct WeatherInformation: View {
    @Binding var weather: WeatherData?
    
    var body: some View {
        Grid(alignment: .center, horizontalSpacing: 16, verticalSpacing: 16) {
            
            if let icon = weather?.icon,
                let temperature = weather?.temperature.real {
                GridRow {
                    makeDefaultCard(text: self.getFormattedTemperature(temperature),
                                    systemImage: icon)
                    
                    if let feelsLike = weather?.temperature.feelsLike {
                        makeDefaultCard(text: self.getFormattedTemperature(feelsLike),
                                        systemImage: "thermometer.variable.and.figure",
                                        imageColor: temperature < feelsLike ? .yellow : .indigo )
                    }
                }
            }
            
            
            GridRow{
                if let minTemperature = weather?.temperature.min {
                    makeDefaultCard(text: self.getFormattedTemperature(minTemperature),
                                    systemImage: "thermometer.low",
                                    imageColor: .cyan)
                    
                }
                
                if let maxTemperature = weather?.temperature.max {
                    makeDefaultCard(text: self.getFormattedTemperature(maxTemperature),
                                    systemImage: "thermometer.high",
                                    imageColor: .orange)
                }
            }
        }
        List {
            if let pressure = weather?.temperature.pressure,
               let string = self.getFormattedPressure(pressure) {
                Text("Pressure: " + string)
            }
            
            if let humidity = weather?.temperature.humidity,
                let string = self.getFormattedPercent(humidity) {
                Text("Humidity: " + string)
            }
            
            if let rain = weather?.rainAmount,
                let string = self.getFormattedMilimeters(rain) {
                Text("Precipitation: " + string)
            }
            
            if let snow = weather?.snowAmount,
                let string = self.getFormattedMilimeters(snow){
                Text("Snow: " + string)
            }
        }
        .listStyle(.plain)
        .scrollDisabled(true)
    }
    
    @ViewBuilder
    func makeDefaultCard(text: String, systemImage: String, imageColor: Color? = nil) -> some View {
        VStack {
            Image(systemName: systemImage)
                .foregroundStyle(imageColor ?? .primary)
            Text(text)
        }
        .frame(width: 120, height: 120)
        .font(.system(size: 46))
        .baseCardStyle()
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

fileprivate extension View {
    func baseCardStyle() -> some View {
        self
            .background(.bar, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            
    }
}

#Preview {
    WeatherInformation(weather: .constant(
                        WeatherData(cityName: "aaa",
                                    icon: "cloud",
                                    type: "",
                                    visibility: 10,
                                    clouds: 10,
                                    rain: 10,
                                    snow: 10,
                                    temperature:
                                        WeatherData.Temperature(real: 292,
                                                                min: 292,
                                                                max: 292,
                                                                feelsLike: 293,
                                                                pressure: 1015,
                                                                humidity: 97),
                                    wind: WeatherData.Wind(speed: 10,
                                                           degree: 10,
                                                           gust: 10)))
    )
}
