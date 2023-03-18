/**
 * Ice gearing configuration 
 * 
 * This is a bunch of magic numbers derived from GearStateManager
 * Roughly as you get further over the "gearup threshold" the safe zone decreases in size 
 */

array<vec2> ice_gearup_upper = {
    vec2(0, 2.05),
    vec2(8000, 1.95),
    vec2(12000, 1.9),
    vec2(12001, 1.9)
};