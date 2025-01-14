#[compute]
#version 450
#extension GL_EXT_shader_explicit_arithmetic_types_int8 : require

// Invocations in the (x, y, z) dimension
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, std430) restrict buffer led_buffer {
    u8vec4 data[];
} leds;

layout(set = 0, binding = 1, std430) readonly buffer parameters {
    float time;
    float ledcount;
} params;

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
    leds.data[gl_GlobalInvocationID.x] = u8vec4(hsv2rgb(vec3((gl_GlobalInvocationID.x+params.time)/params.ledcount, 1, 1)) * 255, 255);
}
