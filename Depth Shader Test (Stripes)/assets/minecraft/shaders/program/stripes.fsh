#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;

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
    if (mod(depth, 1.0) <= 0.02) {
        gl_FragColor = vec4(1.0,0.0,0.0,0.1);
    } else {
        gl_FragColor = vec4(texture2D(DiffuseSampler, texCoord).rgb, 1.0);
    }
}
