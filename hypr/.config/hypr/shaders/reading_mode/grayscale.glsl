#version 320 es

/*
   E-ink Reading Mode Shader for Hyprland
   
   This shader simulates an e-ink display (like Kindle) to reduce eye strain and improve
   readability for text-heavy work. It combines mathematical techniques to create realistic
   paper texture and ink appearance.
   
   Key Techniques:
   - Bayer Matrix Dithering: Breaks up smooth gradients
   - Hash-based Noise: Deterministic "random" patterns for paper grain
   - Multi-octave Texture: Layers different scales of detail
   - Directional Grain: Simulates paper fiber direction
   - Vignette: Subtle edge darkening like real paper
   
   Performance: Optimized with no trigonometry (sin/cos), uses fast hash functions
*/

precision highp float;
in vec2 v_texcoord;
uniform sampler2D tex;
out vec4 fragColor;

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BAYER MATRIX DITHERING
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4x4 Bayer matrix helps break up smooth gradients into texture
// so it looks less "digital" and more like real paper

float getBayer(vec2 pos) {
    int x = int(mod(pos.x, 4.0));
    int y = int(mod(pos.y, 4.0));
    const mat4 bayer = mat4(
        0.0, 12.0,  3.0, 15.0,
        8.0,  4.0, 11.0,  7.0,
        2.0, 14.0,  1.0, 13.0,
        10.0,  6.0,  9.0,  5.0
    );
    return bayer[x][y] / 16.0;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIGH-PERFORMANCE HASH FUNCTION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// No trigonometry (sin/cos) - just bit manipulation for speed
// Creates deterministically random patterns for paper grain
// Source: https://www.shadertoy.com/view/4djSRW

float hash(vec2 p) {
    // fract() keeps only the decimal part for wave-like dusty pattern
    // .1031 is a special prime to avoid perfect alignments with pixel grid
    vec3 p3 = fract(vec3(p.xyx) * .1031);
    
    // dot product mixes x, y, z values so they depend on each other
    p3 += dot(p3, p3.yzx + 33.33);
    
    // return the final entangled decimal - deterministically random
    return fract((p3.x + p3.y) * p3.z);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MULTI-OCTAVE PAPER TEXTURE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Layers different scales of noise to create realistic paper fiber texture
// Like how real paper has large fibers AND fine grain

float paperTexture(vec2 uv) {
    float n = 0.0;
    n += hash(uv * 0.3) * 0.6;       // Very large fibers
    n += hash(uv * 0.8) * 0.4;       // Large fibers
    n += hash(uv * 2.5) * 0.3;       // Medium detail
    n += hash(uv * 6.0) * 0.2;       // Fine grain
    n += hash(uv * 15.0) * 0.1;      // Very fine grain
    return n / 1.6; // Normalize
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIRECTIONAL PAPER GRAIN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Simulates paper fibers running in one direction (like real paper)

float directionalGrain(vec2 uv) {
    vec2 direction = vec2(0.7, 0.3); // Fiber direction
    float grain = 0.0;
    grain += hash(uv * 3.0 + direction * 2.0) * 0.5;
    grain += hash(uv * 8.0 + direction * 5.0) * 0.3;
    return grain / 0.8;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VIGNETTE EFFECT
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Subtle darkening at edges like real paper

float vignette(vec2 uv) {
    vec2 center = uv - 0.5;
    float dist = length(center);
    // smoothstep creates S-curve so shadow falls off naturally
    return 1.0 - smoothstep(0.4, 1.2, dist) * 0.15;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN SHADER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    
    // ─────────────────────────────────────────────────────────────
    // GRAYSCALE CONVERSION
    // ─────────────────────────────────────────────────────────────
    // Not using simple average (r+g+b)/3 because human eyes see
    // green as brighter than blue. These are proper luminance weights.
    float gray = dot(pixColor.rgb, vec3(0.299, 0.587, 0.114));
    
    // ─────────────────────────────────────────────────────────────
    // E-INK CHARACTERISTIC RESPONSE CURVE
    // ─────────────────────────────────────────────────────────────
    // Real e-ink isn't linear. This exponent simulates ink clumping.
    gray = pow(gray, 1.2);
    
    // ─────────────────────────────────────────────────────────────
    // CONTRAST ENHANCEMENT WITH S-CURVE
    // ─────────────────────────────────────────────────────────────
    // Clips pure blacks/whites but keeps the middle smooth
    gray = smoothstep(0.08, 0.92, gray);
    
    // ─────────────────────────────────────────────────────────────
    // MID-TONE BOOST
    // ─────────────────────────────────────────────────────────────
    // Enhances readability by boosting mid-tones
    float midBoost = smoothstep(0.3, 0.5, gray) * (1.0 - smoothstep(0.5, 0.7, gray));
    gray += midBoost * 0.1;
    
    vec2 screenPos = gl_FragCoord.xy;
    
    // ─────────────────────────────────────────────────────────────
    // APPLY PAPER GRAIN
    // ─────────────────────────────────────────────────────────────
    float paperGrain = (paperTexture(screenPos * 0.3) - 0.5) * 0.035;
    float dirGrain = (directionalGrain(screenPos * 0.4) - 0.5) * 0.025;
    
    float bayerValue = getBayer(screenPos);
    
    // Apply to bright areas (paper), also slightly to mid-tones for visible grain
    float textureMask = smoothstep(0.5, 0.95, gray);
    
    // Apply both grain types
    gray += paperGrain * textureMask;
    gray += dirGrain * textureMask * 0.7; // Directional grain slightly weaker
    
    // ─────────────────────────────────────────────────────────────
    // DITHERING FOR TEXTURE
    // ─────────────────────────────────────────────────────────────
    float ditherStrength = 0.025;
    gray += (bayerValue - 0.5) * ditherStrength * textureMask;
    
    // ─────────────────────────────────────────────────────────────
    // VIGNETTE FOR PAPER EDGES
    // ─────────────────────────────────────────────────────────────
    float vig = vignette(v_texcoord);
    gray *= vig;
    
    // Clamp to valid range
    gray = clamp(gray, 0.0, 1.0);
    
    // ─────────────────────────────────────────────────────────────
    // E-INK COLOR PALETTE
    // ─────────────────────────────────────────────────────────────
    // Warm off-white paper + cool near-black ink
    vec3 paperColor = vec3(0.94, 0.92, 0.86);
    vec3 inkColor   = vec3(0.10, 0.10, 0.12);
    
    // Add subtle color variation for paper texture realism
    float colorVariation = hash(screenPos * 0.08) * 0.02;
    paperColor += vec3(colorVariation, colorVariation * 0.5, -colorVariation * 0.2);
    
    // ─────────────────────────────────────────────────────────────
    // FINAL COLOR MIX
    // ─────────────────────────────────────────────────────────────
    // Linear interpolation: paints gray value onto our color palette
    vec3 finalColor = mix(inkColor, paperColor, gray);
    
    fragColor = vec4(finalColor, pixColor.a);
}
