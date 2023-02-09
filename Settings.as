[Setting category="General" name="Enable utility"]
bool g_visible = true;

[Setting category="General" name="Hide during Intro sequences"]
bool Setting_General_HideWhenNotPlaying = true;

[Setting category="Display" name="Graph width" drag min=50 max=2000  ]
int graph_width = 1000;

[Setting category="Display" name="Graph height" drag min=50 max=1000 ]
int graph_height = 200;

[Setting category="Display" name="Graph x offset" drag min=0 max=4000]
int graph_x_offset = 0;

[Setting category="Display" name="Graph y offset" drag min=0 max=2000]
int graph_y_offset = 32;

[Setting category="Display" name="Center graph"]
bool override_center_graph = true;

[Setting category="Display" name="Force graph always on"]
bool override_graph_on = false;

[Setting category="Graph Display Settings" name="Number of calculated ice subpoints" min=10 max=500]
int ICE_POINT_COUNT = 150;

[Setting category="Graph Display Settings" name="Number of calculated non-ice subpoints" min=10 max=500]
int POINT_COUNT = 75;

[Setting category="Ice" name="Acceleration view bound" min=0.01 max=0.05]
float ICE_ACC_BOUND = 0.012;

[Setting category="Ice" name="Lower acceleration view bound" min=-0.05 max=0]
float ICE_LOWER_ACC_BOUND = -0.005;

[Setting category="Ice" name="Ice slip angle bound" min=1.57 max=3.1415926]
float ICE_SLIP_BOUND = 2.25;

[Setting category="Tarmac" name="Acceleration view bound" min=0.01 max=0.05]
float TARMAC_ACC_BOUND = 0.01;

[Setting category="Tarmac" name="Lower acceleration view bound" min=-0.05 max=0.05]
float TARMAC_LOWER_ACC_BOUND = 0;

[Setting category="Tarmac" name="Fullspeed tarmac slip angle bound" min=0.01 max=1.57]
float TARMAC_SLIP_BOUND = 0.1;

[Setting category="Grass/Dirt/Plastic" name="Acceleration view bound" min=0.01 max=0.05]
float GDP_ACC_BOUND = 0.013;

[Setting category="Grass/Dirt/Plastic" name="Lower acceleration view bound" min=-0.05 max=0]
float GDP_LOWER_ACC_BOUND = -0.005;

[Setting category="Grass/Dirt/Plastic" name="Slip angle bound" min=0.01 max=1.57]
float GDP_SLIP_BOUND = .35;

[Setting category="Backwards" name="Acceleration view bound" min=0.01 max=0.05]
float BACKWARDS_ACC_BOUND = 0.012;

[Setting category="Backwards" name="Lower acceleration view bound" min=-0.05 max=0]
float BACKWARDS_LOWER_ACC_BOUND = -0.003;

[Setting category="Backwards" name="Slip angle bound" min=0.01 max=1.57]
float BACKWARDS_SLIP_BOUND = .35;

[Setting category="Display" name="Enable gear and input tool"]
bool GEAR_INPUT_TOOL_ENABLED = true;

[Setting category="Display" name="Side tool width" min=10 max=50]
int SCALE = 30;

[Setting category="General" name="Sync tarmac slip bound to grass/dirt/plastic"]
bool SYNC_TARMAC_GENERAL_SLIP = false;

[Setting category="Player View" name="Use currently viewed player"]
bool UseCurrentlyViewedPlayer = true;

[Setting category="Player View" name="Player index to grab" drag min=0 max=100]
int player_index = 0;

[Setting category="Display" name="Graph Projection Line Width" drag min=0 max=5]
float LineWidth = 2.0f;

[Setting category="Display" name="Graph Player Line Width" drag min=0 max=5]
float PlayerLineWidth = 3.0f;

[Setting category="Display" name="Backdrop Color" color]
vec4 BackdropColor = vec4(.317, .312, .312, 0.9f);

[Setting category="Display" name="Border color" color]
vec4 BorderColor = vec4(0, 0, 0, 1);

[Setting category="Display" name="Border width" drag min=0 max=10]
float BorderWidth = 1.0f;	

[Setting category="Display" name="Border radius" drag min=0 max=50]
float BorderRadius = 5.0f;

[Setting category="Display" name="Padding" drag min=0 max=.5]
float Padding = .25f;

[Setting category="Display" name="Projected Acc, Top Color" color]
vec4 AccelColor = vec4(1, 1, 1, 0.5f);

[Setting category="Display" name="Projected Acc, Bottom Color" color]
vec4 DeccelColor = vec4(.4274, 0.196, .4274, 0.5f);

[Setting category="Display" name="Current Slip Color" color]
vec4 ActualColor = vec4(1, 1, 1, 0.5);

[Setting category="Display" name="Zero Accel Color" color]
// vec4 ZeroColor = vec4(.459, .459, .459, 0.5);
vec4 ZeroColor = vec4(.7, .7, .7, .7);

[Setting category="Player View" name="Number past points" min=0 max=500 drag]
int NUM_PAST_POINTS = 40;

[Setting category="Player View" name="Falloff ratio" min=0 max=2 drag]
float FALLOFF = 0.246;

[Setting category="Display" name="Fade in and out speed" min=0.001 max=.1 drag]
float GRADIENT_SPEED = 0.01;

[Setting category="Supported Surfaces" name="Grass"]
bool GRASS_ENABLED = true;

[Setting category="Supported Surfaces" name="FS Tarmac"]
bool FS_TARMAC_ENABLED = true;

[Setting category="Supported Surfaces" name="Dirt"]
bool DIRT_ENABLED = true;

[Setting category="Supported Surfaces" name="Ice"]
bool ICE_ENABLED = true;

[Setting category="Supported Surfaces" name="Plastic"]
bool PLASTIC_ENABLED = true;

[Setting category="Graph Display Settings" name="Surface smoothing value" drag min=1 max=200]
int surface_smoothing = 50;

[Setting category="Player View" name="Render all ghosts"]
bool RENDER_ALL_GHOSTS = false;

[Setting category="Player View" name="Rolling average points for ghosts" min=1 max=50 drag]
int ALL_ROLLING_COUNT = 5;

[Setting category="Player View" name="Draw self trail"]
bool DRAW_SELF_TRAIL = false;

[Setting category="Graph Display Settings" name="Minimum Activation Speed" min=0.1 max=400]
float MIN_ACTIVATION_SPEED = 40;

[Setting category="General" name="Disable update warning flags"]
bool DISABLE_UPDATE_WARNING_FLAG = false;

[Setting category="Display" name="All ghosts color start" color]
vec4 allGhostColorStart = vec4(1, 0.4470588235294118, 0.6235294117647059, 1);

[Setting category="Display" name="All ghosts color end" color]
vec4 allGhostColorEnd = vec4(0.3372549019607843, 0.796078431372549, 0.9764705882352941, 1);

[Setting category="Graph Display Settings" name="Number of line graph smoothing points" drag min=1 max=25]
int NUM_SMOOTHING_POINTS = 5;

[Setting category="Graph Display Settings" name="Enable gravity" min=0.001]
bool ENABLE_GRAVITY = true;

[Setting category="Graph Display Settings" name="Gravity value" min=0.001]
float GRAVITY_VALUE = 2.5; 

[Setting category="Graph Display Settings" name="Graph Offset" drag min=-0.01 max=0.01]
float MODEL_CORRECTION = 0;

[Setting category="Graph Display Settings" name="Enable dynamic one-sided view"]
bool ABS_ANGLE = false;

[Setting category="Graph Display Settings" name="Minimum slip for one sided view"]
float SLIP_MIN_ONE_SIDED = 0.01;

[Setting category="Graph Display Settings" name="Graph Transition Speed (lower is faster)" min=0 max=8 drag]
int TRANSITION_BASE_FACTOR = 2;

[Setting category="Graph Display Settings" name="Invert slip"]
bool INVERT_SLIP = false;

[Setting category="Display" name="Normal gearup color indicator" color]
vec4 NORMAL_UPSHIFT(0, 108.0/255.0, 103.0/255.0, 0.5);

[Setting category="Display" name="Danger gearup color indicator" color]
vec4 DANGER_UPSHIFT(241.0/255.0, 148.0/255.0, 180.0/255.0, 0.5);

// ##############################################################


[Setting category="Ice" name="Player pointer start" drag min=0 max=2]
float ICE_PP_S = 0.5;

[Setting category="Ice" name="Player pointer length" drag min=0 max=2]
float ICE_PP_L = 1;

[Setting category="Ice" name="Player pointer width" drag min=1 max=10]
float ICE_PP_W = 1;

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