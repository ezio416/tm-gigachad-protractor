[Setting category="General" name="Enable utility"]
bool g_visible = true;

[Setting category="General" name="Player index" min=0 max=10]
int PLAYER_IDX = 0;

[Setting category="Display" name="Normal gearup color indicator" color]
// vec4 NORMAL_UPSHIFT(0, 108.0/255.0, 103.0/255.0, 0.5);
vec4 NORMAL_UPSHIFT(1.0f);

[Setting category="Display" name="Danger gearup color indicator" color]
// vec4 DANGER_UPSHIFT(241.0/255.0, 148.0/255.0, 180.0/255.0, 0.5);
vec4 DANGER_UPSHIFT(1.0f, 0.0f, 0.0f, 1.0f);

[Setting category="Display" name="Assist line length fraction" min=1.0f max=10.0f]
float PLAYER_FRACTION = 4.0f;

[Setting category="Ice" name="Ice Player pointer start" min=0.0f max=16.0f]
float ICE_PP_S = 2.856f;

[Setting category="Ice" name="Ice Player pointer length" min=0.0f max=16.0f]
float ICE_PP_L = 1.5f;

[Setting category="Display" name="Player pointer line width" min=1.0f max=10.0f]
float FS_PP_W = 4.7f;

[Setting category="Ice" name="Ice assist line length fraction" min=1.0f max=10.0f]
float ICE_PLAYER_FRACTION = 2.0f;

[Setting category="Ice" name="Ice player pointer color" color]
vec4 ICE_PP_COLOR = vec4(0.0f, 0.0f, 0.0f, 1.0f);

[Setting category="Colors" name="Optimal color" color]
vec4 COLOR_100(0.0f, 1.0f, 0.0f, 1.0f);

[Setting category="Colors" name="90% color" color]
vec4 COLOR_90(0.0f, 0.0f, 1.0f, 1.0f);

[Setting category="Colors" name="50% color" color]
vec4 COLOR_50(1.0f, 0.0f, 0.0f, 1.0f);

[Setting category="Colors" name="No accel color" color]
vec4 COLOR_0(0.0f, 0.0f, 0.0f, 1.0f);

[Setting category="General" name="Min line brightness" min=0.0f max=1.0f]
float MIN_BRIGHTNESS = 0.1f;

[Setting category="General" name="Slip smoothing" min=1 max=100]
int SLIP_SMOOTHING = 1;

[Setting category="Theta mults" name="Tarmac/Platform Theta Mult" min=1.0f max=16.0f]
float TARMAC_TM = 4.0f;

[Setting category="Theta mults" name="Dirt Theta Mult" min=1.0f max=16.0f]
float DIRT_TM = 4.0f;

[Setting category="Theta mults" name="Grass Theta Mult" min=1.0f max=16.0f]
float GRASS_TM = 4.0f;

[Setting category="Theta mults" name="Plastic Theta Mult" min=1.0f max=16.0f]
float PLASTIC_TM = 4.0f;

[Setting category="Theta mults" name="Backwards Theta Mult" min=0.1f max=2.0f]
float BACKWARDS_TM = 1.0f;

[Setting category="Theta mults" name="Wood Theta Mult" min=0.1f max=2.0f]
float WOOD_TM = 1.0f;

[Setting category="Advanced" name="Advanced: Theta mult derivative" min=0.1f max=0.5f]
float THETA_MULT_DERIVATIVE = 0.35f;

[Setting category="General" name="Show warning line on early slide/noslide"]
bool SHOW_BAD_SLIDE = false;

[Setting category="Advanced" name="Advanced: Player Pointer Opacity Derivative" min=0.001f max=0.01f]
float PLAYER_OPACITY_DERIVATIVE = 0.003f;

[Setting category="General" name="Fade out on overslide"]
bool FADE_WHEN_OVERSLIDE = true;

[Setting category="General" name="Overslide fade location" min=1.0f max=3.0f]
float FADE_OVERSLIDE_MULT = 1.5f;

[Setting category="Display" name="Number of layers" min=1 max=10]
int NUM_LAYERS = 1;

[Setting category="Display" name="Layer height" min=0.1f max=1.0f]
float LAYER_HEIGHT = 0.1f;

[Setting category="General" name="SD start offset" min=0.0f max=16.0f]
float SD_POINTER_S = 3.8f;

[Setting category="General" name="SD pointer length" min=0.0f max=16.0f]
float SD_POINTER_L = 8.0f;

[Setting category="Cam3" name="Internal cam3 start" min=0.1f max=10.0f]
float CAM3_I_S = 5.629f;

[Setting category="Cam3" name="Internal cam3 length" min=0.1f max=100.0f]
float CAM3_I_L = 100.0f;

[Setting category="Cam3" name="External cam3 start" min=0.1f max=10.0f]
float CAM3_E_S = 2.792f;

[Setting category="Cam3" name="External cam3 length" min=0.1f max=100]
float CAM3_E_L = 100.0f;

[Setting category="General" name="Display on back of car"]
bool FLIP_DISPLAY = false;

[Setting category="Ice" name="Ice: Display on front of car"]
bool FLIP_DISPLAY_ICE = true;

[Setting category="Ice" name="Ice: Pointer X offset" min=-3.0f max=3.0f]
float ICE_POINTER_X_OFFSET = 0.0f;

[Setting category="Ice" name="Ice: Pointer Z offset" min=-3.0f max=3.0f]
float ICE_POINTER_Z_OFFSET = 0.0f;

[Setting category="Ice" name="Ice: Pointer angle offset" min=-1.41f max=1.41f]
float ICE_POINTER_ANGLE_OFFSET = 0.0f;

[Setting category="Ice" name="Set pointer to front corner"]
bool ICE_RESET_TO_FRONT_CORNER = false;

[Setting category="General" name="Reset pointer for front"]
bool RESET_TO_FRONT = false;

[Setting category="General" name="Reset pointer for back"]
bool RESET_TO_BACK = false;

[Setting category="Display" name="Line background color" color]
vec4 LINE_BACKGROUND_COLOR = vec4(0.0f, 0.0f, 0.0f, 1.0f);

[Setting category="Display" name="Show line background"]
bool SHOW_LINE_BACKGROUND = true;

[Setting category="Display" name="Line background width" min=1.05f max=2.0f]
float LINE_BACKGROUND_WIDTH = 1.1f;

[Setting category="Display" name="Line background color fraction (lower = darker)" min=0.0f max=1.0f]
float LINE_BACKGROUND_COLOR_FRAC = 0.1f;

[Setting category="Simplified view" name="Simplified view"]
bool SIMPLIFIED_VIEW = false;

[Setting category="Simplified view" name="Simplified view X offset" min=-2.0f max=2.0f]
float SIMPLIFIED_VIEW_X = -1.5f;

[Setting category="Simplified view" name="Simplified view Z offset" min=0.1f max=2.0f]
float SIMPLIFIED_VIEW_Z = 0.867f;

[Setting category="Simplified view" name="Simplified view pointer start" min=0.1f max=1.0f]
float SIMPLIFIED_START = 0.1f;

[Setting category="Simplified view" name="Simplified view pointer length" min=0.5f max=2.0f]
float SIMPLIFIED_LENGTH = 1.5f;

[Setting category="Simplified view" name="Simplified opacity override" min=0.0f max=1.0f]
float SIMPLIFIED_OPACITY_MULT = 0.117f;

[Setting category="Simplified view" name="Simplified view line thickness" min=1.0f max=20.0f]
float SIMPLIFIED_LINE_THICKNESS_OVERRIDE = 10.0f;

[Setting category="Simplified view" name="Draw Cam 3 lines in simplified view"]
bool DRAW_CAM3_IN_SIMPLIFIED_VIEW = false;

[Setting category="General" name="Draw good acceleration line"]
bool DRAW_GOOD = true;

[Setting category="General" name="'Good' speedslide threshold" min=0.1f max=0.995f]
float GOOD_THRESH = 0.9f;

[Setting category="General" name="Draw base acceleration line"]
bool DRAW_BASE = true;

[Setting category="General" name="'Base' speedslide threshold" min=0.1f max=0.9f]
float BASE_THRESH = 0.5f;

[Setting category="General" name="Draw zero-acceleration line"]
bool DRAW_OUTER = true;

[Setting category="General" name="Show gears in pointer line"]
bool SHOW_GEARS_IN_POINTER = false;

[Setting category="General" name="Hide gears when in gear 5"]
bool HIDE_GEAR_POINTER_FIFTH = true;

[Setting category="Advanced" name="Gear pointer offset" min=0.0f max=1.0f]
float GEAR_PLAYER_OFFSET = 0.2f;

[Setting category="Advanced" name="Gear theta flip threshold (in rads)"]
float THETA_FLIP_THRESH = 0.1f;

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

[Setting category="Preview" name="Preview wood"]
bool PREVIEW_WOOD = false;

[Setting category="Preview" name="Preview speed" min=0.0f max=1000.0f]
float PREVIEW_SPEED = 500.0f;

[Setting category="Preview" name="Preview slip" min=-3.14f max=3.14f]
float PREVIEW_SLIP = 0.1f;

[Setting category="Preview" name="Preview gear" min=1 max=5]
int PREVIEW_GEAR = 5;

[Setting category="Preview" name="Wet Preview"]
bool PREVIEW_WET = false;

[Setting category="Preview" name="Icy Preview"]
bool PREVIEW_ICY = false;

[Setting category="General" name="Show full gear lines on ice"]
bool SHOW_VERBOSE_GEARS_ICE = false;

[Setting category="Noodlebob" name="Enable noodlebob"]
bool ENABLE_NOODLEBOB = false;

[Setting category="Noodlebob" name="Number of derivatives" min=2 max=10]
int NUM_DERIVATIVES = 4;

[Setting category="Noodlebob" name="Smoothing frames" min=5 max=100]
int SMOOTHING = 66;

[Setting category="Noodlebob" name="Forward projection number of points" min=2 max=20]
int NUM_NOODLEBOB_POINTS = 9;

[Setting category="Noodlebob" name="Noodlebob start offset" min=0 max=3]
int NOODLEBOB_START_OFFSET = 0;

[Setting category="Noodlebob" name="Forward projection scale" min=0.01f max=1.0f]
float NOODLEBOB_SCALE = 0.072f;

[Setting category="Noodlebob" name="Noodlebob color" color]
vec4 NOODLEBOB_COLOR = vec4(0.0f, 0.0f, 0.0f, 0.25f);

[Setting category="Noodlebob" name="Noodlebob width" min=1.0f max=20.0f]
float NOODLEBOB_WIDTH = 5.0f;

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
bool SHOW_ICE_CUSTOM_ANGLE = false;

[Setting category="Ice" name="Ice custom angle (in degrees)" min=0.0f max=180.0f]
float ICE_CUSTOM_ANGLE = 90.0f;

[Setting category="Ice" name="Ice custom angle color" color]
vec4 ICE_CUSTOM_ANGLE1_COLOR = vec4(1.0f, 0.0f, 1.0f, 1.0f);

[Setting category="Ice" name="Show custom angle 2"]
bool SHOW_ICE_CUSTOM_ANGLE2 = false;

[Setting category="Ice" name="Ice custom angle 2 (in degrees)" min=0.0f max=180.0f]
float ICE_CUSTOM_ANGLE2 = 92.0f;

[Setting category="Ice" name="Ice custom angle color 2" color]
vec4 ICE_CUSTOM_ANGLE2_COLOR = vec4(0.0f, 0.0f, 1.0f, 1.0f);

[Setting category="Ice" name="Ice line minimum brightness" min=0.0f max=1.0f]
float ICE_LINE_MIN_BRIGHTNESS = 0.1f;

[Setting category="Ice" name="Ice line fade rate (higher = slower)" min=0.1f max=1.0f]
float ICE_LINE_FADE_RATE = 0.3f;

[Setting category="Ice" name="Ice ideal angle color" color]
vec4 ICE_IDEAL_ANGLE_COLOR = vec4(0.0f, 1.0f, 0.0f, 1.0f);

[Setting category="Ice" name="Show regions"]
bool ICE_REGIONS_SHOW = true;

[Setting category="Ice" name="Show gear lines"]
bool ICE_GEAR_LINES_SHOW = false;

[Setting category="Ice" name="Resolution (points per circle)" min=2 max=300]
int ICE_REGIONS_RESOLUTION = 80;

[Setting category="Ice" name="Ice safe region color" color]
vec4 ICE_REGIONS_GOOD = vec4(0.0f, 1.0f, 0.0f, 0.5f);

[Setting category="Ice" name="Draw colored regions for safe zones"]
bool ICE_REGIONS_RENDER = true;

[Setting category="Ice" name="Draw outline over safe region"]
bool ICE_REGION_OUTLINE_BOOL = false;

[Setting category="Ice" name="Ice region outline color" color]
vec4 ICE_REGIONS_OUTLINE = vec4(0.0f, 0.0f, 0.0f, 0.5f);

[Setting category="Ice" name="Ice region outline thickness" min=0.0f max=5.0f]
float ICE_REGIONS_THICKNESS = 2.0f;

[Setting category="Ice" name="Ice region warning inset frac" min=0.0f max=0.5f]
float ICE_REGIONS_INSET = 0.023f;

[Setting category="Ice" name="Ice region start (relative to player pointer)" min=0.0f max=1.0f]
float ICE_REGION_START = 0.561f;

[Setting category="Ice" name="Ice region end (relative to player pointer)" min=0 max=1]
float ICE_REGION_END = 0.891f;

[Setting category="Ice" name="Ice warning region color" color]
vec4 ICE_REGIONS_WARNING = vec4(222.0f, 235.0f, 52.0f, 255.0f) / 255.0f;

[Setting category="Ice" name="Ice region inset frac" min=0.0f max=0.1f]
float ICE_REGIONS_EDGE_FRAC = 0.0f;

[Setting category="Ice" name="Ice radial root inset fraction" min=0.0f max=3.0f]
float ICE_REGIONS_RADIAL_INSET_FRAC = 0.887f;

[Setting category="Ice" name="Ice gradient inner diameter" min=0.0f max=200.0f]
float ICE_REGIONS_GRADIENT_INNER_DIAMETER = 23.656f;

[Setting category="Ice" name="Ice gradient outer diameter" min=0.0f max=200.0f]
float ICE_REGIONS_GRADIENT_OUTER_DIAMETER = 70.968f;

[Setting category="Ice" name="Ice radial dark color frac" min=0.0f max=1.0f]
float ICE_REGIONS_DARK_COLOR_FRAC = 1.0f;

[Setting category="Ice" name="Ice danger wedge color" color]
vec4 ICE_REGIONS_DANGER_WEDGE_COLOR = vec4(1.0f, 0.0f, 0.0f, 1.0f);

// [Setting category="Gear Display" name="Graph Width" min=50 max=2000]
int graph_width = 100;

// [Setting category="Gear Display" name="Graph Height" min=50 max=1000]
int graph_height = 200;

// [Setting category="Gear Display" name="Graph X Offset" min=0 max=4000]
int graph_x_offset = 32;

// [Setting category="Gear Display" name="Graph Y Offset" min=0 max=2000]
int graph_y_offset = 600;

// [Setting category="Gear Display" name="Border Radius" min=0 max=50]
float BorderRadius = 5.0f;

// [Setting category="Gear Display" name="Backdrop Color" color]
vec4 BackdropColor = vec4(0.0f, 0.0f, 0.0f, 0.7f);

// [Setting category="Gear Display" name="Border Color" color]
vec4 BorderColor = vec4(0.0f, 0.0f, 0.0f, 1.0f);

// [Setting category="Gear Display" name="Border Width" min=0 max=10]
float BorderWidth = 1.0f;

// [Setting category="Gear Display" name="Milliseconds Averaged" min=200 max=1000]
int MILLISECONDS_AVERAGED = 250;

// [Setting category="Gear Display" name="Enable Gear Hud"]
bool RENDER_GEAR_HUD = false;

[Setting category="History" name="Enable run history view"]
bool HISTORY_ENABLED = true;

[Setting category="History" name="Number of run history points to draw" min=1 max=100]
int HISTORY_POINTS = 60;

[Setting category="History" name="Amount of time to show in history (in seconds)" min=0.5 max=5.0f]
float HISTORY_SECONDS = 1.0f;

[Setting category="History" name="History min width" min=1.0f max=4.0f]
float HISTORY_WIDTH_MIN = 1.32f;

[Setting category="History" name="History max width" min=4.0f max=16.0f]
float HISTORY_WIDTH_MAX = 12.13f;

[Setting category="History" name="Start opacity" min=0.05f max=1.0f]
float HISTORY_START_OPACITY = 0.115f;

[Setting category="History" name="Decay factor" min=1.01f max=10.0f]
float HISTORY_DECAY_FACTOR = 7.583f;

[Setting category="History" name="Start base offset" min=-3.0f max=3.0f]
float HISTORY_START_OFFSET = 1.09f;

[Setting category="History" name="Start offset" min=-3.0f max=10.0f]
float HISTORY_START_HEIGHT = 5.599f;

[Setting category="History" name="End offset" min=0.0f max=3.0f]
float HISTORY_END_HEIGHT = 0.289f;

[Setting category="History" name="History distance factor" min=0.5f max=5.0f]
float HISTORY_DISTANCE_FACTOR = 1.0f;

[Setting category="Ice" name="Hide history on ice"]
bool HISTORY_HIDE_ON_ICE = true;

[Setting category="Advanced" name="Perspective constant" min=1.0f max=20.0f]
float PERSPECTIVE_CONSTANT = 7.0f;

[Setting category="Advanced" name="History Perspective constant" min=0.5f max=40.0f]
float HISTORY_PERSPECTIVE_CONSTANT = 30.0f;

[Setting category="Overrides" name="Is Rally Car"]
bool RALLY_CAR_OVERRIDE = true;
