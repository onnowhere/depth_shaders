#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;

uniform vec2 ScreenSize;
uniform float _FOV;

in vec2 texCoord;
out vec4 fragColor;

float near = 0.1; 
float far  = 1000.0;
  
float LinearizeDepth(float depth) 
{
    float z = depth * 2.0 - 1.0;
    return (near * far) / (far + near - z * (far - near));    
}

void main() {
    float depth = LinearizeDepth(texture(DiffuseDepthSampler, texCoord).r);
    float distance = length(vec3(1., (2.*texCoord - 1.) * vec2(ScreenSize.x/ScreenSize.y,1.) * tan(radians(_FOV / 2.))) * depth);
    if (mod(distance, 1.0) <= 0.05) {
        fragColor = vec4(0.0,0.0,0.0,1.0);
    } else {
        fragColor = vec4(texture(DiffuseSampler, texCoord).rgb, 1.0);
    }
}
