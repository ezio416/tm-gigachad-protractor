class Protractor {
    vec3 vel;
    float slipAngle = 0.0f;
    int current_run_starttime = 0;
    EPlugSurfaceMaterialId surface_normalized;
    float[] slip_arr(100);
    int slip_pos = 0;
    float theta_mult;
    int is_cam3 = 0;
    bool BAD_SLIDE = false;
    // opacity settings
    float playerFadeOpacity;
    RenderMode RENDER_MODE = RenderMode::NORMAL;
    float gearPointerFlip = 1.0f;
    bool activeWood = false;

    GearStateManager gearStateManager();
    ForwardProjection fowardProjection();
    HistoryTrail historyTrail();

    float get_theta_base(const vec3&in vec) {
        float t = vec.z == 0 ? 0.0f : Math::Atan(vec.x / vec.z);
        if (vec.z < 0.0f) {
            t += Math::PI;
        }
        return t;
    }

    Protractor() { }

    float GetIceLineBrightness(const float slip, const float theta) {
        const float diff = Math::Abs(slip - theta);
        const float ret = Math::InvLerp(ICE_LINE_FADE_RATE, 0.0f, diff);
        return Math::Max(ret, ICE_LINE_MIN_BRIGHTNESS);
    }

    vec2[] GetLinesToBeRendered(const float ideal, const float good, const float base, const float outer, const bool draw_good) {
        vec2[] out_arr;
        if (SIMPLIFIED_VIEW) {
            return out_arr;
        }
        out_arr.InsertLast(vec2(ideal, 0.0f));
        if (DRAW_GOOD && draw_good)
            out_arr.InsertLast(vec2(good, 1.0f));
        if (DRAW_BASE)
            out_arr.InsertLast(vec2(base, 2.0f));
        if (DRAW_OUTER)
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
            pos = Math::InvLerp(outer, outer * FADE_OVERSLIDE_MULT, sideSpeed);
            lcol = 3;
            ucol = 3;
        }

        if (lcol == ucol) {
            return COLOR_0;
        }
        const vec4 c = (GetColor(lcol) * (1.0f - pos)) + (GetColor(ucol) * pos);
        return c;
    }

    float GetSlipSmoothed(const vec3&in left, const vec3&in vel) {
        if (IsPreview()) {
            return PREVIEW_SLIP;
        }

        const float slip = CalcVecAngle(left, vel);
        slip_arr[slip_pos % SLIP_SMOOTHING] = slip;
        slip_pos += 1;

        float ret = 0.0f;
        for (int i = 0; i < SLIP_SMOOTHING; i++) {
            ret += slip_arr[i];
        }
        return ret / SLIP_SMOOTHING;
    }

    vec2 GetStartAndLength() {
        float start = SD_POINTER_S;
        float length = SD_POINTER_L;

        if (is_cam3 > 0) {
            if (is_cam3 == 1) {
                start = CAM3_I_S;
                length = CAM3_I_L;
            } else {
                start = CAM3_E_S;
                length = CAM3_E_L;
            }
        }
        return vec2(start, length);
    }

    void HandleGearPointerFlip(const float theta) {
        if (GEAR_ON_BOTH_SIDES) {
            gearPointerFlip = 1.0f;
            return;
        }
        if (Math::Abs(theta) > THETA_FLIP_THRESH) {
            gearPointerFlip = (theta < 0.0f ? -1.0f : 1.0f);
        }
    }

    void HandleNormalizeSurface(CSceneVehicleVisState@ visState) {
        if (PREVIEW_TARMAC) {
            surface_normalized = EPlugSurfaceMaterialId::Asphalt;
        } else if (PREVIEW_DIRT) {
            surface_normalized = EPlugSurfaceMaterialId::Dirt;
        } else if (PREVIEW_PLASTIC) {
            surface_normalized = EPlugSurfaceMaterialId::Plastic;
        } else if (PREVIEW_GRASS) {
            surface_normalized = EPlugSurfaceMaterialId::Grass;
        } else if (PREVIEW_ICE) {
            surface_normalized = EPlugSurfaceMaterialId::Ice;
        } else if (PREVIEW_WOOD) {
            surface_normalized = EPlugSurfaceMaterialId::Wood;
        } else {
            if (visState.FLGroundContactMaterial != EPlugSurfaceMaterialId::XXX_Null) {
                surface_normalized = visState.FLGroundContactMaterial;
            }
        }
    }

    void HandleRunStart() {
        if (GetPlayerStartTime() == current_run_starttime) {
            return;
        } else {
            current_run_starttime = GetPlayerStartTime();
            playerFadeOpacity = 0.0f;
        }
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
        } else if (v1 > 2.3f && v1 < 2.4f && v2 > 2.7f && v2 < 2.8f) {
            return 2;
        } else {
            return 0;
        }
    }

    void IsPreviewOpacityCheck() {
        if (IsPreview()) {
            playerFadeOpacity = 1.0f;
        }
    }

    void OnSettingsChanged() {
        if (RESET_TO_FRONT) {
            SD_POINTER_S = 3.8f;
            SD_POINTER_L = 8.0f;
            RESET_TO_FRONT = false;
        }

        if (RESET_TO_BACK) {
            SD_POINTER_S = 1.731f;
            SD_POINTER_L = 2.69f;
            RESET_TO_BACK = false;
        }

        if (ICE_RESET_TO_FRONT_CORNER) {
            ICE_RESET_TO_FRONT_CORNER = false;
            ICE_POINTER_X_OFFSET = 1.7f;
            ICE_POINTER_Z_OFFSET = -0.7f;
            ICE_POINTER_ANGLE_OFFSET = -0.6f;
        }
    }

    float ProcessTheta(float theta) {
        if (RENDER_MODE == RenderMode::ICE) {
            if (FLIP_DISPLAY_ICE)
                theta = 2.0f * Math::PI - theta;
            return theta;
        }
        if (SIMPLIFIED_VIEW && RENDER_MODE == RenderMode::NORMAL && is_cam3 == 0) {
            return Math::PI - theta;
        }

        if (RENDER_MODE == RenderMode::BACKWARDS) {
            theta *= -1.0f;
        }

        theta *= theta_mult;
        if (FLIP_DISPLAY ^^ (RENDER_MODE == RenderMode::BACKWARDS))
            theta = Math::PI + theta;

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
        is_cam3 = IsCam3(visState);
        HandleRunStart();
        IsPreviewOpacityCheck();
        SetThetaMult(visState);
        HandleNormalizeSurface(visState);
        fowardProjection.UpdateAndRender(visState);

        float vel;

        if (IsPreview()) {
            vel = PREVIEW_SPEED / 3.6;
        } else {
            vel = visState.WorldVel.Length();
            slipAngle = NormalizeSlipAngle(CalcVecAngle(visState.Left, visState.WorldVel), visState.FrontSpeed);
        }

        const vec3 vec_vel = visState.WorldVel / vel;
        if (vel < 10.0f) {
            return;
        }

        gearStateManager.HandleUpdate(slipAngle, vel,
            (IsPreview() ? PREVIEW_GEAR : visState.CurGear), VehicleState::GetRPM(visState));

        if ((VehicleState::GetVehicleType(visState) == VehicleState::VehicleType::CarSport && !RALLY_CAR_OVERRIDE) && IsIceSurface(surface_normalized) && visState.FLIcing01 > 0.0f) {
            RENDER_MODE = RenderMode::ICE;
            RenderIce(visState, vel, vec_vel);
            return;
        }

        if (visState.FrontSpeed < 0.0f || (IsPreview() && PREVIEW_SPEED < 0.0f)) {
            RENDER_MODE = RenderMode::BACKWARDS;
            if (IsGrassSurface(surface_normalized)) {
                RenderSurface(visState, vel, vec_vel, backwards_min, bw_grass_ideal, {}, bw_grass_zero);
                return;
            }
            if (IsDirtSurface(surface_normalized)) {
                RenderSurface(visState, vel, vec_vel, backwards_min, bw_dirt_ideal, {}, bw_dirt_zero);
                return;
            }
            if (IsPlasticSurface(surface_normalized)) {
                // just using grass ideals for plastic BW for now
                RenderSurface(visState, vel, vec_vel, backwards_min, bw_grass_ideal, {}, bw_grass_zero);
                return;
            }
            if (IsTarmacSurface(surface_normalized)) {
                RenderSurface(visState, vel, vec_vel, backwards_min, bw_tarmac_ideal, {}, bw_tarmac_zero);
                return;
            }
        }

        RENDER_MODE = RenderMode::NORMAL;
        if (IsGrassSurface(surface_normalized)) {
            RenderSurface(visState, vel, vec_vel, other_min, grass_ideal, grass_base, grass_zero);
            return;
        }
        if (IsDirtSurface(surface_normalized)) {
            RenderSurface(visState, vel, vec_vel, other_min, dirt_ideal, dirt_base, dirt_zero);
            return;
        }
        if (IsPlasticSurface(surface_normalized)) {
            RenderSurface(visState, vel, vec_vel, other_min, plastic_ideal, plastic_base, plastic_zero);
            return;
        }
        if (IsTarmacSurface(surface_normalized)) {
            RenderSurface(visState, vel, vec_vel, tarmac_min, tarmac_ideal, tarmac_base, tarmac_zero);
            return;
        }

        if (IsIceSurface(surface_normalized)) {
            if (VehicleState::GetVehicleType(visState) ==  VehicleState::VehicleType::CarRally) {
                RenderSurface(visState, vel, vec_vel, 10, rally_ice_peak, rally_ice_zero, rally_ice_slideout, false);
            }
            if (VehicleState::GetVehicleType(visState) ==  VehicleState::VehicleType::CarDesert) {
                RenderSurface(visState, vel, vec_vel, 10, desert_ice_peak, desert_ice_zero, desert_ice_backpeak, false);
            }
        }
        if (IsWoodSurface(surface_normalized) && (PREVIEW_WET || visState.WetnessValue01 > 0.0f)) {
            activeWood = true;
            if (PREVIEW_ICY || ((visState.FLIcing01 + visState.FRIcing01 + visState.RLIcing01 + visState.RRIcing01) > 0.0f)) {
                RenderSurface(visState, vel, vec_vel, wood_min, wood_wet_ice_p1, wood_wet_ice_valley, wood_wet_ice_p2, false);
            } else {
                RenderSurface(visState, vel, vec_vel, wood_min, wood_p1, wood_valley, wood_p2);
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
        if (SIMPLIFIED_VIEW && RENDER_MODE == RenderMode::NORMAL && is_cam3 == 0) {
            RenderSimplifiedView(visState, start, length, width, theta, offset, color);
            return;
        } else {
            _RenderAngle(visState, start, length, width, theta, offset, color);
        }
    }

    void RenderAngleConditional(
        CSceneVehicleVisState@ visState,
        const float start,
        const float length,
        const float width,
        const float theta,
        const vec3&in offset,
        const vec4&in color,
        const bool conditional
    ) {
        if (conditional)
            RenderAngle(visState, start, length, width, theta, offset, color);
    }

    void renderHistoryTrail(CSceneVehicleVisState@ visState, const float start, const float length, const float width) {
        HistoryTrailObject@ o = historyTrail.GetAtIdx(0);
        float slip = o.slip;
        slip = ProcessTheta(slip);
        float opacity, next_opacity;

        float rel_fade, stroke_width, height_offset, next_rel_fade, next_height_offset, start_theta, end_theta;
        vec3 start_p, end_p;
        vec3 off;

        if (SIMPLIFIED_VIEW && is_cam3 > 0) {
            return;
        }

        off.x += SIMPLIFIED_VIEW_X;
        for (int i = (SIMPLIFIED_VIEW ? -1 : 1); i <= 1; i += 2) {
            off.z = (i * SIMPLIFIED_VIEW_Z);
            opacity = HISTORY_START_OPACITY;
            for (int j = 1; j < HISTORY_POINTS - 2; j++) {
                next_opacity = opacity * (1.0f - (1.0f / HISTORY_POINTS)) ** HISTORY_DECAY_FACTOR;  //- (1 / (HISTORY_POINTS * 10));

                rel_fade = Math::InvLerp(0.0f, HISTORY_START_OPACITY, opacity);
                stroke_width = Math::Lerp(HISTORY_WIDTH_MIN, HISTORY_WIDTH_MAX, rel_fade);
                height_offset = Math::Lerp(HISTORY_START_HEIGHT, HISTORY_END_HEIGHT, rel_fade ** HISTORY_DISTANCE_FACTOR);

                next_rel_fade = Math::InvLerp(0.0f, HISTORY_START_OPACITY, next_opacity);
                next_height_offset = Math::Lerp(HISTORY_START_HEIGHT, HISTORY_END_HEIGHT, next_rel_fade ** HISTORY_DISTANCE_FACTOR);

                start_theta = ProcessTheta(historyTrail.GetAtIdx(j).slip);
                end_theta = ProcessTheta(historyTrail.GetAtIdx(j + 1).slip);

                start_p = ProjectAngle(visState, height_offset + HISTORY_START_OFFSET + start + length, start_theta);
                end_p = ProjectAngle(visState, next_height_offset + HISTORY_START_OFFSET + start + length, end_theta);

                if (SIMPLIFIED_VIEW) {
                    start_p = ProjectOffset(visState, start_p, off);
                    end_p = ProjectOffset(visState, end_p, off);
                }

                if (Camera::IsBehind(start_p) || Camera::IsBehind(end_p)) {
                    continue;
                }

                const vec3 cameraDist = start_p - Camera::GetCurrentPosition();
                float rendered_width = stroke_width / cameraDist.Length();
                rendered_width *= HISTORY_PERSPECTIVE_CONSTANT;  // normalizes width to pixels, approximately, based on vibes

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

        if (FIX_GUIDES_TO_CAR) {
            t = -slip;
        } else {
            t = -HALF_PI;
        }
        if (Math::Angle(vec_vel, visState.Left) > HALF_PI || IsPreview()) {
            t *= -1.0f;
        } else {
            t *= 1.0f;
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
        RenderIceCustomAngle1(visState, vel, vec_vel);
        RenderIceCustomAngle2(visState, vel, vec_vel);

        RenderPlayerPointer(  // player pointer
            visState,
            ICE_PP_S,
            ICE_PP_L,
            FS_PP_W,
            t,
            vec3(),
            color
        );
    }

    void RenderIceAngle(CSceneVehicleVisState@ visState, const float vel, const vec3&in vec_vel, const vec4&in color, const float t) {
        RenderAngle(
            visState,
            ICE_PP_S,
            ICE_PP_L / ICE_PLAYER_FRACTION,
            FS_PP_W,
            t,
            vec3(),
            color
        );
    }

    void RenderIceCustomAngle1(CSceneVehicleVisState@ visState, const float vel, const vec3&in vec_vel) {
        if (!SHOW_ICE_CUSTOM_ANGLE) {
            return;
        }

        const float angle = ICE_CUSTOM_ANGLE * 0.0174533f;
        const float slip = Math::Angle(visState.Dir, vec_vel);
        float t;

        if (FIX_GUIDES_TO_CAR) {
            t = -angle;
        } else {
            t = slip - angle - HALF_PI;
        }

        if (Math::Angle(vec_vel, visState.Left) > HALF_PI || IsPreview()) {
            t *= -1.0f;
        }
        RenderIceAngle(visState, vel, vec_vel, ICE_CUSTOM_ANGLE1_COLOR, t);
    }

    void RenderIceCustomAngle2(CSceneVehicleVisState@ visState, const float vel, const vec3&in vec_vel) {
        if (!SHOW_ICE_CUSTOM_ANGLE2) {
            return;
        }

        const float angle = ICE_CUSTOM_ANGLE2 * 0.0174533f;
        const float slip = Math::Angle(visState.Dir, vec_vel);
        float t;

        if (FIX_GUIDES_TO_CAR) {
            t = -angle;
        } else {
            t = slip - angle - HALF_PI;
        }

        if (Math::Angle(vec_vel, visState.Left) > HALF_PI || IsPreview()) {
            t *= -1.0f;
        }
        RenderIceAngle(visState, vel, vec_vel, ICE_CUSTOM_ANGLE2_COLOR, t);
    }

    void RenderIceGearLines(CSceneVehicleVisState@ visState, const float v, const vec3&in vel, float slip) {
        float[] lines;
        lines.InsertLast(LerpToMidpoint(ice_gearup_1, v));
        lines.InsertLast(LerpToMidpoint(ice_gearup_2, v));
        lines.InsertLast(LerpToMidpoint(ice_gearup_3, v));
        lines.InsertLast(LerpToMidpoint(ice_gearup_4, v));
        float t;

        vec4 color;

        if (ICE_GEAR_LINES_SHOW) {
            if (gearStateManager.expectedTrueRpm > gearStateManager.GEARUP_RPM_THRESH) {
                color = gearStateManager.GetGearupColor();
                for (uint i = 0; i < lines.Length; i++) {
                    if (i == 1 || i == 2) {
                        continue;
                    }
                    if (FIX_GUIDES_TO_CAR) {
                        t = -lines[i];
                    } else {
                        t = slip - lines[i] - HALF_PI;
                    }
                    if (Math::Angle(vel, visState.Left) > HALF_PI || IsPreview()) {
                        t *= -1.0f;
                    }
                    RenderAngle(
                        visState,
                        ICE_PP_S,
                        ICE_PP_L / ICE_PLAYER_FRACTION,
                        FS_PP_W,
                        t,
                        vec3(),
                        IO(color, slip, t)
                    );
                }
            }

            if (gearStateManager.expectedTrueRpm < gearStateManager.GEARDOWN_RPM_THRESH) {
                float[] lines1;
                lines1.InsertLast(LerpToMidpoint(ice_gearup_1, v));
                lines1.InsertLast(LerpToMidpoint(ice_gearup_4, v));
                color = gearStateManager.GetGeardownColor();
                for (uint i = 0; i < lines1.Length; i++) {
                    slip = Math::Angle(visState.Dir, vel);
                    if (FIX_GUIDES_TO_CAR) {
                        t = -lines1[i];
                    } else {
                        t = slip - lines1[i] - HALF_PI;
                    }
                    if (Math::Angle(vel, visState.Left) > HALF_PI || IsPreview()) {
                        t *= -1.0f;
                    }
                    RenderAngle(
                        visState,
                        ICE_PP_S,
                        ICE_PP_L / ICE_PLAYER_FRACTION,
                        FS_PP_W,
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

        if (ICE_REGIONS_RENDER) {
            float appliedOpacity;
            if (relativePos >= 0.5f) {
                appliedOpacity = gearStateManager.GetGearupMult();
                RenderRegion(
                    visState,
                    (ICE_PP_S + ICE_PP_L) * ICE_REGION_START,
                    (ICE_PP_S + ICE_PP_L) * ICE_REGION_END - (ICE_PP_S + ICE_PP_L) * ICE_REGION_START,
                    lines[0],
                    lines[1],
                    vec3(),
                    ApplyOpacityToColor(ICE_REGIONS_GOOD, appliedOpacity),
                    ApplyOpacityToColor(ICE_REGIONS_OUTLINE, appliedOpacity),
                    slip,
                    ICE_REGIONS_THICKNESS,
                    true,
                    appliedOpacity
                );
                RenderRegion(
                    visState,
                    (ICE_PP_S + ICE_PP_L) * ICE_REGION_START,
                    (ICE_PP_S + ICE_PP_L) * ICE_REGION_END - (ICE_PP_S + ICE_PP_L) * ICE_REGION_START,
                    lines[2],
                    lines[3],
                    vec3(),
                    ApplyOpacityToColor(ICE_REGIONS_GOOD, appliedOpacity),
                    ApplyOpacityToColor(ICE_REGIONS_OUTLINE, appliedOpacity),
                    slip,
                    ICE_REGIONS_THICKNESS,
                    true,
                    appliedOpacity
                );
                RenderRegion(
                    visState,
                    (ICE_PP_S + ICE_PP_L) * ICE_REGION_START,
                    (ICE_PP_S + ICE_PP_L) * ICE_REGION_END - (ICE_PP_S + ICE_PP_L) * ICE_REGION_START,
                    lines[1],
                    lines[2],
                    vec3(),
                    ApplyOpacityToColor(ICE_REGIONS_DANGER_WEDGE_COLOR, appliedOpacity),
                    ApplyOpacityToColor(ICE_REGIONS_OUTLINE, appliedOpacity),
                    slip,
                    ICE_REGIONS_THICKNESS,
                    false,
                    appliedOpacity
                );

            } else if (relativePos < 0.5f) {
                appliedOpacity = Math::Min((0.5f - relativePos), 1);
                RenderRegion(
                    visState,
                    (ICE_PP_S + ICE_PP_L) * ICE_REGION_START,
                    (ICE_PP_S + ICE_PP_L) * ICE_REGION_END - (ICE_PP_S + ICE_PP_L) * ICE_REGION_START,
                    lines[0],
                    lines[1],
                    vec3(),
                    ApplyOpacityToColor(ICE_REGIONS_GOOD, appliedOpacity),
                    ApplyOpacityToColor(ICE_REGIONS_OUTLINE, appliedOpacity),
                    slip,
                    ICE_REGIONS_THICKNESS,
                    true,
                    appliedOpacity
                );
            }
        }
    }

    void RenderIceIdealAngle(CSceneVehicleVisState@ visState, const float vel, const vec3&in vec_vel, const float slip) {
        const float angle = gearStateManager.GetIdealAngle(vel);
        float t;

        if (FIX_GUIDES_TO_CAR) {
            t = -angle;
        } else {
            t = slip - angle - HALF_PI;
        }

        if (Math::Angle(vec_vel, visState.Left) > HALF_PI || IsPreview()) {
            t *= -1;
        }
        RenderIceAngle(visState, vel, vec_vel, IO(ICE_IDEAL_ANGLE_COLOR, slip, t), t);
    }

    void RenderPlayerPointer(CSceneVehicleVisState@ visState, const float pointer_start, const float pointer_length, const float pointer_width, const float theta, const vec3&in offset, vec4 color) {
        if (HISTORY_ENABLED &&
        (
            RENDER_MODE != RenderMode::ICE || !HISTORY_HIDE_ON_ICE
        )) {
            historyTrail.Update(theta, color);
            renderHistoryTrail(visState, pointer_start, pointer_length, pointer_width);
        }
        HandleGearPointerFlip(theta);

        if (BAD_SLIDE && SHOW_BAD_SLIDE && !IsPreview()) {
            color = COLOR_50;
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
            !SHOW_GEARS_IN_POINTER ||
            (HIDE_GEAR_POINTER_FIFTH && visState.CurGear == 5) ||
            (IsPreview() && PREVIEW_GEAR == 5) ||
            (RENDER_MODE == RenderMode::ICE && !SHOW_VERBOSE_GEARS_ICE)) {
            return;
        }

        vec3 offset_apply;
        offset_apply.x += Math::Sin(theta) * GEAR_PLAYER_OFFSET;
        offset_apply.z += gearPointerFlip * Math::Cos(theta) * GEAR_PLAYER_OFFSET;

        // make a graph of [absolute min] *** [geardown max] ************* [gearup min] [absolute max]

        for (int i = 1;
            (i >= (GEAR_ON_BOTH_SIDES ? -1 : 1)); i -= 2) {
            const float abs_max = 13000.0f;
            const float abs_min = 7000.0f;
            const float rpm = Math::Clamp(gearStateManager.expectedRpm, abs_min, abs_max);

            const float rpm_pos = Math::InvLerp(abs_min, abs_max, rpm) * pointer_length;
            const float geardown_pos = Math::InvLerp(abs_min, abs_max, gearStateManager.GEARDOWN_RPM_THRESH) * pointer_length;

            if (rpm < gearStateManager.GEARDOWN_RPM_THRESH) {
                const float color_pos = Math::InvLerp(abs_min, gearStateManager.GEARDOWN_RPM_THRESH, rpm);
                const vec4 color1 = DANGER_UPSHIFT * (1.0f - color_pos) + NORMAL_UPSHIFT * color_pos;
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
                    ApplyOpacityToColor(NORMAL_UPSHIFT, playerFadeOpacity)
                );
            } else {
                const float color_pos = Math::InvLerp(gearStateManager.GEARUP_RPM_THRESH, abs_max, rpm);
                const vec4 color1 = DANGER_UPSHIFT * color_pos + NORMAL_UPSHIFT * (1 - color_pos);
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
        CSceneVehicleVisState @ visState,
        const float start,
        const float length,
        float thetaStart,
        float thetaEnd,
        const vec3&in offset,
        vec4 fillColor,
        const vec4&in outlineColor,
        const float slip,
        const float outlineThickness,
        const bool renderWarnZone,
        const float appliedOpacity
    ) {
        // this is to inset [not warning, just to make it look visually good]
        float diff = thetaEnd - thetaStart;
        const int flip = (Math::Angle(visState.WorldVel, visState.Left) > HALF_PI || IsPreview()) ? -1 : 1;
        thetaStart += diff * ICE_REGIONS_EDGE_FRAC;
        thetaEnd -= diff * ICE_REGIONS_EDGE_FRAC;

        diff = thetaEnd - thetaStart;

        float inner_thetaStart = thetaStart + (diff > 0.0f ? 1.0f : -1.0f) * ICE_REGIONS_INSET;
        float inner_thetaEnd = thetaEnd - (diff > 0.0f ? 1.0f : -1.0f) * ICE_REGIONS_INSET;

        thetaStart *= flip;
        thetaEnd *= flip;
        inner_thetaStart *= flip;
        inner_thetaEnd   *= flip;

        const vec2 radialRoot = Camera::ToScreenSpace(ProjectAngle(visState, (start + length) * ICE_REGIONS_RADIAL_INSET_FRAC, -1.0f * flip * ProcessTheta(slip)));
        const vec2 outermostPos = Camera::ToScreenSpace(ProjectAngle(visState, (start + length), ((thetaStart + thetaEnd) / 2.0f)));
        const vec2 innerPos = Camera::ToScreenSpace(ProjectAngle(visState, (start), ((thetaStart + thetaEnd) / 2.0f)));
        vec2 radialParams = vec2((radialRoot - innerPos).Length(), (radialRoot - outermostPos).Length());
        radialParams /= 5.0f;

        fillColor = ApplyOpacityToColor(fillColor, appliedOpacity);
        const vec4 warnColor = ApplyOpacityToColor(ICE_REGIONS_WARNING, appliedOpacity);

        if (renderWarnZone) {
            _RenderRegion(visState, start, length, inner_thetaStart, inner_thetaEnd, offset, fillColor, ICE_REGIONS_DARK_COLOR_FRAC, radialRoot, radialParams, outlineColor, outlineThickness);
            _RenderRegion(visState, start, length, thetaStart, inner_thetaStart, offset, warnColor, ICE_REGIONS_DARK_COLOR_FRAC, radialRoot, radialParams, vec4(), outlineThickness);
            _RenderRegion(visState, start, length, inner_thetaEnd, thetaEnd, offset, warnColor, ICE_REGIONS_DARK_COLOR_FRAC, radialRoot, radialParams, vec4(), outlineThickness);
        } else {
            _RenderRegion(visState, start, length, thetaStart, thetaEnd, offset, fillColor, ICE_REGIONS_DARK_COLOR_FRAC, radialRoot, radialParams, outlineColor, outlineThickness);
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
        start = SIMPLIFIED_START;
        length = SIMPLIFIED_LENGTH;
        o.x += SIMPLIFIED_VIEW_X;
        for (int i = -1; i <= 1; i += 2) {
            o.z = offset.z - (i * SIMPLIFIED_VIEW_Z);
            _RenderAngle(visState, start, length, width, theta, o, color);
        }
    }

    void RenderSurface(CSceneVehicleVisState@ visState, const float speed, const vec3&in vec_vel, const float min_vel, const vec2[]&in ideal_config, const vec2[]&in base_config, const vec2[]&in zero_config) {
        RenderSurface(visState, speed, vec_vel, min_vel, ideal_config, base_config, zero_config, true);
    }

    void RenderSurface(CSceneVehicleVisState@ visState, const float speed, const vec3&in vec_vel, const float min_vel, const vec2[]&in ideal_config, const vec2[]&in base_config, const vec2[]&in zero_config, const bool show_good_ss) {
        const float target_ss = ApproximateSideSpeed(ideal_config, speed);
        const float outer_ss = ApproximateSideSpeed(zero_config, speed);
        const float base_ss = ApproximateSideSpeed(base_config, speed);
        const float good_ss = Math::Lerp(outer_ss, target_ss, GOOD_THRESH);

        const float slip = PreviewSlip(GetSlipSmoothed(visState.Left, vec_vel));
        const float sideSpeed = speed * Math::Sin(PreviewSlip(Math::Angle(visState.Dir, vec_vel)));
        const float abs_sidespeed = Math::Abs(sideSpeed);

        const vec2 startAndLength = GetStartAndLength();
        const vec2[] targets = GetLinesToBeRendered(target_ss, good_ss, base_ss, outer_ss, show_good_ss);

        RenderPlayerPointer(
            visState,
            startAndLength.x,
            startAndLength.y,
            FS_PP_W,
            slip,
            vec3(),
            ApplyOpacityToColor(GetPlayerPointerColor(abs_sidespeed, target_ss, good_ss, base_ss, outer_ss), 1.0f)
        );

        BAD_SLIDE = false;
        int OP_RES = 0;
        if (speed < min_vel) {
            if (SHOW_BAD_SLIDE && GetSlipTotal(visState) > 0.0f) {
                OP_RES = 1;
                BAD_SLIDE = true;
            } else {
                OP_RES = -1;
            }
        } else {
            if (GetSlipTotal(visState) == 0.0f && !(IsWoodSurface(visState.FLGroundContactMaterial) && visState.FLIcing01 > 0.0f && visState.WetnessValue01 > 0.0f)) {
                if (SHOW_BAD_SLIDE) {
                    OP_RES = 1;
                    BAD_SLIDE = true;
                } else {
                    OP_RES = -1;
                }
            } else {
                if (abs_sidespeed > outer_ss * FADE_OVERSLIDE_MULT) {
                    OP_RES = -1;
                } else {
                    OP_RES = 1;
                }
            }
        }

        if (OP_RES > 0) {
            playerFadeOpacity = Math::Min(1.0f, playerFadeOpacity + PLAYER_OPACITY_DERIVATIVE);
        } else {
            playerFadeOpacity = Math::Max(0.0f, playerFadeOpacity - PLAYER_OPACITY_DERIVATIVE);
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
                targetOpacity = Math::Max(Math::InvLerp(lower, upper, abs_sidespeed), MIN_BRIGHTNESS);
                lower = upper;
                RenderAngle(
                    visState,
                    startAndLength.x,
                    startAndLength.y / PLAYER_FRACTION,
                    FS_PP_W,
                    (GetSideSpeedAngle(speed, targets[j].x * i)),
                    vec3(),
                    ApplyOpacityToColor(GetColor(int(targets[j].y)), i == polarity ? targetOpacity : MIN_BRIGHTNESS)
                );
            }
        }
    }

    void SetThetaMult(CSceneVehicleVisState@ visState) {
        float target = GetTargetThetaMultFactor(visState);
        if (target < 0.0f || target == theta_mult) {
            return;
        }
        if (target > theta_mult) {
            theta_mult = Math::Min(target, theta_mult + THETA_MULT_DERIVATIVE);
        } else {
            theta_mult = Math::Max(target, theta_mult - THETA_MULT_DERIVATIVE);
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
        if (is_cam3 > 0 && (!DRAW_CAM3_IN_SIMPLIFIED_VIEW) && SIMPLIFIED_VIEW) {
            return;
        }

        if (RENDER_MODE == RenderMode::ICE) {
            offset.x += ICE_POINTER_X_OFFSET;
            offset.z += (theta < 0.0f ? -1.0f : 1.0f) * ICE_POINTER_Z_OFFSET;
            theta += (theta < 0.0f ? -1.0f : 1.0f) * ICE_POINTER_ANGLE_OFFSET;
        }

        if (SHOW_LINE_BACKGROUND) {
            vec4 c = color * LINE_BACKGROUND_COLOR_FRAC + (1.0f - LINE_BACKGROUND_COLOR_FRAC) * LINE_BACKGROUND_COLOR;
            c.w = color.w;
            __RenderAngle(visState, start, length, width * LINE_BACKGROUND_WIDTH, theta, offset, c);
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
        const vec2&in radialRoot,
        const vec2&in radialParams,
        const vec4&in outlineColor,
        const float outlineThickness
    ) {
        if (RENDER_MODE == RenderMode::ICE) {
            offset.x += ICE_POINTER_X_OFFSET;
            offset.z += (thetaStart < 0.0f ? -1.0f : 1.0f) * ICE_POINTER_Z_OFFSET;
            thetaStart += (thetaStart < 0.0f ? -1.0f : 1.0f) * ICE_POINTER_ANGLE_OFFSET;
            thetaEnd += (thetaEnd < 0.0f ? -1.0f : 1.0f) * ICE_POINTER_ANGLE_OFFSET;
        }

        const float diff = thetaEnd - thetaStart;
        const int flip = (Math::Angle(visState.WorldVel, visState.Left) > HALF_PI || IsPreview()) ? 1 : -1;

        fillColor = ApplyOpacityToColor(fillColor, playerFadeOpacity);

        vec4 fillColorDark = fillColor;
        fillColorDark *= fillDarknessCoef;
        fillColorDark.w *= 0.1f;

        // We need to draw a shaded region by drawing a closed path outlining
        // the "region" inbetwixt the lines of interest, then filling it.

        const float angle_per_point = (flip * Math::PI * 2.0f) / ICE_REGIONS_RESOLUTION;
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
            nvg::FillPaint(nvg::RadialGradient(radialRoot, ICE_REGIONS_GRADIENT_INNER_DIAMETER, ICE_REGIONS_GRADIENT_OUTER_DIAMETER, fillColor, fillColorDark));
            nvg::Fill();
            nvg::ClosePath();
        }

        nvg::BeginPath();
        nvg::MoveTo(Camera::ToScreenSpace(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (points * angle_per_point)), offset)));
        _LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaEnd), offset));
        _LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaEnd), offset));
        _LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + (points * angle_per_point)), offset));
        _LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (points * angle_per_point)), offset));
        nvg::FillPaint(nvg::RadialGradient(radialRoot, ICE_REGIONS_GRADIENT_INNER_DIAMETER, ICE_REGIONS_GRADIENT_OUTER_DIAMETER, fillColor, fillColorDark));
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

        if (SIMPLIFIED_VIEW && RENDER_MODE == RenderMode::NORMAL && is_cam3 == 0) {
            color = ApplyOpacityToColor(color, SIMPLIFIED_OPACITY_MULT);
            width = SIMPLIFIED_LINE_THICKNESS_OVERRIDE;
        }

        for (int i = 0; i < (is_cam3 > 0 ? 1 : NUM_LAYERS); i++) {
            vec3 o = offset;
            const float y_offset = LAYER_HEIGHT * i;
            o.y += y_offset;

            const vec3 v_start = ProjectOffset(visState, ProjectAngle(visState, start, theta), o);
            const vec3 v_end = ProjectOffset(visState, ProjectAngle(visState, start + length, theta), o);

            if (Camera::IsBehind(v_start) || Camera::IsBehind(v_end)) {
                return;
            }
            const vec3 cameraDist = v_start - Camera::GetCurrentPosition();
            float rendered_width = width / cameraDist.Length();
            rendered_width *= PERSPECTIVE_CONSTANT; // normalizes width to pixels, approximately, based on vibes
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
