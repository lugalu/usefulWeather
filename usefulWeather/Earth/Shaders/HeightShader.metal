#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

struct NodeBuffer {
    float4x4 modelTransform;
    float4x4 modelViewProjectionTransform;
    float4x4 modelViewTransform;
    float4x4 normalTransform;
    float2x3 boundingBox;
};

struct VertexInput {
    float3 position  [[attribute(SCNVertexSemanticPosition)]];
    float3 normal [[attribute(SCNVertexSemanticNormal)]];
    float2 uv [[attribute(SCNVertexSemanticTexcoord0)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 normal;
    float2 uv;
};

//https://easings.net/#easeInOutCubic
float easeInOutCubic(sampler textSample, float2 uv, texture2d<float, access::sample> map) {
    float color = map.sample(textSample, uv).r;
    return sqrt(1 - pow(color - 1, 2));
}

vertex VertexOut textureSamplerVertex(VertexInput in [[ stage_in ]],
                                      constant NodeBuffer& scn_node [[buffer(1)]],
                                      constant float4x4& modelMatrix [[buffer(2)]],
                                      texture2d<float, access::sample> heightMap [[texture(0)]]) {
    constexpr sampler textureSampler;
    
    float heightColor = easeInOutCubic(textureSampler, in.uv, heightMap);
    float3 vertexHeightOffset = in.normal * heightColor * 0.1 ;
    float3 newVertexPos = in.position + vertexHeightOffset;
    
    VertexOut out;
    out.worldPosition = (modelMatrix * float4(in.position, 1.0)).xyz;
    out.position = scn_node.modelViewProjectionTransform * float4(newVertexPos, 1);
    out.uv = in.uv;
    out.normal = in.normal;
    
    return out;
}
float4 calculateColor(VertexOut out,
                      sampler textureSampler,
                      texture2d<float, access::sample> heightMap,
                      texture2d<float, access::sample> countryLand,
                      texture2d<float, access::sample> continentOutline,
                      texture2d<float, access::sample> countriesOutline,
                      texture2d<float, access::sample> snowCover
                      ) {
    
    float4 continentOutlineColor = continentOutline.sample(textureSampler, out.uv);
    if (continentOutlineColor.a != 0) {
        return float4(1, 0.98
, 0.8, 1);
    }
    
    float4 countriesOutlineColor = countriesOutline.sample(textureSampler, out.uv);
    if (countriesOutlineColor.a != 0){
        return float4(0.16, 0.18, 0.21, 1);
    }
    
    float4 snowCoverColor = snowCover.sample(textureSampler, out.uv);
    if(snowCoverColor.a == 1) {
        float3 col = abs(1 - (float3(0.8, 0.93, 0.98) + easeInOutCubic(textureSampler, out.uv, snowCover)));
        return float4(col, 1);
    }
    
    float4 countryLandColor = countryLand.sample(textureSampler, out.uv);
    if (countryLandColor.a != 0) {
        float colorModifier = 1 - easeInOutCubic(textureSampler, out.uv, heightMap);
        float3 color = float3(0.66, 1, 0) * colorModifier;
        return float4(color, 1);
    }
    
    return float4(0, 0.4, 0.99, 1);
    
}


constant float3 lightDirection = float3(0.436436, -0.2, 0.218218);
constant float3 lightAmbient = float3(0.0);
constant float3 lightDiffuse = float3(1.0);
constant float3 lightSpecular = float3(1);

fragment float4 textureSamplerFragment(VertexOut out [[ stage_in ]],
                                       constant float3& viewPosition [[buffer(0)]],
                                       texture2d<float, access::sample> heightMap [[texture(0)]],
                                       texture2d<float, access::sample> countryLand [[texture(1)]],
                                       texture2d<float, access::sample> continentOutline [[texture(2)]],
                                       texture2d<float, access::sample> countriesOutline [[texture(3)]],
                                       texture2d<float, access::sample> snowCover [[texture(4)]],
                                       texture2d<float, access::sample> nightLights [[texture(5)]]
                                       ) {
    constexpr sampler textureSampler;
    
    float3 diffuseColor = calculateColor(out,
                          textureSampler,
                          heightMap,
                          countryLand,
                          continentOutline,
                          countriesOutline,
                          snowCover).rgb;
    
    
    //Ambient
    float3 ambient = lightAmbient * diffuseColor;
    float3 normal = normalize(out.normal);
    //Diffuse
    float3 diff = max(dot(normal, -lightDirection), 0.0);
    float3 diffuse = lightDiffuse * diff * diffuseColor;
    
    //Specular
    float3 viewDir = normalize(viewPosition - out.worldPosition);
    float3 reflectDir = reflect(lightDirection, normal);
    float3 spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
    float3 specular = lightSpecular * spec;
    
    float3 result = float3(ambient+diffuse+specular);
    if (result.r == 0 && result.g == 0 && result.b == 0){
        float4 nightLightsColor = nightLights.sample(textureSampler, out.uv);
        if (nightLightsColor.a != 0){
            return nightLightsColor;
        }
    }
    
    return float4(float3(ambient + diffuse + specular),1);
}
