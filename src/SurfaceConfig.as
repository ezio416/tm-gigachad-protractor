
/*

Surface configuration: 

Provide two `vec2` arrays: ideal and zero. 

The "ideal" array should provide the most precise "best" sidespeed possible for that speed. 
The "zero" array should provide the sidespeed at which the car doesn't accelerate. 
All intermediate values can be linearly interpreted from these. 

Format of vec2: (speed, target_sidespeed)

*/

array<vec2> tarmac_ideal = {
    vec2(111, 5.9),
    vec2(140, 5.6),
    vec2(210, 5.75),
    vec2(232, 5.75),
    vec2(280, 5.85)
};

array<vec2> tarmac_base = {
    vec2(111, 6.6),
    vec2(150.95, 8.920),
    vec2(244, 13.8), 
    vec2(265, 15.04),
    vec2(277.5, 15.75)
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

array<vec2> dirt_base = {
    vec2(55, 4),
    vec2(86.6, 7.25),
    vec2(216, 20.13),
    vec2(250, 21.39)
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

array<vec2> plastic_base = {
    vec2(55, 12),
    vec2(91.6, 17.65),
    vec2(106, 18.3),
    vec2(120, 23.8),
    vec2(165, 29.5),
    vec2(275, 36)
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

array<vec2> grass_base = {
    vec2(55, 4),
    vec2(86.6, 7.25),
    vec2(216, 20.13),
    vec2(250, 21.39)
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
    vec2(0, 3.5),
    vec2(31, 5.4),
    vec2(40, 8.0),
    vec2(130, 8.2)
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

array<vec2> wood_p1 = {
    vec2(13.23, 0.0792),
    vec2(48.96, 3.25),
    vec2(55.32, 4.23),
    vec2(58, 7.35),
    vec2(116, 8.6),
    vec2(274.5, 10.20)
};

array<vec2> wood_valley = {
    vec2(11.9, 4.74),
    vec2(26.0, 10.21),
    vec2(207.15, 81),
    vec2(277.8, 108.3)
};
array<vec2> wood_p2 = {
    vec2(11.3, 7.3),
    vec2(87.8, 58.54),
    vec2(136.86, 90.68),
    vec2(177.5, 116.4),
    vec2(276.6, 159.90)
};

array<vec2> wood_wet_ice_p1 = {
    vec2(13.23, 0),
    vec2(48.96, 0),
    vec2(55.32, 0),
    vec2(58, 0),
    vec2(116, 0),
    vec2(274.5, 10)
};

array<vec2> wood_wet_ice_valley = {
    vec2(10, 4.34),
    vec2(400, 173.986213644)
};
array<vec2> wood_wet_ice_p2 = {
    vec2(4.7, 3.6),
    vec2(78.74, 56.52),
    vec2(189.4, 125.0),
    vec2(253.8, 157.6),
    vec2(271.1, 165.6)
};

array<vec2> rally_ice_peak = {
    vec2(1.0, 0),
    vec2(400, 0.0)
};

array<vec2> rally_ice_zero = {
    vec2(17.6, 0),
    vec2(44.425, 18.1), 
    vec2(57.34, 23.92),
    vec2(80.4, 38.25)
};

array<vec2> rally_ice_slideout = {
    vec2(1, 0.717),
    vec2(50.5, 41.325),
    vec2(400, 329.95)
};


array<vec2> desert_ice_peak = {
    vec2(2.125, 0.2),
    vec2(15, .4),
    vec2(28, .9),
    vec2(31, .3),
    vec2(104, .7),
    vec2(187.7, 1),
    vec2(272.6, 86.8)
};

array<vec2> desert_ice_zero = {
    vec2(2.5, 1.8),
    vec2(70.5, 64.8),
    vec2(108, 107.75),
    vec2(170, 165.95)
};

array<vec2> desert_ice_backpeak = {
    vec2(2.5, 0.2),
    vec2(84.2, 79.5),
    vec2(116.75, 115.6)
};


float backwards_min = 15;
float tarmac_min = 395 / 3.6;
float other_min = 200 / 3.6;
float wood_min = 10;

