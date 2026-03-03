const string  pluginColor = "\\$393";
const string  pluginIcon  = Icons::Bars;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

const float HALF_PI = 1.570796f;

float      g_dt = 0.0f;
Protractor protractor;

void Main() {
    Skipped::Load();
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
        S_IcePointerFrontCorner = false;
        S_IcePointerOffsetX = 1.7f;
        S_IcePointerOffsetZ = -0.7f;
        S_IcePointerOffsetAngle = -0.6f;
    }
}

void Render() {
    if (!S_Enabled or Skipped::Skipped(GetMapUid())) {
        return;
    }

    CGameCtnApp@ App = GetApp();
    if (App.CurrentPlayground !is null and App.CurrentPlayground.UIConfigs.Length > 0) {
        if (App.CurrentPlayground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::Intro) {
            return;
        }
    }

    if (App.GameScene !is null) {
        protractor.Render();
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
