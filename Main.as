Protractor @ protractor;
float HALF_PI = 1.57079632679;

string getMapUid() {
  auto app = cast < CTrackMania > (GetApp());
  if (app != null) {
    if (app.RootMap != null) {
      if (app.RootMap.MapInfo != null) {
        return app.RootMap.MapInfo.MapUid;
      }
    }
  }
  return "";
}

CSceneVehicleVisState@ getVisState() {
  return VehicleState::ViewingPlayerState();
}

void Render() {
  if (!g_visible) {
    return;
  }

  if (protractor!is null) {
    auto app = GetApp();
    if (app.CurrentPlayground!is null && (app.CurrentPlayground.UIConfigs.Length > 0)) {
      if (app.CurrentPlayground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::Intro) {
        return;
      }
    }

    if (app!is null && app.GameScene!is null) {
      protractor.render();
    }
  }
}


void Main() {
  @protractor = Protractor();
}

void OnSettingsChanged() {
  protractor.OnSettingsChanged();
}