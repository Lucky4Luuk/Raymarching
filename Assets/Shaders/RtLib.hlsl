float sdSphere(float3 p, float r) {
    return length(p) - r;
}

float map(float3 p) {
    return sdSphere(p, 0.5);
}

struct RayHit {
    bool hit;
    float t;
};

RayHit trace(float3 ro, float3 rd, float tmin, const uint max_steps, const float precision) {
    RayHit rhit;
    rhit.hit = false;

    float t = tmin;
    for (int i = 0; i < max_steps; i++) {
        float3 p = ro + rd * t;
        float d = map(p);
        t += d;
        if (d < precision) {
            rhit.hit = true;
            rhit.t = t;
            break;
        }
    }
    return rhit;
}

float4 calc(float4 bg_color) {
    float4 c = bg_color;

    

    return c;
}
