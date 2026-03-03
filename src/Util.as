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

CameraMode GetCameraMode(CSceneVehicleVisState@ visState) {
    const vec3 pos = visState.Position;
    const vec3 cameraPos = Camera::GetCurrentPosition();
    const vec3 pos_offset_forward = visState.Position + visState.Dir;

    const float v1 = (cameraPos - pos_offset_forward).LengthSquared();
    const float v2 = (cameraPos - pos).LengthSquared();

    if (v1 > 1.9f and v1 < 2.0f and v2 > 0.85f and v2 < 0.9f) {
        return CameraMode::Cam3;
    }

    if (v1 > 2.3f and v1 < 2.4f and v2 > 2.7f and v2 < 2.8f) {
        return CameraMode::AltCam3;
    }

    return CameraMode::External;
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

vec2 GetStartAndLength() {
    switch (camera) {
        case CameraMode::Cam3:    return vec2(S_Cam3InternalStart, S_Cam3InternalLength);
        case CameraMode::AltCam3: return vec2(S_Cam3ExternalStart, S_Cam3ExternalLength);
        default:                  return vec2(S_SDPointerStart,    S_SDPointerLength);
    }
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

void LineTo(const vec3&in p) {
    if (!Camera::IsBehind(p)) {
        nvg::LineTo(Camera::ToScreenSpace(p));
    }
}

bool IsPreview() {
    return S_PreviewDirt or S_PreviewGrass or S_PreviewIce or S_PreviewPlastic or S_PreviewRoad or S_PreviewWood;
}

void PreviewOpacityCheck() {
    if (IsPreview()) {
        playerFadeOpacity = 1.0f;
    }
}

float PreviewSlip(const float in_slip) {
    return IsPreview() ? S_PreviewSlip : in_slip;
}

vec3 ProjectAngle(CSceneVehicleVisState@ visState, const float r, const float theta) {
    return vec3()
        + visState.Position
        + (visState.Dir  * Math::Cos(theta) * r)
        + (visState.Left * Math::Sin(theta) * r)
    ;
}

vec3 ProjectOffset(CSceneVehicleVisState@ visState, const vec3&in in_pos, const vec3&in offset) {
    return vec3()
        + in_pos
        + (visState.Dir  * offset.x)
        + (visState.Up   * offset.y)
        + (visState.Left * offset.z)
    ;
}
