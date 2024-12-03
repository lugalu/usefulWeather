//Created by Lugalu on 28/10/24.

import SceneKit

fileprivate struct CustomData {
    var viewPosition: simd_float3 = simd_float3()
    var lightDirection: simd_float3 = simd_float3(0.436436, -0.2, 0.218218)
}
//TODO: missing geometry for weather,
class EarthScene: SCNScene, SCNSceneRendererDelegate {
    
    private var planetNode: SCNNode?
    private var weatherNode: SCNNode?
    private var data: CustomData = CustomData()
    let cameraNode: SCNNode = SCNNode()
    var locator: ServiceLocator?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        makeBackground()
        configureCamera()
        configurePlanet()
    }
    
    private func makeBackground() {
        self.background.contents = Assets.starBackground!
    }
    
    private func configureCamera() {
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
    
    private func configurePlanet() {
        let program = SCNProgram()
        program.vertexFunctionName = "textureSamplerVertex"
        program.fragmentFunctionName = "textureSamplerFragment"

        program.handleBinding(ofBufferNamed: "data", frequency: .perFrame) { buffer, _, _, _ in
            buffer.writeBytes(&self.data, count: MemoryLayout<CustomData>.stride)
        }
        
        let planetMaterial = SCNMaterial()
        planetMaterial.program = program
        planetMaterial.setValuesForKeys(makeEarthMaterialDict())

        let width = 2048 / 16
        
        let planetGeometry = SCNSphere(radius: 2)
        planetGeometry.segmentCount = width
        planetGeometry.materials = [planetMaterial]

        let planetNode = SCNNode(geometry: planetGeometry)
        self.rootNode.addChildNode(planetNode)
        self.planetNode = planetNode
    }
    
    private func makeEarthMaterialDict() -> [String: Any] {
        let heightMap = SCNMaterialProperty(contents: Assets.earthHeightMap!)
        let landOutline = SCNMaterialProperty(contents: Assets.earthLandOutline!)
        let continentalOutline = SCNMaterialProperty(contents: Assets.earthContinentalBoundaries!)
        let countriesOutline = SCNMaterialProperty(contents: Assets.earthCountriesOutline!)
        let snowCover = SCNMaterialProperty(contents: Assets.earthSnowCover!)
        let nightLights = SCNMaterialProperty(contents: Assets.earthLightEmission!)
        let specularMap = SCNMaterialProperty(contents: Assets.earthSpecularMap!)
        
        return [
            "heightMap": heightMap,
            "countryLand": landOutline,
            "continentOutline": continentalOutline,
            "countriesOutline": countriesOutline,
            "snowCover": snowCover,
            "nightLights": nightLights,
            "specularMap": specularMap
        ]
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
        data.lightDirection = rotateAroundYAxis(vector: data.lightDirection, angle: newAngle * .pi/180)
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let pov = renderer.pointOfView else { return }
        self.data.viewPosition = pov.simdPosition
        
    }

    func injectLocator(_ locator: ServiceLocator) {
        self.locator = locator
        fetchMaps()
    }
    
    private func fetchMaps() {
        Task{
            do {
                let database = locator?.getDatabaseService()
                var mapData: MapData
                
                if let cache = try await database?.fetchMapCache(),
                   cache.timestamp.timeIntervalSinceNow < 60 * 60
                {
                    mapData = cache
                }else {
                    mapData = try await downloadMaps(network: locator?.getNetworkService(),
                                                          decoder: locator?.getDecoderService())
                    try await database?.insertNewMapCache(mapData)
                }
                
                createWeatherNode(mapData)
                
            }catch{
                print("hm", error.localizedDescription)
            }
            
        }
    }
    
    private func downloadMaps(network: NetworkInterface?, decoder: DecoderInterface?) async throws -> MapData {
        async let temperatureMapData = network?.downloadData(from: .temperatureMap)
        async let cloudMapData = network?.downloadData(from: .cloudMap)
        async let rainMapData = network?.downloadData(from: .precipitationMap)
        
        
        let (temperatureMap, cloudMap, rainMap) = try await (temperatureMapData, cloudMapData, rainMapData)
        
        return MapData(temperatureMap: temperatureMap, cloudMap: cloudMap, rainMap: rainMap)
    }
    
    
    private func createWeatherNode(_ mapData: MapData) {
        let program = SCNProgram()
        program.vertexFunctionName = "weatherVertexShader"
        program.fragmentFunctionName = "cloudsShader"
        program.isOpaque = false
        
        
        let weatherMaterial = SCNMaterial()
        weatherMaterial.program = program
        weatherMaterial.setValuesForKeys(makeWeatherMaterialsDict(mapData))
        
        let width = 2048 / 16
        let weatherGeometry = SCNSphere(radius: 2.3)
        weatherGeometry.segmentCount = width
        weatherGeometry.materials = [weatherMaterial]
        
        let weatherNode = SCNNode(geometry: weatherGeometry)
        self.rootNode.addChildNode(weatherNode)
        self.weatherNode = weatherNode
    }
    
    private func makeWeatherMaterialsDict(_ mapData: MapData) -> [String: Any]{
        let temperature = SCNMaterialProperty()
        if let temperatureMap = mapData.temperatureMap {
            temperature.contents = temperatureMap
        }
        
        let cloud = SCNMaterialProperty()
        if let cloudMap = mapData.cloudMap {
            cloud.contents = cloudMap
        }
        
        let rain = SCNMaterialProperty()
        if let rainMap = mapData.rainMap {
            rain.contents = rainMap
        }
        
        return [
            "temperatureMap": temperature,
            "cloudMap": cloud,
            "rain": rain
        ]
        
    }
    
}


