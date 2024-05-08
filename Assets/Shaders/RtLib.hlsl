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
    for (uint i = 0; i < max_steps; i++) {
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

float4 calc(float4 bg_color, float3 ro, float3 rd) {
    float4 c = bg_color;

    RayHit hit = trace(ro, rd, 0.02, 128, 0.05);
    if (hit.hit) {
        float t = hit.t / 128.0;
        // c = float4(float3(t,t,t), 1.0);
        c = float4(0.5, 0.3, 1.0, 1.0);
    }

    return c;
}
