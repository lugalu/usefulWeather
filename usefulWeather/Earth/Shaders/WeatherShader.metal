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


float2 mercatorToEquirectangular(float2 uv) {
    //uv to equirectangular
    float lat = (uv.x) * 2 * M_PI_F;    // from 0 to 2PI
    float lon = (uv.y - .5f) * M_PI_F;  // from -PI to PI

    // equirectangular to mercator
    float x = lat;
    float y = log(tan(M_PI_F / 4. + lon / 2.));

    // bring x,y into [0,1] range
    x = x / (2 * M_PI_F);
    y = (y + M_PI_F) / (2 * M_PI_F);

    // sample mercator projection
    return float2(x,y);
}


float3 blur(sampler textureSampler, texture2d<float, access::sample> texture, float2 uv,float4 col, float kernelSize = 8) {
    const float PI = M_PI_F * 2;
    const float2 resolution = float2(2046, 1024);

    float direction = 16;
    float quality = 3;
    float2 kernelRadius = kernelSize / resolution;
    
    float3 accumulate = col.rgb;
    
    for( float d = 0; d < PI; d += PI / direction) {
        for(float i = 1 / quality; i < 1.01; i += 1.0 / quality) {
            
            float2 newUV = float2(cos(d), sin(d));
            newUV *= kernelRadius;
            newUV *= i;
            newUV += uv;
            accumulate += texture.sample(textureSampler, newUV).rgb;
        }
    }

    accumulate /= quality * direction + 1;
    
    return accumulate;
}

fragment float4 cloudsShader(VertexInput in [[stage_in]],
                             texture2d<float, access::sample> cloudMap ){
    constexpr sampler textureSampler;
    float2 uv = mercatorToEquirectangular(in.uv);
    
    float4 result = float4(0);
    
    float4 cloudsColor = cloudMap.sample(textureSampler, uv);
    if (cloudsColor.a > 0.2) {
        result =  calculateCloudsColor(uv, cloudsColor);
    }
    
    result.rgb = blur(textureSampler, cloudMap, uv,  result) * 2;

    return result;
}

fragment float4 temperatureShader(VertexInput in [[stage_in]], texture2d<float, access::sample> temperatureMap ){
    constexpr sampler textureSampler;
    float2 uv = mercatorToEquirectangular(in.uv);
    
    float4 result = temperatureMap.sample(textureSampler, uv);
    return result;
}

fragment float4 rainShader(VertexInput in [[stage_in]], texture2d<float, access::sample> rainMap ){
    constexpr sampler textureSampler;
    float2 uv = mercatorToEquirectangular(in.uv);
    
    float4 result = float4(0);
    

    float4 rainColor = rainMap.sample(textureSampler, uv);
    if (rainColor.a > 0) {
        result = calculateCloudsColor(uv, rainColor);
    }

    result.rgb = blur(textureSampler, rainMap, uv,  result, 6) * 10;

    return result;
}
