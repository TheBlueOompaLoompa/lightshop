#version 450
#extension GL_EXT_shader_explicit_arithmetic_types_int8 : enable

#define TARGET_LINEAR 0
#define TARGET_SPATIAL 1
#define TARGET_BINARY 2
#define TARGET_POSITION 3
#define TARGET_ROTATION 3

#define TYPE_INT 0
#define TYPE_FLOAT 1
#define TYPE_VECTOR2 2
#define TYPE_VECTOR3 3
#define TYPE_VECTOR4 4
#define TYPE_COLOR 5
#define TYPE_BOOL 6
#define TYPE_CURVE 7

#define CURVE_POINT_COUNT 5

#define PIXEL data.layers[layer * constant.count + p_i]
#define PIXEL_COUNT constant.count
#define TIME time
#define TARGET constant.target
#define INDEX ind

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer color_buffer {
    vec4 layers[];
} data;

layout(set = 0, binding = 1, std430) restrict buffer const_buffer {
    float time;
    uint count;
    uint layer_count;
    uint effect_count;
    uint target;
} constant;

layout(set = 0, binding = 2, std430) restrict buffer effects_list_bufffer {
    int data[];
} effects;

layout(set = 0, binding = 3, std430) restrict buffer params_bufffer {
    uint data[];
} pbuf;

layout(set = 0, binding = 4, std430) restrict buffer out_bufffer {
    u8vec4 data[];
} outbuf;

uint layer = 0;
uint p_i = 0;
uint ind = 0;
uint params_i = 0;
float time = 0;

int mixers[100];

///////////////////
// HELPERS BEGIN //
///////////////////

// NOISE REPLACE

float random(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

///////////////////
//  HELPERS END  //
///////////////////


///////////////////
// EFFECTS BEGIN //
///////////////////

// EFFECT REPLACE

void run_effect(uint effect_idx) {
    if(INDEX >= constant.count || INDEX < 0.0) return;
    switch(effect_idx) {
// RUN REPLACE
        case -1:
            mixers[layer] = int(pbuf.data[params_i]);
            params_i += 1;
            layer += 1;
            break;
    }
}

///////////////////
//  EFFECTS END  //
///////////////////

#define CURRENT data.layers[i * constant.count + p_i]
#define NEXT data.layers[(i+1) * constant.count + p_i]

void main() {
    p_i = gl_GlobalInvocationID.x;
    INDEX = p_i;
    time = constant.time;
    PIXEL = vec4(0.0, 0.0, 0.0, 1.0);
    layer = 0;
    for(uint i = 0; i < constant.effect_count; i++) {
        run_effect(effects.data[i]);
    }

    for(uint i = 0; i < layer; i++) {
        switch(mixers[i]) {
            case 0: // alpha
                NEXT = clamp(vec4(CURRENT.rgb * CURRENT.a + NEXT.rgb * (1.0 - CURRENT.a), CURRENT.a + NEXT.a), vec4(0.0, 0.0, 0.0, 0.0), vec4(1.0, 1.0, 1.0, 1.0));
                break;
            case 1: // add 
                NEXT = clamp(CURRENT + NEXT, vec4(0.0, 0.0, 0.0, 0.0), vec4(1.0, 1.0, 1.0, 1.0));
                break;
            case 2: // multiply 
                NEXT = clamp(CURRENT.rgba * NEXT.rgba, vec4(0.0, 0.0, 0.0, 0.0), vec4(1.0, 1.0, 1.0, 1.0));
        }
    }

    outbuf.data[p_i] = u8vec4(uint8_t(PIXEL.r*PIXEL.a*255), uint8_t(PIXEL.g*PIXEL.a*255), uint8_t(PIXEL.b*PIXEL.a*255), uint8_t(PIXEL.a*255));
}
