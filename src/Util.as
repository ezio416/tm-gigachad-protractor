vec4 ApplyOpacityToColor(const vec4&in inColor, const float opacity) {
    if (Math::IsInf(opacity) || Math::IsNaN(opacity)) {
        return vec4();
    }

    if (Math::IsInf(inColor.x) || Math::IsNaN(inColor.x)) {
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
        if (entry.x < speed && entry.x > lower.x) {
            lower = entry;
        }
        if (entry.x > speed && entry.x < upper.x) {
            upper = entry;
        }
    }
    const float t = Math::InvLerp(lower.x, upper.x, speed);
    const float interpolated = Math::Lerp(lower.y, upper.y, t);
    return interpolated;
}

float CalcAngle(const vec3&in v1, const vec3&in v2) {
    if (IsPreview()) {
        return PREVIEW_SLIP;
    }
    return Math::Angle(v1, v2);
}

float CalcVecAngle(const vec3&in vec1, const vec3&in vec2) {
    if (vec1.Length() == 0 || vec2.Length() == 0) {
        return 0.0f;
    }
    float angle = Math::Acos(Math::Dot(vec1, vec2) / (vec1.Length() * vec2.Length())) - HALF_PI;
    return angle;
}

vec4 GetColor(const int idx) {
    switch (idx) {
        case 0:
            return COLOR_100;
        case 1:
            return COLOR_90;
        case 2:
            return COLOR_50;
        case 3:
            return COLOR_0;
    }
    return COLOR_0;
}

string GetMapUid() {
    CGameCtnApp@ App = GetApp();
    return App.RootMap !is null ? App.RootMap.EdChallengeId : "";
}

CSmPlayer@ GetPlayer() {
    auto playground = GetPlayground();
    if (playground !is null) {
        if (playground.GameTerminals.Length > 0) {
            return cast<CSmPlayer>(playground.GameTerminals[0].GUIPlayer);
        }
    }
    return null;
}

int GetPlayerStartTime() {
    CSmPlayer@ Player = GetPlayer();
    if (Player !is null)
        return Player.StartTime;
    return 0;
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
        return BACKWARDS_TM;
    }

    if (SIMPLIFIED_VIEW) {
        return 1.0f;
    }

    float sum =
        GetThetaMultForSurface(visState.FLGroundContactMaterial)
            + GetThetaMultForSurface(visState.FRGroundContactMaterial)
            + GetThetaMultForSurface(visState.RLGroundContactMaterial)
            + GetThetaMultForSurface(visState.RRGroundContactMaterial);

    return sum / 4.0f;
}

float GetThetaMultForSurface(const EPlugSurfaceMaterialId surface) {
    if (IsIceSurface(surface)) {
        return 1.0f;
    }
    if (IsDirtSurface(surface)) {
        return DIRT_TM;
    }
    if (IsTarmacSurface(surface)) {
        return TARMAC_TM;
    }
    if (IsGrassSurface(surface)) {
        return GRASS_TM;
    }
    if (IsPlasticSurface(surface)) {
        return PLASTIC_TM;
    }
    if (IsWoodSurface(surface)) {
        return WOOD_TM;
    }
    return -1000.0f;
}

CSceneVehicleVisState@ GetVisState() {
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

bool IsDirtSurface(const EPlugSurfaceMaterialId surface) {
    return
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Dirt ||
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::DirtRoad;
}

bool IsGrassSurface(const EPlugSurfaceMaterialId surface) {
    return surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Grass ||
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Green;
}

bool IsIceSurface(const EPlugSurfaceMaterialId surface) {
    return
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Ice ||
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Concrete ||
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::RoadIce ||
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Snow;
}

bool IsPlasticDirtOrGrass(const EPlugSurfaceMaterialId surface) {
    return IsPlasticSurface(surface) ||
        IsDirtSurface(surface) ||
        IsGrassSurface(surface);
}

bool IsPlasticSurface(const EPlugSurfaceMaterialId surface) {
    return
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Plastic ||
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Rubber ||  // found on edges of some plastic items, e.g., the mesh roof decor thing
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Water;  // ??? is this a good fit?
}

bool IsPreview() {
    return PREVIEW_DIRT || PREVIEW_GRASS || PREVIEW_ICE || PREVIEW_PLASTIC || PREVIEW_TARMAC || PREVIEW_WOOD;
}

bool IsSupportedSurface(const EPlugSurfaceMaterialId surface) {
    return IsPlasticSurface(surface) ||
        IsIceSurface(surface) ||
        IsDirtSurface(surface) ||
        IsGrassSurface(surface) ||
        IsWoodSurface(surface);
}

bool IsTarmacSurface(const EPlugSurfaceMaterialId surface) {
    return
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Concrete ||
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Asphalt ||
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::RoadSynthetic ||
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::TechMagnetic ||
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::TechSuperMagnetic ||
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::ResonantMetal;
}

bool IsWoodSurface(const EPlugSurfaceMaterialId surface) {
    return
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Wood ||
        surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::SlidingWood;
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
        if (points[i].x < c) {
            lower = points[i];
            upper = points[i + 1];
        } else {
            break;
        }
    }
    const float pos = Math::InvLerp(lower.x, upper.x, c);
    return Math::Lerp(lower.y, upper.y, pos);
}

float NormalizeSlipAngle(float slipAngle, const float frontSpeed) {
    int polarity;
    float ret;

    if (slipAngle < 0) {
        polarity = -1;
    } else {
        polarity = 1;
    }

    slipAngle = Math::Abs(slipAngle);

    if (frontSpeed < 0) {
        ret = Math::PI - slipAngle;
    } else {
        ret = slipAngle;
    }
    return ret * polarity;
}

float PreviewSlip(const float in_slip) {
    if (IsPreview()) {
        return PREVIEW_SLIP;
    } else {
        return in_slip;
    }
}
