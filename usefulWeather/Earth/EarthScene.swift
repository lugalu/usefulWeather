//Created by Lugalu on 28/10/24.

import SceneKit

class EarthScene: SCNScene {
    
    private var planetNode: SCNNode?
    private var globalLight: SCNNode?
    private var planetRotation: SCNAction?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        makeBackground()
        configureCamera()
        configureTemporaryPlanet()
        createLight()
        createPlanetRotation()
    }
    
    private func makeBackground() {
        self.background.contents = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    func configureCamera() {
        self.rootNode.position = SCNVector3(x: 0, y: 0, z: -6)
    }
    
    func configureTemporaryPlanet() {
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
    
    func createLight() {
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light?.type = SCNLight.LightType.omni
        omniLightNode.light?.color = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        omniLightNode.position = SCNVector3Make(50, 0, 30)
        self.globalLight = omniLightNode
    }
    
    func createPlanetRotation() {
        let action = SCNAction.rotate(by: 90, around: .init(x: 0, y: 3.14, z: 0), duration:  360)
        let repeatAction = SCNAction.repeatForever(action)
        self.planetRotation = repeatAction
    }
    
    func addPlanetRotation() {
        guard let planetRotation else { fatalError("Planet rotation not instantiated") }
        planetNode?.runAction(planetRotation)
    }
    func disablePlanetRotation() {
        planetNode?.removeAllActions()
    }

    
    func addLight() {
        guard let globalLight else { return }
        self.rootNode.addChildNode(globalLight)
    }
}
