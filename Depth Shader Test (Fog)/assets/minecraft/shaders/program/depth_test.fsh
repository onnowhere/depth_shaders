#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;

varying vec2 texCoord;
varying vec2 oneTexel;

void main() {
    float col = 1.0-(1.0-texture2D(DiffuseDepthSampler, texCoord).r)*500.0;
    gl_FragColor = vec4(vec3(col), 1.0);
}
