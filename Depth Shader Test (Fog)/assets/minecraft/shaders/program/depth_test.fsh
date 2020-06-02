#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;

varying vec2 texCoord;
varying vec2 oneTexel;

void main() {
    gl_FragColor = 1.0-(1.0-texture2D(DiffuseDepthSampler, texCoord))*500.0;
}
