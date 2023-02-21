class Protractor {
    vec3 vel, sepPlane;

    int radius = 1;

    int NUM_SECTIONS = 100;

    int tssIdx = 0;
    int tssMax = 20;
    int tssCount = 0;
    int tssCountMax = 5;

    float slipAngle = 0;

    int numWheels = 8;
    int curWheel = 0;
    int numWheelTrailPoints = 50;
    int curWheelTrailPoint = 0;

    array<float> slip_arr(100);
    int slip_pos = 0;

    float theta_mult;

    int is_cam3 = 0;
    
    // opacity settings
    float playerPointerOpacity, playerFadeOpacity;

    GearStateManager gearStateManager();

    Protractor() {
    }

    void setThetaMult(CSceneVehicleVisState@ visState) {
        float target = getTargetThetaMultFactor(visState);
        if (target < 0 || target == theta_mult) {
            return;
        }
        if (target > theta_mult) {
            theta_mult = Math::Min(target, theta_mult + THETA_MULT_DERIVATIVE);
        } else {
            theta_mult = Math::Max(target, theta_mult - THETA_MULT_DERIVATIVE);
        }

    }

    void renderAngle(
        CSceneVehicleVisState@ visState,
        float start,
        float length,
        float width,
        float theta,
        vec3 offset,
        vec4 color
    ) {
        theta *= theta_mult;

        int layers = NUM_LAYERS; 
        if (is_cam3 > 0) {
            layers = 1;
        }

        for (int i = 0; i < layers; i++) {
            vec3 o = offset;
            float y_offset = LAYER_HEIGHT * i;
            o.y += y_offset;

            vec3 v_start = projectOffset(visState, projectAngle(visState, start, theta), o);
            vec3 v_end = projectOffset(visState, projectAngle(visState, start + length, theta), o);
            
            if (Camera::IsBehind(v_start) || Camera::IsBehind(v_end)) {
                return;
            } 

            if (theta < -HALF_PI || theta > HALF_PI) {
                return;
            }

            nvg::BeginPath();
            nvg::MoveTo(Camera::ToScreenSpace(v_start));
            nvg::LineTo(Camera::ToScreenSpace(v_end));
            nvg::StrokeColor(ApplyOpacityToColor(color, playerFadeOpacity));
            nvg::StrokeWidth(width);
            nvg::Stroke();
            nvg::ClosePath();
        }

    }

    vec3 projectAngle(CSceneVehicleVisState@ visState, float r, float theta) {

        vec3 p = visState.Position;

        p += visState.Dir * Math::Cos(theta) * r;
        p += visState.Left * Math::Sin(theta) * r;

        return p;
    }

    float get_theta_base(vec3 vec) {
        if (vec.z == 0) {
            return 0;
        }

        float t = Math::Atan(vec.x / vec.z);
        if (vec.z < 0) {
            t += 2 * HALF_PI;
        }
        return t;
    }

    vec3 projectOffset(CSceneVehicleVisState@ visState, vec3 in_pos, vec3 offset) {
        return in_pos +
            visState.Dir * offset.x + 
            visState.Up * offset.y + 
            visState.Left * offset.z;
    }

    float getSideSpeedAngle(float vel, float target_sidespeed) {
        return Math::Asin(target_sidespeed / vel);
    }

    /** 
     * Return codes:
     * 0: Not cam 3. 
     * 1: Cam 3 in-car. 
     * 2: Cam three full. 
     */
    int isCam3(CSceneVehicleVisState@ visState) {
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

    void render() {
        CSceneVehicleVisState@ visState = getVisState();
        if (visState == null) {
            return;
        }
        is_cam3 = isCam3(visState);

        setThetaMult(visState);
        float vel = visState.WorldVel.Length();
        vec3 vec_vel = visState.WorldVel / vel;
        iso4 loc = Camera::GetCurrent().Location;
        vec3 cameraLoc = vec3(loc.tx, loc.ty, loc.tz);
        vec3 diff = visState.Position - cameraLoc;

        if (vel < 5) {
            return;
        }

        sepPlane = Math::Cross(diff, visState.Up);
        sepPlane /= sepPlane.Length();

        slipAngle = normalizeSlipAngle(calcVecAngle(visState.Left, visState.WorldVel), visState.FrontSpeed);
        tssCount = (tssCount + 1) % tssCountMax;

        gearStateManager.handleUpdate(slipAngle, visState.WorldVel.Length(),
            visState.CurGear, VehicleState::GetRPM(visState));

        if (isIceSurface(visState.FLGroundContactMaterial) && visState.FLIcing01 > 0) {
            renderIce(visState, vel, vec_vel);
        } else if (isTarmacSurface(visState.FLGroundContactMaterial)) {
            renderSurface(visState, vel, vec_vel, 5, tarmac_fs_arr);
        } else if (isPlasticDirtOrGrass(visState.FLGroundContactMaterial)) {
            renderSurface(visState, vel, vec_vel, 4, gdp_arr);
        }
        
    }

    void renderIce(CSceneVehicleVisState@ visState, float vel, vec3 vec_vel) {
        renderAngle( // player pointer
            visState,
            ICE_PP_S,
            ICE_PP_L,
            ICE_PP_W,
            0,
            vec3(0, 0, 0),
            ICE_PP_COLOR
        );
        renderIceGearLines(visState, vec_vel);
        renderIceIdealAngle(visState, vel, vec_vel);
    }
    void renderIceGearLines(CSceneVehicleVisState@ visState, vec3 vel) {
        array < float > lines = gearStateManager.getGearUpLines();
        vec4 color = gearStateManager.getGearupColorProjection();

        for (int i = 0; i < lines.Length; i++) {
            renderAngle(
            visState,
            ICE_G_S,
            ICE_G_L,
            ICE_G_W,
            lines[i],
            vec3(0, 0, 0),
            color
        );
        }

        lines = gearStateManager.getGearDownLines();
        color = gearStateManager.getGeardownColorProjection();
        for (int i = 0; i < lines.Length; i++) {
            renderAngle(
            visState,
            ICE_G_S,
            ICE_G_L,
            ICE_G_W,
            lines[i],
            vec3(0, 0, 0),
            color
            );
        }
    }
    void renderIceIdealAngle(CSceneVehicleVisState@ visState, float vel, vec3 vec_vel) {
        float angle = gearStateManager.getIdealAngle(vel);
        renderAngle(
        visState,
        ICE_G_S,
        ICE_G_L,
        ICE_G_W,
        angle,
        vec3(0, 0, 0),
        ICE_PP_COLOR
        );
    }

    vec4 getPlayerPointerColor(float sideSpeed, array<vec2> ideal_sidespeed_arr) { {
        vec2 lower, upper, cur;
        upper.y = -1;
        lower.y = -1;
        for (int i = 0; i < ideal_sidespeed_arr.Length; i++) {
            cur = ideal_sidespeed_arr[i];
            if (sideSpeed > cur.x) {
                lower = cur;
                continue;
            }
            if (sideSpeed < cur.x && upper.y == -1) {
                upper = cur;
                continue;
            }
        }

        if (lower.y == -1 || upper.y == -1) {
            return getColor(3);
        }
        float pos = Math::InvLerp(lower.x, upper.x, sideSpeed);
        vec4 c = (getColor(lower.y) * (1 - pos)) + (getColor(upper.y) * pos);
        return c;
     }
    }

    float getSlipTotal(CSceneVehicleVisState@ visState) {
        return visState.FLSlipCoef + visState.FRSlipCoef + visState.RLSlipCoef + visState.RRSlipCoef;
    }

    float getSlip(vec3 left, vec3 vel) {
        float slip = calcVecAngle(left, vel);
        slip_arr[slip_pos % SLIP_SMOOTHING] = slip;
        slip_pos += 1;

        float ret = 0; 
        for (int i = 0; i < SLIP_SMOOTHING; i++) {
            ret += slip_arr[i];
        }
        return ret / SLIP_SMOOTHING;
    }

    void renderSurface(CSceneVehicleVisState@ visState, float vel, vec3 vec_vel, int min_slide_gear, array<vec2> ideal_sidespeed_arr) {
        float sideSpeed = vel * Math::Sin(Math::Angle(visState.Dir, vec_vel));
        vec4 color = getPlayerPointerColor(sideSpeed, ideal_sidespeed_arr);
        float slip = getSlip(visState.Left, vec_vel);

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

        if (visState.CurGear >= min_slide_gear) {
            vec2 upper, lower;
            for (int i = -1; i <= 1; i += 2) {
                if ((slip < 0 && i < 0) || (slip > 0 && i > 0)) {
                    vec2 cur;
                    upper.y = -1;
                    lower.y = -1;
                    for (int j = 0; j < ideal_sidespeed_arr.Length; j++) {
                        cur = ideal_sidespeed_arr[j];
                        if (sideSpeed > cur.x) {
                            lower = cur;
                            continue;
                        }
                        if (sideSpeed < cur.x && upper.y == -1) {
                            upper = cur;
                            continue;
                        }
                    }

                    float pos = 1;

                    if (lower.y != -1 && upper.y != -1) {
                        pos = Math::InvLerp(lower.x, upper.x, sideSpeed);
                    } else {
                        pos = Math::InvLerp(lower.x, lower.x * 1.5, sideSpeed);
                    }



                    if (lower.y != -1) {
                        renderAngle( // ideal angle
                            visState,
                            start,
                            length / PLAYER_FRACTION,
                            ICE_PP_W,
                            (getSideSpeedAngle(vel, lower.x * i)),
                            vec3(0, 0, 0),
                            ApplyOpacityToColor(getColor(lower.y), 1 - pos)
                        );
                        playerPointerOpacity = Math::Max(playerPointerOpacity, (1 - pos));
                    }

                    if (upper.y != -1) {
                        renderAngle( // ideal angle
                            visState,
                            start,
                            length / PLAYER_FRACTION,
                            ICE_PP_W,
                            (getSideSpeedAngle(vel, upper.x * i)),
                            vec3(0, 0, 0),
                            ApplyOpacityToColor(getColor(upper.y), pos)
                        );
                        playerPointerOpacity = Math::Max(playerPointerOpacity, pos);
                    }
                }

                vec2 cur;
                for (int j = 0; j < ideal_sidespeed_arr.Length; j++) {
                    cur = ideal_sidespeed_arr[j];
                    if (cur.x != upper.x && cur.x != lower.x) {
                        renderAngle( // ideal angle
                            visState,
                            start,
                            length / PLAYER_FRACTION,
                            ICE_PP_W,
                            (getSideSpeedAngle(vel, cur.x * i)),
                            vec3(0, 0, 0),
                            ApplyOpacityToColor(getColor(cur.y), min_brightness)
                        );
                    }
                }
            }
        }

        
        if (SHOW_BAD_SLIDE && (visState.CurGear < min_slide_gear && getSlipTotal(visState) > 0 || visState.CurGear >= min_slide_gear && getSlipTotal(visState) == 0)) {
            color = FS_B_COLOR;
            playerFadeOpacity = Math::Min(1, playerFadeOpacity + PLAYER_OPACITY_DERIVATIVE);
        } else if (FADE_WHEN_OVERSLIDE && Math::Abs(sideSpeed) > ideal_sidespeed_arr[ideal_sidespeed_arr.Length - 1].x * FADE_OVERSLIDE_MULT) {
            playerFadeOpacity = Math::Max(0, playerFadeOpacity - PLAYER_OPACITY_DERIVATIVE);
        } else if (visState.CurGear >= min_slide_gear && (SHOW_BAD_SLIDE || getSlipTotal(visState) == 4)) {
            playerFadeOpacity = Math::Min(1, playerFadeOpacity + PLAYER_OPACITY_DERIVATIVE);
        } else {
            playerFadeOpacity = Math::Max(0, playerFadeOpacity - PLAYER_OPACITY_DERIVATIVE);
        }

        renderAngle( // player pointer
            visState,
            start,
            length,
            ICE_PP_W,
            slip,
            vec3(0, 0, 0),
            ApplyOpacityToColor(color, playerPointerOpacity)
        );

    }

    vec4 ApplyOpacityToColor(vec4 inColor, float opacity) {
        vec4 outColor = inColor;
        outColor.w = Math::Min(opacity, outColor.w);
        outColor.w = Math::Max(outColor.w, 0);
        return outColor;
    }

}