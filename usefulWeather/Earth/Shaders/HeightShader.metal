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

//https://easings.net/#easeInOutCubic
float easeInOutCubic(sampler textSample, float2 uv, texture2d<float, access::sample> map) {
    float color = map.sample(textSample, uv).r;
    return sqrt(1 - pow(color - 1, 2));
}

vertex VertexOut textureSamplerVertex(VertexInput in [[ stage_in ]],
                                      constant NodeBuffer& scn_node [[buffer(1)]],
                                      texture2d<float, access::sample> heightMap [[texture(0)]]) {
    constexpr sampler textureSampler;
    
    float heightColor = easeInOutCubic(textureSampler, in.uv, heightMap);
    float3 vertexHeightOffset = in.normal * heightColor * 0.1 ;
    float3 newVertexPos = in.position + vertexHeightOffset;
    
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(newVertexPos, 1);
    out.uv = in.uv;
    
    return out;
}

fragment float4 textureSamplerFragment(VertexOut out [[ stage_in ]],
                                       texture2d<float, access::sample> heightMap [[texture(0)]],
                                       texture2d<float, access::sample> countryLand [[texture(1)]],
                                       texture2d<float, access::sample> continentOutline [[texture(2)]],
                                       texture2d<float, access::sample> countriesOutline [[texture(3)]],
                                       texture2d<float, access::sample> snowCover [[texture(4)]]
                                       ) {
    constexpr sampler textureSampler;

    
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
