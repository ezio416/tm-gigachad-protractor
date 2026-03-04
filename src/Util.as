const float TWO_PI     = Math::PI * 2.0f;
const float HALF_PI    = Math::PI * 0.5f;
const float THIRD_PI   = Math::PI / 3.0f;
const float QUARTER_PI = HALF_PI  * 0.5f;
const float SIXTH_PI   = THIRD_PI * 0.5f;

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

vec4 ApplyOpacityToColor(const vec4&in color, const float opacity) {
    if (false
        or Math::IsInf(opacity)
        or Math::IsNaN(opacity)
        or Math::IsInf(color.x)
        or Math::IsNaN(color.x)
    ) {
        return vec4();
    }

    vec4 ret = color;
    ret.w = Math::Min(opacity, ret.w);
    ret.w = Math::Max(ret.w, 0.0f);

    return ret;
}

float ApproximateSideSpeed(const vec2[]&in data, const float speed) {
    if (data.Length == 0) {
        return 0.0f;
    }

    vec2 lower = data[0];
    vec2 upper = data[data.Length - 1];

    vec2 entry;
    for (uint i = 0; i < data.Length; i++) {
        entry = data[i];

        if (entry.x < speed and entry.x > lower.x) {
            lower = entry;
        }

        if (entry.x > speed and entry.x < upper.x) {
            upper = entry;
        }
    }

    return Math::Lerp(lower.y, upper.y, Math::InvLerp(lower.x, upper.x, speed));
}

float CalcAngle(const vec3&in v1, const vec3&in v2) {
    return IsPreview() ? S_PreviewSlip : Math::Angle(v1, v2);
}

float CalcVecAngle(const vec3&in v1, const vec3&in v2) {
    if (v1.Length() == 0.0f or v2.Length() == 0.0f) {
        return 0.0f;
    }

    return Math::Acos(Math::Dot(v1, v2) / (v1.Length() * v2.Length())) - HALF_PI;
}

CameraMode GetCameraMode(CSceneVehicleVisState@ visState) {
    const vec3 cameraPos = Camera::GetCurrentPosition();
    const float v1 = (cameraPos - (visState.Position + visState.Dir)).LengthSquared();
    const float v2 = (cameraPos - visState.Position).LengthSquared();

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
        case 0: return S_OptimalAccelColor;
        case 1: return S_GoodAccelColor;
        case 2: return S_BaseAccelColor;
    }

    return S_ZeroAccelColor;
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

float GetSideSpeedAngle(const float vel, const float targetSideSpeed) {
    return Math::Asin(targetSideSpeed / vel);
}

float GetSlipSmoothed(const vec3&in left, const vec3&in vel) {
    return IsPreview() ? S_PreviewSlip : CalcVecAngle(left, vel);
}

float GetSlipTotal(CSceneVehicleVisState@ visState) {
    return visState.FLSlipCoef + visState.FRSlipCoef + visState.RRSlipCoef + visState.RLSlipCoef;
}

vec2 GetStartAndLength() {
    switch (camera) {
        case CameraMode::Cam3:    return vec2(S_Cam3InternalStart, S_Cam3InternalLength);
        case CameraMode::AltCam3: return vec2(S_Cam3ExternalStart, S_Cam3ExternalLength);
    }

    return vec2(S_Start, S_Length);
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
        + Surface::GetThetaMult(visState.RRGroundContactMaterial)
        + Surface::GetThetaMult(visState.RLGroundContactMaterial)
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

    CSceneVehicleVis@ vis = AllVis[Math::Clamp(S_PlayerIndex, 0, AllVis.Length - 1)];
    return vis !is null ? vis.AsyncState : null;
}

bool IsPreview() {
    return S_PreviewDirt or S_PreviewGrass or S_PreviewIce or S_PreviewPlastic or S_PreviewRoad or S_PreviewWood;
}

float LerpToMidpoint(const vec2[]&in points, const float c) {
    if (points.Length < 2) {
        return 0.0f;
    }

    vec2 lower = points[0];
    if (c < lower.x) {
        return lower.y;
    }

    vec2 upper = points[points.Length - 1];
    if (c > upper.x) {
        return upper.y;
    }

    upper = points[1];

    for (uint i = 1; i < points.Length - 1; i++) {
        if (points[i].x >= c) {
            break;
        }

        lower = points[i];
        upper = points[i + 1];
    }

    return Math::Lerp(lower.y, upper.y, Math::InvLerp(lower.x, upper.x, c));
}

void LineTo(const vec3&in p) {
    if (!Camera::IsBehind(p)) {
        nvg::LineTo(Camera::ToScreenSpace(p));
    }
}

float NormalizeSlipAngle(float slipAngle, const float frontSpeed) {
    const float polarity = slipAngle < 0.0f ? -1.0f : 1.0f;
    slipAngle = Math::Abs(slipAngle);
    return polarity * (frontSpeed < 0.0f ? Math::PI - slipAngle : slipAngle);
}

float PreviewSlip(const float slip) {
    return IsPreview() ? S_PreviewSlip : slip;
}

vec3 ProjectAngle(CSceneVehicleVisState@ visState, const float rad, const float theta) {
    return vec3()
        + visState.Position
        + (visState.Dir  * Math::Cos(theta) * rad)
        + (visState.Left * Math::Sin(theta) * rad)
    ;
}

vec3 ProjectOffset(CSceneVehicleVisState@ visState, const vec3&in pos, const vec3&in offset) {
    return vec3()
        + pos
        + (visState.Dir  * offset.x)
        + (visState.Up   * offset.y)
        + (visState.Left * offset.z)
    ;
}
