//
//  Variablur.ci.metal
//  Variablur
//
//  Created by Shindge Wong on 5/29/26.
//  Copyright © 2026 Whatsin Lab. All rights reserved.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h>

using namespace metal;

static inline float variablur_clamp01(float value)
{
    return clamp(value, 0.0f, 1.0f);
}

static inline float variablur_sample_cubic(float a1, float a2, float t)
{
    float invT = 1.0f - t;
    return 3.0f * invT * invT * t * a1 + 3.0f * invT * t * t * a2 + t * t * t;
}

static inline float variablur_sample_cubic_derivative(float a1, float a2, float t)
{
    float invT = 1.0f - t;
    return 3.0f * invT * invT * a1
        + 6.0f * invT * t * (a2 - a1)
        + 3.0f * t * t * (1.0f - a2);
}

static inline float variablur_curve(float progress, float x1, float y1, float x2, float y2)
{
    float x = variablur_clamp01(progress);
    float t = x;

    for (int i = 0; i < 5; i++) {
        float currentX = variablur_sample_cubic(x1, x2, t) - x;
        float derivative = variablur_sample_cubic_derivative(x1, x2, t);
        if (abs(derivative) < 0.0001f) {
            break;
        }
        t = variablur_clamp01(t - currentX / derivative);
    }

    float low = 0.0f;
    float high = 1.0f;
    for (int i = 0; i < 5; i++) {
        float currentX = variablur_sample_cubic(x1, x2, t);
        if (abs(currentX - x) < 0.0001f) {
            break;
        }
        if (currentX < x) {
            low = t;
        } else {
            high = t;
        }
        t = (low + high) * 0.5f;
    }

    return variablur_clamp01(variablur_sample_cubic(y1, y2, t));
}

static inline float variablur_sampled_curve(
    float progress,
    float s0,
    float s1,
    float s2,
    float s3,
    float s4,
    float s5,
    float s6,
    float s7,
    float s8
) {
    float scaled = variablur_clamp01(progress) * 8.0f;
    int index = min(int(floor(scaled)), 7);
    float local = scaled - float(index);
    float samples[9] = { s0, s1, s2, s3, s4, s5, s6, s7, s8 };
    return mix(samples[index], samples[index + 1], local);
}

static inline float variablur_rounded_box_sdf(float2 point, float2 halfSize, float radius)
{
    float r = min(max(radius, 0.0f), min(halfSize.x, halfSize.y));
    float2 delta = abs(point) - (halfSize - float2(r));
    float outside = length(max(delta, float2(0.0f)));
    float inside = min(max(delta.x, delta.y), 0.0f);
    return outside + inside - r;
}

extern "C" { namespace coreimage {

half4 variablurAllMask(
    float width,
    float height,
    float cornerRadius,
    float fadeWidth,
    float curveMode,
    float c0,
    float c1,
    float c2,
    float c3,
    float c4,
    float c5,
    float c6,
    float c7,
    float c8,
    coreimage::destination dest
) {
    float2 size = max(float2(width, height), float2(1.0f));
    float2 halfSize = size * 0.5f;
    float2 point = dest.coord() + float2(0.5f) - halfSize;
    float distance = variablur_rounded_box_sdf(point, halfSize, cornerRadius);
    float progress = variablur_clamp01(1.0f + distance / max(fadeWidth, 1.0f));
    float alphaValue = curveMode < 0.5f
        ? variablur_curve(progress, c0, c1, c2, c3)
        : variablur_sampled_curve(progress, c0, c1, c2, c3, c4, c5, c6, c7, c8);
    half alpha = half(alphaValue);
    return half4(alpha, alpha, alpha, alpha);
}

half4 variablurDirectionalMask(
    float width,
    float height,
    float startX,
    float startY,
    float endX,
    float endY,
    float fadeLength,
    float curveMode,
    float c0,
    float c1,
    float c2,
    float c3,
    float c4,
    float c5,
    float c6,
    float c7,
    float c8,
    coreimage::destination dest
) {
    float2 start = float2(startX, startY);
    float2 end = float2(endX, endY);
    float2 direction = end - start;
    float lengthSquared = dot(direction, direction);

    if (lengthSquared < 0.0001f) {
        direction = float2(0.0f, -1.0f);
        lengthSquared = 1.0f;
    }

    float vectorLength = sqrt(lengthSquared);
    float2 normal = direction / vectorLength;
    float along = dot(dest.coord() + float2(0.5f) - start, normal);
    float denominator = max(fadeLength, 1.0f);
    float awayFromStart = variablur_clamp01(along / denominator);
    float progress = 1.0f - awayFromStart;
    float alphaValue = curveMode < 0.5f
        ? variablur_curve(progress, c0, c1, c2, c3)
        : variablur_sampled_curve(progress, c0, c1, c2, c3, c4, c5, c6, c7, c8);
    half alpha = half(alphaValue);
    return half4(alpha, alpha, alpha, alpha);
}

}}
