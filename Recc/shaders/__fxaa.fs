#version 330

in vec2 fragTexCoord;
out vec4 finalColor;

uniform sampler2D texture0;
uniform vec2 resolution;

void main() {
    vec2 texelSize = 1.0 / resolution;
    vec2 uv = fragTexCoord;

    // Luma-Gewichte
    const vec3 luma = vec3(0.299, 0.587, 0.114);

    // Nachbarpixel samplen
    vec3 rgbNW = texture(texture0, uv + vec2(-1.0, -1.0) * texelSize).rgb;
    vec3 rgbNE = texture(texture0, uv + vec2( 1.0, -1.0) * texelSize).rgb;
    vec3 rgbSW = texture(texture0, uv + vec2(-1.0,  1.0) * texelSize).rgb;
    vec3 rgbSE = texture(texture0, uv + vec2( 1.0,  1.0) * texelSize).rgb;
    vec3 rgbM  = texture(texture0, uv).rgb;

    float lumaNW = dot(rgbNW, luma);
    float lumaNE = dot(rgbNE, luma);
    float lumaSW = dot(rgbSW, luma);
    float lumaSE = dot(rgbSE, luma);
    float lumaM  = dot(rgbM,  luma);

    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

    // Kantenerkennung — bei zu wenig Kontrast direkt raus
    if ((lumaMax - lumaMin) < lumaMax * 0.125) {
        finalColor = vec4(rgbM, 1.0);
        return;
    }

    // Blur-Richtung berechnen
    vec2 dir;
    dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
    dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));

    const float REDUCE_MIN = 1.0 / 128.0;
    const float REDUCE_MUL = 1.0 / 8.0;
    const float SPAN_MAX   = 8.0;

    float dirReduce = max(
        (lumaNW + lumaNE + lumaSW + lumaSE) * 0.25 * REDUCE_MUL,
        REDUCE_MIN
    );
    float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
    dir = clamp(dir * rcpDirMin, -SPAN_MAX, SPAN_MAX) * texelSize;

    // Zwei Blur-Samples (nah)
    vec3 rgbA =
        texture(texture0, uv + dir * (1.0/3.0 - 0.5)).rgb +
        texture(texture0, uv + dir * (2.0/3.0 - 0.5)).rgb;
    rgbA *= 0.5;

    // Zwei weitere Samples (weit) für bessere Qualität
    vec3 rgbB = rgbA * 0.5 + 0.25 * (
        texture(texture0, uv + dir * -0.5).rgb +
        texture(texture0, uv + dir *  0.5).rgb
    );

    float lumaB = dot(rgbB, luma);
    finalColor = vec4(
        (lumaB < lumaMin || lumaB > lumaMax) ? rgbA : rgbB,
        1.0
    );
}