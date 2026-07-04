#version 330 core

in vec2 fragTexCoord;
out vec3 fragColor;

uniform sampler2D texture0;
uniform vec2 inverseScreenSize;

// ---------------------------------------------------------------
// Qualität einstellen — diese 3 Defines sind deine Stellschrauben
// ---------------------------------------------------------------
#define EDGE_THRESHOLD_MIN  0.0312  // Dunkle Bereiche ignorieren
                                    // kleiner = mehr AA in dunklen Bereichen
                                    // Bereich: 0.01 - 0.05

#define EDGE_THRESHOLD_MAX  0.063   // Kontrast-Schwelle für Kantenerkennung
                                    // kleiner = aggressiver (mehr Kanten erkannt)
                                    // größer = konservativer (nur starke Kanten)
                                    // Bereich: 0.063 (höchste Qualität) - 0.333 (schnellste)

#define ITERATIONS          12      // Wie weit der Shader entlang einer Kante sucht
                                    // höher = bessere Qualität, langsamer
                                    // Bereich: 4 (schnell) - 12 (beste Qualität)

#define SUBPIXEL_QUALITY    1.0    // Subpixel-AA Stärke
                                    // 0.0 = aus, 1.0 = maximum
                                    // 0.75 ist der empfohlene Sweet Spot

#define QUALITY(q) ((q) < 5 ? 1.0 : ((q) > 5 ? ((q) < 10 ? 2.0 : ((q) < 11 ? 4.0 : 8.0)) : 1.5))
// ---------------------------------------------------------------

float rgb2luma(vec3 rgb) {
    return sqrt(dot(rgb, vec3(0.299, 0.587, 0.114)));
}

void main() {
    vec2 uv = fragTexCoord;

    vec3 colorCenter = texture(texture0, uv).rgb;
    float lumaCenter = rgb2luma(colorCenter);

    float lumaDown  = rgb2luma(textureOffset(texture0, uv, ivec2( 0,-1)).rgb);
    float lumaUp    = rgb2luma(textureOffset(texture0, uv, ivec2( 0, 1)).rgb);
    float lumaLeft  = rgb2luma(textureOffset(texture0, uv, ivec2(-1, 0)).rgb);
    float lumaRight = rgb2luma(textureOffset(texture0, uv, ivec2( 1, 0)).rgb);

    float lumaMin = min(lumaCenter, min(min(lumaDown, lumaUp), min(lumaLeft, lumaRight)));
    float lumaMax = max(lumaCenter, max(max(lumaDown, lumaUp), max(lumaLeft, lumaRight)));
    float lumaRange = lumaMax - lumaMin;

    // Keine Kante → unverändert raus
    if (lumaRange < max(EDGE_THRESHOLD_MIN, lumaMax * EDGE_THRESHOLD_MAX)) {
        fragColor = colorCenter;
        return;
    }

    float lumaDownLeft  = rgb2luma(textureOffset(texture0, uv, ivec2(-1,-1)).rgb);
    float lumaUpRight   = rgb2luma(textureOffset(texture0, uv, ivec2( 1, 1)).rgb);
    float lumaUpLeft    = rgb2luma(textureOffset(texture0, uv, ivec2(-1, 1)).rgb);
    float lumaDownRight = rgb2luma(textureOffset(texture0, uv, ivec2( 1,-1)).rgb);

    float lumaDownUp    = lumaDown + lumaUp;
    float lumaLeftRight = lumaLeft + lumaRight;

    float lumaLeftCorners  = lumaDownLeft  + lumaUpLeft;
    float lumaDownCorners  = lumaDownLeft  + lumaDownRight;
    float lumaRightCorners = lumaDownRight + lumaUpRight;
    float lumaUpCorners    = lumaUpRight   + lumaUpLeft;

    float edgeHorizontal = abs(-2.0*lumaLeft   + lumaLeftCorners)  + abs(-2.0*lumaCenter + lumaDownUp)     * 2.0 + abs(-2.0*lumaRight + lumaRightCorners);
    float edgeVertical   = abs(-2.0*lumaUp     + lumaUpCorners)    + abs(-2.0*lumaCenter + lumaLeftRight)  * 2.0 + abs(-2.0*lumaDown  + lumaDownCorners);

    bool isHorizontal = (edgeHorizontal >= edgeVertical);
    float stepLength  = isHorizontal ? inverseScreenSize.y : inverseScreenSize.x;

    float luma1 = isHorizontal ? lumaDown : lumaLeft;
    float luma2 = isHorizontal ? lumaUp   : lumaRight;
    float gradient1 = luma1 - lumaCenter;
    float gradient2 = luma2 - lumaCenter;

    bool is1Steepest = abs(gradient1) >= abs(gradient2);
    float gradientScaled = 0.25 * max(abs(gradient1), abs(gradient2));

    float lumaLocalAverage;
    if (is1Steepest) {
        stepLength = -stepLength;
        lumaLocalAverage = 0.5 * (luma1 + lumaCenter);
    } else {
        lumaLocalAverage = 0.5 * (luma2 + lumaCenter);
    }

    vec2 currentUv = uv;
    if (isHorizontal) currentUv.y += stepLength * 0.5;
    else              currentUv.x += stepLength * 0.5;

    vec2 offset = isHorizontal ? vec2(inverseScreenSize.x, 0.0) : vec2(0.0, inverseScreenSize.y);
    vec2 uv1 = currentUv - offset * QUALITY(0);
    vec2 uv2 = currentUv + offset * QUALITY(0);

    float lumaEnd1 = rgb2luma(texture(texture0, uv1).rgb) - lumaLocalAverage;
    float lumaEnd2 = rgb2luma(texture(texture0, uv2).rgb) - lumaLocalAverage;

    bool reached1    = abs(lumaEnd1) >= gradientScaled;
    bool reached2    = abs(lumaEnd2) >= gradientScaled;
    bool reachedBoth = reached1 && reached2;

    if (!reached1) uv1 -= offset * QUALITY(1);
    if (!reached2) uv2 += offset * QUALITY(1);

    if (!reachedBoth) {
        for (int i = 2; i < ITERATIONS; i++) {
            if (!reached1) { lumaEnd1 = rgb2luma(texture(texture0, uv1).rgb) - lumaLocalAverage; }
            if (!reached2) { lumaEnd2 = rgb2luma(texture(texture0, uv2).rgb) - lumaLocalAverage; }

            reached1    = abs(lumaEnd1) >= gradientScaled;
            reached2    = abs(lumaEnd2) >= gradientScaled;
            reachedBoth = reached1 && reached2;

            if (!reached1) uv1 -= offset * QUALITY(i);
            if (!reached2) uv2 += offset * QUALITY(i);

            if (reachedBoth) break;
        }
    }

    float distance1 = isHorizontal ? (uv.x - uv1.x) : (uv.y - uv1.y);
    float distance2 = isHorizontal ? (uv2.x - uv.x) : (uv2.y - uv.y);

    bool  isDirection1  = distance1 < distance2;
    float distanceFinal = min(distance1, distance2);
    float edgeThickness = distance1 + distance2;

    bool isLumaCenterSmaller = lumaCenter < lumaLocalAverage;
    bool correctVariation1   = (lumaEnd1 < 0.0) != isLumaCenterSmaller;
    bool correctVariation2   = (lumaEnd2 < 0.0) != isLumaCenterSmaller;
    bool correctVariation    = isDirection1 ? correctVariation1 : correctVariation2;

    float pixelOffset = -distanceFinal / edgeThickness + 0.5;
    float finalOffset = correctVariation ? pixelOffset : 0.0;

    // Subpixel-Shift
    float lumaAverage    = (1.0/12.0) * (2.0*(lumaDownUp + lumaLeftRight) + lumaLeftCorners + lumaRightCorners);
    float subPixelOffset1     = clamp(abs(lumaAverage - lumaCenter) / lumaRange, 0.0, 1.0);
    float subPixelOffset2     = (-2.0*subPixelOffset1 + 3.0) * subPixelOffset1 * subPixelOffset1;
    float subPixelOffsetFinal = subPixelOffset2 * subPixelOffset2 * SUBPIXEL_QUALITY;

    finalOffset = max(finalOffset, subPixelOffsetFinal);

    vec2 finalUv = uv;
    if (isHorizontal) finalUv.y += finalOffset * stepLength;
    else              finalUv.x += finalOffset * stepLength;

    fragColor = texture(texture0, finalUv).rgb;
}