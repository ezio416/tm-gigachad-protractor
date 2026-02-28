Protractor@ protractor;
DatabaseFunctions@ databasefunctions;

const float HALF_PI = 1.57079632679f;
float g_dt = 0.0f;

void Main() {
    @protractor = Protractor();
    @databasefunctions = DatabaseFunctions();
}

void OnSettingsChanged() {
    protractor.OnSettingsChanged();
}

void Render() {
    if (!g_visible) {
        return;
    }
    if (databasefunctions.IsMapSkipped(GetMapUid())) {
        return;
    }

    if (protractor !is null) {
        auto App = GetApp();
        if (App.CurrentPlayground !is null && App.CurrentPlayground.UIConfigs.Length > 0) {
            if (App.CurrentPlayground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::Intro) {
                return;
            }
        }

        if (App.GameScene !is null) {
            protractor.Render();
        }
    }
}

void RenderMenu() {
    if (UI::BeginMenu(((g_visible || databasefunctions.IsMapSkipped(GetMapUid())) ? "\\$393" : "\\$999") + Icons::Bars + "\\$z GigaChad Protractor", true)) {
        if (UI::MenuItem(g_visible ? "\\$999" + Icons::Check + "\\$z Disable GCP" : "\\$393" + Icons::Check + "\\$z Enable GCP")) {
            g_visible = !g_visible;
        }
        if (UI::MenuItem("Disable on this map")) {
            databasefunctions.DisableMap(GetMapUid());
        }
        if (UI::MenuItem("Enable on this map")) {
            databasefunctions.EnableMap(GetMapUid());
        }
        UI::EndMenu();
    }
}

void Update(float dt) {
    g_dt = dt;
}
