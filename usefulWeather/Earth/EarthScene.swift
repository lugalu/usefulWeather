//Created by Lugalu on 28/10/24.

import SceneKit

fileprivate struct CustomData {
    var viewPosition: simd_float3
}

class EarthScene: SCNScene, SCNSceneRendererDelegate {

    private var planetNode: SCNNode?
    private var globalLight: SCNNode?
    private var planetRotation: SCNAction?
    private var data: CustomData = CustomData(viewPosition: simd_float3())
    let cameraNode: SCNNode = SCNNode()

    
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
    
    func test() {
        let currentRotation = planetNode!.eulerAngles.y
        planetNode?.eulerAngles = SCNVector3Make(0, currentRotation + .pi/180, 0);
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let pov = renderer.pointOfView else { return }
        self.data.viewPosition = pov.simdPosition
        
    }
    
    private func makeBackground() {
        self.background.contents = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    func configureCamera() {
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 4
        camera.zNear = 0
        camera.zFar = 100
        
        self.cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
        let cameraOrbit = SCNNode()
        cameraOrbit.addChildNode(cameraNode)
        self.rootNode.addChildNode(cameraOrbit)
    }
    
    func configureTemporaryPlanet() {
        let program = SCNProgram()
        program.vertexFunctionName = "textureSamplerVertex"
        program.fragmentFunctionName = "textureSamplerFragment"

        program.handleBinding(ofBufferNamed: "data", frequency: .perFrame) { buffer, _, _, _ in
            buffer.writeBytes(&self.data, count: MemoryLayout<CustomData>.stride)
        }

        
        let heightMap = SCNMaterialProperty(contents: Assets.earthHeightMap!)
        let landOutline = SCNMaterialProperty(contents: Assets.earthLandOutline!)
        let continentalOutline = SCNMaterialProperty(contents: Assets.earthContinentalBoundaries!)
        let countriesOutline = SCNMaterialProperty(contents: Assets.earthCountriesOutline!)
        let snowCover = SCNMaterialProperty(contents: Assets.earthSnowCover!)
        let nightLights = SCNMaterialProperty(contents: Assets.earthLightEmission!)
        let specularMap = SCNMaterialProperty(contents: Assets.earthSpecularMap!)
        
        let planetMaterial = SCNMaterial()
        planetMaterial.program = program
        planetMaterial.setValuesForKeys([
            "heightMap": heightMap,
            "countryLand": landOutline,
            "continentOutline": continentalOutline,
            "countriesOutline": countriesOutline,
            "snowCover": snowCover,
            "nightLights": nightLights,
            "specularMap": specularMap
        ])

        

        
        let width = 2048 / 16
        
        let planetGeometry = SCNSphere(radius: 2)
        planetGeometry.segmentCount = width
        planetGeometry.materials = [planetMaterial]

        let planetNode = SCNNode(geometry: planetGeometry)

        
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
