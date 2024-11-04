//Created by Lugalu on 27/10/24.

import SwiftUI
import SwiftData

struct Weather: View {
    @EnvironmentObject var model: WeatherModel
    @State private var contents = ["socks and sandals", "warm clothes", "the will of a god"]
    
    
    var body: some View {
        VStack{
            Text("27C")
                .font(.system(size: 72))

            HStack {
                Text("Max: 30C")
                Text("Min: 16C")
            }
            HStack {
                Text("Humidity: 22%")
                Text("Precipitation: 2%")
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
        .padding(.horizontal)
        .task {
            do {
                try await model.fetchWeather()
            } catch {
                print("oops", error.localizedDescription)
            }
        }
        .redacted(reason: model.isAuthorized ? [] : .placeholder )

    }
}

#Preview {
    Weather()
}
