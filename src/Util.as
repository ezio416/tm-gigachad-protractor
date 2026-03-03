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

float ApproximateSideSpeed(const vec2[]&in data, const float speed) {
    if (data.Length == 0) {
        return 0.0f;
    }

    vec2 lower = data[0];
    vec2 upper = data[data.Length - 1];
    for (uint i = 0; i < data.Length; i++) {
        const vec2 entry = data[i];
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

float CalcVecAngle(const vec3&in vec1, const vec3&in vec2) {
    if (vec1.Length() == 0.0f or vec2.Length() == 0.0f) {
        return 0.0f;
    }
    return Math::Acos(Math::Dot(vec1, vec2) / (vec1.Length() * vec2.Length())) - HALF_PI;
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

float GetSideSpeedAngle(const float vel, const float target_sidespeed) {
    return Math::Asin(target_sidespeed / vel);
}

float GetSlipTotal(CSceneVehicleVisState@ visState) {
    return visState.FLSlipCoef + visState.FRSlipCoef + visState.RLSlipCoef + visState.RRSlipCoef;
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

    float sum = 0.0f
        + Surface::GetThetaMult(visState.FLGroundContactMaterial)
        + Surface::GetThetaMult(visState.FRGroundContactMaterial)
        + Surface::GetThetaMult(visState.RLGroundContactMaterial)
        + Surface::GetThetaMult(visState.RRGroundContactMaterial)
    ;

    return sum * 0.25f;
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

float LerpToMidpoint(const vec2[]&in points, const float c) {
    if (points.Length == 0) {
        return 0.0f;
    }

    vec2 lower = points[0];
    vec2 upper = points[points.Length - 1];

    if (c < lower.x) {
        return lower.y;
    }
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

float NormalizeSlipAngle(float slipAngle, const float frontSpeed) {
    const int polarity = slipAngle < 0.0f ? -1 : 1;
    slipAngle = Math::Abs(slipAngle);
    return (frontSpeed < 0.0f ? Math::PI - slipAngle : slipAngle) * polarity;
}

float PreviewSlip(const float in_slip) {
    return IsPreview() ? S_PreviewSlip : in_slip;
}
