class Protractor {
    vec3 vel;
    float slipAngle = 0;
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
    float gearPointerFlip = 1;
    bool activeWood = false;

    GearStateManager gearStateManager();
    ForwardProjection fowardProjection();
    HistoryTrail historyTrail();

    float get_theta_base(vec3 vec) {
        float t = vec.z == 0 ? 0 : Math::Atan(vec.x / vec.z);
        if (vec.z < 0) {
            t += 2 * HALF_PI;
        }
        return t;
    }

    Protractor() { }

    float GetIceLineBrightness(float slip, float theta) {
        float diff = Math::Abs(slip - theta);
        float ret = Math::InvLerp(ICE_LINE_FADE_RATE, 0, diff);
        return Math::Max(ret, ICE_LINE_MIN_BRIGHTNESS);
    }

    vec2[] GetLinesToBeRendered(float ideal, float good, float base, float outer, bool draw_good) {
        vec2[] out_arr;
        if (SIMPLIFIED_VIEW) {
            return out_arr;
        }
        out_arr.InsertLast(vec2(ideal, 0));
        if (DRAW_GOOD && draw_good)
            out_arr.InsertLast(vec2(good, 1));
        if (DRAW_BASE)
            out_arr.InsertLast(vec2(base, 2));
        if (DRAW_OUTER)
            out_arr.InsertLast(vec2(outer, 3));
        return out_arr;
    }

    vec4 GetPlayerPointerColor(float sideSpeed, float target, float good, float base, float outer) {
        float pos;
        int lcol, ucol;
        if (sideSpeed < target) {
            pos = Math::InvLerp(0, target, sideSpeed) ** 4;
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
        vec4 c = (GetColor(lcol) * (1 - pos)) + (GetColor(ucol) * pos);
        return c;
    }

    float GetSlipSmoothed(vec3 left, vec3 vel) {
        if (IsPreview()) {
            return PREVIEW_SLIP;
        }

        float slip = CalcVecAngle(left, vel);
        slip_arr[slip_pos % SLIP_SMOOTHING] = slip;
        slip_pos += 1;

        float ret = 0;
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

    void HandleGearPointerFlip(float theta) {
        if (GEAR_ON_BOTH_SIDES) {
            gearPointerFlip = 1;
            return;
        }
        if (Math::Abs(theta) > THETA_FLIP_THRESH) {
            gearPointerFlip = (theta < 0 ? -1 : 1);
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
            playerFadeOpacity = 0;
        }
    }

    vec4 IO(vec4 color, float slip, float theta) {
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
        vec3 pos = visState.Position;
        vec3 cameraPos = Camera::GetCurrentPosition();
        vec3 pos_offset_forward = visState.Position + visState.Dir;

        float v1 = (cameraPos - pos_offset_forward).LengthSquared();
        float v2 = (cameraPos - pos).LengthSquared();

        if (v1 > 1.9 && v1 < 2 && v2 > 0.85 && v2 < 0.9) {
            return 1;
        } else if (v1 > 2.3 && v1 < 2.4 && v2 > 2.7 && v2 < 2.8) {
            return 2;
        } else {
            return 0;
        }
    }

    void IsPreviewOpacityCheck() {
        if (IsPreview()) {
            playerFadeOpacity = 1;
        }
    }

    void OnSettingsChanged() {
        if (RESET_TO_FRONT) {
            SD_POINTER_S = 3.8;
            SD_POINTER_L = 8;
            RESET_TO_FRONT = false;
        }

        if (RESET_TO_BACK) {
            SD_POINTER_S = 1.731;
            SD_POINTER_L = 2.69;
            RESET_TO_BACK = false;
        }

        if (ICE_RESET_TO_FRONT_CORNER) {
            ICE_RESET_TO_FRONT_CORNER = false;
            ICE_POINTER_X_OFFSET = 1.7;
            ICE_POINTER_Z_OFFSET = -.7;
            ICE_POINTER_ANGLE_OFFSET = -.6;
        }
    }

    float ProcessTheta(float theta) {
        if (RENDER_MODE == RenderMode::ICE) {
            if (FLIP_DISPLAY_ICE)
                theta = 4 * HALF_PI - theta;
            return theta;
        }
        if (SIMPLIFIED_VIEW && RENDER_MODE == RenderMode::NORMAL && is_cam3 == 0) {
            return 2 * HALF_PI - (theta);
        }

        if (RENDER_MODE == RenderMode::BACKWARDS) {
            theta *= -1;
        }

        theta *= theta_mult;
        if (FLIP_DISPLAY ^^ (RENDER_MODE == RenderMode::BACKWARDS))
            theta = 2 * HALF_PI + theta;

        return theta;
    }

    vec3 ProjectAngle(CSceneVehicleVisState @ visState, float r, float theta) {
        vec3 p = visState.Position;
        p += visState.Dir * Math::Cos(theta) * r;
        p += visState.Left * Math::Sin(theta) * r;
        return p;
    }

    vec3 ProjectOffset(CSceneVehicleVisState @ visState, vec3 in_pos, vec3 offset) {
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

        vec3 vec_vel = visState.WorldVel / vel;
        if (vel < 10) {
            return;
        }

        gearStateManager.HandleUpdate(slipAngle, vel,
            (IsPreview() ? PREVIEW_GEAR : visState.CurGear), VehicleState::GetRPM(visState));

        if ((VehicleState::GetVehicleType(visState) == VehicleState::VehicleType::CarSport && !RALLY_CAR_OVERRIDE) && IsIceSurface(surface_normalized) && visState.FLIcing01 > 0) {
            RENDER_MODE = RenderMode::ICE;
            RenderIce(visState, vel, vec_vel);
            return;
        }

        if (visState.FrontSpeed < 0 || (IsPreview() && PREVIEW_SPEED < 0)) {
            RENDER_MODE = RenderMode::BACKWARDS;
            if (IsGrassSurface(surface_normalized)) {
                RenderSurface(visState, vel, vec_vel, backwards_min, bw_grass_ideal, array<vec2>(), bw_grass_zero);
                return;
            }
            if (IsDirtSurface(surface_normalized)) {
                RenderSurface(visState, vel, vec_vel, backwards_min, bw_dirt_ideal, array<vec2>(), bw_dirt_zero);
                return;
            }
            if (IsPlasticSurface(surface_normalized)) {
                // just using grass ideals for plastic BW for now
                RenderSurface(visState, vel, vec_vel, backwards_min, bw_grass_ideal, array<vec2>(), bw_grass_zero);
                return;
            }
            if (IsTarmacSurface(surface_normalized)) {
                RenderSurface(visState, vel, vec_vel, backwards_min, bw_tarmac_ideal, array<vec2>(), bw_tarmac_zero);
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
        if (IsWoodSurface(surface_normalized) && (PREVIEW_WET || visState.WetnessValue01 > 0)) {
            activeWood = true;
            if (PREVIEW_ICY || ((visState.FLIcing01 + visState.FRIcing01 + visState.RLIcing01 + visState.RRIcing01) > 0)) {
                RenderSurface(visState, vel, vec_vel, wood_min, wood_wet_ice_p1, wood_wet_ice_valley, wood_wet_ice_p2, false);
            } else {
                RenderSurface(visState, vel, vec_vel, wood_min, wood_p1, wood_valley, wood_p2);
            }
            return;
        }
    }

    void RenderAngle(
        CSceneVehicleVisState@ visState,
        float start,
        float length,
        float width,
        float theta,
        vec3 offset,
        vec4 color
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
        float start,
        float length,
        float width,
        float theta,
        vec3 offset,
        vec4 color,
        bool conditional
    ) {
        if (conditional)
            RenderAngle(visState, start, length, width, theta, offset, color);
    }

    void renderHistoryTrail(CSceneVehicleVisState@ visState, float start, float length, float width) {
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
                next_opacity = opacity * (1.0 - (1.0 / HISTORY_POINTS)) ** HISTORY_DECAY_FACTOR;  //- (1 / (HISTORY_POINTS * 10));

                rel_fade = Math::InvLerp(0, HISTORY_START_OPACITY, opacity);
                stroke_width = Math::Lerp(HISTORY_WIDTH_MIN, HISTORY_WIDTH_MAX, rel_fade);
                height_offset = Math::Lerp(HISTORY_START_HEIGHT, HISTORY_END_HEIGHT, rel_fade ** HISTORY_DISTANCE_FACTOR);

                next_rel_fade = Math::InvLerp(0, HISTORY_START_OPACITY, next_opacity);
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

                vec3 cameraDist = start_p - Camera::GetCurrentPosition();
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

    void RenderIce(CSceneVehicleVisState@ visState, float vel, vec3 vec_vel) {
        float slip = PreviewSlip(CalcAngle(vec_vel, visState.Dir));

        float absSlip = Math::Abs(slip);

        if (absSlip < HALF_PI / 3) {
            playerFadeOpacity = 0;
        }
        else if (absSlip < HALF_PI / 2) {
            playerFadeOpacity = Math::InvLerp(HALF_PI / 3, HALF_PI / 2, absSlip);
        }
        else if (absSlip > HALF_PI / 2) {
            playerFadeOpacity = 1;
        }

        float t;

        if (FIX_GUIDES_TO_CAR) {
            t = -slip;
        } else {
            t = -HALF_PI;
        }
        if (Math::Angle(vec_vel, visState.Left) > HALF_PI || IsPreview()) {
            t *= -1;
        } else {
            t *= 1;
        }

        vec4 color;

        if (gearStateManager.expectedTrueRpm > gearStateManager.GEARUP_RPM_THRESH) {
            color = gearStateManager.GetGearupColor();
        } else if (gearStateManager.expectedTrueRpm < gearStateManager.GEARDOWN_RPM_THRESH) {
            color = gearStateManager.GetGeardownColor();
        } else {
            color = vec4(1, 1, 1, 1);
        }

        color.w = 1;

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
            vec3(0, 0, 0),
            color
        );
    }

    void RenderIceAngle(CSceneVehicleVisState@ visState, float vel, vec3 vec_vel, vec4 color, float t) {
        RenderAngle(
            visState,
            ICE_PP_S,
            ICE_PP_L / ICE_PLAYER_FRACTION,
            FS_PP_W,
            t,
            vec3(0, 0, 0),
            color
        );
    }

    void RenderIceCustomAngle1(CSceneVehicleVisState@ visState, float vel, vec3 vec_vel) {
        if (!SHOW_ICE_CUSTOM_ANGLE) {
            return;
        }

        float angle = ICE_CUSTOM_ANGLE * 0.0174533;
        float slip = Math::Angle(visState.Dir, vec_vel);
        float t;

        if (FIX_GUIDES_TO_CAR) {
            t = -angle;
        } else {
            t = slip - angle - HALF_PI;
        }

        if (Math::Angle(vec_vel, visState.Left) > HALF_PI || IsPreview()) {
            t *= -1;
        }
        RenderIceAngle(visState, vel, vec_vel, ICE_CUSTOM_ANGLE1_COLOR, t);
    }

    void RenderIceCustomAngle2(CSceneVehicleVisState@ visState, float vel, vec3 vec_vel) {
        if (!SHOW_ICE_CUSTOM_ANGLE2) {
            return;
        }

        float angle = ICE_CUSTOM_ANGLE2 * 0.0174533;
        float slip = Math::Angle(visState.Dir, vec_vel);
        float t;

        if (FIX_GUIDES_TO_CAR) {
            t = -angle;
        } else {
            t = slip - angle - HALF_PI;
        }

        if (Math::Angle(vec_vel, visState.Left) > HALF_PI || IsPreview()) {
            t *= -1;
        }
        RenderIceAngle(visState, vel, vec_vel, ICE_CUSTOM_ANGLE2_COLOR, t);
    }

    void RenderIceGearLines(CSceneVehicleVisState@ visState, float v, vec3 vel, float slip) {
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
                        t *= -1;
                    }
                    RenderAngle(
                        visState,
                        ICE_PP_S,
                        ICE_PP_L / ICE_PLAYER_FRACTION,
                        FS_PP_W,
                        t,
                        vec3(0, 0, 0),
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
                        t *= -1;
                    }
                    RenderAngle(
                        visState,
                        ICE_PP_S,
                        ICE_PP_L / ICE_PLAYER_FRACTION,
                        FS_PP_W,
                        t,
                        vec3(0, 0, 0),
                        color
                    );
                }
            }
        }

        // handling shaded 'region' rendering:

        float relativePos = Math::InvLerp(gearStateManager.GEARDOWN_RPM_THRESH, gearStateManager.GEARUP_RPM_THRESH, int(gearStateManager.expectedTrueRpm));

        // we show regions all the time, but fade in and out of them depending on where we are
        // at 0.5, show no regions.
        // above 0.5, show upper regions with opacity derived from relativePos in domain [0.5, 1.5]
        // below 0.5, show lower regions with opacity derived from relativePos in domain [-0.5, 0.5]

        if (ICE_REGIONS_RENDER) {
            float appliedOpacity;
            if (relativePos >= 0.5) {
                appliedOpacity = gearStateManager.GetGearupMult();
                RenderRegion(
                    visState,
                    (ICE_PP_S + ICE_PP_L) * ICE_REGION_START,
                    (ICE_PP_S + ICE_PP_L) * ICE_REGION_END - (ICE_PP_S + ICE_PP_L) * ICE_REGION_START,
                    lines[0],
                    lines[1],
                    vec3(0, 0, 0),
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
                    vec3(0, 0, 0),
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
                    vec3(0, 0, 0),
                    ApplyOpacityToColor(ICE_REGIONS_DANGER_WEDGE_COLOR, appliedOpacity),
                    ApplyOpacityToColor(ICE_REGIONS_OUTLINE, appliedOpacity),
                    slip,
                    ICE_REGIONS_THICKNESS,
                    false,
                    appliedOpacity
                );

            }
            else if (relativePos < 0.5) {
                appliedOpacity = Math::Min((0.5 - relativePos), 1);
                RenderRegion(
                    visState,
                    (ICE_PP_S + ICE_PP_L) * ICE_REGION_START,
                    (ICE_PP_S + ICE_PP_L) * ICE_REGION_END - (ICE_PP_S + ICE_PP_L) * ICE_REGION_START,
                    lines[0],
                    lines[1],
                    vec3(0, 0, 0),
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

    void RenderIceIdealAngle(CSceneVehicleVisState@ visState, float vel, vec3 vec_vel, float slip) {
        float angle = gearStateManager.GetIdealAngle(vel);
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

    void RenderPlayerPointer(CSceneVehicleVisState@ visState, float pointer_start, float pointer_length, float pointer_width, float theta, vec3 offset, vec4 color) {
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

        vec3 offset_apply(0, 0, 0);
        offset_apply.x += Math::Sin(theta) * GEAR_PLAYER_OFFSET;
        offset_apply.z += gearPointerFlip * Math::Cos(theta) * GEAR_PLAYER_OFFSET;

        // make a graph of [absolute min] *** [geardown max] ************* [gearup min] [absolute max]

        for (int i = 1;
            (i >= (GEAR_ON_BOTH_SIDES ? -1 : 1)); i -= 2) {
            float abs_max = 13000;
            float abs_min = 7000;
            float rpm = Math::Clamp(gearStateManager.expectedRpm, abs_min, abs_max);

            float rpm_pos = Math::InvLerp(abs_min, abs_max, rpm) * pointer_length;
            float geardown_pos = Math::InvLerp(abs_min, abs_max, gearStateManager.GEARDOWN_RPM_THRESH) * pointer_length;

            if (rpm < gearStateManager.GEARDOWN_RPM_THRESH) {
                float color_pos = Math::InvLerp(abs_min, gearStateManager.GEARDOWN_RPM_THRESH, rpm);
                vec4 color1 = DANGER_UPSHIFT * (1 - color_pos) + NORMAL_UPSHIFT * color_pos;
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
                float color_pos = Math::InvLerp(gearStateManager.GEARUP_RPM_THRESH, abs_max, rpm);
                vec4 color1 = DANGER_UPSHIFT * color_pos + NORMAL_UPSHIFT * (1 - color_pos);
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
        float start,
        float length,
        float thetaStart,
        float thetaEnd,
        vec3 offset,
        vec4 fillColor,
        vec4 outlineColor,
        float slip,
        float outlineThickness,
        bool renderWarnZone,
        float appliedOpacity
    ) {
        // this is to inset [not warning, just to make it look visually good]
        float diff = thetaEnd - thetaStart;
        int flip = (Math::Angle(visState.WorldVel, visState.Left) > HALF_PI || IsPreview()) ? -1 : 1;
        thetaStart += diff * ICE_REGIONS_EDGE_FRAC;
        thetaEnd -= diff * ICE_REGIONS_EDGE_FRAC;

        diff = thetaEnd - thetaStart;

        float inner_thetaStart = thetaStart + (diff > 0 ? 1 : -1) * ICE_REGIONS_INSET;
        float inner_thetaEnd = thetaEnd - (diff > 0 ? 1 : -1) * ICE_REGIONS_INSET;

        thetaStart *= flip;
        thetaEnd *= flip;
        inner_thetaStart *= flip;
        inner_thetaEnd   *= flip;

        vec2 radialRoot = Camera::ToScreenSpace(ProjectAngle(visState, (start + length) * ICE_REGIONS_RADIAL_INSET_FRAC, -1 * flip * ProcessTheta(slip)));
        vec2 outermostPos = Camera::ToScreenSpace(ProjectAngle(visState, (start + length), ((thetaStart + thetaEnd) / 2)));
        vec2 innerPos = Camera::ToScreenSpace(ProjectAngle(visState, (start), ((thetaStart + thetaEnd) / 2)));
        vec2 radialParams = vec2((radialRoot - innerPos).Length(), (radialRoot - outermostPos).Length());
        radialParams /= 5;

        fillColor = ApplyOpacityToColor(fillColor, appliedOpacity);
        vec4 warnColor = ApplyOpacityToColor(ICE_REGIONS_WARNING, appliedOpacity);

        if (renderWarnZone) {
            _RenderRegion(visState, start, length, inner_thetaStart, inner_thetaEnd, offset, fillColor, ICE_REGIONS_DARK_COLOR_FRAC, radialRoot, radialParams, outlineColor, outlineThickness);
            _RenderRegion(visState, start, length, thetaStart, inner_thetaStart, offset, warnColor, ICE_REGIONS_DARK_COLOR_FRAC, radialRoot, radialParams, vec4(0), outlineThickness);
            _RenderRegion(visState, start, length, inner_thetaEnd, thetaEnd, offset, warnColor, ICE_REGIONS_DARK_COLOR_FRAC, radialRoot, radialParams, vec4(0), outlineThickness);
        } else {
            _RenderRegion(visState, start, length, thetaStart, thetaEnd, offset, fillColor, ICE_REGIONS_DARK_COLOR_FRAC, radialRoot, radialParams, outlineColor, outlineThickness);
        }
    }

    void RenderSimplifiedView(
        CSceneVehicleVisState@ visState,
        float start,
        float length,
        float width,
        float theta,
        vec3 offset,
        vec4 color
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

    void RenderSurface(CSceneVehicleVisState@ visState, float speed, vec3 vec_vel, float min_vel, vec2[] ideal_config, vec2[] base_config,  vec2[] zero_config) {
        RenderSurface(visState, speed, vec_vel, min_vel, ideal_config, base_config, zero_config, true);
    }

    void RenderSurface(CSceneVehicleVisState@ visState, float speed, vec3 vec_vel, float min_vel, vec2[] ideal_config, vec2[] base_config,  vec2[] zero_config, bool show_good_ss) {
        float target_ss = ApproximateSideSpeed(ideal_config, speed);
        float outer_ss = ApproximateSideSpeed(zero_config, speed);
        float base_ss = ApproximateSideSpeed(base_config, speed);
        float good_ss = Math::Lerp(outer_ss, target_ss, GOOD_THRESH);

        float slip = PreviewSlip(GetSlipSmoothed(visState.Left, vec_vel));
        float sideSpeed = speed * Math::Sin(PreviewSlip(Math::Angle(visState.Dir, vec_vel)));
        float abs_sidespeed = Math::Abs(sideSpeed);

        vec2 startAndLength = GetStartAndLength();
        vec2[] targets = GetLinesToBeRendered(target_ss, good_ss, base_ss, outer_ss, show_good_ss);

        RenderPlayerPointer(
            visState,
            startAndLength.x,
            startAndLength.y,
            FS_PP_W,
            slip,
            vec3(0, 0, 0),
            ApplyOpacityToColor(GetPlayerPointerColor(abs_sidespeed, target_ss, good_ss, base_ss, outer_ss), 1)
        );

        BAD_SLIDE = false;
        int OP_RES = 0;
        if (speed < min_vel) {
            if (SHOW_BAD_SLIDE && GetSlipTotal(visState) > 0) {
                OP_RES = 1;
                BAD_SLIDE = true;
            } else {
                OP_RES = -1;
            }
        } else {
            if (GetSlipTotal(visState) == 0 && !(IsWoodSurface(visState.FLGroundContactMaterial) && visState.FLIcing01 > 0 && visState.WetnessValue01 > 0)) {
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
            playerFadeOpacity = Math::Min(1, playerFadeOpacity + PLAYER_OPACITY_DERIVATIVE);
        } else {
            playerFadeOpacity = Math::Max(0, playerFadeOpacity - PLAYER_OPACITY_DERIVATIVE);
        }

        if (playerFadeOpacity == 0) {
            return;
        }

        float lower, upper, targetOpacity;
        int polarity = slip < 0 ? -1 : 1;
        for (int i = -1; i <= 1; i += 2) {
            lower = 0;
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
                    vec3(0, 0, 0),
                    ApplyOpacityToColor(GetColor(int(targets[j].y)), i == polarity ? targetOpacity : MIN_BRIGHTNESS)
                );
            }
        }
    }

    void SetThetaMult(CSceneVehicleVisState@ visState) {
        float target = GetTargetThetaMultFactor(visState);
        if (target < 0 || target == theta_mult) {
            return;
        }
        if (target > theta_mult) {
            theta_mult = Math::Min(target, theta_mult + THETA_MULT_DERIVATIVE);
        } else {
            theta_mult = Math::Max(target, theta_mult - THETA_MULT_DERIVATIVE);
        }
    }

    void _LineTo(vec3 p) {
        if (!Camera::IsBehind(p)) {
            nvg::LineTo(Camera::ToScreenSpace(p));
        }
    }

    void _RenderAngle(
        CSceneVehicleVisState@ visState,
        float start,
        float length,
        float width,
        float theta,
        vec3 offset,
        vec4 color
    ) {
        if (is_cam3 > 0 && (!DRAW_CAM3_IN_SIMPLIFIED_VIEW) && SIMPLIFIED_VIEW) {
            return;
        }

        if (RENDER_MODE == RenderMode::ICE) {
            offset.x += ICE_POINTER_X_OFFSET;
            offset.z += (theta < 0 ? -1 : 1) * ICE_POINTER_Z_OFFSET;
            theta += (theta < 0 ? -1 : 1) * ICE_POINTER_ANGLE_OFFSET;
        }

        if (SHOW_LINE_BACKGROUND) {
            vec4 c = color * LINE_BACKGROUND_COLOR_FRAC + (1 - LINE_BACKGROUND_COLOR_FRAC) * LINE_BACKGROUND_COLOR;
            c.w = color.w;
            __RenderAngle(visState, start, length, width * LINE_BACKGROUND_WIDTH, theta, offset, c);
        }
        __RenderAngle(visState, start, length, width, theta, offset, color);
    }

    void _RenderRegion(
        CSceneVehicleVisState@ visState,
        float start,
        float length,
        float thetaStart,
        float thetaEnd,
        vec3 offset,
        vec4 fillColor,
        float fillDarknessCoef,
        vec2 radialRoot,
        vec2 radialParams,
        vec4 outlineColor,
        float outlineThickness
    ) {
        if (RENDER_MODE == RenderMode::ICE) {
            offset.x += ICE_POINTER_X_OFFSET;
            offset.z += (thetaStart < 0 ? -1 : 1) * ICE_POINTER_Z_OFFSET;
            thetaStart += (thetaStart < 0 ? -1 : 1) * ICE_POINTER_ANGLE_OFFSET;
            thetaEnd += (thetaEnd < 0 ? -1 : 1) * ICE_POINTER_ANGLE_OFFSET;
        }

        float diff = thetaEnd - thetaStart;
        int flip = (Math::Angle(visState.WorldVel, visState.Left) > HALF_PI || IsPreview()) ? 1 : -1;

        fillColor = ApplyOpacityToColor(fillColor, playerFadeOpacity);

        vec4 fillColorDark = fillColor;
        fillColorDark *= fillDarknessCoef;
        fillColorDark.w *= 0.1;

        // We need to draw a shaded region by drawing a closed path outlining
        // the "region" inbetwixt the lines of interest, then filling it.

        float angle_per_point = (flip * Math::PI * 2) / ICE_REGIONS_RESOLUTION;
        int points = int(diff / angle_per_point);

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
            _LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + ((i + 1 ) * angle_per_point)), offset));
            _LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + ((i + 1 ) * angle_per_point)), offset));
            _LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + ((i ) * angle_per_point)), offset));
            _LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + ((i ) * angle_per_point)), offset));
            nvg::FillPaint(nvg::RadialGradient(radialRoot, ICE_REGIONS_GRADIENT_INNER_DIAMETER, ICE_REGIONS_GRADIENT_OUTER_DIAMETER, fillColor, fillColorDark));
            nvg::Fill();
            nvg::ClosePath();
        }

        nvg::BeginPath();
        nvg::MoveTo(Camera::ToScreenSpace(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (points * angle_per_point)), offset)));
        _LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaEnd), offset));
        _LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaEnd), offset));
        _LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + ((points ) * angle_per_point)), offset));
        _LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + ((points) * angle_per_point)), offset));
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
        float start,
        float length,
        float width,
        float theta,
        vec3 offset,
        vec4 color
    ) {
        theta = ProcessTheta(theta);

        if (SIMPLIFIED_VIEW && RENDER_MODE == RenderMode::NORMAL && is_cam3 == 0) {
            color = ApplyOpacityToColor(color, SIMPLIFIED_OPACITY_MULT);
            width = SIMPLIFIED_LINE_THICKNESS_OVERRIDE;
        }

        for (int i = 0; i < (is_cam3 > 0 ? 1 : NUM_LAYERS); i++) {
            vec3 o = offset;
            float y_offset = LAYER_HEIGHT * i;
            o.y += y_offset;

            vec3 v_start = ProjectOffset(visState, ProjectAngle(visState, start, theta), o);
            vec3 v_end = ProjectOffset(visState, ProjectAngle(visState, start + length, theta), o);

            if (Camera::IsBehind(v_start) || Camera::IsBehind(v_end)) {
                return;
            }
            vec3 cameraDist = v_start - Camera::GetCurrentPosition();
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
