[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Player index" min=0 max=10]
int S_PlayerIndex = 0;

[Setting category="General" name="Show warning line on early slide/noslide"]  // TODO
bool S_ShowBadSlide = false;


[Setting category="SD Pointer" name="Minimum brightness" min=0.0f max=1.0f]
float S_BrightnessMin = 0.1f;

[Setting category="SD Pointer" name="Opacity derivative" min=0.001f max=0.01f]
float S_OpacityDerivative = 0.003f;

[Setting category="SD Pointer" name="Start" min=0.0f max=16.0f]
float S_Start = 3.8f;

[Setting category="SD Pointer" name="Start (cam 3)" min=0.1f max=10.0f]
float S_Cam3InternalStart = 5.629f;

[Setting category="SD Pointer" name="Start (alt cam 3)" min=0.1f max=10.0f]
float S_Cam3ExternalStart = 2.792f;

[Setting category="SD Pointer" name="Length" min=0.0f max=16.0f]
float S_Length = 8.0f;

[Setting category="SD Pointer" name="Length (cam 3)" min=0.1f max=100.0f]
float S_Cam3InternalLength = 50.0f;

[Setting category="SD Pointer" name="Length (alt cam 3)" min=0.1f max=100]
float S_Cam3ExternalLength = 5.0f;

[Setting category="SD Pointer" name="Assist line length fraction" min=1.0f max=10.0f]
float S_AssistLength = 4.0f;

[Setting category="SD Pointer" name="Width" min=1.0f max=10.0f]
float S_Width = 4.7f;

[Setting category="SD Pointer" name="Spacing (road)" min=1.0f max=16.0f]
float S_ThetaMultRoad = 4.0f;

[Setting category="SD Pointer" name="Spacing (dirt)" min=1.0f max=16.0f]
float S_ThetaMultDirt = 4.0f;

[Setting category="SD Pointer" name="Spacing (grass)" min=1.0f max=16.0f]
float S_ThetaMultGrass = 4.0f;

[Setting category="SD Pointer" name="Spacing (plastic)" min=1.0f max=16.0f]
float S_ThetaMultPlastic = 4.0f;

[Setting category="SD Pointer" name="Spacing (wood)" min=0.1f max=2.0f]  // TODO
float S_ThetaMultWood = 1.0f;

[Setting category="SD Pointer" name="Spacing (backwards)" min=0.1f max=4.0f]
float S_ThetaMultBW = 1.0f;

[Setting category="SD Pointer" name="Spacing (derivative)" min=0.1f max=0.5f]  // TODO
float S_ThetaMultDerivative = 0.35f;

[Setting category="SD Pointer" name="Optimal acceleration assist lines"]  // TODO
bool S_OptimalAccel = true;

[Setting category="SD Pointer" name="Optimal acceleration color" color if="S_OptimalAccel"]
vec4 S_OptimalAccelColor(0.0f, 1.0f, 0.0f, 1.0f);

[Setting category="SD Pointer" name="Good acceleration assist lines"]
bool S_GoodAccel = true;

[Setting category="SD Pointer" name="Good acceleration color" color if="S_GoodAccel"]
vec4 S_GoodAccelColor(0.0f, 0.0f, 1.0f, 1.0f);

[Setting category="SD Pointer" name="Good acceleration threshold" min=0.1f max=0.995f if="S_GoodAccel"]
float S_GoodAccelThreshold = 0.9f;

[Setting category="SD Pointer" name="Base acceleration assist lines"]
bool S_BaseAccel = true;

[Setting category="SD Pointer" name="Base acceleration color" color if="S_BaseAccel"]
vec4 S_BaseAccelColor(1.0f, 0.0f, 0.0f, 1.0f);

[Setting category="SD Pointer" name="Zero acceleration assist lines"]
bool S_ZeroAccel = true;

[Setting category="SD Pointer" name="Zero acceleration color" color if="S_ZeroAccel"]
vec4 S_ZeroAccelColor(0.0f, 0.0f, 0.0f, 1.0f);

[Setting category="SD Pointer" name="Show gears"]
bool S_Gears = false;

[Setting category="SD Pointer" name="Gears offset" min=0.0f max=1.0f if="S_Gears"]
float S_GearPointerOffset = 0.2f;

[Setting category="SD Pointer" name="Normal gearup color" color if="S_Gears"]
vec4 S_UpshiftNormalColor(1.0f);

[Setting category="SD Pointer" name="Danger gearup color" color if="S_Gears"]
vec4 S_UpshiftDangerColor(1.0f, 0.0f, 0.0f, 1.0f);

[Setting category="SD Pointer" name="Hide gears when in gear 5" if="S_Gears"]
bool S_HideGear5 = true;

[Setting category="SD Pointer" name="Show gears on both sides" if="S_Gears"]
bool S_GearBothSides = true;

[Setting category="SD Pointer" name="Show full gear lines on ice" if="S_Gears"]  // TODO
bool S_VerboseIceGears = false;


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


[Setting category="History Trail" name="Enabled"]
bool S_History = true;

[Setting category="History Trail" name="Number of points to draw" min=1 max=100]
int S_HistoryPoints = 60;

[Setting category="History Trail" name="Amount of time to show" min=0.5 max=5.0f description="in seconds"]
float S_HistorySeconds = 1.0f;

[Setting category="History Trail" name="Minimum width" min=1.0f max=4.0f]
float S_HistoryWidthMin = 1.32f;

[Setting category="History Trail" name="Maximum width" min=4.0f max=16.0f]
float S_HistoryWidthMax = 12.13f;

[Setting category="History Trail" name="Start opacity" min=0.05f max=1.0f]
float S_HistoryStartOpacity = 0.115f;

[Setting category="History Trail" name="Decay factor" min=1.01f max=10.0f]
float S_HistoryDecayFactor = 7.583f;

[Setting category="History Trail" name="Start base offset" min=-3.0f max=3.0f]
float S_HistoryStartOffset = 1.09f;

[Setting category="History Trail" name="Start offset" min=-3.0f max=10.0f]
float S_HistoryStartHeight = 5.599f;

[Setting category="History Trail" name="End offset" min=0.0f max=3.0f]
float S_HistoryEndHeight = 0.289f;

[Setting category="History Trail" name="Distance factor" min=0.5f max=5.0f]
float S_HistoryDistanceFactor = 1.0f;


[Setting category="Simplified View" name="Enabled"]
bool S_Simplified = false;

[Setting category="Simplified View" name="Start" min=0.1f max=1.0f]
float S_SimplifiedStart = 0.1f;

[Setting category="Simplified View" name="Length" min=0.5f max=2.0f]
float S_SimplifiedLength = 1.5f;

[Setting category="Simplified View" name="Width" min=1.0f max=20.0f]
float S_SimplifiedWidth = 10.0f;

[Setting category="Simplified View" name="X offset" min=-2.0f max=2.0f]
float S_SimplifiedOffsetX = -1.5f;

[Setting category="Simplified View" name="Z offset" min=0.1f max=2.0f]
float S_SimplifiedOffsetZ = 0.867f;

[Setting category="Simplified View" name="Opacity override" min=0.0f max=1.0f]
float S_SimplifiedOpacity = 0.117f;

[Setting category="Simplified View" name="Draw in cam 3"]
bool S_SimplifiedCam3 = true;


[Setting category="Preview" name="Road"]
bool S_PreviewRoad = false;

[Setting category="Preview" name="Grass"]
bool S_PreviewGrass = false;

[Setting category="Preview" name="Dirt"]
bool S_PreviewDirt = false;

[Setting category="Preview" name="Plastic"]
bool S_PreviewPlastic = false;

[Setting category="Preview" name="Ice"]
bool S_PreviewIce = false;

[Setting category="Preview" name="Wood"]
bool S_PreviewWood = false;

[Setting category="Preview" name="Wet"]
bool S_PreviewWet = false;

[Setting category="Preview" name="Icy"]
bool S_PreviewIcy = false;

[Setting category="Preview" name="Speed" min=0.0f max=1000.0f]
float S_PreviewSpeed = 500.0f;

[Setting category="Preview" name="Slip" min=-3.14f max=3.14f]
float S_PreviewSlip = 0.1f;

[Setting category="Preview" name="Gear" min=1 max=5]
int S_PreviewGear = 5;


[Setting category="Overrides" name="Rally Car"]
bool S_RallyOverride = false;
