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
    float2 uv;
};

vertex VertexOut textureSamplerVertex(VertexInput in [[ stage_in ]],
                                      constant NodeBuffer& scn_node [[buffer(1)]],
                                      texture2d<float, access::sample> heightMap [[texture(0)]]) {
    constexpr sampler textureSampler;
    float col = heightMap.sample(textureSampler, in.uv).r;
    col = sqrt(1 - pow(col - 1, 2));
    float3 t = in.normal * col * 0.1 ;
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position + t, 1);
    
    
    out.uv = in.uv;
    return out;
}

fragment float4 textureSamplerFragment(VertexOut out [[ stage_in ]],
                                       texture2d<float, access::sample> heightMap [[texture(0)]],
                                       texture2d<float, access::sample> countryLand [[texture(1)]],
                                       texture2d<float, access::sample> continentOutline [[texture(2)]],
                                       texture2d<float, access::sample> countriesOutline [[texture(3)]]) {
    constexpr sampler textureSampler;
    float4 countryLandColor = countryLand.sample(textureSampler, out.uv);
    float4 continentOutlineColor = continentOutline.sample(textureSampler, out.uv);
    float4 countriesOutlineColor = countriesOutline.sample(textureSampler, out.uv);
    
    if (continentOutlineColor.a != 0) {
        return float4(1);
    }
    
    if (countriesOutlineColor.a != 0){
        return float4(0,0,0,1);
    }
    
    
    if (countryLandColor.a != 0) {
        float colorModifier = heightMap.sample(textureSampler, out.uv).r;
        colorModifier = 1 - sqrt(1 - pow(colorModifier- 1, 2));
        float3 col = float3(0.66, 1, 0) * colorModifier;
        
        return float4(col, 1);
    }
    
    return float4(0, 0.4, 0.99, 1);
}
