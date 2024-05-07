float4 test(float4 bg_color) {
    float4 c = bg_color;
    c.rgb = 1.0 - c.rgb;
    return c;
}
