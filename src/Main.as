const string  pluginColor = "\\$393";
const string  pluginIcon  = Icons::Bars;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

Protractor protractor;
DatabaseFunctions databasefunctions;

const float HALF_PI = 1.57079632679f;
float g_dt = 0.0f;

void OnSettingsChanged() {
    protractor.OnSettingsChanged();
}

void Render() {
    if (!g_visible or databasefunctions.IsMapSkipped(GetMapUid())) {
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
        if (UI::MenuItem("Enabled", "", g_visible)) {
            g_visible = !g_visible;
        }

        const string uid = GetMapUid();

        UI::BeginDisabled(uid.Length == 0);
        if (databasefunctions.IsMapSkipped(uid)) {
            if (UI::MenuItem("Enable on this map")) {
                databasefunctions.EnableMap(uid);
            }
        } else {
            if (UI::MenuItem("Disable on this map")) {
                databasefunctions.DisableMap(uid);
            }
        }
        UI::EndDisabled();

        UI::EndMenu();
    }
}

void Update(float dt) {
    g_dt = dt;
}
