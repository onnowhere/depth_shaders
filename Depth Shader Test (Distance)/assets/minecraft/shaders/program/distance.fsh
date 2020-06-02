#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;

uniform vec2 ScreenSize;
uniform float _FOV;

varying vec2 texCoord;

float near = 0.1; 
float far  = 1000.0;
  
float LinearizeDepth(float depth) 
{
    float z = depth * 2.0 - 1.0;
    return (near * far) / (far + near - z * (far - near));    
}

void main() {
    float depth = LinearizeDepth(texture2D(DiffuseDepthSampler, texCoord).r);
    float distance = length(vec3(1., (2.*texCoord - 1.) * vec2(ScreenSize.x/ScreenSize.y,1.) * tan(radians(_FOV / 2.))) * depth);
    if (mod(distance, 1.0) <= 0.05) {
        gl_FragColor = vec4(1.0,0.0,0.0,0.1);
    } else {
        gl_FragColor = vec4(texture2D(DiffuseSampler, texCoord).rgb, 1.0);
    }
}
