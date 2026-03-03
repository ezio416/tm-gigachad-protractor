const string  pluginColor = "\\$393";
const string  pluginIcon  = Icons::Bars;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

const float TWO_PI     = Math::PI * 2.0f;
const float HALF_PI    = Math::PI * 0.5f;
const float THIRD_PI   = Math::PI / 3.0f;
const float QUARTER_PI = HALF_PI * 0.5f;
const float SIXTH_PI   = THIRD_PI * 0.5f;

float g_dt = 0.0f;

void Main() {
    Skipped::Load();

    for (uint i = 0; i < DERIVATIVES_MAX; i++) {
        derivativeArrays[i] = vec3[](SMOOTHING_MAX);
    }
}

void OnSettingsChanged() {
    if (S_ResetFront) {
        S_SDPointerStart = 3.8f;
        S_SDPointerLength = 8.0f;
        S_ResetFront = false;
    }

    if (S_ResetBack) {
        S_SDPointerStart = 1.731f;
        S_SDPointerLength = 2.69f;
        S_ResetBack = false;
    }

    if (S_IcePointerFrontCorner) {
        S_IcePointerOffsetX = 1.7f;
        S_IcePointerOffsetZ = -0.7f;
        S_IcePointerOffsetAngle = -0.6f;
        S_IcePointerFrontCorner = false;
    }
}

void Render() {
    if (!S_Enabled or Skipped::Skipped(GetMapUid())) {
        return;
    }

    CGameCtnApp@ App = GetApp();
    if (true
        and App.CurrentPlayground !is null
        and App.CurrentPlayground.UIConfigs.Length > 0
        and App.CurrentPlayground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::Intro
    ) {
        return;
    }

    if (App.GameScene !is null) {
        RenderProtractor();
    }
}

void RenderMenu() {
    if (UI::BeginMenu(pluginTitle)) {
        if (UI::MenuItem("Enabled", "", S_Enabled)) {
            S_Enabled = !S_Enabled;
        }

        const string uid = GetMapUid();

        UI::BeginDisabled(uid.Length == 0);
        if (Skipped::Skipped(uid)) {
            if (UI::MenuItem("Enable on this map")) {
                Skipped::Unskip(uid);
            }
        } else {
            if (UI::MenuItem("Disable on this map")) {
                Skipped::Skip(uid);
            }
        }
        UI::EndDisabled();

        UI::EndMenu();
    }
}

void Update(float dt) {
    g_dt = dt;
}
