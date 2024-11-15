//Created by Lugalu on 07/11/24.

import SwiftUI

struct WeatherInformation: View {
    @Binding var weather: WeatherData?
    
    var body: some View {
        Grid(horizontalSpacing: 16, verticalSpacing: 4) {
            GridRow(alignment:.firstTextBaseline){
                if let icon = weather?.icon {
                    Image(systemName: icon)
                }
                if let temperature = weather?.temperature.real {
                    Text(self.getFormattedTemperature(temperature))
                }
            }
            .font(.system(size: 72))
            
            
            GridRow{
                if let minTemperature = weather?.temperature.min {
                    Text("Min: " + self.getFormattedTemperature(minTemperature))
                }
                
                if let maxTemperature = weather?.temperature.max {
                    Text("Max: " + self.getFormattedTemperature(maxTemperature))
                }
            }
            
            GridRow {
                
                if let feelsLike = weather?.temperature.feelsLike {
                    Text("FeelsLike: " + self.getFormattedTemperature(feelsLike))
                }
                
                if let pressure = weather?.temperature.pressure,
                let string = self.getFormattedPressure(pressure) {
                    Text("Pressure: " + string )
                }
            }
            
            GridRow {
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




