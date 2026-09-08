#version 460 core
#include <flutter/runtime_effect.glsl>

out vec4 fragColor;

uniform vec2 u_resolution;      // Viewport widget layout dimensions
uniform float u_opacity;       
uniform float u_linethickness;  // Target thickness in raw screen pixels (e.g. 1.0)
uniform float u_cellsize;       // Static cell width on your display glass (e.g. 40.0)
uniform float u_zoomScale;      // Current native zoom scale factor (Index 4)

void main() {
    // 1. Get absolute physical screen pixel coordinates
    vec2 screenPos = FlutterFragCoord().xy;

    // 2. FIXED CELL SIZING & COMPENSATION:
    // To make sure the cells stay a fixed size on the glass when Flutter scales 
    // the canvas geometry up and down, we divide the coordinates by the zoom scale.
    // This perfectly cancels out the compression/expansion of the native matrix.
    vec2 gridSpace = screenPos / (u_cellsize * u_zoomScale);

    // 3. Transform coordinates into a continuous symmetrical triangle wave distance field
    vec2 distanceToCellCenter = abs(fract(gridSpace - 0.5) - 0.5);

    // 4. Analytical Derivative calculation matching our screen-space loop
    vec2 derivatives = vec2(1.0) / (u_cellsize * u_zoomScale);

    // 5. Anti-alias precisely across exactly 1 physical screen pixel
    vec2 targetThickness = u_linethickness * derivatives;
    vec2 smoothLines = smoothstep(targetThickness, targetThickness + derivatives, distanceToCellCenter);

    // 6. Intersect structural grids together to construct vertical and horizontal lines
    float gridLine = 1.0 - (smoothLines.x * smoothLines.y);

    // 7. Output final color combined cleanly with your alpha opacity variable
    fragColor = vec4(vec3(gridLine), gridLine * u_opacity);
}
