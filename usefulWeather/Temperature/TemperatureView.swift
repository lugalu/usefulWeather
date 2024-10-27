//Created by Lugalu on 27/10/24.

import SwiftUI
import SwiftData

struct TemperatureView: View {
    @Environment(\.modelContext) private var modelContext

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
            Spacer()
        }
    }

}

#Preview {
    TemperatureView()
}
