//Created by Lugalu on 27/10/24.

import SwiftUI
import SceneKit

struct EarthView: View {
    let scene = EarthScene()

    
    var body: some View {
        ZStack(alignment: .bottom) {
            SceneView(
                scene: scene,
                pointOfView: scene.cameraNode,
                options: [.allowsCameraControl,.autoenablesDefaultLighting, .rendersContinuously],
                delegate: scene
            )
         
            Button(action: {
                scene.test()
            }, label: { Text("Rotate Earth (temporary)")})
            .font(.largeTitle)
            .buttonStyle(.borderedProminent)
        }
    }
}





