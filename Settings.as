[Setting category="General" name="Enable utility"]
bool g_visible = true;

[Setting category="Display" name="Normal gearup color indicator" color]
// vec4 NORMAL_UPSHIFT(0, 108.0/255.0, 103.0/255.0, 0.5);
vec4 NORMAL_UPSHIFT(1, 1, 1, 1);

[Setting category="Display" name="Danger gearup color indicator" color]
// vec4 DANGER_UPSHIFT(241.0/255.0, 148.0/255.0, 180.0/255.0, 0.5);
vec4 DANGER_UPSHIFT(1, 0, 0, 1);

[Setting category="Display" name="Assist line length fraction" drag min=1 max=10]
float PLAYER_FRACTION = 4;

[Setting category="Ice" name="Ice Player pointer start" drag min=0 max=16]
float ICE_PP_S = 2.856;

[Setting category="Ice" name="Ice Player pointer length" drag min=0 max=16]
float ICE_PP_L = 1.5;

[Setting category="Display" name="Player pointer line width" drag min=1 max=10]
float FS_PP_W = 4.7;

[Setting category="Ice" name="Ice assist line length fraction" drag min=1 max=10] 
float ICE_PLAYER_FRACTION = 2;

[Setting category="Ice" name="Ice player pointer color" color]
vec4 ICE_PP_COLOR = vec4(0, 0, 0, 1);

[Setting category="Colors" name="Optimal color" color]
vec4 COLOR_100(0, 1, 0, 1);

[Setting category="Colors" name="90% color" color]
vec4 COLOR_90(0, 0, 1, 1);

[Setting category="Colors" name="50% color" color]
vec4 COLOR_50(1, 0, 0, 1);

[Setting category="Colors" name="No accel color" color]
vec4 COLOR_0(0, 0, 0, 1);

[Setting category="General" name="Min line brightness" drag min=0 max=1]
float MIN_BRIGHTNESS = 0.1;

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

[Setting category="Theta mults" name="Backwards Theta Mult" drag min=0.1 max=2]
float BACKWARDS_TM = 1;

[Setting category="Advanced" name="Advanced: Theta mult derivative" drag min=0.1 max=0.5]
float THETA_MULT_DERIVATIVE = 0.35;

[Setting category="General" name="Show warning line on early slide/noslide"]
bool SHOW_BAD_SLIDE = false;

[Setting category="Advanced" name="Advanced: Player Pointer Opacity Derivative" drag min=0.001 max=0.01]
float PLAYER_OPACITY_DERIVATIVE = 0.003;

[Setting category="General" name="Fade out on overslide"]
bool FADE_WHEN_OVERSLIDE = true;

[Setting category="General" name="Overslide fade location" drag min=1 max=3]
float FADE_OVERSLIDE_MULT = 1.5;

[Setting category="Display" name="Number of layers" drag min=1 max=10]
int NUM_LAYERS = 1;

[Setting category="Display" name="Layer height" drag min=0.1 max=1]
float LAYER_HEIGHT = 0.1;

[Setting category="General" name="SD start offset" drag min=0 max=16]
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

[Setting category="Ice" name="Ice: Display on front of car"]
bool FLIP_DISPLAY_ICE = true;

[Setting category="Ice" name="Ice: Pointer X offset" drag min=-3 max=3]
float ICE_POINTER_X_OFFSET = 0;

[Setting category="Ice" name="Ice: Pointer Z offset" drag min=-3 max=3]
float ICE_POINTER_Z_OFFSET = 0;

[Setting category="Ice" name="Ice: Pointer angle offset" drag min=-1.41 max=1.41]
float ICE_POINTER_ANGLE_OFFSET = 0;

[Setting category="Ice" name="Set pointer to front corner"] 
bool ICE_RESET_TO_FRONT_CORNER = false;

[Setting category="General" name="Reset pointer for front"]
bool RESET_TO_FRONT = false;

[Setting category="General" name="Reset pointer for back"]
bool RESET_TO_BACK = false;

[Setting category="Display" name="Line background color" color]
vec4 LINE_BACKGROUND_COLOR = vec4(0, 0, 0, 1);

[Setting category="Display" name="Show line background"]
bool SHOW_LINE_BACKGROUND = true;

[Setting category="Display" name="Line background width" drag min=1.05 max=2]
float LINE_BACKGROUND_WIDTH = 1.1;

[Setting category="Display" name="Line background color fraction (lower = darker)" drag min=0 max=1]
float LINE_BACKGROUND_COLOR_FRAC = 0.1;

[Setting category="Simplified view" name="Simplified view"]
bool SIMPLIFIED_VIEW = false;

[Setting category="Simplified view" name="Simplified view X offset" drag min=-2 max=2]
float SIMPLIFIED_VIEW_X = -1.5;

[Setting category="Simplified view" name="Simplified view Z offset" drag min=0.1 max=2]
float SIMPLIFIED_VIEW_Z = 0.867;

[Setting category="Simplified view" name="Simplified view pointer start" drag min=0.1 max=1]
float SIMPLIFIED_START = 0.1;

[Setting category="Simplified view" name="Simplified view pointer length" drag min=0.5 max=2]
float SIMPLIFIED_LENGTH = 1.5;

[Setting category="Simplified view" name="Simplified opacity override" drag min=0 max=1]
float SIMPLIFIED_OPACITY_MULT = 0.117;

[Setting category="Simplified view" name="Simplified view line thickness" drag min=1 max=20]
float SIMPLIFIED_LINE_THICKNESS_OVERRIDE = 10;

[Setting category="Simplified view" name="Draw Cam 3 lines in simplified view" drag min=1 max=20]
bool DRAW_CAM3_IN_SIMPLIFIED_VIEW = false;

[Setting category="General" name="Draw good acceleration line"]
bool DRAW_GOOD = true;

[Setting category="General" name="'Good' speedslide threshold" drag min=0.1 max=0.995]
float GOOD_THRESH = 0.9;

[Setting category="General" name="Draw base acceleration line"]
bool DRAW_BASE = true;

[Setting category="General" name="'Base' speedslide threshold" drag min=0.1 max=0.9]
float BASE_THRESH = 0.5; 

[Setting category="General" name="Draw zero-acceleration line"]
bool DRAW_OUTER = true;

[Setting category="General" name="Show gears in pointer line"] 
bool SHOW_GEARS_IN_POINTER = true;

[Setting category="General" name="Hide gears when in gear 5"]
bool HIDE_GEAR_POINTER_FIFTH = true;

[Setting category="Advanced" name="Gear pointer offset" drag min=0 max=1]
float GEAR_PLAYER_OFFSET = 0.2;

[Setting category="Advanced" name="Gear theta flip threshold (in rads)"]
float THETA_FLIP_THRESH = 0.1;

[Setting category="General" name="Show gear view on both sides"]
bool GEAR_ON_BOTH_SIDES = true;

[Setting category="Preview" name="Preview tarmac"]
bool PREVIEW_TARMAC = false; 

[Setting category="Preview" name="Preview grass"]
bool PREVIEW_GRASS = false; 

[Setting category="Preview" name="Preview dirt"]
bool PREVIEW_DIRT = false; 

[Setting category="Preview" name="Preview plastic"]
bool PREVIEW_PLASTIC = false; 

[Setting category="Preview" name="Preview ice"]
bool PREVIEW_ICE = false; 

[Setting category="Preview" name="Preview speed" drag min=0 max=1000]
float PREVIEW_SPEED = 500;

[Setting category="Preview" name="Preview slip" drag min=-1.5 max=1.5]
float PREVIEW_SLIP = 0.1;

[Setting category="Preview" name="Preview gear" drag min=1 max=5]
int PREVIEW_GEAR = 5;

[Setting category="General" name="Show full gear lines on ice"]
bool SHOW_VERBOSE_GEARS_ICE = false;

[Setting category="Noodlebob" name="Enable noodlebob"]
bool ENABLE_NOODLEBOB = false;

[Setting category="Noodlebob" name="Number of derivatives" drag min=2 max=10]
int NUM_DERIVATIVES = 4;

[Setting category="Noodlebob" name="Smoothing frames" drag min=5 max=100]
int SMOOTHING = 66;

[Setting category="Noodlebob" name="Forward projection number of points" drag min=2 max=20]
int NUM_NOODLEBOB_POINTS = 9;

[Setting category="Noodlebob" name="Noodlebob start offset" drag min=0 max=3]
int NOODLEBOB_START_OFFSET = 0;

[Setting category="Noodlebob" name="Forward projection scale" drag min=0.01 max=1]
float NOODLEBOB_SCALE = .072;

[Setting category="Noodlebob" name="Noodlebob color" color]
vec4 NOODLEBOB_COLOR = vec4(0, 0, 0, 0.25);

[Setting category="Noodlebob" name="Noodlebob width" drag min=1 max=20]
float NOODLEBOB_WIDTH = 5;

[Setting category="Noodlebob" name="Enable tarmac"]
bool NOODLEBOB_TARMAC = false; 

[Setting category="Noodlebob" name="Enable grass"]
bool NOODLEBOB_GRASS = false; 

[Setting category="Noodlebob" name="Enable dirt"]
bool NOODLEBOB_DIRT = false; 

[Setting category="Noodlebob" name="Enable plastic"]
bool NOODLEBOB_PLASTIC = false; 

[Setting category="Noodlebob" name="Enable ice"]
bool NOODLEBOB_ICE = true; 

[Setting category="Ice" name="Fix guides to car instead of pointer"]
bool FIX_GUIDES_TO_CAR = true;

[Setting category="Ice" name="Show custom angle"]
bool SHOW_ICE_CUSTOM_ANGLE = true;

[Setting category="Ice" name="Ice custom angle (in degrees)" drag min=0 max=180]
float ICE_CUSTOM_ANGLE = 90;

[Setting category="Ice" name="Ice custom angle color" color]
vec4 ICE_CUSTOM_ANGLE1_COLOR = vec4(1, 0, 1, 1);

[Setting category="Ice" name="Show custom angle2"]
bool SHOW_ICE_CUSTOM_ANGLE2 = true;

[Setting category="Ice" name="Ice2 custom angle (in degrees)" drag min=0 max=180]
float ICE_CUSTOM_ANGLE2 = 90;

[Setting category="Ice" name="Ice custom angle color2" color]
vec4 ICE_CUSTOM_ANGLE2_COLOR = vec4(0, 0, 1, 1);