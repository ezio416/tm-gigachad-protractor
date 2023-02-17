[Setting category="General" name="Enable utility"]
bool g_visible = true;

[Setting category="General" name="Hide during Intro sequences"]
bool Setting_General_HideWhenNotPlaying = true;

[Setting category="Player View" name="Use currently viewed player"]
bool UseCurrentlyViewedPlayer = true;

[Setting category="Player View" name="Player index to grab" drag min=0 max=100]
int player_index = 0;

[Setting category="Graph Display Settings" name="Surface smoothing value" drag min=1 max=200]
int surface_smoothing = 50;

[Setting category="Player View" name="Render all ghosts"]
bool RENDER_ALL_GHOSTS = false;

[Setting category="Graph Display Settings" name="Minimum Activation Speed" min=0.1 max=400]
float MIN_ACTIVATION_SPEED = 40;

[Setting category="General" name="Disable update warning flags"]
bool DISABLE_UPDATE_WARNING_FLAG = false;

[Setting category="Display" name="Normal gearup color indicator" color]
vec4 NORMAL_UPSHIFT(0, 108.0/255.0, 103.0/255.0, 0.5);

[Setting category="Display" name="Danger gearup color indicator" color]
vec4 DANGER_UPSHIFT(241.0/255.0, 148.0/255.0, 180.0/255.0, 0.5);

// ##############################################################


[Setting category="General" name="Player pointer start" drag min=0 max=16]
float ICE_PP_S = 4;

[Setting category="General" name="Player pointer length" drag min=0 max=16]
float ICE_PP_L = 8;

[Setting category="General" name="Player pointer width" drag min=1 max=10]
float ICE_PP_W = 1;

[Setting category="General" name="Guide line length fraction" drag min=1 max=10]
float PLAYER_FRACTION = 4;


[Setting category="Ice" name="Player pointer color" color]
vec4 ICE_PP_COLOR = vec4(0, 0, 0, 1);

[Setting category="Ice" name="Gear pointer start" drag min=0 max=2]
float ICE_G_S = 0.5;

[Setting category="Ice" name="Gear pointer length" drag min=0 max=2]
float ICE_G_L = 1;

[Setting category="Ice" name="Gear pointer width" drag min=0 max=2]
float ICE_G_W = 1;

[Setting category="Ice" name="Gear gear up color" drag min=0 max=2]
vec4 ICE_G_COLOR = vec4(0, 1, 1, 1);

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

bool DISPLAY_FLIPPED = true;

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

[Setting category="General" drag min=0 max=10]
int player_selected = 0;

[Setting category="General" drag min=1 max=100]
int SLIP_SMOOTHING = 20;

[Setting category="Theta mults" name="Tarmac/Platform Theta Mult" drag min=1 max=16]
float TARMAC_TM = 4;

[Setting category="Theta mults" name="Dirt Theta Mult" drag min=1 max=16]
float DIRT_TM = 4;

[Setting category="Theta mults" name="Grass Theta Mult" drag min=1 max=16]
float GRASS_TM = 4;

[Setting category="Theta mults" name="Plastic Theta Mult" drag min=1 max=16]
float PLASTIC_TM = 4;

[Setting category="Theta mults" name="Meta: Theta mult derivative" drag min=0.1 max=0.5]
float THETA_MULT_DERIVATIVE = 0.35;