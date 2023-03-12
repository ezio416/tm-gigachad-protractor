
/*

Surface configuration: 

Provide two `vec2` arrays: ideal and zero. 

The "ideal" array should provide the most precise "best" sidespeed possible for that speed. 
The "zero" array should provide the sidespeed at which the car doesn't accelerate. 
All intermediate values can be linearly interpreted from these. 

Format of vec2: (speed, target_sidespeed)

*/

array<vec2> tarmac_ideal = {
    vec2(111, 3.75),
    vec2(118, 3.75),
    vec2(118.5, 5.9),
    vec2(129, 5.9),
    vec2(129.5, 5.5),
    vec2(200, 5.55),
    vec2(232, 5.75),
    vec2(280, 5.85)
};

array<vec2> tarmac_zero = {
    vec2(111, 11.32),
    vec2(112.64, 11.938),
    vec2(129.25, 13.975),
    vec2(145.5, 15.7),
    vec2(191.6, 19.92),
    vec2(220, 22),
    vec2(247, 24.2),
    vec2(264.425, 25.9050),
    vec2(277.5, 27.184)
};

array<vec2> dirt_ideal = {
    vec2(55, 1.0),
    vec2(100, 1.5),
    vec2(202, 2.15),
    vec2(250, 2.15)
};

array<vec2> dirt_zero = {
    vec2(55, 11.96),
    vec2(56.55, 12.18),
    vec2(80.25, 15.664),
    vec2(142.275, 24.0675),
    vec2(168.85, 26.54),
    vec2(202.65, 29.714),
    vec2(224.5, 31.525),
    vec2(250, 33.33)
};

array<vec2> plastic_ideal = {
    vec2(55, 1.0),
    vec2(99.5, 1.0),
    vec2(100, 1.3),
    vec2(142, 1.3),
    vec2(150, 1.725),
    vec2(184.5, 1.725),
    vec2(200, 2),
    vec2(250, 2)
};

array<vec2> plastic_zero = {
    vec2(55, 12.5),
    vec2(70, 16.6),
    vec2(94.5, 20.4),
    vec2(153.9, 28.2),
    vec2(230.4, 35.85),
    vec2(265.0, 39.35),
    vec2(250, 33.33),
    vec2(277.5, 41.45)
};

array<vec2> grass_ideal = {
    vec2(55, 1.0),
    vec2(80, 1.365),
    vec2(110, 1.4),
    vec2(145, 1.7),
    vec2(180, 2.0),
    vec2(216, 2.4),
    vec2(250, 2.8)
};

array<vec2> grass_zero = {
    vec2(55, 13.5),
    vec2(87, 17.6),
    vec2(112.6, 21.25),
    vec2(145.0, 25.42),
    vec2(216.4, 32.54),
    vec2(250, 35.4)
};

array<vec2> bw_dirt_ideal = {
    vec2(0, 2),
    vec2(25, 2),
    vec2(30, 2.3),
    vec2(60, 2.7),
    vec2(80, 2.85),
    vec2(130, 2.9)
};

array<vec2> bw_dirt_zero = {
    vec2(0, 8),
    vec2(56, 17),
    vec2(30, 2.3),
    vec2(73, 19.75),
    vec2(84.5, 21),
    vec2(103, 23.5),
    vec2(130, 26.5)
};

array<vec2> bw_tarmac_ideal = {
    vec2(0, 2.3),
    vec2(55, 2.4),
    vec2(60, 2.7),
    vec2(70, 2.8),
    vec2(90, 2.9),
    vec2(130, 3.1)
};

array<vec2> bw_tarmac_zero = {
    vec2(0, 8),
    vec2(55, 16),
    vec2(85, 20),
    vec2(110, 24),
    vec2(130, 26)
};

array<vec2> bw_grass_ideal = {
    vec2(0, 1.4),
    vec2(28, 1.7),
    vec2(75, 2.18),
    vec2(110, 2.2),
    vec2(130, 2.25)
};

array<vec2> bw_grass_zero = {
    vec2(0, 2),
    vec2(10, 6),
    vec2(30, 12),
    vec2(50, 17),
    vec2(110, 25),
    vec2(130, 27.4)
};

float backwards_min = 15;
float tarmac_min = 400 / 3.6;
float other_min = 200 / 3.6;

