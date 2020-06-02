#version 110

uniform sampler2D BlurSampler;
uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D TranslucentSampler;
uniform sampler2D TranslucentDepthSampler;

uniform vec2 FocusRange;
uniform vec2 DepthScale;

varying vec2 texCoord;
varying vec2 oneTexel;

float near = 0.1; 
float far  = 100.0; 
  
float LinearizeDepth(float depth) 
{
    float z = depth * 2.0 - 1.0; // back to NDC 
    return (2.0 * near * far) / (far + near - z * (far - near));    
}

void main() {
    float depth = LinearizeDepth(texture2D(TranslucentDepthSampler, texCoord).r) / far; // divide by far for demonstration
    depth = clamp(depth, 0.0, 1.0);
    vec4 col = vec4(texture2D(DiffuseSampler, texCoord).rgb, 1.0);
    vec4 col_blur = vec4(texture2D(BlurSampler, texCoord).rgb, 1.0);
    vec2 focus_range = FocusRange;
    if (depth > focus_range.y) {
        depth *= DepthScale.x;
        focus_range.y *= DepthScale.x;
        depth -= focus_range.y;
        depth = clamp(depth, 0.0, 1.0);
        col = col*(1.0-depth) + col_blur*(depth);
    } else if (depth < focus_range.x) {
        depth *= DepthScale.y;
        focus_range.x *= DepthScale.y;
        depth += 1.0 - focus_range.x;
        depth = clamp(depth, 0.0, 1.0);
        col = col*(depth) + col_blur*(1.0-depth);
    }
    gl_FragColor = col;
}
