//Created by Lugalu on 27/10/24.

import SwiftUI
import SceneKit

class EarthModel: ObservableObject, Observable{
    
}

enum WeatherVisuals: String, CaseIterable, Identifiable {
    case clouds = "cloud.fill"
    case rain = "cloud.rain.fill"
    case temperature = "thermometer.low"
    case noSelection = "eye.slash"
    
    var id: Self { self }
}

struct EarthView: View {
    @EnvironmentObject var locator: ServiceLocator
    let scene = EarthScene()
    @State var angle: Angle = .degrees(0)
    @State var isShowingAlert = false
    @State var didInject = false
    @State var selectedVisual: WeatherVisuals = .clouds
    
    var body: some View {
        ZStack{
            SceneView(
                scene: scene,
                pointOfView: scene.cameraNode,
                options: [.allowsCameraControl,.autoenablesDefaultLighting, .rendersContinuously],
                delegate: scene
            )
            .onAppear{
                if !didInject {
                    scene.injectLocator(locator)
                    didInject.toggle()
                }
            }
            
            helpAndClockView()
        }
        .alert("Information", isPresented: $isShowingAlert){} message: {
            Text("The Time of day displayed here does not reflect on the weather, is purely cosmetic and based on real world data from many satellites including NASA, natural earth, open weather, and more.")
        }
        
    }
    
    fileprivate func helpAndClockView() -> some View {
        return VStack {
            HStack {
                
                Picker("",selection: $selectedVisual){
                    ForEach(WeatherVisuals.allCases) { visual in
                        Image(systemName: visual.rawValue)
                            .font(.title)

                    }
                }
                .pickerStyle(.segmented)

                
                Button(action: {
                    isShowingAlert.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .font(.title)
                        .padding(.vertical, 2)
                }
                .tint(.secondary)
                .buttonStyle(.bordered)
                
            }
            .padding(.horizontal, 8)
            
            Spacer()
            
            Image("Clock")
                .resizable()
                .frame(width: Assets.clockSize, height: Assets.clockSize, alignment: .center)
                .rotationEffect(angle, anchor: .center)
                .gesture(dragGesture())
                .sensoryFeedback(.impact(weight: .heavy, intensity: 1), trigger: (0..<1).contains(angle.degrees.truncatingRemainder(dividingBy: 90)))
                .offset(y: Assets.clockOffset)
        }
        .padding(.top, 8)
        .onChange(of: selectedVisual){
            switch selectedVisual {
            case .noSelection:
                scene.hideWeather()
            case .clouds:
                scene.changeToCloudShader()
            case .rain:
                scene.changeToRainShader()
            case .temperature:
                scene.changeToTemperatureShader()
            }
        }
    }
    
    func dragGesture() -> some Gesture {
        return DragGesture(minimumDistance: 1)
            .onChanged { gesture in
                let start = gesture.startLocation
                let end = gesture.location

                let startAngle = atan2(start.x, start.y)
                let endAngle = atan2(end.x, start.y)
                
                let result = (endAngle - startAngle + 180).truncatingRemainder(dividingBy: 360) - 180
                
                self.angle += .degrees(result)
                scene.rotate(withAngle: Float(result * .pi * 2))
                
            }
    }
}





