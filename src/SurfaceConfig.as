/*
Surface configuration:

Provide two `vec2` arrays: ideal and zero.

The "ideal" array should provide the most precise "best" sidespeed possible for that speed.
The "zero" array should provide the sidespeed at which the car doesn't accelerate.
All intermediate values can be linearly interpreted from these.

Format of vec2: (speed, target_sidespeed)
*/

const vec2[] tarmac_ideal = {
    vec2(111.0f, 5.9f),
    vec2(140.0f, 5.6f),
    vec2(210.0f, 5.75f),
    vec2(232.0f, 5.75f),
    vec2(280.0f, 5.85f)
};

const vec2[] tarmac_base = {
    vec2(111.0f,  6.6f),
    vec2(150.95f, 8.92f),
    vec2(244.0f,  13.8f),
    vec2(265.0f,  15.04f),
    vec2(277.5f,  15.75f)
};

const vec2[] tarmac_zero = {
    vec2(111.0f,   11.32f),
    vec2(112.64f,  11.938f),
    vec2(129.25f,  13.975f),
    vec2(145.5f,   15.7f),
    vec2(191.6f,   19.92f),
    vec2(220.0f,   22.0f),
    vec2(247.0f,   24.2f),
    vec2(264.425f, 25.905f),
    vec2(277.5f,   27.184f)
};

const vec2[] dirt_ideal = {
    vec2(55.0f,  1.0f),
    vec2(100.0f, 1.5f),
    vec2(202.0f, 2.15f),
    vec2(250.0f, 2.15f)
};

const vec2[] dirt_base = {
    vec2(55.0f,  4.0f),
    vec2(86.6f,  7.25f),
    vec2(216.0f, 20.13f),
    vec2(250.0f, 21.39f)
};

const vec2[] dirt_zero = {
    vec2(55.0f,    11.96f),
    vec2(56.55f,   12.18f),
    vec2(80.25f,   15.664f),
    vec2(142.275f, 24.0675f),
    vec2(168.85f,  26.54f),
    vec2(202.65f,  29.714f),
    vec2(224.5f,   31.525f),
    vec2(250.0f,   33.33f)
};

const vec2[] plastic_ideal = {
    vec2(55.0f,  1.0f),
    vec2(99.5f,  1.0f),
    vec2(100.0f, 1.3f),
    vec2(142.0f, 1.3f),
    vec2(150.0f, 1.725f),
    vec2(184.5f, 1.725f),
    vec2(200.0f, 2.0f),
    vec2(250.0f, 2.0f)
};

const vec2[] plastic_base = {
    vec2(55.0f,  12.0f),
    vec2(91.6f,  17.65f),
    vec2(106.0f, 18.3f),
    vec2(120.0f, 23.8f),
    vec2(165.0f, 29.5f),
    vec2(275.0f, 36.0f)
};

const vec2[] plastic_zero = {
    vec2(55.0f,  12.5f),
    vec2(70.0f,  16.6f),
    vec2(94.5f,  20.4f),
    vec2(153.9f, 28.2f),
    vec2(230.4f, 35.85f),
    vec2(265.0f, 39.35f),
    vec2(250.0f, 33.33f),
    vec2(277.5f, 41.45f)
};

const vec2[] grass_ideal = {
    vec2(55.0f,  1.0f),
    vec2(80.0f,  1.365f),
    vec2(110.0f, 1.4f),
    vec2(145.0f, 1.7f),
    vec2(180.0f, 2.0f),
    vec2(216.0f, 2.4f),
    vec2(250.0f, 2.8f)
};

const vec2[] grass_base = {
    vec2(55.0f,  4.0f),
    vec2(86.6f,  7.25f),
    vec2(216.0f, 20.13f),
    vec2(250.0f, 21.39f)
};

const vec2[] grass_zero = {
    vec2(55.0f,  13.5f),
    vec2(87.0f,  17.6f),
    vec2(112.6f, 21.25f),
    vec2(145.0f, 25.42f),
    vec2(216.4f, 32.54f),
    vec2(250.0f, 35.4f)
};

const vec2[] bw_dirt_ideal = {
    vec2(0.0f,   2.0f),
    vec2(25.0f,  2.0f),
    vec2(30.0f,  2.3f),
    vec2(60.0f,  2.7f),
    vec2(80.0f,  2.85f),
    vec2(130.0f, 2.9f)
};

const vec2[] bw_dirt_zero = {
    vec2(0.0f,   8.0f),
    vec2(56.0f,  17.0f),
    vec2(30.0f,  2.3f),
    vec2(73.0f,  19.75f),
    vec2(84.5f,  21.0f),
    vec2(103.0f, 23.5f),
    vec2(130.0f, 26.5f)
};

const vec2[] bw_tarmac_ideal = {
    vec2(0.0f,   3.5f),
    vec2(31.0f,  5.4f),
    vec2(40.0f,  8.0f),
    vec2(130.0f, 8.2f)
};

const vec2[] bw_tarmac_zero = {
    vec2(0.0f,   8.0f),
    vec2(55.0f,  16.0f),
    vec2(85.0f,  20.0f),
    vec2(110.0f, 24.0f),
    vec2(130.0f, 26.0f)
};

const vec2[] bw_grass_ideal = {
    vec2(0.0f,   1.4f),
    vec2(28.0f,  1.7f),
    vec2(75.0f,  2.18f),
    vec2(110.0f, 2.2f),
    vec2(130.0f, 2.25f)
};

const vec2[] bw_grass_zero = {
    vec2(0.0f,   2.0f),
    vec2(10.0f,  6.0f),
    vec2(30.0f,  12.0f),
    vec2(50.0f,  17.0f),
    vec2(110.0f, 25.0f),
    vec2(130.0f, 27.4f)
};

const vec2[] wood_p1 = {
    vec2(13.23f, 0.0792f),
    vec2(48.96f, 3.25f),
    vec2(55.32f, 4.23f),
    vec2(58.0f,  7.35f),
    vec2(116.0f, 8.6f),
    vec2(274.5f, 10.2f)
};

const vec2[] wood_valley = {
    vec2(11.9f,   4.74f),
    vec2(26.0f,   10.21f),
    vec2(207.15f, 81.0f),
    vec2(277.8f,  108.3f)
};

const vec2[] wood_p2 = {
    vec2(11.3f,   7.3f),
    vec2(87.8f,   58.54f),
    vec2(136.86f, 90.68f),
    vec2(177.5f,  116.4f),
    vec2(276.6f,  159.9f)
};

const vec2[] wood_wet_ice_p1 = {
    vec2(13.23f, 0.0f),
    vec2(48.96f, 0.0f),
    vec2(55.32f, 0.0f),
    vec2(58.0f,  0.0f),
    vec2(116.0f, 0.0f),
    vec2(274.5f, 10.0f)
};

const vec2[] wood_wet_ice_valley = {
    vec2(10.0f,  4.34f),
    vec2(400.0f, 173.986213644f)
};

const vec2[] wood_wet_ice_p2 = {
    vec2(4.7f,   3.6f),
    vec2(78.74f, 56.52f),
    vec2(189.4f, 125.0f),
    vec2(253.8f, 157.6f),
    vec2(271.1f, 165.6f)
};

const vec2[] rally_ice_peak = {
    vec2(1.0f,   0.0f),
    vec2(400.0f, 0.0f)
};

const vec2[] rally_ice_zero = {
    vec2(17.6f,   0.0f),
    vec2(44.425f, 18.1f),
    vec2(57.34f,  23.92f),
    vec2(80.4f,   38.25f)
};

const vec2[] rally_ice_slideout = {
    vec2(1.0f,   0.717f),
    vec2(50.5f,  41.325f),
    vec2(400.0f, 329.95f)
};

const vec2[] desert_ice_peak = {
    vec2(2.125f, 0.2f),
    vec2(15.0f,  0.4f),
    vec2(28.0f,  0.9f),
    vec2(31.0f,  0.3f),
    vec2(104.0f, 0.7f),
    vec2(187.7f, 1.0f),
    vec2(272.6f, 86.8f)
};

const vec2[] desert_ice_zero = {
    vec2(2.5f,   1.8f),
    vec2(70.5f,  64.8f),
    vec2(108.0f, 107.75f),
    vec2(170.0f, 165.95f)
};

const vec2[] desert_ice_backpeak = {
    vec2(2.5f,    0.2f),
    vec2(84.2f,   79.5f),
    vec2(116.75f, 115.6f)
};

const float backwards_min = 15.0f;
const float tarmac_min = 395.0f / 3.6f;
const float other_min = 200.0f / 3.6f;
const float wood_min = 10.0f;
