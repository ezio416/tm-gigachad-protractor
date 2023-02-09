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

    // opacity settings
    float playerPointerOpacity, playerTargetOpacity;

    GearStateManager gearStateManager();

    Protractor() {
    }

    void renderAngle(
        CSceneVehicleVisState@ visState,
        vec3 basis,
        float start,
        float length,
        float width,
        float theta,
        vec3 offset,
        vec4 color
    ) {
        vec3 v_start = projectOffset(visState, projectAngle(visState, basis, start, theta), offset);
        vec3 v_end = projectOffset(visState, projectAngle(visState, basis, start + length, theta), offset);

        nvg::BeginPath();
        nvg::MoveTo(Camera::ToScreenSpace(v_start));
        nvg::LineTo(Camera::ToScreenSpace(v_end));
        nvg::StrokeColor(color);
        nvg::StrokeWidth(width);
        nvg::Stroke();
        nvg::ClosePath();
    }

    vec3 projectAngle(CSceneVehicleVisState@ visState, vec3 basis, float r, float theta) {
        if (DISPLAY_FLIPPED) {
            r += 2;
            theta = (2 * HALF_PI - theta);
            theta *= -1;
        }
        vec3 p = visState.Position;
        vec3 angle_cross = getAngleCylindrical(basis, theta);

        vec3 next = p + vec3(r, r, r) * Math::Cross(visState.Up, angle_cross);
        return next;

        p += visState.Dir * Math::Sin(theta) * r;
        p += visState.Left * Math::Cos(theta) * r;
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

    vec3 getAngleCylindrical(vec3 basis, float theta) {
        theta += get_theta_base(basis);
        vec3 angle_cross = vec3(Math::Sin(theta), 0, Math::Cos(theta));
        return angle_cross;
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

    void render() {
        CSceneVehicleVisState@ visState = getVisState();
        if (visState == null) {
            return;
        }
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
        } else if (isDirtSurface(visState.FLGroundContactMaterial)) {
            renderSurface(visState, vel, vec_vel, 4, 5 / 3.6);
        } else if (isTarmacSurface(visState.FLGroundContactMaterial)) {
            renderSurface(visState, vel, vec_vel, 5, 5.50);
        } else if (isGrassSurface(visState.FLGroundContactMaterial)) {
            renderSurface(visState, vel, vec_vel, 4, 5 / 3.6);
        }
    }

    void renderIce(CSceneVehicleVisState@ visState, float vel, vec3 vec_vel) {
        renderAngle( // player pointer
            visState,
            visState.Dir,
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
            vel,
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
            vel,
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
        vec_vel,
        ICE_G_S,
        ICE_G_L,
        ICE_G_W,
        angle,
        vec3(0, 0, 0),
        ICE_PP_COLOR
        );
    }

    vec4 getPlayerPointerColor(float expected, float actual) {
        float diff = (Math::Abs((Math::Abs(expected) - Math::Abs(actual))) / expected) ** 10;
        print(tostring(diff));

        return FS_B_COLOR * (1 - diff) + FS_G_COLOR * diff;
    }

    float getSlipTotal(CSceneVehicleVisState@ visState) {
        return visState.FLSlipCoef + visState.FRSlipCoef + visState.RLSlipCoef + visState.RRSlipCoef;
    }

    void renderSurface(CSceneVehicleVisState@ visState, float vel, vec3 vec_vel, int min_slide_gear, float ideal_sidespeed) {
        vec4 color = ICE_PP_COLOR;
        if (visState.CurGear < min_slide_gear || visState.CurGear >= min_slide_gear && getSlipTotal(visState) == 0) {
            color = FS_B_COLOR;
        } else {
            float ideal_angle = getSideSpeedAngle(vel, ideal_sidespeed) + HALF_PI;
            color = getPlayerPointerColor(ideal_angle, calcVecAngle(visState.Dir, vec_vel) + HALF_PI);
        }

        
        if (((visState.CurGear < min_slide_gear) && getSlipTotal(visState)> 0) || visState.CurGear >= min_slide_gear)
            {
                playerPointerOpacity = Math::Max(1, playerPointerOpacity + 0.01);
            } else {
                playerPointerOpacity = Math::Min(0, playerPointerOpacity - 0.01);
            }

            
        // float ideal_angle = getSideSpeedAngle(vel, ideal_sidespeed) + HALF_PI;
        // vec4 color = getPlayerPointerColor(ideal_angle, calcVecAngle(visState.Dir, vec_vel));
            
        renderAngle( // player pointer
            visState,
            visState.Dir,
            ICE_PP_S,
            ICE_PP_L,
            ICE_PP_W,
            HALF_PI,
            vec3(0, 0, 0),
            ApplyOpacityToColor(color, playerPointerOpacity)
        );

        if (visState.CurGear >= min_slide_gear) {

            for (int i = -1; i <= 1; i += 2) {
                renderAngle( // ideal angle
                    visState,
                    vec_vel,
                    ICE_PP_S,
                    ICE_PP_L,
                    ICE_PP_W,
                    (getSideSpeedAngle(vel, ideal_sidespeed) * i) + HALF_PI,
                    vec3(0, 0, 0),
                    ICE_PP_COLOR
                );
            }
        }
    }

    vec4 ApplyOpacityToColor(vec4 inColor, float opacity) {
        vec4 outColor = inColor;
        outColor.w = Math::Min(opacity, outColor.w);
        outColor.w = Math::Max(outColor.w, 0);
        return outColor;
    }

}