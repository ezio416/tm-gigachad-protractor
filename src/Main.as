Protractor@ protractor;
DatabaseFunctions@ databasefunctions;

float HALF_PI = 1.57079632679;
float g_dt = 0;

string getMapUid() {
    auto App = cast<CTrackMania>(GetApp());
    if (App.RootMap !is null) {
        App.RootMap.EdChallengeId;
    }
    return "";
}

CSceneVehicleVisState@ getVisState() {
    if (PLAYER_IDX == 0) {
        return VehicleState::ViewingPlayerState();
    }
    int pidx = Math::Clamp(PLAYER_IDX, 0, VehicleState::GetAllVis(GetApp().GameScene).Length);
    auto arr = VehicleState::GetAllVis(GetApp().GameScene);
    if (arr.Length == 0) {
        return null;
    }
    auto vs = arr[pidx];
    if (vs !is null) {
        return vs.AsyncState;
    }
    return null;
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

void Update(float dt) {
    g_dt = dt;
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

void Main() {
    @protractor = Protractor();
    @databasefunctions = DatabaseFunctions();
}

void OnSettingsChanged() {
    protractor.OnSettingsChanged();
}

[Setting category="General" name="Player index" drag min=0 max=10]
int PLAYER_IDX = 0;
