const uint  GEARDOWN_RPM_THRESH  = 7500;
const uint  GEARUP_RPM_THRESH    = 10000;
const float POINTER_ABSOLUTE_MAX = 13000.0f;
const float POINTER_ABSOLUTE_MIN = 7000.0f;

CameraMode             camera              = CameraMode::External;
int                    currentRunStartTime = 0;
float                  gearPointerFlip     = 1.0f;
HistoryTrail           historyTrail;
float                  playerFadeOpacity;
RenderMode             renderMode          = RenderMode::Normal;
float                  slipAngle           = 0.0f;
EPlugSurfaceMaterialId surfaceNormalized;
float                  thetaMult;

vec2[] GetLinesToBeRendered(const float ideal, const float good, const float base, const float outer, const bool drawGood) {
    vec2[] ret;

    if (!S_Simplified) {
        if (S_OptimalAccel) {
            ret.InsertLast(vec2(ideal, 0.0f));
        }

        if (S_GoodAccel and drawGood) {
            ret.InsertLast(vec2(good, 1.0f));
        }

        if (S_BaseAccel) {
            ret.InsertLast(vec2(base, 2.0f));
        }

        if (S_ZeroAccel) {
            ret.InsertLast(vec2(outer, 3.0f));
        }
    }

    return ret;
}

vec4 GetPlayerPointerColor(const float sideSpeed, const float target, const float good, const float base, const float outer) {
    float pos;
    int lcol, ucol;

    if (sideSpeed < target) {
        pos = Math::InvLerp(0.0f, target, sideSpeed) ** 4;
        lcol = 2;
        ucol = 0;
    } else if (sideSpeed < good) {
        pos = Math::InvLerp(target, good, sideSpeed);
        lcol = 0;
        ucol = 1;
    } else if (sideSpeed < base) {
        pos = Math::InvLerp(good, base, sideSpeed);
        lcol = 1;
        ucol = 2;
    } else if (sideSpeed < outer) {
        pos = Math::InvLerp(base, outer, sideSpeed);
        lcol = 2;
        ucol = 3;
    } else {
        return S_ZeroAccelColor;
    }

    return GetColor(lcol) * (1.0f - pos) + GetColor(ucol) * pos;
}

float ProcessTheta(float theta) {
    if (renderMode == RenderMode::Ice) {
        return TWO_PI - theta;
    }

    if (true
        and S_Simplified
        and renderMode == RenderMode::Normal
        and camera == CameraMode::External
    ) {
        return Math::PI - theta;
    }

    if (renderMode == RenderMode::Backwards) {
        theta *= -1.0f;
    }

    theta *= thetaMult;

    if (renderMode == RenderMode::Backwards) {
        theta = Math::PI + theta;
    }

    return theta;
}

void RenderAngle(
    CSceneVehicleVisState@ visState,
    const float start,
    const float length,
    const float width,
    const float theta,
    const vec3&in offset,
    const vec4&in color
) {
    if (true
        and S_Simplified
        and renderMode == RenderMode::Normal
        and camera == CameraMode::External
    ) {
        vec3 o = offset;
        o.x += S_SimplifiedOffsetX;
        for (int i = -1; i <= 1; i += 2) {
            o.z = offset.z - (i * S_SimplifiedOffsetZ);
            _RenderAngle(visState, S_SimplifiedStart, S_SimplifiedLength, width, theta, o, color);
        }

    } else {
        _RenderAngle(visState, start, length, width, theta, offset, color);
    }
}

void _RenderAngle(
    CSceneVehicleVisState@ visState,
    const float start,
    const float length,
    float width,
    float theta,
    const vec3&in offset,
    vec4 color
) {
    if (true
        and S_Simplified
        and camera != CameraMode::External
        and !S_SimplifiedCam3
    ) {
        return;
    }

    theta = ProcessTheta(theta);

    if (true
        and S_Simplified
        and camera == CameraMode::External
        and renderMode == RenderMode::Normal
    ) {
        color = ApplyOpacityToColor(color, S_SimplifiedOpacity);
        width = S_SimplifiedWidth;
    }

    const vec3 startPoint = ProjectOffset(visState, ProjectAngle(visState, start, theta), offset);
    const vec3 endPoint = ProjectOffset(visState, ProjectAngle(visState, start + length, theta), offset);

    if (Camera::IsBehind(startPoint) or Camera::IsBehind(endPoint)) {
        return;
    }

    nvg::BeginPath();
    nvg::MoveTo(Camera::ToScreenSpace(startPoint));
    nvg::LineTo(Camera::ToScreenSpace(endPoint));
    nvg::StrokeColor(ApplyOpacityToColor(color, playerFadeOpacity));
    nvg::StrokeWidth(width / (startPoint - Camera::GetCurrentPosition()).Length() * 7.0f);
    nvg::LineCap(nvg::LineCapType::Round);
    nvg::Stroke();
    nvg::ClosePath();
}

void RenderPlayerPointer(
    CSceneVehicleVisState@ visState,
    const float pointerStart,
    const float pointerLength,
    const float pointerWidth,
    const float theta,
    const vec3&in offset,
    vec4 color
) {
    if (S_History and (renderMode != RenderMode::Ice or S_HistoryIce)) {
        historyTrail.Update(theta, color);
        historyTrail.Render(visState, pointerStart, pointerLength);
    }

    if (S_GearBothSides) {
        gearPointerFlip = 1.0f;
    } else if (Math::Abs(theta) > 0.001f) {
        gearPointerFlip = (theta < 0.0f ? -1.0f : 1.0f);
    }

    RenderAngle(
        visState,
        pointerStart,
        pointerLength,
        pointerWidth,
        theta,
        offset,
        ApplyOpacityToColor(color, playerFadeOpacity)
    );

    if (false
        or !S_Gears
        or renderMode == RenderMode::Ice
        or (S_HideGear5 and visState.CurGear == 5)
        or (IsPreview() and S_PreviewGear == 5)
    ) {
        return;
    }

    float rpm, rpmPos, geardownPos, colorPos;
    const vec3 offset_apply = vec3(Math::Sin(theta), 0.0f, gearPointerFlip * Math::Cos(theta)) * S_GearPointerOffset;

    for (int i = 1; i >= (S_GearBothSides ? -1 : 1); i -= 2) {
        rpm = Math::Clamp(Surface::Ice::expectedRpm, POINTER_ABSOLUTE_MIN, POINTER_ABSOLUTE_MAX);
        rpmPos = Math::InvLerp(POINTER_ABSOLUTE_MIN, POINTER_ABSOLUTE_MAX, rpm) * pointerLength;
        geardownPos = Math::InvLerp(POINTER_ABSOLUTE_MIN, POINTER_ABSOLUTE_MAX, GEARDOWN_RPM_THRESH) * pointerLength;

        if (rpm < GEARDOWN_RPM_THRESH) {
            colorPos = Math::InvLerp(POINTER_ABSOLUTE_MIN, GEARDOWN_RPM_THRESH, rpm);

            RenderAngle(
                visState,
                pointerStart + rpmPos,
                geardownPos - rpmPos,
                pointerWidth,
                theta,
                i * offset_apply,
                ApplyOpacityToColor(
                    S_UpshiftDangerColor * (1.0f - colorPos) + S_UpshiftNormalColor * colorPos,
                    playerFadeOpacity
                )
            );

        } else if (rpm < GEARUP_RPM_THRESH) {
            RenderAngle(
                visState,
                pointerStart + geardownPos,
                rpmPos,
                pointerWidth,
                theta,
                i * offset_apply,
                ApplyOpacityToColor(S_UpshiftNormalColor, playerFadeOpacity)
            );

        } else {
            colorPos = Math::InvLerp(GEARUP_RPM_THRESH, POINTER_ABSOLUTE_MAX, rpm);

            RenderAngle(
                visState,
                pointerStart + geardownPos,
                rpmPos,
                pointerWidth,
                theta,
                i * offset_apply,
                ApplyOpacityToColor(
                    S_UpshiftDangerColor * colorPos + S_UpshiftNormalColor * (1 - colorPos),
                    playerFadeOpacity
                )
            );
        }
    }
}

void RenderProtractor() {
    CSceneVehicleVisState@ visState = GetVisState();
    if (visState is null) {
        return;
    }

    camera = GetCameraMode(visState);

    if (S_PreviewRoad) {
        surfaceNormalized = EPlugSurfaceMaterialId::Asphalt;
    } else if (S_PreviewDirt) {
        surfaceNormalized = EPlugSurfaceMaterialId::Dirt;
    } else if (S_PreviewPlastic) {
        surfaceNormalized = EPlugSurfaceMaterialId::Plastic;
    } else if (S_PreviewGrass) {
        surfaceNormalized = EPlugSurfaceMaterialId::Grass;
    } else if (S_PreviewIce) {
        surfaceNormalized = EPlugSurfaceMaterialId::Ice;
    } else if (S_PreviewWood) {
        surfaceNormalized = EPlugSurfaceMaterialId::Wood;
    } else if (visState.FLGroundContactMaterial != EPlugSurfaceMaterialId::XXX_Null) {
        surfaceNormalized = visState.FLGroundContactMaterial;
    }

    const int startTime = GetPlayerStartTime();
    if (currentRunStartTime != startTime) {
        currentRunStartTime = startTime;
        playerFadeOpacity = 0.0f;
    }

    if (IsPreview()) {
        playerFadeOpacity = 1.0f;
    }

    const float target = GetTargetThetaMultFactor(visState);
    if (target >= 0.0f and target != thetaMult) {
        if (target > thetaMult) {
            thetaMult = Math::Min(target, thetaMult + S_ThetaMultDerivative);
        } else {
            thetaMult = Math::Max(target, thetaMult - S_ThetaMultDerivative);
        }
    }

    float speed;

    if (IsPreview()) {
        speed = S_PreviewSpeed / 3.6f;
    } else {
        speed = visState.WorldVel.Length();
        slipAngle = NormalizeSlipAngle(CalcVecAngle(visState.Left, visState.WorldVel), visState.FrontSpeed);
    }

    if (speed < 10.0f) {
        return;
    }

    const vec3 vel = visState.WorldVel / speed;

    Surface::Ice::HandleUpdate(slipAngle, speed, (IsPreview() ? S_PreviewGear : visState.CurGear));

    if (true
        and visState.FLIcing01 > 0.0f
        and Surface::Ice::Is(surfaceNormalized)
        and VehicleState::GetVehicleType(visState) == VehicleState::VehicleType::CarSport
    ) {
        renderMode = RenderMode::Ice;
        Surface::Ice::Render(visState, speed, vel);
        return;
    }

    if (visState.FrontSpeed < 0.0f or (IsPreview() and S_PreviewSpeed < 0.0f)) {
        renderMode = RenderMode::Backwards;

        if (Surface::Grass::Is(surfaceNormalized)) {
            Surface::Grass::RenderBackwards(visState, speed, vel);
            return;
        }

        if (Surface::Dirt::Is(surfaceNormalized)) {
            Surface::Dirt::RenderBackwards(visState, speed, vel);
            return;
        }

        if (Surface::Plastic::Is(surfaceNormalized)) {
            Surface::Plastic::RenderBackwards(visState, speed, vel);
            return;
        }

        if (Surface::Road::Is(surfaceNormalized)) {
            Surface::Road::RenderBackwards(visState, speed, vel);
            return;
        }
    }

    renderMode = RenderMode::Normal;

    if (Surface::Grass::Is(surfaceNormalized)) {
        Surface::Grass::Render(visState, speed, vel);
        return;
    }

    if (Surface::Dirt::Is(surfaceNormalized)) {
        Surface::Dirt::Render(visState, speed, vel);
        return;
    }

    if (Surface::Plastic::Is(surfaceNormalized)) {
        Surface::Plastic::Render(visState, speed, vel);
        return;
    }

    if (Surface::Road::Is(surfaceNormalized)) {
        Surface::Road::Render(visState, speed, vel);
        return;
    }

    if (Surface::Ice::Is(surfaceNormalized)) {
        switch (VehicleState::GetVehicleType(visState)) {
            case VehicleState::VehicleType::CarRally:
                Surface::Ice::RenderRally(visState, speed, vel);
                break;

            case VehicleState::VehicleType::CarDesert:
                Surface::Ice::RenderDesert(visState, speed, vel);
        }

        return;
    }

    if (Surface::Wood::Is(surfaceNormalized) and (S_PreviewWet or visState.WetnessValue01 > 0.0f)) {
        if (false
            or S_PreviewIcy
            or visState.FLIcing01 > 0.0f
            or visState.FRIcing01 > 0.0f
            or visState.RRIcing01 > 0.0f
            or visState.RLIcing01 > 0.0f
        ) {
            Surface::Wood::RenderIcy(visState, speed, vel);
        } else {
            Surface::Wood::Render(visState, speed, vel);
        }
    }
}
