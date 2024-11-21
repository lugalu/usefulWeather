//Created by Lugalu on 07/11/24.

import SwiftUI

struct WeatherInformation: View {
    @Binding var weather: WeatherData?
    

    
    var body: some View {
        
        Grid(horizontalSpacing: 16, verticalSpacing: 16) {
            if let icon = weather?.icon,
                let temperature = weather?.temperature.real {
                GridRow {
                    makeDefaultCard(text: self.getFormattedTemperature(temperature),
                                    systemImage: icon, imageColor: weather?.iconColor)
                    
                    if let feelsLike = weather?.temperature.feelsLike {
                        makeDefaultCard(text: self.getFormattedTemperature(feelsLike),
                                        systemImage: "thermometer.variable.and.figure",
                                        imageColor:
                                            getFeelsLikeColor(feelsLike,
                                                              temperature))
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
        
        makeList()
            .padding(.top, 8)
    }
    
    
    func getFeelsLikeColor(_ feelsLike: Double, _ temperature: Double) -> Color {
        guard self.getFormattedTemperature(feelsLike) != self.getFormattedTemperature(temperature) else {
            return weather?.iconColor ?? .gray
        }
        if feelsLike > temperature { return .orange }
        return .cyan
    }
    
    @ViewBuilder
    func makeList() -> some View {
        VStack(alignment: .leading) {
            if let pressure = weather?.temperature.pressure,
               let string = self.getFormattedPressure(pressure) {
                Text("Pressure: " + string)
                Divider()

            }
            
            if let humidity = weather?.temperature.humidity,
               let string = self.getFormattedPercent(humidity) {
                Text("Humidity: " + string)
                Divider()

            }

            if let rain = weather?.rainAmount,
               let string = self.getFormattedMilimeters(rain) {
                Text("Precipitation: " + string)
                Divider()
            }
            
            if let snow = weather?.snowAmount,
               let string = self.getFormattedMilimeters(snow){
                Text("Snow: " + string)
                Divider()
            }
        }
        .padding(.horizontal, 4)
    }
    
    @ViewBuilder
    func makeDefaultCard(text: String, systemImage: String, imageColor: Color? = nil) -> some View {
        VStack {
            Image(systemName: systemImage)
                .foregroundStyle(imageColor ?? .primary)
            Text(text)
        }
        .frame(width: 150, height: 150)
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
        formatter.unitOptions = .providedUnit
        let formattedMilimeters =  Measurement<UnitLength>(value: number, unit: .millimeters)
        return formatter.string(from: formattedMilimeters)

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
                                        Temperature(real: 292,
                                                                min: 287,
                                                                max: 295,
                                                                feelsLike: 292.5,
                                                                pressure: 1015,
                                                                humidity: 97),
                                    wind: Wind(speed: 10,
                                                           degree: 10,
                                                           gust: 10)))
    )
}
