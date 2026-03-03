enum CameraMode {
    External,
    Cam3,
    AltCam3
}

enum RenderMode {
    Normal,
    Ice,
    Backwards
}

vec4 ApplyOpacityToColor(const vec4&in inColor, const float opacity) {
    if (false
        or Math::IsInf(opacity)
        or Math::IsNaN(opacity)
        or Math::IsInf(inColor.x)
        or Math::IsNaN(inColor.x)
    ) {
        return vec4();
    }

    vec4 outColor = inColor;
    outColor.w = Math::Min(opacity, outColor.w);
    outColor.w = Math::Max(outColor.w, 0.0f);

    return outColor;
}

vec4 GetColor(const int index) {
    switch (index) {
        case 0: return S_ColorOptimal;
        case 1: return S_Color90;
        case 2: return S_Color50;
        case 3: return S_Color0;
    }
    return S_Color0;
}

string GetMapUid() {
    CGameCtnApp@ App = GetApp();
    return App.RootMap !is null ? App.RootMap.EdChallengeId : "";
}

CSmPlayer@ GetPlayer() {
    auto playground = GetPlayground();
    if (true
        and playground !is null
        and playground.GameTerminals.Length > 0
        and playground.GameTerminals[0] !is null
    ) {
        return cast<CSmPlayer>(playground.GameTerminals[0].GUIPlayer);
    }
    return null;
}

int GetPlayerStartTime() {
    CSmPlayer@ Player = GetPlayer();
    return Player !is null ? Player.StartTime : 0;
}

CSmArenaClient@ GetPlayground() {
    return cast<CSmArenaClient>(GetApp().CurrentPlayground);
}

float GetSlipTotal(CSceneVehicleVisState@ visState) {
    return visState.FLSlipCoef + visState.FRSlipCoef + visState.RRSlipCoef + visState.RLSlipCoef;
}

float GetTargetThetaMultFactor(CSceneVehicleVisState@ visState) {
    if (visState.FLIcing01 > 0.0f) {
        return 1.0f;
    }

    if (visState.FrontSpeed < 0.0f) {
        return S_ThetaMultBW;
    }

    if (S_Simplified) {
        return 1.0f;
    }

    return 0.25f * (0.0f
        + Surface::GetThetaMult(visState.FLGroundContactMaterial)
        + Surface::GetThetaMult(visState.FRGroundContactMaterial)
        + Surface::GetThetaMult(visState.RLGroundContactMaterial)
        + Surface::GetThetaMult(visState.RRGroundContactMaterial)
    );
}

CSceneVehicleVisState@ GetVisState() {
    if (S_PlayerIndex == 0) {
        return VehicleState::ViewingPlayerState();
    }

    CSceneVehicleVis@[] AllVis = VehicleState::GetAllVis(GetApp().GameScene);
    if (AllVis.Length == 0) {
        return null;
    }

    CSceneVehicleVis@ vis = AllVis[Math::Clamp(S_PlayerIndex, 0, AllVis.Length)];
    return vis !is null ? vis.AsyncState : null;
}

bool IsPreview() {
    return S_PreviewDirt or S_PreviewGrass or S_PreviewIce or S_PreviewPlastic or S_PreviewRoad or S_PreviewWood;
}

float PreviewSlip(const float in_slip) {
    return IsPreview() ? S_PreviewSlip : in_slip;
}
