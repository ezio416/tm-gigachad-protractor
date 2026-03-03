bool                   badSlide            = false;
CameraMode             camera              = CameraMode::External;
int                    currentRunStartTime = 0;
float                  gearPointerFlip     = 1.0f;
GearStateManager       gearStateManager;
HistoryTrail           historyTrail;
float                  playerFadeOpacity;
RenderMode             renderMode          = RenderMode::Normal;
float[]                slipArr(100);
int                    slipPos             = 0;
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
        pos = Math::InvLerp(outer, outer * S_OverslideFadeMult, sideSpeed);
        lcol = 3;
        ucol = 3;
    }

    if (lcol == ucol) {
        return S_Color0;
    }

    return GetColor(lcol) * (1.0f - pos) + GetColor(ucol) * pos;
}

float GetSlipSmoothed(const vec3&in left, const vec3&in vel) {
    if (IsPreview()) {
        return S_PreviewSlip;
    }

    slipArr[slipPos % S_SlipSmoothing] = CalcVecAngle(left, vel);
    slipPos += 1;

    float ret = 0.0f;
    for (int i = 0; i < S_SlipSmoothing; i++) {
        ret += slipArr[i];
    }

    return ret / S_SlipSmoothing;
}

void HandleGearPointerFlip(const float theta) {
    if (S_GearBothSides) {
        gearPointerFlip = 1.0f;
        return;
    }

    if (Math::Abs(theta) > S_ThetaFlipThreshold) {
        gearPointerFlip = (theta < 0.0f ? -1.0f : 1.0f);
    }
}

void HandleNormalizeSurface(CSceneVehicleVisState@ visState) {
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
}

void HandleRunStart() {
    if (GetPlayerStartTime() == currentRunStartTime) {
        return;
    }

    currentRunStartTime = GetPlayerStartTime();
    playerFadeOpacity = 0.0f;
}

float ProcessTheta(float theta) {
    if (renderMode == RenderMode::Ice) {
        if (S_FlipDisplayIce) {
            theta = TWO_PI - theta;
        }

        return theta;
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
    if (S_FlipDisplay xor (renderMode == RenderMode::Backwards)) {
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
        RenderSimplifiedView(visState, start, length, width, theta, offset, color);
    } else {
        _RenderAngle(visState, start, length, width, theta, offset, color);
    }
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
    if (S_History and (renderMode != RenderMode::Ice or !S_HistoryHideIce)) {
        historyTrail.Update(theta, color);
        historyTrail.Render(visState, pointer_start, pointer_length);
    }

    HandleGearPointerFlip(theta);

    if (badSlide and S_ShowBadSlide and !IsPreview()) {
        color = S_Color50;
    }

    RenderAngle(
        visState,
        pointer_start,
        pointer_length,
        pointer_width,
        theta,
        offset,
        ApplyOpacityToColor(color, playerFadeOpacity)
    );

    if (false
        or !S_PointerGears
        or (S_HideGear5 and visState.CurGear == 5)
        or (IsPreview() and S_PreviewGear == 5)
        or (renderMode == RenderMode::Ice and !S_VerboseIceGears)
    ) {
        return;
    }

    vec3 offset_apply;
    offset_apply.x += Math::Sin(theta) * S_GearPointerOffset;
    offset_apply.z += gearPointerFlip * Math::Cos(theta) * S_GearPointerOffset;

    // make a graph of [absolute min] *** [geardown max] ************* [gearup min] [absolute max]

    const float abs_max = 13000.0f;
    const float abs_min = 7000.0f;

    for (int i = 1; i >= (S_GearBothSides ? -1 : 1); i -= 2) {
        const float rpm = Math::Clamp(gearStateManager.expectedRpm, abs_min, abs_max);
        const float rpm_pos = Math::InvLerp(abs_min, abs_max, rpm) * pointer_length;
        const float geardown_pos = Math::InvLerp(abs_min, abs_max, GEARDOWN_RPM_THRESH) * pointer_length;

        if (rpm < GEARDOWN_RPM_THRESH) {
            const float color_pos = Math::InvLerp(abs_min, GEARDOWN_RPM_THRESH, rpm);
            const vec4 color1 = S_ColorUpshiftDanger * (1.0f - color_pos) + S_ColorUpshiftNormal * color_pos;

            RenderAngle(
                visState,
                pointer_start + rpm_pos,
                geardown_pos - rpm_pos,
                pointer_width,
                theta,
                i * offset_apply,
                ApplyOpacityToColor(color1, playerFadeOpacity)
            );

        } else if (rpm < GEARUP_RPM_THRESH) {
            RenderAngle(
                visState,
                pointer_start + geardown_pos,
                rpm_pos,
                pointer_width,
                theta,
                i * offset_apply,
                ApplyOpacityToColor(S_ColorUpshiftNormal, playerFadeOpacity)
            );

        } else {
            const float color_pos = Math::InvLerp(GEARUP_RPM_THRESH, abs_max, rpm);
            const vec4 color1 = S_ColorUpshiftDanger * color_pos + S_ColorUpshiftNormal * (1 - color_pos);

            RenderAngle(
                visState,
                pointer_start + geardown_pos,
                rpm_pos,
                pointer_width,
                theta,
                i * offset_apply,
                ApplyOpacityToColor(color1, playerFadeOpacity)
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
    HandleRunStart();
    PreviewOpacityCheck();
    SetThetaMult(visState);
    HandleNormalizeSurface(visState);
    UpdateAndRenderProjection(visState);

    float vel;

    if (IsPreview()) {
        vel = S_PreviewSpeed / 3.6f;
    } else {
        vel = visState.WorldVel.Length();
        slipAngle = NormalizeSlipAngle(CalcVecAngle(visState.Left, visState.WorldVel), visState.FrontSpeed);
    }

    const vec3 vec_vel = visState.WorldVel / vel;
    if (vel < 10.0f) {
        return;
    }

    gearStateManager.HandleUpdate(slipAngle, vel, (IsPreview() ? S_PreviewGear : visState.CurGear));

    if (true
        and VehicleState::GetVehicleType(visState) == VehicleState::VehicleType::CarSport
        and !S_RallyOverride
        and Surface::Ice::Is(surfaceNormalized)
        and visState.FLIcing01 > 0.0f
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

/*
Wrapper function for renderRegion.
This lets us split it out to render subregions - i.e., the "safe" zone and warning zones
*/
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
    // this is to inset [not warning, just to make it look visually good]
    float diff = thetaEnd - thetaStart;
    const int flip = (Math::Angle(visState.WorldVel, visState.Left) > HALF_PI or IsPreview()) ? -1 : 1;
    thetaStart += diff * S_IceRegionInsetFraction;
    thetaEnd -= diff * S_IceRegionInsetFraction;

    diff = thetaEnd - thetaStart;

    float inner_thetaStart = thetaStart + (diff > 0.0f ? 1.0f : -1.0f) * S_IceRegionInset;
    float inner_thetaEnd = thetaEnd - (diff > 0.0f ? 1.0f : -1.0f) * S_IceRegionInset;

    thetaStart *= flip;
    thetaEnd *= flip;
    inner_thetaStart *= flip;
    inner_thetaEnd *= flip;

    const vec2 radialRoot = Camera::ToScreenSpace(ProjectAngle(visState, (start + length) * S_IceRegionRadialInsetFraction, flip * -ProcessTheta(slip)));

    fillColor = ApplyOpacityToColor(fillColor, appliedOpacity);
    const vec4 warnColor = ApplyOpacityToColor(S_IceRegionWarning, appliedOpacity);

    if (renderWarnZone) {
        _RenderRegion(visState, start, length, inner_thetaStart, inner_thetaEnd, offset, fillColor, S_IceRadialDarkFraction, radialRoot);
        _RenderRegion(visState, start, length, thetaStart, inner_thetaStart, offset, warnColor, S_IceRadialDarkFraction, radialRoot);
        _RenderRegion(visState, start, length, inner_thetaEnd, thetaEnd, offset, warnColor, S_IceRadialDarkFraction, radialRoot);
    } else {
        _RenderRegion(visState, start, length, thetaStart, thetaEnd, offset, fillColor, S_IceRadialDarkFraction, radialRoot);
    }
}

void RenderSimplifiedView(
    CSceneVehicleVisState@ visState,
    float start,
    float length,
    const float width,
    const float theta,
    const vec3&in offset,
    const vec4&in color
) {
    vec3 o = offset;
    start = S_SimplifiedStart;
    length = S_SimplifiedLength;
    o.x += S_SimplifiedOffsetX;
    for (int i = -1; i <= 1; i += 2) {
        o.z = offset.z - (i * S_SimplifiedOffsetZ);
        _RenderAngle(visState, start, length, width, theta, o, color);
    }
}

void SetThetaMult(CSceneVehicleVisState@ visState) {
    const float target = GetTargetThetaMultFactor(visState);
    if (target < 0.0f or target == thetaMult) {
        return;
    }

    if (target > thetaMult) {
        thetaMult = Math::Min(target, thetaMult + S_ThetaMultDerivative);
    } else {
        thetaMult = Math::Max(target, thetaMult - S_ThetaMultDerivative);
    }
}

void _RenderAngle(
    CSceneVehicleVisState@ visState,
    const float start,
    const float length,
    const float width,
    float theta,
    vec3 offset,
    const vec4&in color
) {
    if (true
        and camera != CameraMode::External
        and !S_SimplifiedCam3
        and S_Simplified
    ) {
        return;
    }

    if (renderMode == RenderMode::Ice) {
        offset.x += S_IcePointerOffsetX;
        offset.z += (theta < 0.0f ? -1.0f : 1.0f) * S_IcePointerOffsetZ;
        theta += (theta < 0.0f ? -1.0f : 1.0f) * S_IcePointerOffsetAngle;
    }

    if (S_LineBackground) {
        vec4 c = color * S_LineBackgroundColorFraction + (1.0f - S_LineBackgroundColorFraction) * S_ColorLineBackground;
        c.w = color.w;
        __RenderAngle(visState, start, length, width * S_LineBackgroundWidth, theta, offset, c);
    }
    __RenderAngle(visState, start, length, width, theta, offset, color);
}

void _RenderRegion(
    CSceneVehicleVisState@ visState,
    const float start,
    const float length,
    float thetaStart,
    float thetaEnd,
    vec3 offset,
    vec4 fillColor,
    const float fillDarknessCoef,
    const vec2&in radialRoot
) {
    if (renderMode == RenderMode::Ice) {
        offset.x += S_IcePointerOffsetX;
        offset.z += (thetaStart < 0.0f ? -1.0f : 1.0f) * S_IcePointerOffsetZ;
        thetaStart += (thetaStart < 0.0f ? -1.0f : 1.0f) * S_IcePointerOffsetAngle;
        thetaEnd += (thetaEnd < 0.0f ? -1.0f : 1.0f) * S_IcePointerOffsetAngle;
    }

    const float diff = thetaEnd - thetaStart;
    const int flip = (Math::Angle(visState.WorldVel, visState.Left) > HALF_PI or IsPreview()) ? 1 : -1;

    fillColor = ApplyOpacityToColor(fillColor, playerFadeOpacity);

    vec4 fillColorDark = fillColor;
    fillColorDark *= fillDarknessCoef;
    fillColorDark.w *= 0.1f;

    // We need to draw a shaded region by drawing a closed path outlining
    // the "region" inbetwixt the lines of interest, then filling it.

    const float angle_per_point = flip * TWO_PI / S_IceRegionResolution;
    const int points = int(diff / angle_per_point);

    // print("__renderRegion");
    // print("start:\t" + tostring(start));
    // print("length:\t" + tostring(length));
    // print("diff:\t" + tostring(diff));
    // print("thetaStart:\t" + tostring(thetaStart));
    // print("thetaEnd:\t" + tostring(thetaEnd));
    // print("offset:\t" + tostring(offset));
    // print("fillColor:\t" + tostring(fillColor));
    // print("points:\t" + tostring(points));
    // print("angle_per_point:\t" + tostring(angle_per_point));
    // print("radialRoot:\t" + tostring(radialRoot));
    // print("position:\t" + tostring(visState.Position));

    for (int i = 0; i < points; i++) {
        nvg::BeginPath();
        nvg::MoveTo(Camera::ToScreenSpace(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (i * angle_per_point)), offset)));
        LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + ((i + 1) * angle_per_point)), offset));
        LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + ((i + 1) * angle_per_point)), offset));
        LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + (i * angle_per_point)), offset));
        LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (i * angle_per_point)), offset));
        nvg::FillPaint(nvg::RadialGradient(radialRoot, S_IceGradientInnerDiameter, S_IceGradientOuterDiameter, fillColor, fillColorDark));
        nvg::Fill();
        nvg::ClosePath();
    }

    nvg::BeginPath();
    nvg::MoveTo(Camera::ToScreenSpace(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (points * angle_per_point)), offset)));
    LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaEnd), offset));
    LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaEnd), offset));
    LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + (points * angle_per_point)), offset));
    LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (points * angle_per_point)), offset));
    nvg::FillPaint(nvg::RadialGradient(radialRoot, S_IceGradientInnerDiameter, S_IceGradientOuterDiameter, fillColor, fillColorDark));
    nvg::Fill();
    nvg::ClosePath();

    // nvg::BeginPath();
    // nvg::Circle(radialRoot, 8);
    // nvg::StrokeColor(vec4(1));
    // nvg::Stroke();
    // nvg::ClosePath();
}

void __RenderAngle(
    CSceneVehicleVisState@ visState,
    const float start,
    const float length,
    float width,
    float theta,
    const vec3&in offset,
    vec4 color
) {
    theta = ProcessTheta(theta);

    if (true
        and S_Simplified
        and renderMode == RenderMode::Normal
        and camera == CameraMode::External
    ) {
        color = ApplyOpacityToColor(color, S_SimplifiedOpacity);
        width = S_SimplifiedLineThickness;
    }

    vec3 o, v_start, v_end;

    for (int i = 0; i < (camera != CameraMode::External ? 1 : S_LayerCount); i++) {
        o = offset;
        o.y += S_LayerHeight * i;

        v_start = ProjectOffset(visState, ProjectAngle(visState, start, theta), o);
        v_end = ProjectOffset(visState, ProjectAngle(visState, start + length, theta), o);

        if (Camera::IsBehind(v_start) or Camera::IsBehind(v_end)) {
            return;
        }

        nvg::BeginPath();
        nvg::MoveTo(Camera::ToScreenSpace(v_start));
        nvg::LineTo(Camera::ToScreenSpace(v_end));
        nvg::StrokeColor(ApplyOpacityToColor(color, playerFadeOpacity));
        nvg::StrokeWidth(width / (v_start - Camera::GetCurrentPosition()).Length() * S_PerspectiveConstant);
        nvg::LineCap(nvg::LineCapType::Round);
        nvg::Stroke();
        nvg::ClosePath();
    }
}
