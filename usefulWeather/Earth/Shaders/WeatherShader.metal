//Created by Lugalu on 02/12/24.

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

float noise(float2 uv) {
    return fract( sin(uv.x * 124 + uv.y * 215) * 21412 );
}

float3 noiseSmooth(float2 uv) {
    
    float2 index = floor(uv);
    float2 newUV = fract(uv);
    newUV = smoothstep(0, 1, newUV);
    
    float topLeft = noise(index);
    float topRight = noise(index + float2(1,0));
    float top = mix(topLeft, topRight, newUV.x);
    
    float bottomLeft = noise(index + float2(0,1));
    float bottomRight = noise(index + float2(1, 1));
    float bottom = mix(bottomLeft, bottomRight, newUV.x);
    
    return float3(mix(top, bottom, newUV.y));
}

float4 calculateCloudsColor(float2 uv,float4 cloudsColor) {
    float alpha = (cloudsColor.r == 1 & cloudsColor.g == 1 && cloudsColor.b == 1) ? 1 : cloudsColor.a;
    
    float3 col = noiseSmooth(uv * 4.);
    col += noiseSmooth(uv * 8.) * 0.5;
    col += noiseSmooth(uv * 16.) * 0.25;
    col += noiseSmooth(uv * 32.) * 0.125;
    col += noiseSmooth(uv * 64.) * 0.0625;
    col /= 2;
    col *= smoothstep(0.2, .6, col);
    col = mix(1. - (col / 7.), 1, 1. - col);
    col *= alpha;
    return float4(col,alpha);
}

fragment float4 cloudsShader(VertexInput in [[stage_in]],
                             texture2d<float, access::sample> cloudMap,
                             texture2d<float, access::sample> rainMap,
                             texture2d<float, access::sample> temperatureMap
                 ){
    constexpr sampler textureSampler;
    
    float4 cloudsColor = cloudMap.sample(textureSampler, in.uv);
    if (cloudsColor.a > 0.2) {
        return calculateCloudsColor(in.uv, cloudsColor);
    }
    
    
    return float4(0,0,0,0);
}
