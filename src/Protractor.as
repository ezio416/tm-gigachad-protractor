const uint  GEARDOWN_RPM_THRESH  = 7500;
const uint  GEARUP_RPM_THRESH    = 10000;
const float POINTER_ABSOLUTE_MAX = 13000.0f;
const float POINTER_ABSOLUTE_MIN = 7000.0f;

bool                   badSlide            = false;
CameraMode             camera              = CameraMode::External;
int                    currentRunStartTime = 0;
float                  gearPointerFlip     = 1.0f;
HistoryTrail           historyTrail;
float                  playerFadeOpacity;
RenderMode             renderMode          = RenderMode::Normal;
float                  slipAngle           = 0.0f;
EPlugSurfaceMaterialId surfaceNormalized;
float                  thetaMult;

vec2[] GetLinesToBeRendered(const float ideal, const float good, const float base, const float outer, const bool draw_good) {
    vec2[] ret;

    if (!S_Simplified) {
        ret.InsertLast(vec2(ideal, 0.0f));

        if (S_GoodAccel and draw_good) {
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

float GetSlipSmoothed(const vec3&in left, const vec3&in vel) {
    return IsPreview() ? S_PreviewSlip : CalcVecAngle(left, vel);
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

    const vec3 v_start = ProjectOffset(visState, ProjectAngle(visState, start, theta), offset);
    const vec3 v_end = ProjectOffset(visState, ProjectAngle(visState, start + length, theta), offset);

    if (Camera::IsBehind(v_start) or Camera::IsBehind(v_end)) {
        return;
    }

    nvg::BeginPath();
    nvg::MoveTo(Camera::ToScreenSpace(v_start));
    nvg::LineTo(Camera::ToScreenSpace(v_end));
    nvg::StrokeColor(ApplyOpacityToColor(color, playerFadeOpacity));
    nvg::StrokeWidth(width / (v_start - Camera::GetCurrentPosition()).Length() * 7.0f);
    nvg::LineCap(nvg::LineCapType::Round);
    nvg::Stroke();
    nvg::ClosePath();
}

void RenderPlayerPointer(
    CSceneVehicleVisState@ visState,
    const float pointer_start,
    const float pointer_length,
    const float pointer_width,
    const float theta,
    const vec3&in offset,
    vec4 color
) {
    if (S_History and (renderMode != RenderMode::Ice or S_HistoryIce)) {
        historyTrail.Update(theta, color);
        historyTrail.Render(visState, pointer_start, pointer_length);
    }

    if (S_GearBothSides) {
        gearPointerFlip = 1.0f;
    } else if (Math::Abs(theta) > 0.001f) {
        gearPointerFlip = (theta < 0.0f ? -1.0f : 1.0f);
    }

    RenderAngle(
        visState,
        pointer_start,
        pointer_length,
        pointer_width,
        theta,
        offset,
        ApplyOpacityToColor(
            badSlide and S_ShowBadSlide and !IsPreview() ? S_BaseAccelColor : color,
            playerFadeOpacity
        )
    );

    if (false
        or !S_Gears
        or renderMode == RenderMode::Ice
        or (S_HideGear5 and visState.CurGear == 5)
        or (IsPreview() and S_PreviewGear == 5)
    ) {
        return;
    }

    float rpm, rpm_pos, geardown_pos, color_pos;
    const vec3 offset_apply = vec3(Math::Sin(theta), 0.0f, gearPointerFlip * Math::Cos(theta)) * S_GearPointerOffset;

    for (int i = 1; i >= (S_GearBothSides ? -1 : 1); i -= 2) {
        rpm = Math::Clamp(Surface::Ice::expectedRpm, POINTER_ABSOLUTE_MIN, POINTER_ABSOLUTE_MAX);
        rpm_pos = Math::InvLerp(POINTER_ABSOLUTE_MIN, POINTER_ABSOLUTE_MAX, rpm) * pointer_length;
        geardown_pos = Math::InvLerp(POINTER_ABSOLUTE_MIN, POINTER_ABSOLUTE_MAX, GEARDOWN_RPM_THRESH) * pointer_length;

        if (rpm < GEARDOWN_RPM_THRESH) {
            color_pos = Math::InvLerp(POINTER_ABSOLUTE_MIN, GEARDOWN_RPM_THRESH, rpm);

            RenderAngle(
                visState,
                pointer_start + rpm_pos,
                geardown_pos - rpm_pos,
                pointer_width,
                theta,
                i * offset_apply,
                ApplyOpacityToColor(
                    S_UpshiftDangerColor * (1.0f - color_pos) + S_UpshiftNormalColor * color_pos,
                    playerFadeOpacity
                )
            );

        } else if (rpm < GEARUP_RPM_THRESH) {
            RenderAngle(
                visState,
                pointer_start + geardown_pos,
                rpm_pos,
                pointer_width,
                theta,
                i * offset_apply,
                ApplyOpacityToColor(S_UpshiftNormalColor, playerFadeOpacity)
            );

        } else {
            color_pos = Math::InvLerp(GEARUP_RPM_THRESH, POINTER_ABSOLUTE_MAX, rpm);

            RenderAngle(
                visState,
                pointer_start + geardown_pos,
                rpm_pos,
                pointer_width,
                theta,
                i * offset_apply,
                ApplyOpacityToColor(
                    S_UpshiftDangerColor * color_pos + S_UpshiftNormalColor * (1 - color_pos),
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

    if (GetPlayerStartTime() != currentRunStartTime) {
        currentRunStartTime = GetPlayerStartTime();
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

    float vel;

    if (IsPreview()) {
        vel = S_PreviewSpeed / 3.6f;
    } else {
        vel = visState.WorldVel.Length();
        slipAngle = NormalizeSlipAngle(CalcVecAngle(visState.Left, visState.WorldVel), visState.FrontSpeed);
    }

    if (vel < 10.0f) {
        return;
    }

    const vec3 vec_vel = visState.WorldVel / vel;

    Surface::Ice::HandleUpdate(slipAngle, vel, (IsPreview() ? S_PreviewGear : visState.CurGear));

    if (true
        and !S_RallyOverride
        and visState.FLIcing01 > 0.0f
        and Surface::Ice::Is(surfaceNormalized)
        and VehicleState::GetVehicleType(visState) == VehicleState::VehicleType::CarSport
    ) {
        renderMode = RenderMode::Ice;
        Surface::Ice::Render(visState, vel, vec_vel);
        return;
    }

    if (visState.FrontSpeed < 0.0f or (IsPreview() and S_PreviewSpeed < 0.0f)) {
        renderMode = RenderMode::Backwards;

        if (Surface::Grass::Is(surfaceNormalized)) {
            Surface::Grass::RenderBackwards(visState, vel, vec_vel);
            return;
        }

        if (Surface::Dirt::Is(surfaceNormalized)) {
            Surface::Dirt::RenderBackwards(visState, vel, vec_vel);
            return;
        }

        if (Surface::Plastic::Is(surfaceNormalized)) {
            Surface::Plastic::RenderBackwards(visState, vel, vec_vel);
            return;
        }

        if (Surface::Road::Is(surfaceNormalized)) {
            Surface::Road::RenderBackwards(visState, vel, vec_vel);
            return;
        }
    }

    renderMode = RenderMode::Normal;

    if (Surface::Grass::Is(surfaceNormalized)) {
        Surface::Grass::Render(visState, vel, vec_vel);
        return;
    }

    if (Surface::Dirt::Is(surfaceNormalized)) {
        Surface::Dirt::Render(visState, vel, vec_vel);
        return;
    }

    if (Surface::Plastic::Is(surfaceNormalized)) {
        Surface::Plastic::Render(visState, vel, vec_vel);
        return;
    }

    if (Surface::Road::Is(surfaceNormalized)) {
        Surface::Road::Render(visState, vel, vec_vel);
        return;
    }

    if (Surface::Ice::Is(surfaceNormalized)) {
        switch (VehicleState::GetVehicleType(visState)) {
            case VehicleState::VehicleType::CarRally:
                Surface::Ice::RenderRally(visState, vel, vec_vel);
                break;

            case VehicleState::VehicleType::CarDesert:
                Surface::Ice::RenderDesert(visState, vel, vec_vel);
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
            Surface::Wood::RenderIcy(visState, vel, vec_vel);
        } else {
            Surface::Wood::Render(visState, vel, vec_vel);
        }
    }
}

void RenderRegion(
    CSceneVehicleVisState@ visState,
    const float start,
    const float length,
    float thetaStart,
    float thetaEnd,
    const vec3&in offset,
    vec4 fillColor,
    const float slip,
    const bool renderWarnZone,
    const float appliedOpacity
) {
    const float diffFactor = (thetaEnd - thetaStart > 0.0f ? 1.0f : -1.0f) * S_IceRegionWarningWidth;
    const int flip = IsPreview() or Math::Angle(visState.WorldVel, visState.Left) > HALF_PI ? -1 : 1;
    const float inner_thetaStart = (thetaStart + diffFactor) * flip;
    const float inner_thetaEnd = (thetaEnd - diffFactor) * flip;

    thetaStart *= flip;
    thetaEnd *= flip;

    const vec2 radialRoot = Camera::ToScreenSpace(ProjectAngle(
        visState,
        (start + length) * S_IceRegionRadialInsetFraction,
        flip * -ProcessTheta(slip)
    ));

    fillColor = ApplyOpacityToColor(fillColor, appliedOpacity);
    const vec4 warnColor = ApplyOpacityToColor(S_IceRegionWarningColor, appliedOpacity);

    if (renderWarnZone) {
        _RenderRegion(visState, start, length, inner_thetaStart, inner_thetaEnd, offset, fillColor, radialRoot);
        _RenderRegion(visState, start, length, thetaStart, inner_thetaStart, offset, warnColor, radialRoot);
        _RenderRegion(visState, start, length, inner_thetaEnd, thetaEnd, offset, warnColor, radialRoot);
    } else {
        _RenderRegion(visState, start, length, thetaStart, thetaEnd, offset, fillColor, radialRoot);
    }
}

void _RenderRegion(
    CSceneVehicleVisState@ visState,
    const float start,
    const float length,
    float thetaStart,
    float thetaEnd,
    vec3 offset,
    vec4 fillColor,
    const vec2&in radialRoot
) {
    const float diff = thetaEnd - thetaStart;
    const int flip = (Math::Angle(visState.WorldVel, visState.Left) > HALF_PI or IsPreview()) ? 1 : -1;

    fillColor = ApplyOpacityToColor(fillColor, playerFadeOpacity);

    vec4 fillColorDark = fillColor * S_IceRadialDarkFraction;
    fillColorDark.w *= 0.1f;

    const float angle_per_point = flip * TWO_PI / 50.0f;
    const int points = int(diff / angle_per_point);
    const nvg::Paint gradient = nvg::RadialGradient(radialRoot, S_IceGradientInnerDiameter, S_IceGradientOuterDiameter, fillColor, fillColorDark);

    for (int i = 0; i < points; i++) {
        nvg::BeginPath();
        nvg::MoveTo(Camera::ToScreenSpace(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (i * angle_per_point)), offset)));
        LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + ((i + 1) * angle_per_point)), offset));
        LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + ((i + 1) * angle_per_point)), offset));
        LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + (i * angle_per_point)), offset));
        LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (i * angle_per_point)), offset));
        nvg::FillPaint(gradient);
        nvg::Fill();
        nvg::ClosePath();
    }

    nvg::BeginPath();
    nvg::MoveTo(Camera::ToScreenSpace(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (points * angle_per_point)), offset)));
    LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaEnd), offset));
    LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaEnd), offset));
    LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + (points * angle_per_point)), offset));
    LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (points * angle_per_point)), offset));
    nvg::FillPaint(gradient);
    nvg::Fill();
    nvg::ClosePath();
}
