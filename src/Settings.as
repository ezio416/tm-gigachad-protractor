[Setting category="General" name="Enable utility"]
bool S_Enabled = true;

[Setting category="General" name="Player index" min=0 max=10]
int S_PlayerIndex = 0;

[Setting category="General" name="Min line brightness" min=0.0f max=1.0f]
float S_BrightnessMin = 0.1f;

[Setting category="General" name="Slip smoothing" min=1 max=100]
int S_SlipSmoothing = 1;

[Setting category="General" name="Show warning line on early slide/noslide"]
bool S_ShowBadSlide = false;

[Setting category="General" name="Overslide fade location" min=1.0f max=3.0f]
float S_OverslideFadeMult = 1.5f;

[Setting category="General" name="SD start offset" min=0.0f max=16.0f]
float S_SDPointerStart = 3.8f;

[Setting category="General" name="SD pointer length" min=0.0f max=16.0f]
float S_SDPointerLength = 8.0f;

[Setting category="General" name="Display on back of car"]
bool S_FlipDisplay = false;

[Setting category="General" name="Reset pointer for front"]
bool S_ResetFront = false;

[Setting category="General" name="Reset pointer for back"]
bool S_ResetBack = false;

[Setting category="General" name="Draw good acceleration line"]
bool S_GoodAccel = true;

[Setting category="General" name="'Good' speedslide threshold" min=0.1f max=0.995f]
float S_GoodSDThreshold = 0.9f;

[Setting category="General" name="Draw base acceleration line"]
bool S_BaseAccel = true;

[Setting category="General" name="Draw zero-acceleration line"]
bool S_ZeroAccel = true;

[Setting category="General" name="Show gears in pointer line"]
bool S_PointerGears = false;

[Setting category="General" name="Hide gears when in gear 5"]
bool S_HideGear5 = true;

[Setting category="General" name="Show gear view on both sides"]
bool S_GearBothSides = true;

[Setting category="General" name="Show full gear lines on ice"]
bool S_VerboseIceGears = false;


[Setting category="Display" name="Normal gearup color indicator" color]
vec4 S_ColorUpshiftNormal(1.0f);

[Setting category="Display" name="Danger gearup color indicator" color]
vec4 S_ColorUpshiftDanger(1.0f, 0.0f, 0.0f, 1.0f);

[Setting category="Display" name="Assist line length fraction" min=1.0f max=10.0f]
float S_PlayerFraction = 4.0f;

[Setting category="Display" name="Player pointer line width" min=1.0f max=10.0f]
float S_FullspeedPlayerPointerWidth = 4.7f;

[Setting category="Display" name="Number of layers" min=1 max=10]
int S_LayerCount = 1;

[Setting category="Display" name="Layer height" min=0.1f max=1.0f]
float S_LayerHeight = 0.1f;

[Setting category="Display" name="Line background color" color]
vec4 S_ColorLineBackground = vec4(0.0f, 0.0f, 0.0f, 1.0f);

[Setting category="Display" name="Show line background"]
bool S_LineBackground = true;

[Setting category="Display" name="Line background width" min=1.05f max=2.0f]
float S_LineBackgroundWidth = 1.1f;

[Setting category="Display" name="Line background color fraction (lower = darker)" min=0.0f max=1.0f]
float S_LineBackgroundColorFraction = 0.1f;


[Setting category="Ice" name="Ice Player pointer start" min=0.0f max=16.0f]
float S_IcePlayerPointerStart = 2.856f;

[Setting category="Ice" name="Ice Player pointer length" min=0.0f max=16.0f]
float S_IcePlayerPointerLength = 1.5f;

[Setting category="Ice" name="Ice assist line length fraction" min=1.0f max=10.0f]
float S_IcePlayerFraction = 2.0f;

[Setting category="Ice" name="Display on front of car"]
bool S_FlipDisplayIce = true;

[Setting category="Ice" name="Pointer X offset" min=-3.0f max=3.0f]
float S_IcePointerOffsetX = 0.0f;

[Setting category="Ice" name="Pointer Z offset" min=-3.0f max=3.0f]
float S_IcePointerOffsetZ = 0.0f;

[Setting category="Ice" name="Pointer angle offset" min=-1.41f max=1.41f]
float S_IcePointerOffsetAngle = 0.0f;

[Setting category="Ice" name="Set pointer to front corner"]
bool S_IcePointerFrontCorner = false;

[Setting category="Ice" name="Fix guides to car instead of pointer"]
bool S_FixIceGuides = true;

[Setting category="Ice" name="Show custom angle"]
bool S_ShowCustomIceAngle = false;

[Setting category="Ice" name="Ice custom angle (in degrees)" min=0.0f max=180.0f]
float S_CustomIceAngle = 90.0f;

[Setting category="Ice" name="Ice custom angle color" color]
vec4 S_CustomIceAngleColor = vec4(1.0f, 0.0f, 1.0f, 1.0f);

[Setting category="Ice" name="Show custom angle 2"]
bool S_ShowCustomIceAngle2 = false;

[Setting category="Ice" name="Ice custom angle 2 (in degrees)" min=0.0f max=180.0f]
float S_CustomIceAngle2 = 92.0f;

[Setting category="Ice" name="Ice custom angle color 2" color]
vec4 S_CustomIceAngle2Color = vec4(0.0f, 0.0f, 1.0f, 1.0f);

[Setting category="Ice" name="Ice line minimum brightness" min=0.0f max=1.0f]
float S_IceBrightnessMin = 0.1f;

[Setting category="Ice" name="Ice line fade rate (higher = slower)" min=0.1f max=1.0f]
float S_IceLineFadeRate = 0.3f;

[Setting category="Ice" name="Ice ideal angle color" color]
vec4 S_IceIdealAngleColor = vec4(0.0f, 1.0f, 0.0f, 1.0f);

[Setting category="Ice" name="Show gear lines"]
bool S_IceGearLines = false;

[Setting category="Ice" name="Resolution (points per circle)" min=2 max=300]
int S_IceRegionResolution = 80;

[Setting category="Ice" name="Ice safe region color" color]
vec4 S_IceRegionGoodColor = vec4(0.0f, 1.0f, 0.0f, 0.5f);

[Setting category="Ice" name="Draw colored regions for safe zones"]
bool S_IceRegionSafe = true;

[Setting category="Ice" name="Ice region warning inset frac" min=0.0f max=0.5f]
float S_IceRegionInset = 0.023f;

[Setting category="Ice" name="Ice region start (relative to player pointer)" min=0.0f max=1.0f]
float S_IceRegionStart = 0.561f;

[Setting category="Ice" name="Ice region end (relative to player pointer)" min=0.0f max=1.0f]
float S_IceRegionEnd = 0.891f;

[Setting category="Ice" name="Ice warning region color" color]
vec4 S_IceRegionWarning = vec4(0.871f, 0.922f, 0.204f, 1.0f);

[Setting category="Ice" name="Ice region inset frac" min=0.0f max=0.1f]
float S_IceRegionInsetFraction = 0.0f;

[Setting category="Ice" name="Ice radial root inset fraction" min=0.0f max=3.0f]
float S_IceRegionRadialInsetFraction = 0.887f;

[Setting category="Ice" name="Ice gradient inner diameter" min=0.0f max=200.0f]
float S_IceGradientInnerDiameter = 23.656f;

[Setting category="Ice" name="Ice gradient outer diameter" min=0.0f max=200.0f]
float S_IceGradientOuterDiameter = 70.968f;

[Setting category="Ice" name="Ice radial dark color frac" min=0.0f max=1.0f]
float S_IceRadialDarkFraction = 1.0f;

[Setting category="Ice" name="Ice danger wedge color" color]
vec4 S_IceDangerWedgeColor = vec4(1.0f, 0.0f, 0.0f, 1.0f);

[Setting category="Ice" name="Hide history on ice"]
bool S_HistoryHideIce = true;


[Setting category="Colors" name="Optimal color" color]
vec4 S_ColorOptimal(0.0f, 1.0f, 0.0f, 1.0f);

[Setting category="Colors" name="90% color" color]
vec4 S_Color90(0.0f, 0.0f, 1.0f, 1.0f);

[Setting category="Colors" name="50% color" color]
vec4 S_Color50(1.0f, 0.0f, 0.0f, 1.0f);

[Setting category="Colors" name="No accel color" color]
vec4 S_Color0(0.0f, 0.0f, 0.0f, 1.0f);


[Setting category="Theta mults" name="Road" min=1.0f max=16.0f]
float S_ThetaMultRoad = 4.0f;

[Setting category="Theta mults" name="Dirt" min=1.0f max=16.0f]
float S_ThetaMultDirt = 4.0f;

[Setting category="Theta mults" name="Grass" min=1.0f max=16.0f]
float S_ThetaMultGrass = 4.0f;

[Setting category="Theta mults" name="Plastic" min=1.0f max=16.0f]
float S_ThetaMultPlastic = 4.0f;

[Setting category="Theta mults" name="Backwards" min=0.1f max=2.0f]
float S_ThetaMultBW = 1.0f;

[Setting category="Theta mults" name="Wood" min=0.1f max=2.0f]
float S_ThetaMultWood = 1.0f;

[Setting category="Theta mults" name="Derivative" min=0.1f max=0.5f]
float S_ThetaMultDerivative = 0.35f;


[Setting category="Cam3" name="Internal cam3 start" min=0.1f max=10.0f]
float S_Cam3InternalStart = 5.629f;

[Setting category="Cam3" name="Internal cam3 length" min=0.1f max=100.0f]
float S_Cam3InternalLength = 100.0f;

[Setting category="Cam3" name="External cam3 start" min=0.1f max=10.0f]
float S_Cam3ExternalStart = 2.792f;

[Setting category="Cam3" name="External cam3 length" min=0.1f max=100]
float S_Cam3ExternalLength = 100.0f;


[Setting category="Simplified view" name="Simplified view"]
bool S_Simplified = false;

[Setting category="Simplified view" name="Simplified view X offset" min=-2.0f max=2.0f]
float S_SimplifiedOffsetX = -1.5f;

[Setting category="Simplified view" name="Simplified view Z offset" min=0.1f max=2.0f]
float S_SimplifiedOffsetZ = 0.867f;

[Setting category="Simplified view" name="Simplified view pointer start" min=0.1f max=1.0f]
float S_SimplifiedStart = 0.1f;

[Setting category="Simplified view" name="Simplified view pointer length" min=0.5f max=2.0f]
float S_SimplifiedLength = 1.5f;

[Setting category="Simplified view" name="Simplified opacity override" min=0.0f max=1.0f]
float S_SimplifiedOpacity = 0.117f;

[Setting category="Simplified view" name="Simplified view line thickness" min=1.0f max=20.0f]
float S_SimplifiedLineThickness = 10.0f;

[Setting category="Simplified view" name="Draw Cam 3 lines in simplified view"]
bool S_SimplifiedCam3 = false;


[Setting category="Preview" name="Preview road"]
bool S_PreviewRoad = false;

[Setting category="Preview" name="Preview grass"]
bool S_PreviewGrass = false;

[Setting category="Preview" name="Preview dirt"]
bool S_PreviewDirt = false;

[Setting category="Preview" name="Preview plastic"]
bool S_PreviewPlastic = false;

[Setting category="Preview" name="Preview ice"]
bool S_PreviewIce = false;

[Setting category="Preview" name="Preview wood"]
bool S_PreviewWood = false;

[Setting category="Preview" name="Preview speed" min=0.0f max=1000.0f]
float S_PreviewSpeed = 500.0f;

[Setting category="Preview" name="Preview slip" min=-3.14f max=3.14f]
float S_PreviewSlip = 0.1f;

[Setting category="Preview" name="Preview gear" min=1 max=5]
int S_PreviewGear = 5;

[Setting category="Preview" name="Wet Preview"]
bool S_PreviewWet = false;

[Setting category="Preview" name="Icy Preview"]
bool S_PreviewIcy = false;


[Setting category="History" name="Enable run history view"]
bool S_History = true;

[Setting category="History" name="Number of run history points to draw" min=1 max=100]
int S_HistoryPoints = 60;

[Setting category="History" name="Amount of time to show in history (in seconds)" min=0.5 max=5.0f]
float S_HistorySeconds = 1.0f;

[Setting category="History" name="History min width" min=1.0f max=4.0f]
float S_HistoryWidthMin = 1.32f;

[Setting category="History" name="History max width" min=4.0f max=16.0f]
float S_HistoryWidthMax = 12.13f;

[Setting category="History" name="Start opacity" min=0.05f max=1.0f]
float S_HistoryStartOpacity = 0.115f;

[Setting category="History" name="Decay factor" min=1.01f max=10.0f]
float S_HistoryDecayFactor = 7.583f;

[Setting category="History" name="Start base offset" min=-3.0f max=3.0f]
float S_HistoryStartOffset = 1.09f;

[Setting category="History" name="Start offset" min=-3.0f max=10.0f]
float S_HistoryStartHeight = 5.599f;

[Setting category="History" name="End offset" min=0.0f max=3.0f]
float S_HistoryEndHeight = 0.289f;

[Setting category="History" name="History distance factor" min=0.5f max=5.0f]
float S_HistoryDistanceFactor = 1.0f;


[Setting category="Advanced" name="Player Pointer Opacity Derivative" min=0.001f max=0.01f]
float S_PlayerOpacityDerivative = 0.003f;

[Setting category="Advanced" name="Gear pointer offset" min=0.0f max=1.0f]
float S_GearPointerOffset = 0.2f;

[Setting category="Advanced" name="Gear theta flip threshold (in rads)"]
float S_ThetaFlipThreshold = 0.1f;

[Setting category="Advanced" name="Perspective constant" min=1.0f max=20.0f]
float S_PerspectiveConstant = 7.0f;

[Setting category="Advanced" name="History Perspective constant" min=0.5f max=40.0f]
float S_HistoryPerspectiveConstant = 30.0f;


[Setting category="Overrides" name="Is Rally Car"]
bool S_RallyOverride = false;


// [Setting category="Gear Display" name="Graph Width" min=50 max=2000]
int S_GraphWidth = 100;

// [Setting category="Gear Display" name="Graph Height" min=50 max=1000]
int S_GraphHeight = 200;

// [Setting category="Gear Display" name="Graph X Offset" min=0 max=4000]
int S_GraphOffsetX = 32;

// [Setting category="Gear Display" name="Graph Y Offset" min=0 max=2000]
int S_GraphOffsetY = 600;

// [Setting category="Gear Display" name="Border Radius" min=0 max=50]
float S_BorderRadius = 5.0f;

// [Setting category="Gear Display" name="Backdrop Color" color]
vec4 S_ColorBackdrop = vec4(0.0f, 0.0f, 0.0f, 0.7f);

// [Setting category="Gear Display" name="Border Color" color]
vec4 S_ColorBorder = vec4(0.0f, 0.0f, 0.0f, 1.0f);

// [Setting category="Gear Display" name="Border Width" min=0 max=10]
float S_BorderWidth = 1.0f;

// [Setting category="Gear Display" name="Milliseconds Averaged" min=200 max=1000]
int S_MsAveraged = 250;

// [Setting category="Gear Display" name="Enable Gear Hud"]
bool S_GearHUD = false;
