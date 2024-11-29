//Created by Lugalu on 27/10/24.

import SwiftUI
import SceneKit

struct EarthView: View {
    let scene = EarthScene()

    
    var body: some View {
        ZStack {
            SceneView(
                scene: scene,
                pointOfView: scene.cameraNode,
                options: [.allowsCameraControl,.autoenablesDefaultLighting],
                delegate: scene
            )
         
            Button(action: {
                scene.test()
            }, label: { Text("try me")})
        }
    }
}





