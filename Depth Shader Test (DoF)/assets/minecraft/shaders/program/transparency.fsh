#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D TranslucentSampler;
uniform sampler2D TranslucentDepthSampler;
uniform sampler2D ItemEntitySampler;
uniform sampler2D ItemEntityDepthSampler;
uniform sampler2D ParticlesSampler;
uniform sampler2D ParticlesDepthSampler;
uniform sampler2D WeatherSampler;
uniform sampler2D WeatherDepthSampler;
uniform sampler2D CloudsSampler;
uniform sampler2D CloudsDepthSampler;

varying vec2 texCoord;

#define NUM_LAYERS 6
#define try_add_sample(color_sampler, depth_sampler) { \
    vec4 color = texture2D(color_sampler, texCoord); \
    if (color.a > 0.0) { \
        color_samples[sample_count] = color; \
        depth_samples[sample_count] = texture2D(depth_sampler, texCoord).r; \
        sample_count++; \
    } \
}

// Avoid an array of structs to keep data aligned in memory, helps some on older hardware
// The color samples can then be linearly scanned after sorting is done, making optimal use of the cache lines
vec4 color_samples[NUM_LAYERS];
float depth_samples[NUM_LAYERS];

vec4 blend(vec4 tex, vec4 sample) {
    float factor = 1.0 - sample.a;
    return (tex * factor) + sample;
}

void main() {
    // There will always be at least one sample (from the diffuse layer)
    int sample_count = 1;
    
    // Always sample the diffuse layer to provide a base color for blending
    color_samples[0] = texture2D(DiffuseSampler, texCoord);
    color_samples[0].w = 1.0; // Discard the alpha channel to fix issues with cutout textures
    depth_samples[0] = texture2D(DiffuseDepthSampler, texCoord).r;
    
    // Try to add a sample from each layer
    // If the sample's color component is empty, do not add it to the list of samples
    try_add_sample(TranslucentSampler, TranslucentDepthSampler);
    try_add_sample(ItemEntitySampler, ItemEntityDepthSampler);
    try_add_sample(ParticlesSampler, ParticlesDepthSampler);
    try_add_sample(WeatherSampler, WeatherDepthSampler);
    try_add_sample(CloudsSampler, CloudsDepthSampler);

    // Perform an insertion sort over the samples in the array, sorted by descending depth
    for (int i = 1; i < sample_count; i++) {
        int j = i;
        
        while (depth_samples[j] > depth_samples[j - 1]) {
            vec4 color = color_samples[j];
            color_samples[i] = color_samples[i - 1];
            color_samples[i - 1] = color;
            
            float depth = depth_samples[j];
            depth_samples[i] = depth_samples[i - 1];
            depth_samples[i - 1] = depth;
            
            // Postpone the bounds check as it will never be true on the first iteration
            if (--j <= 0) {
                break;
            }
        }
    }
    
    // Blend and merge the framebuffer samples
    vec4 tex = vec4(0.0);
    
    for (int i = 0; i < sample_count; i++) {
        tex = blend(tex, color_samples[i]);
    }
    
    // Write the blended colors to the final framebuffer output
    gl_FragColor = vec4(tex.rgb, 1.0);
}
