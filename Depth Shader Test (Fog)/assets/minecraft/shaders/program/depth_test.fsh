#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;

in vec2 texCoord;
in vec2 oneTexel;
out vec4 fragColor;

void main() {
    float col = 1.0-(1.0-texture(DiffuseDepthSampler, texCoord).r)*500.0;
    fragColor = vec4(vec3(col), 1.0);
}
