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
            options: [.allowsCameraControl, .autoenablesDefaultLighting]
        )
    }
    
    private static func createCameraNode() -> SCNNode {
        let node = SCNNode()
        node.camera = SCNCamera()
        return node
    }
}

class EarthScene: SCNScene {
    
    private var planetNode: SCNNode?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        makeBackground()
        configureCamera()
        addStuff()
        addOmniLight()
        addPlanetRotation()
    }
    
    private func makeBackground() {
        self.background.contents = NSColor.black
    }
    
    func configureCamera() {
        self.rootNode.position = SCNVector3(x: 0, y: 0, z: -4)
    }
    
    func addStuff() {
        let planetMaterial = SCNMaterial()
        planetMaterial.diffuse.contents = Assets.earthColorMap
        planetMaterial.specular.contents = Assets.earthLightMap
        planetMaterial.normal.contents = Assets.earthHeightMap
           
        let planetGeometry = SCNSphere(radius: 2)
        planetGeometry.materials = [planetMaterial]

        let planetNode = SCNNode(geometry: planetGeometry)
        planetNode.position = SCNVector3(0, 0, 0)
        
        self.rootNode.addChildNode(planetNode)
        self.planetNode = planetNode
    }
    
    func addOmniLight() {
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        
        omniLightNode.light?.type = SCNLight.LightType.omni
        omniLightNode.light?.color = NSColor.white
        omniLightNode.position = SCNVector3Make(50, 0, 30)
        
        self.rootNode.addChildNode(omniLightNode)
    }
    
    func addPlanetRotation() {
        let action = SCNAction.rotate(by: 90, around: .init(x: 0, y: 3.14, z: 0), duration:  360)
        let repeatAction = SCNAction.repeatForever(action)
        planetNode?.runAction(repeatAction)
        
    }
}


final class Assets {
    private init(){}
    
    static let earthColorMap = NSImage(named: "earth_diffuse")
    static let earthLightMap = NSImage (data: NSDataAsset(name: "earth_specular")!.data)
    static let earthHeightMap = NSImage(data:  NSDataAsset(name: "earth_normal")!.data)
}
