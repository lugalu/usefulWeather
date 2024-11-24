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
    float2 uv [[attribute(SCNVertexSemanticTexcoord0)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut textureSamplerVertex(VertexInput in [[ stage_in ]], constant NodeBuffer& scn_node [[buffer(1)]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1);
    out.uv = in.uv;
    return out;
}

fragment float4 textureSamplerFragment(VertexOut out [[ stage_in ]],
                                       texture2d<float, access::sample> countryLand [[texture(0)]],
                                       texture2d<float, access::sample> continentOutline [[texture(1)]],
                                       texture2d<float, access::sample> countriesOutline [[texture(2)]]) {
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
        return float4(0.66, 1, 0, 1);
    }
    
    return float4(0, 0.4, 0.99, 1);
}
