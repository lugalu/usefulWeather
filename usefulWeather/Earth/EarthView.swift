//Created by Lugalu on 27/10/24.

import SwiftUI
import SceneKit

struct EarthView: View {
    let scene = EarthScene()
    let cameraNode: SCNNode = createCameraNode()
    
    var body: some View {
        SceneView(
            scene: scene,
            pointOfView: cameraNode,
            options: [.allowsCameraControl]
        )
    }
    
    private static func createCameraNode() -> SCNNode {
        let node = SCNNode()
        node.camera = SCNCamera()
        return node
    }
}





