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
        addLight()
    }
    
    private func makeBackground() {
        self.background.contents = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    func configureCamera() {
        self.rootNode.position = SCNVector3(x: 0, y: 0, z: -6)
    }
    
    func configureTemporaryPlanet() {
        let program = SCNProgram()
        program.vertexFunctionName = "textureSamplerVertex"
        program.fragmentFunctionName = "textureSamplerFragment"
        
        let heightMap = SCNMaterialProperty(contents: Assets.earthHeightMap!)
        let landOutline = SCNMaterialProperty(contents: Assets.earthLandOutline!)
        let continentalOutline = SCNMaterialProperty(contents: Assets.earthContinentalBoundaries!)
        let countriesOutline = SCNMaterialProperty(contents: Assets.earthCountriesOutline!)
        let snowCover = SCNMaterialProperty(contents: Assets.earthSnowCover!)
        
        let planetMaterial = SCNMaterial()
        planetMaterial.program = program
        planetMaterial.setValue(heightMap, forKey: "heightMap")
        planetMaterial.setValue(landOutline, forKey: "countryLand")
        planetMaterial.setValue(continentalOutline, forKey: "continentOutline")
        planetMaterial.setValue(countriesOutline, forKey: "countriesOutline")
        planetMaterial.setValue(snowCover, forKey: "snowCover")
        
        let width = 2048 / 16
        
        let planetGeometry = SCNSphere(radius: 2)
        planetGeometry.segmentCount = width
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
        self.lightingEnvironment.contents = omniLightNode
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
