Protractor@ protractor;
DatabaseFunctions@ databasefunctions;

float HALF_PI = 1.57079632679;
float g_dt = 0;

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
    if (databasefunctions.isMapSkipped(getMapUid())) {
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
            protractor.render();
        }
    }
}

void RenderMenu() {
    if (UI::BeginMenu(((g_visible || databasefunctions.isMapSkipped(getMapUid())) ? "\\$393" : "\\$999") + Icons::Bars + "\\$z GigaChad Protractor", true)) {
        if (UI::MenuItem(g_visible ? "\\$999" + Icons::Check + "\\$z Disable GCP" : "\\$393" + Icons::Check + "\\$z Enable GCP")) {
            g_visible = !g_visible;
        }
        if (UI::MenuItem("Disable on this map")) {
            databasefunctions.disableMap(getMapUid());
        }
        if (UI::MenuItem("Enable on this map")) {
            databasefunctions.enableMap(getMapUid());
        }
        UI::EndMenu();
    }
}

void Update(float dt) {
    g_dt = dt;
}
