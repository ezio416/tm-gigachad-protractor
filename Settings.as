[Setting category="General" name="Enable utility"]
bool g_visible = true;

[Setting category="Display" name="Normal gearup color indicator" color]
vec4 NORMAL_UPSHIFT(0, 108.0/255.0, 103.0/255.0, 0.5);

[Setting category="Display" name="Danger gearup color indicator" color]
vec4 DANGER_UPSHIFT(241.0/255.0, 148.0/255.0, 180.0/255.0, 0.5);

[Setting category="General" name="Assist line length fraction" drag min=1 max=10]
float PLAYER_FRACTION = 4;

[Setting category="Ice" name="Ice Player pointer start" drag min=0 max=16]
float ICE_PP_S = .918;

[Setting category="Ice" name="Ice Player pointer length" drag min=0 max=16]
float ICE_PP_L = 4.8;

[Setting category="General" name="Ice Player pointer width" drag min=1 max=10]
float ICE_PP_W = 1;

[Setting category="Ice" name="Ice Player pointer color" color]
vec4 ICE_PP_COLOR = vec4(0, 0, 0, 1);

[Setting category="Other surfaces" name="Gear pointer start" drag min=0 max=2]
float FS_G_S = 0.5;

[Setting category="Other surfaces" name="Gear pointer length" drag min=0 max=2]
float FS_G_L = 1;

[Setting category="Other surfaces" name="Gear pointer width" drag min=0 max=2]
float FS_G_W = 1;

[Setting category="Other surfaces" name="Gear bad slide color" drag min=0 max=2]
vec4 FS_B_COLOR = vec4(1, 0, 0, 1);

[Setting category="Other surfaces" name="Gear good slide color" drag min=0 max=2]
vec4 FS_G_COLOR = vec4(0, 1, 0, 1);

[Setting category="Colors" name="Optimal color" color]
vec4 COLOR_100(0, 0, 1, 1);

[Setting category="Colors" name="90% color" color]
vec4 COLOR_90(0, 1, 0, 1);

[Setting category="Colors" name="50% color" color]
vec4 COLOR_50(1, 0, 0, 1);

[Setting category="Colors" name="No accel color" color]
vec4 COLOR_0(0, 0, 0, 1);

[Setting category="General" name="Min line brightness" drag min=0 max=1]
float min_brightness = 0.1;

[Setting category="General" name="Slip smoothing" drag min=1 max=100]
int SLIP_SMOOTHING = 1;

[Setting category="Theta mults" name="Tarmac/Platform Theta Mult" drag min=1 max=16]
float TARMAC_TM = 4;

[Setting category="Theta mults" name="Dirt Theta Mult" drag min=1 max=16]
float DIRT_TM = 4;

[Setting category="Theta mults" name="Grass Theta Mult" drag min=1 max=16]
float GRASS_TM = 4;

[Setting category="Theta mults" name="Plastic Theta Mult" drag min=1 max=16]
float PLASTIC_TM = 4;

[Setting category="Advanced" name="Advanced: Theta mult derivative" drag min=0.1 max=0.5]
float THETA_MULT_DERIVATIVE = 0.35;

[Setting category="General" name="Show warning line on early slide/noslide"]
bool SHOW_BAD_SLIDE = false;

[Setting category="Advanced" name="Advanced: Player Pointer Opacity Derivative" drag min=0.01 max=0.5]
float PLAYER_OPACITY_DERIVATIVE = 0.05;

[Setting category="General" name="Fade out on overslide"]
bool FADE_WHEN_OVERSLIDE = true;

[Setting category="General" name="Overslide fade location" drag min=1 max=3]
float FADE_OVERSLIDE_MULT = 1.5;

[Setting category="Display" name="Number of layers" drag min=1 max=10]
int NUM_LAYERS = 1;

[Setting category="Display" name="Layer height" drag min=0.1 max=1]
float LAYER_HEIGHT = 0.1;

[Setting category="General" name="SD start length" drag min=0 max=16]
float SD_POINTER_S = 3.8;

[Setting category="General" name="SD pointer length" drag min=0 max=16]
float SD_POINTER_L = 8;

[Setting category="Cam3" name="Internal cam3 start" drag min=0.1 max=10]
float CAM3_I_S = 5.629;

[Setting category="Cam3" name="Internal cam3 length" drag min=0.1 max=100]
float CAM3_I_L = 100;

[Setting category="Cam3" name="External cam3 start" drag min=0.1 max=10]
float CAM3_E_S = 2.792;

[Setting category="Cam3" name="External cam3 length" drag min=0.1 max=100]
float CAM3_E_L = 100;

[Setting category="General" name="Display on back of car"]
bool FLIP_DISPLAY = false;

[Setting category="General" name="Ice: Display on front of car"]
bool FLIP_DISPLAY_ICE = false;

[Setting category="General" name="Reset pointer for front"]
bool RESET_TO_FRONT = false;

[Setting category="General" name="Reset pointer for back"]
bool RESET_TO_BACK = false;