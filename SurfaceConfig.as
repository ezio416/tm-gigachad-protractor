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

/*

Surface configuration: 

Types: 
  * float: literal side speed
  * vec4: Format (low_speed, low_side_speed, high_speed, high_side_speed)

Required objects:
  * [surface]_min (float): Minimum speed for tool activation (in m/s)
  * [surface]_target (float): Optimal side speed 
  * [surface]_base (vec4): Where you accelerate more than noslide. 
  * [surface]_outer (vec4): Where you accelerate more than 0. 
*/

// outer: 0.005 m/s/ms 
// base: 0 m/s/ms

float tarmac_min = (400.0) / 3.6;
float tarmac_target = 5.575;
vec4 tarmac_base = vec4((400 / 3.6), 6.5, 1000 / 3.6, 17);
vec4 tarmac_outer = vec4((400 / 3.6), 11, 1000 / 3.6, 26.5);

float grass_min = (200.0) / 3.6;
float grass_target = 1.6;
vec4 grass_base = vec4(121, 8.8, 220, 21.75);
vec4 grass_outer = vec4(72, 15.5, 220, 32.6);

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

