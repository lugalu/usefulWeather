//Created by Lugalu on 28/10/24.

import SceneKit

fileprivate struct CustomData {
    var viewPosition: simd_float3 = simd_float3()
    var lightDirection: simd_float3 = simd_float3(0.436436, -0.2, 0.218218)
}
//TODO: missing geometry for weather,
class EarthScene: SCNScene, SCNSceneRendererDelegate {

    private var planetNode: SCNNode?
    private var data: CustomData = CustomData()
    let cameraNode: SCNNode = SCNNode()

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        makeBackground()
        configureCamera()
        configureTemporaryPlanet()
    }
    
    func rotate(withAngle newAngle: Float) {
        func rotateAroundYAxis(vector: simd_float3, angle: Float) -> simd_float3 {
            let rotationMatrix = float3x3(
                simd_float3(cos(angle), 0, sin(angle)),
                simd_float3(0, 1, 0),
                simd_float3(-sin(angle), 0, cos(angle))
            )
            return rotationMatrix * vector
        }
       // self.planetNode?.simdEulerAngles = rotateAroundYAxis(vector: self.planetNode!.simdEulerAngles, angle: newAngle * .pi/180)
        data.lightDirection = rotateAroundYAxis(vector: data.lightDirection, angle: newAngle * .pi/180)
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
    
}
