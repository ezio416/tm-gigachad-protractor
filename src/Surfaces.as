/*
Surface configuration:

Provide two `vec2` arrays: ideal and zero.

The "ideal" array should provide the most precise "best" sidespeed possible for that speed.
The "zero" array should provide the sidespeed at which the car doesn't accelerate.
All intermediate values can be linearly interpreted from these.

Format of vec2: (speed, target_sidespeed)
*/

namespace Surface {
    float GetThetaMult(const EPlugSurfaceMaterialId surface) {
        if (Ice::Is(surface)) {
            return 1.0f;
        }

        if (Dirt::Is(surface)) {
            return S_ThetaMultDirt;
        }

        if (Road::Is(surface)) {
            return S_ThetaMultRoad;
        }

        if (Grass::Is(surface)) {
            return S_ThetaMultGrass;
        }

        if (Plastic::Is(surface)) {
            return S_ThetaMultPlastic;
        }

        if (Wood::Is(surface)) {
            return S_ThetaMultWood;
        }

        return -1000.0f;
    }

    void Render(
        CSceneVehicleVisState@ visState,
        const float speed,
        const vec3&in vel,
        const float minSpeed,
        const vec2[]&in ideal,
        const vec2[]&in base,
        const vec2[]&in zero,
        const bool showGoodSD = true
    ) {
        const float targetSD = ApproximateSideSpeed(ideal, speed);
        const float outerSD = ApproximateSideSpeed(zero, speed);
        const float baseSD = ApproximateSideSpeed(base, speed);
        const float goodSD = Math::Lerp(outerSD, targetSD, S_GoodAccelThreshold);
        const float slip = PreviewSlip(GetSlipSmoothed(visState.Left, vel));
        const float sideSpeed = speed * Math::Sin(PreviewSlip(Math::Angle(visState.Dir, vel)));
        const float absSideSpeed = Math::Abs(sideSpeed);
        const vec2 startAndLength = GetStartAndLength();
        const vec2[] targets = GetLinesToBeRendered(targetSD, goodSD, baseSD, outerSD, showGoodSD);

        RenderPlayerPointer(
            visState,
            startAndLength.x,
            startAndLength.y,
            S_Width,
            slip,
            vec3(),
            ApplyOpacityToColor(
                GetPlayerPointerColor(absSideSpeed, targetSD, goodSD, baseSD, outerSD),
                1.0f
            )
        );

        int opRes = 0;
        if (speed < minSpeed) {
            opRes = -1;
        } else {
            if (true
                and GetSlipTotal(visState) == 0.0f
                and !(Wood::Is(visState.FLGroundContactMaterial) and visState.FLIcing01 > 0.0f and visState.WetnessValue01 > 0.0f)
            ) {
                opRes = -1;
            } else {
                opRes = absSideSpeed > outerSD ? -1 : 1;
            }
        }

        if (opRes > 0) {
            playerFadeOpacity = Math::Min(1.0f, playerFadeOpacity + S_OpacityDerivative);
        } else {
            playerFadeOpacity = Math::Max(0.0f, playerFadeOpacity - S_OpacityDerivative);
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
                targetOpacity = Math::Max(Math::InvLerp(lower, upper, absSideSpeed), S_BrightnessMin);
                lower = upper;
                RenderAngle(
                    visState,
                    startAndLength.x,
                    startAndLength.y / S_AssistLength,
                    S_Width,
                    (GetSideSpeedAngle(speed, targets[j].x * i)),
                    vec3(),
                    ApplyOpacityToColor(
                        GetColor(int(targets[j].y)),
                        i == polarity ? targetOpacity : S_BrightnessMin
                    )
                );
            }
        }
    }

    namespace Dirt {
        const vec2[] BASE = {
            vec2(55.0f,  4.0f),
            vec2(86.6f,  7.25f),
            vec2(216.0f, 20.13f),
            vec2(250.0f, 21.39f)
        };

        const vec2[] BW_IDEAL = {
            vec2(0.0f,   2.0f),
            vec2(25.0f,  2.0f),
            vec2(30.0f,  2.3f),
            vec2(60.0f,  2.7f),
            vec2(80.0f,  2.85f),
            vec2(130.0f, 2.9f)
        };

        const vec2[] BW_ZERO = {
            vec2(0.0f,   8.0f),
            vec2(56.0f,  17.0f),
            vec2(30.0f,  2.3f),
            vec2(73.0f,  19.75f),
            vec2(84.5f,  21.0f),
            vec2(103.0f, 23.5f),
            vec2(130.0f, 26.5f)
        };

        const vec2[] IDEAL = {
            vec2(55.0f,  1.0f),
            vec2(100.0f, 1.5f),
            vec2(202.0f, 2.15f),
            vec2(250.0f, 2.15f)
        };

        const vec2[] ZERO = {
            vec2(55.0f,    11.96f),
            vec2(56.55f,   12.18f),
            vec2(80.25f,   15.664f),
            vec2(142.275f, 24.0675f),
            vec2(168.85f,  26.54f),
            vec2(202.65f,  29.714f),
            vec2(224.5f,   31.525f),
            vec2(250.0f,   33.33f)
        };

        bool Is(const EPlugSurfaceMaterialId surface) {
            switch (surface) {
                case EPlugSurfaceMaterialId::Dirt:
                case EPlugSurfaceMaterialId::DirtRoad:
                    return true;
            }

            return false;
        }

        void Render(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel) {
            Surface::Render(visState, speed, vel, Other::MIN, IDEAL, BASE, ZERO);
        }

        void RenderBackwards(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel) {
            Surface::Render(visState, speed, vel, Other::BW_MIN, BW_IDEAL, {}, BW_ZERO);
        }
    }

    namespace Grass {
        const vec2[] BASE = {
            vec2(55.0f,  4.0f),
            vec2(86.6f,  7.25f),
            vec2(216.0f, 20.13f),
            vec2(250.0f, 21.39f)
        };

        const vec2[] BW_IDEAL = {
            vec2(0.0f,   1.4f),
            vec2(28.0f,  1.7f),
            vec2(75.0f,  2.18f),
            vec2(110.0f, 2.2f),
            vec2(130.0f, 2.25f)
        };

        const vec2[] BW_ZERO = {
            vec2(0.0f,   2.0f),
            vec2(10.0f,  6.0f),
            vec2(30.0f,  12.0f),
            vec2(50.0f,  17.0f),
            vec2(110.0f, 25.0f),
            vec2(130.0f, 27.4f)
        };

        const vec2[] IDEAL = {
            vec2(55.0f,  1.0f),
            vec2(80.0f,  1.365f),
            vec2(110.0f, 1.4f),
            vec2(145.0f, 1.7f),
            vec2(180.0f, 2.0f),
            vec2(216.0f, 2.4f),
            vec2(250.0f, 2.8f)
        };

        const vec2[] ZERO = {
            vec2(55.0f,  13.5f),
            vec2(87.0f,  17.6f),
            vec2(112.6f, 21.25f),
            vec2(145.0f, 25.42f),
            vec2(216.4f, 32.54f),
            vec2(250.0f, 35.4f)
        };

        bool Is(const EPlugSurfaceMaterialId surface) {
            switch (surface) {
                case EPlugSurfaceMaterialId::Green:
                case EPlugSurfaceMaterialId::Grass:
                    return true;
            }

            return false;
        }

        void Render(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel) {
            Surface::Render(visState, speed, vel, Other::MIN, IDEAL, BASE, ZERO);
        }

        void RenderBackwards(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel) {
            Surface::Render(visState, speed, vel, Other::BW_MIN, BW_IDEAL, {}, BW_ZERO);
        }
    }

    namespace Ice {
        const float MIN       = 10.0f;
        const float SCORE_MAX = 15000.0f;

        const vec2[] DESERT_BACK_PEAK = {
            vec2(2.5f,    0.2f),
            vec2(84.2f,   79.5f),
            vec2(116.75f, 115.6f)
        };

        const vec2[] DESERT_PEAK = {
            vec2(2.125f, 0.2f),
            vec2(15.0f,  0.4f),
            vec2(28.0f,  0.9f),
            vec2(31.0f,  0.3f),
            vec2(104.0f, 0.7f),
            vec2(187.7f, 1.0f),
            vec2(272.6f, 86.8f)
        };

        const vec2[] DESERT_ZERO = {
            vec2(2.5f,   1.8f),
            vec2(70.5f,  64.8f),
            vec2(108.0f, 107.75f),
            vec2(170.0f, 165.95f)
        };

        const vec2[] GEARUP_1 = {
            vec2(37.5f,   2.15f),
            vec2(45.64f,  2.0834f),
            vec2(52.15f,  2.01175f),
            vec2(64.65f,  1.9276f),
            vec2(67.465f, 1.9093f),
            vec2(77.5f,   1.866f)
        };

        const vec2[] GEARUP_2 = {
            vec2(29.65f, 1.69f),
            vec2(43.5f,  1.642f),
            vec2(52.86f, 1.632f),
            vec2(68.5f,  1.622f),
            vec2(75.0f,  1.618f)
        };

        const vec2[] GEARUP_3 = {
            vec2(35.0f,  1.637f),
            vec2(46.0f,  1.6195f),
            vec2(52.3f,  1.6095f),
            vec2(75.95f, 1.596f)
        };

        const vec2[] GEARUP_4 = {
            vec2(46.6f,   1.44f),
            vec2(56.2f,   1.502f),
            vec2(62.4f,   1.53f),
            vec2(78.52f,  1.526f),
            vec2(79.825f, 1.5175f),
            vec2(80.26f,  1.508f)
        };

        const vec2[] IDEAL_ANGLES = {
            vec2(0.0f,   1.47f),
            vec2(40.0f,  1.47f),
            vec2(50.0f,  1.4f),
            vec2(57.0f,  1.35f),
            vec2(64.0f,  1.3f),
            vec2(70.0f,  1.24f),
            vec2(76.0f,  1.2f),
            vec2(84.0f,  1.24f),
            vec2(90.0f,  1.25f),
            vec2(100.0f, 1.27f),
            vec2(130.0f, 1.35f),
            vec2(150.0f, 1.4f)
        };

        const vec2[] RALLY_PEAK = {
            vec2(1.0f,   0.0f),
            vec2(400.0f, 0.0f)
        };

        const vec2[] RALLY_SLIDEOUT = {
            vec2(1.0f,   0.717f),
            vec2(50.5f,  41.325f),
            vec2(400.0f, 329.95f)
        };

        const vec2[] RALLY_ZERO = {
            vec2(17.6f,   0.0f),
            vec2(44.425f, 18.1f),
            vec2(57.34f,  23.92f),
            vec2(80.4f,   38.25f)
        };

        int     currentIndex        = 0;
        float   dt                  = 0.0f;
        float   expectedRpm         = 0.0f;
        float   expectedTrueRpm     = 0.0f;
        int     framesAveraged      = 100;
        float[] frameTimes(500);
        float[] gearupScores(500);
        uint64  lastColorFetchTime  = 0;
        float   lastColorFetchScore = 0.0f;

        int GetAndIncrementIdx() {
            const int index = currentIndex;
            frameTimes[index] = dt;
            currentIndex = (currentIndex + 1) % framesAveraged;

            if (currentIndex == 0) {
                float sum = 0.0f;
                for (int i = 0; i < framesAveraged; i++) {
                    sum += frameTimes[i];
                }

                framesAveraged = int(250 / (sum / framesAveraged));
            }

            return index;
        }

        float GetExpectedRpm(const float speed, const int gear, const float slip, const bool checkSlip) {
            if (!checkSlip or !InSafeZone(slip, speed)) {
                return speed * GetExpectedRpmBySpeedMult(gear);
            }

            return 0.0f;
        }

        float GetExpectedRpmBySpeedMult(const int gear) {
            switch (gear) {
                case 0: return -375.0f;
                case 1: return 425.0f;
                case 2: return 275.0f;  // 270 is from grass - different across surfaces?
                case 3: return 180.0f;
                case 4: return 125.0f;
                case 5: return 90.0f;
            }

            return 0.0f;
        }

        vec4 GetGeardownColor() {
            if (expectedTrueRpm < GEARDOWN_RPM_THRESH) {
                vec4 c = S_UpshiftNormalColor;
                c.w *= GetGeardownMult();
                return c;
            }

            return vec4();
        }

        float GetGeardownMult() {
            return Math::Min(
                1,
                Math::InvLerp(
                    GEARDOWN_RPM_THRESH,
                    GEARDOWN_RPM_THRESH - 3000,
                    int(expectedTrueRpm)
                )
            );
        }

        vec4 GetGearupColor() {
            if (expectedTrueRpm > GEARUP_RPM_THRESH) {
                const float pos = GetGearupScore() / GetGearupScoreMax();
                vec4 c = S_UpshiftDangerColor * pos + S_UpshiftNormalColor * (1.0f - pos);
                c.w *= GetGearupMult();
                return c;
            }

            return vec4();
        }

        float GetGearupMult() {
            return Math::Min(
                1,
                Math::InvLerp(
                    GEARUP_RPM_THRESH + 500,
                    GEARUP_RPM_THRESH + 3000,
                    int(expectedTrueRpm)
                )
            );
        }

        float GetGearupScore() {
            if (Time::Now == lastColorFetchTime) {
                return lastColorFetchScore;
            }

            float score = 0.0f;
            for (int i = 0; i < framesAveraged; i++) {
                score += gearupScores[i];
            }

            lastColorFetchScore = Math::Min(score, GetGearupScoreMax());
            lastColorFetchTime = Time::Now;

            return lastColorFetchScore;
        }

        float GetGearupScoreMax() {
            return SCORE_MAX * framesAveraged;
        }

        float GetIdealAngle(const float speed) {
            return LerpToMidpoint(IDEAL_ANGLES, speed);
        }

        float GetLineBrightness(const float slip, const float theta) {
            const float diff = Math::Abs(slip - theta);
            const float ret = Math::InvLerp(0.3f, 0.0f, diff);
            return Math::Max(ret, S_IceBrightnessMin);
        }

        void HandleUpdate(const float slip, const float speed, const int gear) {
            const int index = GetAndIncrementIdx();
            expectedRpm = GetExpectedRpm(speed, gear, slip, true);
            expectedTrueRpm = GetExpectedRpm(speed, gear, slip, false);
            gearupScores[index] = Math::Min(expectedRpm, SCORE_MAX);
        }

        bool Is(const EPlugSurfaceMaterialId surface) {
            switch (surface) {
                case EPlugSurfaceMaterialId::Concrete:
                case EPlugSurfaceMaterialId::Ice:
                case EPlugSurfaceMaterialId::RoadIce:
                case EPlugSurfaceMaterialId::Snow:
                    return true;
            }

            return false;
        }

        bool InSafeZone(float slip, const float speed) {
            slip = Math::Abs(slip);

            if (slip >= LerpToMidpoint(Surface::Ice::GEARUP_1, speed)) {
                return false;
            }

            if (slip >= LerpToMidpoint(Surface::Ice::GEARUP_2, speed)) {
                return true;
            }

            if (slip >= LerpToMidpoint(Surface::Ice::GEARUP_3, speed)) {
                return false;
            }

            if (slip >= LerpToMidpoint(Surface::Ice::GEARUP_4, speed)) {
                return true;
            }

            return false;
        }

        vec4 Opacity(const vec4&in color, const float slip, const float theta) {
            vec4 c = color;
            c.w *= Surface::Ice::GetLineBrightness(slip, theta);
            return c;
        }

        void Render(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel) {
            const float slip = PreviewSlip(CalcAngle(vel, visState.Dir));
            const float absSlip = Math::Abs(slip);

            if (absSlip < SIXTH_PI) {
                playerFadeOpacity = 0.0f;
            } else if (absSlip < QUARTER_PI) {
                playerFadeOpacity = Math::InvLerp(THIRD_PI, QUARTER_PI, absSlip);
            } else if (absSlip > QUARTER_PI) {
                playerFadeOpacity = 1.0f;
            }

            float theta = -slip;
            if (Math::Angle(vel, visState.Left) > HALF_PI or IsPreview()) {
                theta *= -1.0f;
            }

            vec4 color;

            if (expectedTrueRpm > GEARUP_RPM_THRESH) {
                color = GetGearupColor();
            } else if (expectedTrueRpm < GEARDOWN_RPM_THRESH) {
                color = GetGeardownColor();
            } else {
                color = vec4(1.0f);
            }

            color.w = 1.0f;

            RenderGearLines(visState, speed, vel, slip);
            RenderIdealAngle(visState, speed, vel, slip);
            RenderCustomAngle1(visState, vel);
            RenderCustomAngle2(visState, vel);

            RenderPlayerPointer(
                visState,
                S_IceStart,
                S_IceLength,
                S_Width,
                theta,
                vec3(),
                color
            );
        }

        void RenderAngle(CSceneVehicleVisState@ visState, const vec4&in color, const float theta) {
            ::RenderAngle(
                visState,
                S_IceStart,
                S_IceLength / S_IceAssistLength,
                S_Width,
                theta,
                vec3(),
                color
            );
        }

        void RenderCustomAngle(CSceneVehicleVisState@ visState, float theta, const vec3&in vel, const vec4&in color) {
            theta *= -0.0174533f;
            if (Math::Angle(vel, visState.Left) > HALF_PI or IsPreview()) {
                theta *= -1.0f;
            }

            RenderAngle(visState, color, theta);
        }

        void RenderCustomAngle1(CSceneVehicleVisState@ visState, const vec3&in vel) {
            if (S_IceShowCustomAngle) {
                RenderCustomAngle(visState, S_IceCustomAngle, vel, S_IceCustomAngleColor);
            }
        }

        void RenderCustomAngle2(CSceneVehicleVisState@ visState, const vec3&in vel) {
            if (S_IceShowCustomAngle2) {
                RenderCustomAngle(visState, S_IceCustomAngle2, vel, S_IceCustomAngle2Color);
            }
        }

        void RenderDesert(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel) {
            Surface::Render(visState, speed, vel, MIN, DESERT_PEAK, DESERT_ZERO, DESERT_BACK_PEAK, false);
        }

        void RenderGearLines(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel, float slip) {
            const float[] lines = {
                LerpToMidpoint(Surface::Ice::GEARUP_1, speed),
                LerpToMidpoint(Surface::Ice::GEARUP_2, speed),
                LerpToMidpoint(Surface::Ice::GEARUP_3, speed),
                LerpToMidpoint(Surface::Ice::GEARUP_4, speed)
            };

            if (S_IceGearLines) {
                float theta;
                vec4 color;

                if (expectedTrueRpm > GEARUP_RPM_THRESH) {
                    color = GetGearupColor();
                    for (uint i = 0; i < lines.Length; i++) {
                        switch (i) {
                            case 1: case 2: continue;
                        }

                        theta = -lines[i];
                        if (Math::Angle(vel, visState.Left) > HALF_PI or IsPreview()) {
                            theta *= -1.0f;
                        }

                        ::RenderAngle(
                            visState,
                            S_IceStart,
                            S_IceLength / S_IceAssistLength,
                            S_Width,
                            theta,
                            vec3(),
                            Opacity(color, slip, theta)
                        );
                    }
                }

                if (expectedTrueRpm < GEARDOWN_RPM_THRESH) {
                    const float[] lines1 = {
                        LerpToMidpoint(Surface::Ice::GEARUP_1, speed),
                        LerpToMidpoint(Surface::Ice::GEARUP_4, speed)
                    };

                    color = GetGeardownColor();

                    for (uint i = 0; i < lines1.Length; i++) {
                        slip = Math::Angle(visState.Dir, vel);

                        theta = -lines1[i];
                        if (Math::Angle(vel, visState.Left) > HALF_PI or IsPreview()) {
                            theta *= -1.0f;
                        }

                        ::RenderAngle(
                            visState,
                            S_IceStart,
                            S_IceLength / S_IceAssistLength,
                            S_Width,
                            theta,
                            vec3(),
                            color
                        );
                    }
                }
            }

            // handling shaded 'region' rendering:

            const float relativePos = Math::InvLerp(GEARDOWN_RPM_THRESH, GEARUP_RPM_THRESH, int(expectedTrueRpm));

            // we show regions all the time, but fade in and out of them depending on where we are
            // at 0.5, show no regions.
            // above 0.5, show upper regions with opacity derived from relativePos in domain [0.5, 1.5]
            // below 0.5, show lower regions with opacity derived from relativePos in domain [-0.5, 0.5]

            if (S_IceRegions) {
                float appliedOpacity;

                if (relativePos >= 0.5f) {
                    appliedOpacity = GetGearupMult();

                    RenderRegion(
                        visState,
                        (S_IceStart + S_IceLength) * S_IceRegionStart,
                        (S_IceStart + S_IceLength) * S_IceRegionEnd - (S_IceStart + S_IceLength) * S_IceRegionStart,
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
                        (S_IceStart + S_IceLength) * S_IceRegionStart,
                        (S_IceStart + S_IceLength) * S_IceRegionEnd - (S_IceStart + S_IceLength) * S_IceRegionStart,
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
                        (S_IceStart + S_IceLength) * S_IceRegionStart,
                        (S_IceStart + S_IceLength) * S_IceRegionEnd - (S_IceStart + S_IceLength) * S_IceRegionStart,
                        lines[1],
                        lines[2],
                        vec3(),
                        ApplyOpacityToColor(S_IceRegionDangerColor, appliedOpacity),
                        slip,
                        false,
                        appliedOpacity
                    );

                } else {
                    appliedOpacity = Math::Min(1.0f, 0.5f - relativePos);

                    RenderRegion(
                        visState,
                        (S_IceStart + S_IceLength) * S_IceRegionStart,
                        (S_IceStart + S_IceLength) * S_IceRegionEnd - (S_IceStart + S_IceLength) * S_IceRegionStart,
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

        void RenderIdealAngle(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel, const float slip) {
            float theta = -GetIdealAngle(speed);
            if (Math::Angle(vel, visState.Left) > HALF_PI or IsPreview()) {
                theta *= -1.0f;
            }

            RenderAngle(visState, Opacity(S_IceIdealAngleColor, slip, theta), theta);
        }

        void RenderRally(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel) {
            Surface::Render(visState, speed, vel, MIN, RALLY_PEAK, RALLY_ZERO, RALLY_SLIDEOUT, false);
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
            const float thetaStartInner = (thetaStart + diffFactor) * flip;
            const float thetaEndInner = (thetaEnd - diffFactor) * flip;

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
                _RenderRegion(visState, start, length, thetaStartInner, thetaEndInner, offset, fillColor, radialRoot);
                _RenderRegion(visState, start, length, thetaStart, thetaStartInner, offset, warnColor, radialRoot);
                _RenderRegion(visState, start, length, thetaEndInner, thetaEnd, offset, warnColor, radialRoot);
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

            const float anglePerPoint = flip * TWO_PI / 50.0f;
            const int points = int(diff / anglePerPoint);
            const nvg::Paint gradient = nvg::RadialGradient(radialRoot, S_IceGradientInnerDiameter, S_IceGradientOuterDiameter, fillColor, fillColorDark);

            for (int i = 0; i < points; i++) {
                nvg::BeginPath();
                nvg::MoveTo(Camera::ToScreenSpace(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (i * anglePerPoint)), offset)));
                LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + ((i + 1) * anglePerPoint)), offset));
                LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + ((i + 1) * anglePerPoint)), offset));
                LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + (i * anglePerPoint)), offset));
                LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (i * anglePerPoint)), offset));
                nvg::FillPaint(gradient);
                nvg::Fill();
                nvg::ClosePath();
            }

            nvg::BeginPath();
            nvg::MoveTo(Camera::ToScreenSpace(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (points * anglePerPoint)), offset)));
            LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaEnd), offset));
            LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaEnd), offset));
            LineTo(ProjectOffset(visState, ProjectAngle(visState, start + length, thetaStart + (points * anglePerPoint)), offset));
            LineTo(ProjectOffset(visState, ProjectAngle(visState, start, thetaStart + (points * anglePerPoint)), offset));
            nvg::FillPaint(gradient);
            nvg::Fill();
            nvg::ClosePath();
        }
    }

    namespace Other {
        const float BW_MIN = 15.0f;
        const float MIN    = 55.555555f;
    }

    namespace Plastic {
        const vec2[] BASE = {
            vec2(55.0f,  12.0f),
            vec2(91.6f,  17.65f),
            vec2(106.0f, 18.3f),
            vec2(120.0f, 23.8f),
            vec2(165.0f, 29.5f),
            vec2(275.0f, 36.0f)
        };

        const vec2[] IDEAL = {
            vec2(55.0f,  1.0f),
            vec2(99.5f,  1.0f),
            vec2(100.0f, 1.3f),
            vec2(142.0f, 1.3f),
            vec2(150.0f, 1.725f),
            vec2(184.5f, 1.725f),
            vec2(200.0f, 2.0f),
            vec2(250.0f, 2.0f)
        };

        const vec2[] ZERO = {
            vec2(55.0f,  12.5f),
            vec2(70.0f,  16.6f),
            vec2(94.5f,  20.4f),
            vec2(153.9f, 28.2f),
            vec2(230.4f, 35.85f),
            vec2(265.0f, 39.35f),
            vec2(250.0f, 33.33f),
            vec2(277.5f, 41.45f)
        };

        bool Is(const EPlugSurfaceMaterialId surface) {
            switch (surface) {
                case EPlugSurfaceMaterialId::Plastic:
                case EPlugSurfaceMaterialId::Rubber:  // found on edges of some plastic items, e.g., the mesh roof decor thing
                case EPlugSurfaceMaterialId::Water:  // ??? is this a good fit?
                    return true;
            }

            return false;
        }

        void Render(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel) {
            Surface::Render(visState, speed, vel, Other::MIN, IDEAL, BASE, ZERO);
        }

        void RenderBackwards(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel) {
            // just using grass ideals for plastic BW for now
            Surface::Grass::RenderBackwards(visState, speed, vel);
        }
    }

    namespace Road {
        const float MIN = 109.722222f;

        const vec2[] BASE = {
            vec2(111.0f,  6.6f),
            vec2(150.95f, 8.92f),
            vec2(244.0f,  13.8f),
            vec2(265.0f,  15.04f),
            vec2(277.5f,  15.75f)
        };

        const vec2[] BW_IDEAL = {
            vec2(0.0f,   3.5f),
            vec2(31.0f,  5.4f),
            vec2(40.0f,  8.0f),
            vec2(130.0f, 8.2f)
        };

        const vec2[] BW_ZERO = {
            vec2(0.0f,   8.0f),
            vec2(55.0f,  16.0f),
            vec2(85.0f,  20.0f),
            vec2(110.0f, 24.0f),
            vec2(130.0f, 26.0f)
        };

        const vec2[] IDEAL = {
            vec2(111.0f, 5.9f),
            vec2(140.0f, 5.6f),
            vec2(210.0f, 5.75f),
            vec2(232.0f, 5.75f),
            vec2(280.0f, 5.85f)
        };

        const vec2[] ZERO = {
            vec2(111.0f,   11.32f),
            vec2(112.64f,  11.938f),
            vec2(129.25f,  13.975f),
            vec2(145.5f,   15.7f),
            vec2(191.6f,   19.92f),
            vec2(220.0f,   22.0f),
            vec2(247.0f,   24.2f),
            vec2(264.425f, 25.905f),
            vec2(277.5f,   27.184f)
        };

        bool Is(const EPlugSurfaceMaterialId surface) {
            switch (surface) {
                case EPlugSurfaceMaterialId::Asphalt:
                case EPlugSurfaceMaterialId::Concrete:
                case EPlugSurfaceMaterialId::RoadSynthetic:
                case EPlugSurfaceMaterialId::TechMagnetic:
                case EPlugSurfaceMaterialId::TechSuperMagnetic:
                case EPlugSurfaceMaterialId::ResonantMetal:
                    return true;
            }

            return false;
        }

        void Render(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel) {
            Surface::Render(visState, speed, vel, MIN, IDEAL, BASE, ZERO);
        }

        void RenderBackwards(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel) {
            Surface::Render(visState, speed, vel, Other::BW_MIN, BW_IDEAL, {}, BW_ZERO);
        }
    }

    namespace Wood {
        const float MIN = 10.0f;

        const vec2[] P1 = {
            vec2(13.23f, 0.0792f),
            vec2(48.96f, 3.25f),
            vec2(55.32f, 4.23f),
            vec2(58.0f,  7.35f),
            vec2(116.0f, 8.6f),
            vec2(274.5f, 10.2f)
        };

        const vec2[] P2 = {
            vec2(11.3f,   7.3f),
            vec2(87.8f,   58.54f),
            vec2(136.86f, 90.68f),
            vec2(177.5f,  116.4f),
            vec2(276.6f,  159.9f)
        };

        const vec2[] VALLEY = {
            vec2(11.9f,   4.74f),
            vec2(26.0f,   10.21f),
            vec2(207.15f, 81.0f),
            vec2(277.8f,  108.3f)
        };

        const vec2[] WET_ICE_P1 = {
            vec2(13.23f, 0.0f),
            vec2(48.96f, 0.0f),
            vec2(55.32f, 0.0f),
            vec2(58.0f,  0.0f),
            vec2(116.0f, 0.0f),
            vec2(274.5f, 10.0f)
        };

        const vec2[] WET_ICE_P2 = {
            vec2(4.7f,   3.6f),
            vec2(78.74f, 56.52f),
            vec2(189.4f, 125.0f),
            vec2(253.8f, 157.6f),
            vec2(271.1f, 165.6f)
        };

        const vec2[] WET_ICE_VALLEY = {
            vec2(10.0f,  4.34f),
            vec2(400.0f, 173.986214f)
        };

        bool Is(const EPlugSurfaceMaterialId surface) {
            switch (surface) {
                case EPlugSurfaceMaterialId::SlidingWood:
                case EPlugSurfaceMaterialId::Wood:
                    return true;
            }

            return false;
        }

        void Render(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel) {
            Surface::Render(visState, speed, vel, MIN, P1, VALLEY, P2);
        }

        void RenderIcy(CSceneVehicleVisState@ visState, const float speed, const vec3&in vel) {
            Surface::Render(visState, speed, vel, MIN, WET_ICE_P1, WET_ICE_VALLEY, WET_ICE_P2, false);
        }
    }
}
