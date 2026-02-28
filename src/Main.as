const string  pluginColor = "\\$393";
const string  pluginIcon  = Icons::Bars;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

float      g_dt = 0.0f;
Protractor protractor;

void Main() {
    Skipped::Load();
}

void OnSettingsChanged() {
    protractor.OnSettingsChanged();
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
