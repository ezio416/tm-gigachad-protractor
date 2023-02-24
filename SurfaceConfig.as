vec4 getColor(int idx) {
    switch (idx) {
        case 0:
            return COLOR_100;
        case 1:
            return COLOR_90;
        case 2:
            return COLOR_50;
        case 3:
            return COLOR_0;
    }
    return COLOR_0;

}

array<vec2> tarmac_fs_arr = {
    vec2(0.0, 3),
    vec2(4.5, 2),
    vec2(5.5, 0),
    vec2(6.5, 1),
    vec2(8.0, 2),
    vec2(12.5, 3)
};

array<vec2> gdp_arr = {
    vec2(0.0, 3),
    vec2(.75, 2),
    vec2(1.2, 0),
    vec2(5.0, 1),
    vec2(10, 2),
    vec2(20, 3)
};

array<vec2> b_dirt_arr = {
    vec2(0, 3),
    vec2(1.7, 2),
    vec2(2, 0),
    vec2(5.0, 1),
    vec2(12.5, 2),
    vec2(20, 3)
};

array<vec2> b_tarmac_arr = {
    vec2(0, 3),
    vec2(4, 2),
    vec2(8, 0),
    vec2(13, 1),
    vec2(20, 2),
    vec2(30, 3)
};

