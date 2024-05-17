struct MapInfo {
    float4 mat;
    float d;
};

MapInfo opU(MapInfo a, MapInfo b) {
    // MapInfo r = ((a.d < b.d) ? a : b);
    MapInfo r = a;
    if (b.d < a.d) r = b;
    return r;
}

float sdSphere(float3 p, float r) {
    return length(p) - r;
}

MapInfo map(float3 p) {
    // return sdSphere(p, 0.5);
    MapInfo info;
    info.d = 9999.0;

    for (int i = 0; i < SDF_ARR_SIZE; i += 3) {
        if (i >= _SDFCount * 2) break;
        float4 dataA = _SDFs[i];
        float4 dataB = _SDFs[i+1];
        float4 dataC = _SDFs[i+2];

        int kind = int(dataA.x);
        float3 oScale = dataA.yzw;
        float3 oPos = dataB.xyz;

        float3 rayPos = (p - oPos) / oScale;

        MapInfo newInfo;
        newInfo.mat = dataC;
        // TODO: Test performance difference between [call] and [forceswitch]
        [call] switch (i) {
            default:
            case 0:
                newInfo.d = sdSphere(rayPos, 1);
                info = opU(info, newInfo);
                break;
        }
    }

    return info;
}

// Thanks IQ
float3 calcNormal(float3 p)
{
    const float h = 0.001;
    const float2 k = float2(1.0,-1.0);
    return normalize( k.xyy*map( p + k.xyy*h ).d +
                      k.yyx*map( p + k.yyx*h ).d +
                      k.yxy*map( p + k.yxy*h ).d +
                      k.xxx*map( p + k.xxx*h ).d );
}

struct RayHit {
    float4 mat;
    bool hit;
    float t;
    float3 normal;
};

RayHit trace(float3 ro, float3 rd, float tmin, float tmax, const uint max_steps, const float precision) {
    RayHit rhit;
    rhit.hit = false;

    float t = tmin;
    for (uint i = 0; i < max_steps; i++) {
        float3 p = ro + rd * t;
        MapInfo info = map(p);
        t += info.d;
        if (info.d < precision) {
            rhit.mat = info.mat;
            rhit.hit = true;
            rhit.t = t;
            rhit.normal = normalize(calcNormal(p));
            break;
        }
    }
    return rhit;
}

float4 calc(float4 bg_color, float3 ro, float3 rd) {
    float4 c = bg_color;

    RayHit hit = trace(ro, rd, 0.02, 1000.0, 128, 0.05);
    if (hit.hit) {
        // float t = hit.t / 128.0;
        // c = float4(float3(t,t,t), 1.0);

        // c = float4(0.5, 0.3, 1.0, 1.0);

        float n_dot_l = max(dot(normalize(_LightDirection), hit.normal), 0.0);
        c = float4(hit.mat.rgb * n_dot_l,1.0);
        // c = float4(hit.normal, 1.0);
    }

    return c;
}
