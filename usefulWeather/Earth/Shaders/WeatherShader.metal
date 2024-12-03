//Created by Lugalu on 02/12/24.

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>
#pragma transparent

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
    float3 normal;
    float2 uv;
};

vertex VertexOut weatherVertexShader(VertexInput in [[ stage_in ]],
                                      constant NodeBuffer& scn_node [[buffer(2)]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1);
    out.uv = in.uv;
    out.normal = in.normal;
    
    return out;
}


fragment float4 cloudsShader(VertexInput in [[stage_in]],
                             sampler textureSampler,
                             texture2d<float, access::sample> cloudsMap,
                             texture2d<float, access::sample> rainMap,
                             texture2d<float, access::sample> temperatureMap
                             ){
    return float4(1,0,0,0.2);
}
