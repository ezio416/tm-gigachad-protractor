class Protractor {
    bool                   activeWood          = false;
    bool                   badSlide            = false;
    int                    cam3                = 0;
    int                    currentRunStartTime = 0;
    ForwardProjection      forwardProjection;
    float                  gearPointerFlip     = 1.0f;
    GearStateManager       gearStateManager;
    HistoryTrail           historyTrail;
    float                  playerFadeOpacity;
    RenderMode             renderMode           = RenderMode::NORMAL;
    float[]                slipArr(100);
    int                    slipPos              = 0;
    float                  slipAngle            = 0.0f;
    EPlugSurfaceMaterialId surfaceNormalized;
    float                  thetaMult;
    vec3                   vel;

    float GetIceLineBrightness(const float slip, const float theta) {
        const float diff = Math::Abs(slip - theta);
        const float ret = Math::InvLerp(S_IceLineFadeRate, 0.0f, diff);
        return Math::Max(ret, S_IceBrightnessMin);
    }

    vec2[] GetLinesToBeRendered(const float ideal, const float good, const float base, const float outer, const bool draw_good) {
        vec2[] out_arr;
        if (S_Simplified) {
            return out_arr;
        }
        out_arr.InsertLast(vec2(ideal, 0.0f));
        if (S_GoodAccel && draw_good)
            out_arr.InsertLast(vec2(good, 1.0f));
        if (S_BaseAccel)
            out_arr.InsertLast(vec2(base, 2.0f));
        if (S_ZeroAccel)
            out_arr.InsertLast(vec2(outer, 3.0f));
        return out_arr;
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
        const vec4 c = (GetColor(lcol) * (1.0f - pos)) + (GetColor(ucol) * pos);
        return c;
    }

    float GetSlipSmoothed(const vec3&in left, const vec3&in vel) {
        if (IsPreview()) {
            return S_PreviewSlip;
        }

        const float slip = CalcVecAngle(left, vel);
        slipArr[slipPos % S_SlipSmoothing] = slip;
        slipPos += 1;

        float ret = 0.0f;
        for (int i = 0; i < S_SlipSmoothing; i++) {
            ret += slipArr[i];
        }
        return ret / S_SlipSmoothing;
    }

    vec2 GetStartAndLength() {
        float start = S_SDPointerStart;
        float length = S_SDPointerLength;

        if (cam3 > 0) {
            if (cam3 == 1) {
                start = S_Cam3InternalStart;
                length = S_Cam3InternalLength;
            } else {
                start = S_Cam3ExternalStart;
                length = S_Cam3ExternalLength;
            }
        }
        return vec2(start, length);
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
        } else {
            if (visState.FLGroundContactMaterial != EPlugSurfaceMaterialId::XXX_Null) {
                surfaceNormalized = visState.FLGroundContactMaterial;
            }
        }
    }

    void HandleRunStart() {
        if (GetPlayerStartTime() == currentRunStartTime) {
            return;
        }
        currentRunStartTime = GetPlayerStartTime();
        playerFadeOpacity = 0.0f;
    }

    vec4 IO(const vec4&in color, const float slip, const float theta) {
        vec4 c = color;
        c.w *= GetIceLineBrightness(slip, theta);
        return c;
    }

    /**
     * Return codes:
     * 0: Not cam 3.
     * 1: Cam 3 in-car.
     * 2: Cam three full.
     */
    int IsCam3(CSceneVehicleVisState@ visState) {
        const vec3 pos = visState.Position;
        const vec3 cameraPos = Camera::GetCurrentPosition();
        const vec3 pos_offset_forward = visState.Position + visState.Dir;

        const float v1 = (cameraPos - pos_offset_forward).LengthSquared();
        const float v2 = (cameraPos - pos).LengthSquared();

        if (v1 > 1.9f && v1 < 2.0f && v2 > 0.85f && v2 < 0.9f) {
            return 1;
        }
        if (v1 > 2.3f && v1 < 2.4f && v2 > 2.7f && v2 < 2.8f) {
            return 2;
        }
        return 0;
    }

    void IsPreviewOpacityCheck() {
        if (IsPreview()) {
            playerFadeOpacity = 1.0f;
        }
    }

    void OnSettingsChanged() {
        if (S_ResetFront) {
            S_SDPointerStart = 3.8f;
            S_SDPointerLength = 8.0f;
            S_ResetFront = false;
        }

        if (S_ResetBack) {
            S_SDPointerStart = 1.731f;
            S_SDPointerLength = 2.69f;
            S_ResetBack = false;
        }

        if (S_IcePointerFrontCorner) {
            S_IcePointerFrontCorner = false;
            S_IcePointerOffsetX = 1.7f;
            S_IcePointerOffsetZ = -0.7f;
            S_IcePointerOffsetAngle = -0.6f;
        }
    }

    float ProcessTheta(float theta) {
        if (renderMode == RenderMode::ICE) {
            if (S_FlipDisplayIce) {
                theta = 2.0f * Math::PI - theta;
            }
            return theta;
        }
        if (S_Simplified && renderMode == RenderMode::NORMAL && cam3 == 0) {
            return Math::PI - theta;
        }

        if (renderMode == RenderMode::BACKWARDS) {
            theta *= -1.0f;
        }

        theta *= thetaMult;
        if (S_FlipDisplay ^^ (renderMode == RenderMode::BACKWARDS)) {
            theta = Math::PI + theta;
        }

        return theta;
    }

    vec3 ProjectAngle(CSceneVehicleVisState@ visState, const float r, const float theta) {
        vec3 p = visState.Position;
        p += visState.Dir * Math::Cos(theta) * r;
        p += visState.Left * Math::Sin(theta) * r;
        return p;
    }

    vec3 ProjectOffset(CSceneVehicleVisState@ visState, const vec3&in in_pos, const vec3&in offset) {
        return in_pos +
            visState.Dir * offset.x +
            visState.Up * offset.y +
            visState.Left * offset.z;
    }

    void Render() {
        CSceneVehicleVisState@ visState = GetVisState();
        if (visState is null) {
            return;
        }
        cam3 = IsCam3(visState);
        HandleRunStart();
        IsPreviewOpacityCheck();
        SetThetaMult(visState);
        HandleNormalizeSurface(visState);
        forwardProjection.UpdateAndRender(visState);

        float vel;

        if (IsPreview()) {
            vel = S_PreviewSpeed / 3.6;
        } else {
            vel = visState.WorldVel.Length();
            slipAngle = NormalizeSlipAngle(CalcVecAngle(visState.Left, visState.WorldVel), visState.FrontSpeed);
        }

        const vec3 vec_vel = visState.WorldVel / vel;
        if (vel < 10.0f) {
            return;
        }

        gearStateManager.HandleUpdate(slipAngle, vel, (IsPreview() ? S_PreviewGear : visState.CurGear));

        if ((VehicleState::GetVehicleType(visState) == VehicleState::VehicleType::CarSport && !S_RallyOverride) && Surface::Ice::Is(surfaceNormalized) && visState.FLIcing01 > 0.0f) {
            renderMode = RenderMode::ICE;
            RenderIce(visState, vel, vec_vel);
            return;
        }

        if (visState.FrontSpeed < 0.0f || (IsPreview() && S_PreviewSpeed < 0.0f)) {
            renderMode = RenderMode::BACKWARDS;

            if (Surface::Grass::Is(surfaceNormalized)) {
                RenderSurface(visState, vel, vec_vel, Surface::Other::BW_MIN, Surface::Grass::BW_IDEAL, {}, Surface::Grass::BW_ZERO);
                return;
            }

            if (Surface::Dirt::Is(surfaceNormalized)) {
                RenderSurface(visState, vel, vec_vel, Surface::Other::BW_MIN, Surface::Dirt::BW_IDEAL, {}, Surface::Dirt::BW_ZERO);
                return;
            }

            if (Surface::Plastic::Is(surfaceNormalized)) {
                // just using grass ideals for plastic BW for now
                RenderSurface(visState, vel, vec_vel, Surface::Other::BW_MIN, Surface::Grass::BW_IDEAL, {}, Surface::Grass::BW_ZERO);
                return;
            }

            if (Surface::Road::Is(surfaceNormalized)) {
                RenderSurface(visState, vel, vec_vel, Surface::Other::BW_MIN, Surface::Road::BW_IDEAL, {}, Surface::Road::BW_ZERO);
                return;
            }
        }

        renderMode = RenderMode::NORMAL;

        if (Surface::Grass::Is(surfaceNormalized)) {
            RenderSurface(visState, vel, vec_vel, Surface::Other::MIN, Surface::Grass::IDEAL, Surface::Grass::BASE, Surface::Grass::ZERO);
            return;
        }

        if (Surface::Dirt::Is(surfaceNormalized)) {
            RenderSurface(visState, vel, vec_vel, Surface::Other::MIN, Surface::Dirt::IDEAL, Surface::Dirt::BASE, Surface::Dirt::ZERO);
            return;
        }

        if (Surface::Plastic::Is(surfaceNormalized)) {
            RenderSurface(visState, vel, vec_vel, Surface::Other::MIN, Surface::Plastic::IDEAL, Surface::Plastic::BASE, Surface::Plastic::ZERO);
            return;
        }

        if (Surface::Road::Is(surfaceNormalized)) {
            RenderSurface(visState, vel, vec_vel, Surface::Road::MIN, Surface::Road::IDEAL, Surface::Road::BASE, Surface::Road::ZERO);
            return;
        }

        if (Surface::Ice::Is(surfaceNormalized)) {
            if (VehicleState::GetVehicleType(visState) == VehicleState::VehicleType::CarRally) {
                RenderSurface(visState, vel, vec_vel, 10.0f, Surface::Ice::RALLY_PEAK, Surface::Ice::RALLY_ZERO, Surface::Ice::RALLY_SLIDEOUT, false);
            }
            if (VehicleState::GetVehicleType(visState) == VehicleState::VehicleType::CarDesert) {
                RenderSurface(visState, vel, vec_vel, 10.0f, Surface::Ice::DESERT_PEAK, Surface::Ice::DESERT_ZERO, Surface::Ice::DESERT_BACK_PEAK, false);
            }
        }

        if (Surface::Wood::Is(surfaceNormalized) && (S_PreviewWet || visState.WetnessValue01 > 0.0f)) {
            activeWood = true;
            if (S_PreviewIcy || ((visState.FLIcing01 + visState.FRIcing01 + visState.RLIcing01 + visState.RRIcing01) > 0.0f)) {
                RenderSurface(visState, vel, vec_vel, Surface::Wood::MIN, Surface::Wood::WET_ICE_P1, Surface::Wood::WET_ICE_VALLEY, Surface::Wood::WET_ICE_P2, false);
            } else {
                RenderSurface(visState, vel, vec_vel, Surface::Wood::MIN, Surface::Wood::P1, Surface::Wood::VALLEY, Surface::Wood::P2);
            }
            return;
        }
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
        if (S_Simplified && renderMode == RenderMode::NORMAL && cam3 == 0) {
            RenderSimplifiedView(visState, start, length, width, theta, offset, color);
        } else {
            _RenderAngle(visState, start, length, width, theta, offset, color);
        }
    }

    void RenderHistoryTrail(CSceneVehicleVisState@ visState, const float start, const float length) {
        HistoryTrailObject@ o = historyTrail.GetAtIdx(0);
        float slip = o.slip;
        slip = ProcessTheta(slip);
        float opacity, next_opacity;

        float rel_fade, stroke_width, height_offset, next_rel_fade, next_height_offset, start_theta, end_theta;
        vec3 start_p, end_p;
        vec3 off;

        if (S_Simplified && cam3 > 0) {
            return;
        }

        off.x += S_SimplifiedOffsetX;
        for (int i = (S_Simplified ? -1 : 1); i <= 1; i += 2) {
            off.z = (i * S_SimplifiedOffsetZ);
            opacity = S_HistoryStartOpacity;
            for (int j = 1; j < S_HistoryPoints - 2; j++) {
                next_opacity = opacity * (1.0f - (1.0f / S_HistoryPoints)) ** S_HistoryDecayFactor;  //- (1 / (S_HistoryPoints * 10));

                rel_fade = Math::InvLerp(0.0f, S_HistoryStartOpacity, opacity);
                stroke_width = Math::Lerp(S_HistoryWidthMin, S_HistoryWidthMax, rel_fade);
                height_offset = Math::Lerp(S_HistoryStartHeight, S_HistoryEndHeight, rel_fade ** S_HistoryDistanceFactor);

                next_rel_fade = Math::InvLerp(0.0f, S_HistoryStartOpacity, next_opacity);
                next_height_offset = Math::Lerp(S_HistoryStartHeight, S_HistoryEndHeight, next_rel_fade ** S_HistoryDistanceFactor);

                start_theta = ProcessTheta(historyTrail.GetAtIdx(j).slip);
                end_theta = ProcessTheta(historyTrail.GetAtIdx(j + 1).slip);

                start_p = ProjectAngle(visState, height_offset + S_HistoryStartOffset + start + length, start_theta);
                end_p = ProjectAngle(visState, next_height_offset + S_HistoryStartOffset + start + length, end_theta);

                if (S_Simplified) {
                    start_p = ProjectOffset(visState, start_p, off);
                    end_p = ProjectOffset(visState, end_p, off);
                }

                if (Camera::IsBehind(start_p) || Camera::IsBehind(end_p)) {
                    continue;
                }

                const vec3 cameraDist = start_p - Camera::GetCurrentPosition();
                float rendered_width = stroke_width / cameraDist.Length();
                rendered_width *= S_HistoryPerspectiveConstant;  // normalizes width to pixels, approximately, based on vibes

                nvg::BeginPath();
                nvg::MoveTo(Camera::ToScreenSpace(start_p));
                nvg::LineTo(Camera::ToScreenSpace(end_p));
                nvg::StrokeColor(ApplyOpacityToColor(historyTrail.GetAtIdx(j).color, playerFadeOpacity * opacity));
                nvg::StrokeWidth(rendered_width);
                nvg::LineCap(nvg::LineCapType::Round);
                nvg::Stroke();
                nvg::ClosePath();
                opacity = next_opacity;
            }
        }
    }

    void RenderIce(CSceneVehicleVisState@ visState, const float vel, const vec3&in vec_vel) {
        const float slip = PreviewSlip(CalcAngle(vec_vel, visState.Dir));

        const float absSlip = Math::Abs(slip);

        if (absSlip < HALF_PI / 3.0f) {
            playerFadeOpacity = 0.0f;
        } else if (absSlip < HALF_PI / 2.0f) {
            playerFadeOpacity = Math::InvLerp(HALF_PI / 3.0f, HALF_PI / 2.0f, absSlip);
        } else if (absSlip > HALF_PI / 2.0f) {
            playerFadeOpacity = 1.0f;
        }

        float t;

        if (S_FixIceGuides) {
            t = -slip;
        } else {
            t = -HALF_PI;
        }
        if (Math::Angle(vec_vel, visState.Left) > HALF_PI || IsPreview()) {
            t *= -1.0f;
        }

        vec4 color;

        if (gearStateManager.expectedTrueRpm > gearStateManager.GEARUP_RPM_THRESH) {
            color = gearStateManager.GetGearupColor();
        } else if (gearStateManager.expectedTrueRpm < gearStateManager.GEARDOWN_RPM_THRESH) {
            color = gearStateManager.GetGeardownColor();
        } else {
            color = vec4(1.0f);
        }

        color.w = 1.0f;

        RenderIceGearLines(visState, vel, vec_vel, slip);
        RenderIceIdealAngle(visState, vel, vec_vel, slip);
        RenderIceCustomAngle1(visState, vec_vel);
        RenderIceCustomAngle2(visState, vec_vel);

        RenderPlayerPointer(
            visState,
            S_IcePlayerPointerStart,
            S_IcePlayerPointerLength,
            S_FullspeedPlayerPointerWidth,
            t,
            vec3(),
            color
        );
    }

    void RenderIceAngle(CSceneVehicleVisState@ visState, const vec4&in color, const float t) {
        RenderAngle(
            visState,
            S_IcePlayerPointerStart,
            S_IcePlayerPointerLength / S_IcePlayerFraction,
            S_FullspeedPlayerPointerWidth,
            t,
            vec3(),
            color
        );
    }

    void RenderIceCustomAngle1(CSceneVehicleVisState@ visState, const vec3&in vec_vel) {
        if (!S_ShowCustomIceAngle) {
            return;
        }

        const float angle = S_CustomIceAngle * 0.0174533f;
        const float slip = Math::Angle(visState.Dir, vec_vel);
        float t;

        if (S_FixIceGuides) {
            t = -angle;
        } else {
            t = slip - angle - HALF_PI;
        }

        if (Math::Angle(vec_vel, visState.Left) > HALF_PI || IsPreview()) {
            t *= -1.0f;
        }
        RenderIceAngle(visState, S_CustomIceAngleColor, t);
    }

    void RenderIceCustomAngle2(CSceneVehicleVisState@ visState, const vec3&in vec_vel) {
        if (!S_ShowCustomIceAngle2) {
            return;
        }

        const float angle = S_CustomIceAngle2 * 0.0174533f;
        const float slip = Math::Angle(visState.Dir, vec_vel);
        float t;

        if (S_FixIceGuides) {
            t = -angle;
        } else {
            t = slip - angle - HALF_PI;
        }

        if (Math::Angle(vec_vel, visState.Left) > HALF_PI || IsPreview()) {
            t *= -1.0f;
        }
        RenderIceAngle(visState, S_CustomIceAngle2Color, t);
    }

    void RenderIceGearLines(CSceneVehicleVisState@ visState, const float v, const vec3&in vel, float slip) {
        float[] lines;
        lines.InsertLast(LerpToMidpoint(Surface::Ice::GEARUP_1, v));
        lines.InsertLast(LerpToMidpoint(Surface::Ice::GEARUP_2, v));
        lines.InsertLast(LerpToMidpoint(Surface::Ice::GEARUP_3, v));
        lines.InsertLast(LerpToMidpoint(Surface::Ice::GEARUP_4, v));
        float t;

        vec4 color;

        if (S_IceGearLines) {
            if (gearStateManager.expectedTrueRpm > gearStateManager.GEARUP_RPM_THRESH) {
                color = gearStateManager.GetGearupColor();
                for (uint i = 0; i < lines.Length; i++) {
                    if (i == 1 || i == 2) {
                        continue;
                    }
                    if (S_FixIceGuides) {
                        t = -lines[i];
                    } else {
                        t = slip - lines[i] - HALF_PI;
                    }
                    if (Math::Angle(vel, visState.Left) > HALF_PI || IsPreview()) {
                        t *= -1.0f;
                    }
                    RenderAngle(
                        visState,
                        S_IcePlayerPointerStart,
                        S_IcePlayerPointerLength / S_IcePlayerFraction,
                        S_FullspeedPlayerPointerWidth,
                        t,
                        vec3(),
                        IO(color, slip, t)
                    );
                }
            }

            if (gearStateManager.expectedTrueRpm < gearStateManager.GEARDOWN_RPM_THRESH) {
                float[] lines1;
                lines1.InsertLast(LerpToMidpoint(Surface::Ice::GEARUP_1, v));
                lines1.InsertLast(LerpToMidpoint(Surface::Ice::GEARUP_4, v));
                color = gearStateManager.GetGeardownColor();
                for (uint i = 0; i < lines1.Length; i++) {
                    slip = Math::Angle(visState.Dir, vel);
                    if (S_FixIceGuides) {
                        t = -lines1[i];
                    } else {
                        t = slip - lines1[i] - HALF_PI;
                    }
                    if (Math::Angle(vel, visState.Left) > HALF_PI || IsPreview()) {
                        t *= -1.0f;
                    }
                    RenderAngle(
                        visState,
                        S_IcePlayerPointerStart,
                        S_IcePlayerPointerLength / S_IcePlayerFraction,
                        S_FullspeedPlayerPointerWidth,
                        t,
                        vec3(),
                        color
                    );
                }
            }
        }

        // handling shaded 'region' rendering:

        const float relativePos = Math::InvLerp(gearStateManager.GEARDOWN_RPM_THRESH, gearStateManager.GEARUP_RPM_THRESH, int(gearStateManager.expectedTrueRpm));

        // we show regions all the time, but fade in and out of them depending on where we are
        // at 0.5, show no regions.
        // above 0.5, show upper regions with opacity derived from relativePos in domain [0.5, 1.5]
        // below 0.5, show lower regions with opacity derived from relativePos in domain [-0.5, 0.5]

        if (S_IceRegionSafe) {
            float appliedOpacity;
            if (relativePos >= 0.5f) {
                appliedOpacity = gearStateManager.GetGearupMult();
                RenderRegion(
                    visState,
                    (S_IcePlayerPointerStart + S_IcePlayerPointerLength) * S_IceRegionStart,
                    (S_IcePlayerPointerStart + S_IcePlayerPointerLength) * S_IceRegionEnd - (S_IcePlayerPointerStart + S_IcePlayerPointerLength) * S_IceRegionStart,
                    lines[0],
                    lines[1],
                    vec3(),
                    ApplyOpacityToColor(S_IceRegionGoodColor, appliedOpacity),
                    slip,
                    true,
                    appliedOpacity
                );
                RenderRegion(
                    visState,
                    (S_IcePlayerPointerStart + S_IcePlayerPointerLength) * S_IceRegionStart,
                    (S_IcePlayerPointerStart + S_IcePlayerPointerLength) * S_IceRegionEnd - (S_IcePlayerPointerStart + S_IcePlayerPointerLength) * S_IceRegionStart,
                    lines[2],
                    lines[3],
                    vec3(),
                    ApplyOpacityToColor(S_IceRegionGoodColor, appliedOpacity),
                    slip,
                    true,
                    appliedOpacity
                );
                RenderRegion(
                    visState,
                    (S_IcePlayerPointerStart + S_IcePlayerPointerLength) * S_IceRegionStart,
                    (S_IcePlayerPointerStart + S_IcePlayerPointerLength) * S_IceRegionEnd - (S_IcePlayerPointerStart + S_IcePlayerPointerLength) * S_IceRegionStart,
                    lines[1],
                    lines[2],
                    vec3(),
                    ApplyOpacityToColor(S_IceDangerWedgeColor, appliedOpacity),
                    slip,
                    false,
                    appliedOpacity
                );

            } else {
                appliedOpacity = Math::Min((0.5f - relativePos), 1);
                RenderRegion(
                    visState,
                    (S_IcePlayerPointerStart + S_IcePlayerPointerLength) * S_IceRegionStart,
                    (S_IcePlayerPointerStart + S_IcePlayerPointerLength) * S_IceRegionEnd - (S_IcePlayerPointerStart + S_IcePlayerPointerLength) * S_IceRegionStart,
                    lines[0],
                    lines[1],
                    vec3(),
                    ApplyOpacityToColor(S_IceRegionGoodColor, appliedOpacity),
                    slip,
                    true,
                    appliedOpacity
                );
            }
        }
    }

    void RenderIceIdealAngle(CSceneVehicleVisState@ visState, const float vel, const vec3&in vec_vel, const float slip) {
        const float angle = gearStateManager.GetIdealAngle(vel);
        float t;

        if (S_FixIceGuides) {
            t = -angle;
        } else {
            t = slip - angle - HALF_PI;
        }

        if (Math::Angle(vec_vel, visState.Left) > HALF_PI || IsPreview()) {
            t *= -1;
        }
        RenderIceAngle(visState, IO(S_IceIdealAngleColor, slip, t), t);
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
        if (S_History && (renderMode != RenderMode::ICE || !S_HistoryHideIce)) {
            historyTrail.Update(theta, color);
            RenderHistoryTrail(visState, pointer_start, pointer_length);
        }
        HandleGearPointerFlip(theta);

        if (badSlide && S_ShowBadSlide && !IsPreview()) {
            color = S_Color50;
        }
        RenderAngle( // player pointer
            visState,
            pointer_start,
            pointer_length,
            pointer_width,
            theta,
            offset,
            ApplyOpacityToColor(color, playerFadeOpacity)
        );
        if (
            !S_PointerGears ||
            (S_HideGear5 && visState.CurGear == 5) ||
            (IsPreview() && S_PreviewGear == 5) ||
            (renderMode == RenderMode::ICE && !S_VerboseIceGears)) {
            return;
        }

        vec3 offset_apply;
        offset_apply.x += Math::Sin(theta) * S_GearPointerOffset;
        offset_apply.z += gearPointerFlip * Math::Cos(theta) * S_GearPointerOffset;

        // make a graph of [absolute min] *** [geardown max] ************* [gearup min] [absolute max]

        for (int i = 1;
            (i >= (S_GearBothSides ? -1 : 1)); i -= 2) {
            const float abs_max = 13000.0f;
            const float abs_min = 7000.0f;
            const float rpm = Math::Clamp(gearStateManager.expectedRpm, abs_min, abs_max);

            const float rpm_pos = Math::InvLerp(abs_min, abs_max, rpm) * pointer_length;
            const float geardown_pos = Math::InvLerp(abs_min, abs_max, gearStateManager.GEARDOWN_RPM_THRESH) * pointer_length;

            if (rpm < gearStateManager.GEARDOWN_RPM_THRESH) {
                const float color_pos = Math::InvLerp(abs_min, gearStateManager.GEARDOWN_RPM_THRESH, rpm);
                const vec4 color1 = S_ColorUpshiftDanger * (1.0f - color_pos) + S_ColorUpshiftNormal * color_pos;
                RenderAngle( // player pointer
                    visState,
                    pointer_start + rpm_pos,
                    geardown_pos - rpm_pos,
                    pointer_width,
                    theta,
                    i * offset_apply,
                    ApplyOpacityToColor(color1, playerFadeOpacity)
                );
            } else if (rpm < gearStateManager.GEARUP_RPM_THRESH) {
                RenderAngle( // player pointer
                    visState,
                    pointer_start + geardown_pos,
                    rpm_pos,
                    pointer_width,
                    theta,
                    i * offset_apply,
                    ApplyOpacityToColor(S_ColorUpshiftNormal, playerFadeOpacity)
                );
            } else {
                const float color_pos = Math::InvLerp(gearStateManager.GEARUP_RPM_THRESH, abs_max, rpm);
                const vec4 color1 = S_ColorUpshiftDanger * color_pos + S_ColorUpshiftNormal * (1 - color_pos);
                RenderAngle( // player pointer
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

    /**
     * Wrapper function for renderRegion.
     * This lets us split it out to render subregions - i.e., the "safe" zone and warning zones
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
        const int flip = (Math::Angle(visState.WorldVel, visState.Left) > HALF_PI || IsPreview()) ? -1 : 1;
        thetaStart += diff * S_IceRegionInsetFraction;
        thetaEnd -= diff * S_IceRegionInsetFraction;

        diff = thetaEnd - thetaStart;

        float inner_thetaStart = thetaStart + (diff > 0.0f ? 1.0f : -1.0f) * S_IceRegionInset;
        float inner_thetaEnd = thetaEnd - (diff > 0.0f ? 1.0f : -1.0f) * S_IceRegionInset;

        thetaStart *= flip;
        thetaEnd *= flip;
        inner_thetaStart *= flip;
        inner_thetaEnd *= flip;

        const vec2 radialRoot = Camera::ToScreenSpace(ProjectAngle(visState, (start + length) * S_IceRegionRadialInsetFraction, -1.0f * flip * ProcessTheta(slip)));
        const vec2 outermostPos = Camera::ToScreenSpace(ProjectAngle(visState, (start + length), ((thetaStart + thetaEnd) / 2.0f)));
        const vec2 innerPos = Camera::ToScreenSpace(ProjectAngle(visState, (start), ((thetaStart + thetaEnd) / 2.0f)));
        vec2 radialParams = vec2((radialRoot - innerPos).Length(), (radialRoot - outermostPos).Length());
        radialParams /= 5.0f;

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

    void RenderSurface(
        CSceneVehicleVisState@ visState,
        const float speed,
        const vec3&in vec_vel,
        const float min_vel,
        const vec2[]&in ideal_config,
        const vec2[]&in base_config,
        const vec2[]&in zero_config
    ) {
        RenderSurface(visState, speed, vec_vel, min_vel, ideal_config, base_config, zero_config, true);
    }

    void RenderSurface(
        CSceneVehicleVisState@ visState,
        const float speed,
        const vec3&in vec_vel,
        const float min_vel,
        const vec2[]&in ideal_config,
        const vec2[]&in base_config,
        const vec2[]&in zero_config,
        const bool show_good_ss
    ) {
        const float target_ss = ApproximateSideSpeed(ideal_config, speed);
        const float outer_ss = ApproximateSideSpeed(zero_config, speed);
        const float base_ss = ApproximateSideSpeed(base_config, speed);
        const float good_ss = Math::Lerp(outer_ss, target_ss, S_GoodSDThreshold);

        const float slip = PreviewSlip(GetSlipSmoothed(visState.Left, vec_vel));
        const float sideSpeed = speed * Math::Sin(PreviewSlip(Math::Angle(visState.Dir, vec_vel)));
        const float abs_sidespeed = Math::Abs(sideSpeed);

        const vec2 startAndLength = GetStartAndLength();
        const vec2[] targets = GetLinesToBeRendered(target_ss, good_ss, base_ss, outer_ss, show_good_ss);

        RenderPlayerPointer(
            visState,
            startAndLength.x,
            startAndLength.y,
            S_FullspeedPlayerPointerWidth,
            slip,
            vec3(),
            ApplyOpacityToColor(GetPlayerPointerColor(abs_sidespeed, target_ss, good_ss, base_ss, outer_ss), 1.0f)
        );

        badSlide = false;
        int OP_RES = 0;
        if (speed < min_vel) {
            if (S_ShowBadSlide && GetSlipTotal(visState) > 0.0f) {
                OP_RES = 1;
                badSlide = true;
            } else {
                OP_RES = -1;
            }
        } else {
            if (GetSlipTotal(visState) == 0.0f && !(Surface::Wood::Is(visState.FLGroundContactMaterial) && visState.FLIcing01 > 0.0f && visState.WetnessValue01 > 0.0f)) {
                if (S_ShowBadSlide) {
                    OP_RES = 1;
                    badSlide = true;
                } else {
                    OP_RES = -1;
                }
            } else {
                if (abs_sidespeed > outer_ss * S_OverslideFadeMult) {
                    OP_RES = -1;
                } else {
                    OP_RES = 1;
                }
            }
        }

        if (OP_RES > 0) {
            playerFadeOpacity = Math::Min(1.0f, playerFadeOpacity + S_PlayerOpacityDerivative);
        } else {
            playerFadeOpacity = Math::Max(0.0f, playerFadeOpacity - S_PlayerOpacityDerivative);
        }

        if (playerFadeOpacity == 0.0f) {
            return;
        }

        float lower, upper, targetOpacity;
        const int polarity = slip < 0.0f ? -1 : 1;
        for (int i = -1; i <= 1; i += 2) {
            lower = 0.0f;
            for (uint j = 0; j < targets.Length; j++) {
                upper = targets[j].x;
                targetOpacity = Math::Max(Math::InvLerp(lower, upper, abs_sidespeed), S_BrightnessMin);
                lower = upper;
                RenderAngle(
                    visState,
                    startAndLength.x,
                    startAndLength.y / S_PlayerFraction,
                    S_FullspeedPlayerPointerWidth,
                    (GetSideSpeedAngle(speed, targets[j].x * i)),
                    vec3(),
                    ApplyOpacityToColor(GetColor(int(targets[j].y)), i == polarity ? targetOpacity : S_BrightnessMin)
                );
            }
        }
    }

    void SetThetaMult(CSceneVehicleVisState@ visState) {
        float target = GetTargetThetaMultFactor(visState);
        if (target < 0.0f || target == thetaMult) {
            return;
        }
        if (target > thetaMult) {
            thetaMult = Math::Min(target, thetaMult + S_ThetaMultDerivative);
        } else {
            thetaMult = Math::Max(target, thetaMult - S_ThetaMultDerivative);
        }
    }

    void _LineTo(const vec3&in p) {
        if (!Camera::IsBehind(p)) {
            nvg::LineTo(Camera::ToScreenSpace(p));
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
        if (cam3 > 0 && !S_SimplifiedCam3 && S_Simplified) {
            return;
        }

        if (renderMode == RenderMode::ICE) {
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
        if (renderMode == RenderMode::ICE) {
            offset.x += S_IcePointerOffsetX;
            offset.z += (thetaStart < 0.0f ? -1.0f : 1.0f) * S_IcePointerOffsetZ;
            thetaStart += (thetaStart < 0.0f ? -1.0f : 1.0f) * S_IcePointerOffsetAngle;
            thetaEnd += (thetaEnd < 0.0f ? -1.0f : 1.0f) * S_IcePointerOffsetAngle;
        }

        const float diff = thetaEnd - thetaStart;
        const int flip = (Math::Angle(visState.WorldVel, visState.Left) > HALF_PI || IsPreview()) ? 1 : -1;

        fillColor = ApplyOpacityToColor(fillColor, playerFadeOpacity);

        vec4 fillColorDark = fillColor;
        fillColorDark *= fillDarknessCoef;
        fillColorDark.w *= 0.1f;

        // We need to draw a shaded region by drawing a closed path outlining
        // the "region" inbetwixt the lines of interest, then filling it.

        const float angle_per_point = (flip * Math::PI * 2.0f) / S_IceRegionResolution;
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
            _LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + ((i + 1) * angle_per_point)), offset));
            _LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + ((i + 1) * angle_per_point)), offset));
            _LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + (i * angle_per_point)), offset));
            _LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (i * angle_per_point)), offset));
            nvg::FillPaint(nvg::RadialGradient(radialRoot, S_IceGradientInnerDiameter, S_IceGradientOuterDiameter, fillColor, fillColorDark));
            nvg::Fill();
            nvg::ClosePath();
        }

        nvg::BeginPath();
        nvg::MoveTo(Camera::ToScreenSpace(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (points * angle_per_point)), offset)));
        _LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaEnd), offset));
        _LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaEnd), offset));
        _LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + (points * angle_per_point)), offset));
        _LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (points * angle_per_point)), offset));
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

        if (S_Simplified && renderMode == RenderMode::NORMAL && cam3 == 0) {
            color = ApplyOpacityToColor(color, S_SimplifiedOpacity);
            width = S_SimplifiedLineThickness;
        }

        for (int i = 0; i < (cam3 > 0 ? 1 : S_LayerCount); i++) {
            vec3 o = offset;
            const float y_offset = S_LayerHeight * i;
            o.y += y_offset;

            const vec3 v_start = ProjectOffset(visState, ProjectAngle(visState, start, theta), o);
            const vec3 v_end = ProjectOffset(visState, ProjectAngle(visState, start + length, theta), o);

            if (Camera::IsBehind(v_start) || Camera::IsBehind(v_end)) {
                return;
            }
            const vec3 cameraDist = v_start - Camera::GetCurrentPosition();
            float rendered_width = width / cameraDist.Length();
            rendered_width *= S_PerspectiveConstant; // normalizes width to pixels, approximately, based on vibes
            nvg::BeginPath();
            nvg::MoveTo(Camera::ToScreenSpace(v_start));
            nvg::LineTo(Camera::ToScreenSpace(v_end));
            nvg::StrokeColor(ApplyOpacityToColor(color, playerFadeOpacity));
            nvg::StrokeWidth(rendered_width);
            nvg::LineCap(nvg::LineCapType::Round);
            nvg::Stroke();
            nvg::ClosePath();
        }
    }
}
