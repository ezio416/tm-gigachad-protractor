class GearStateManager {
    int     currentIndex        = 0;
    float   expectedRpm;
    float   expectedTrueRpm     = 0.0f;
    int     FRAMES_AVERAGED     = 100;
    float[] frameTimes(500);
    int     GEARDOWN_RPM_THRESH = 7500;
    int     GEARUP_RPM_THRESH   = 10000;
    float[] gearupScores(500);
    uint64  lastColorFetchTime  = 0;
    float   lastColorFetchScore = 0.0f;
    float   SCORE_MAX           = GEARUP_RPM_THRESH * 1.5f;

    vec2[] idealAngles = {
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

    int GetAndIncrementIdx() {
        const int r = currentIndex;
        frameTimes[r] = g_dt;
        currentIndex = (currentIndex + 1) % FRAMES_AVERAGED;

        if (currentIndex == 0) {
            float sum = 0.0f;
            for (int i = 0; i < FRAMES_AVERAGED; i++) {
                sum += frameTimes[i];
            }
            FRAMES_AVERAGED = int(S_MsAveraged / (sum / FRAMES_AVERAGED));
        }
        return r;
    }

    float GetExpectedRpm(const float inSpeed, const int inGear, const float inSlip, const bool checkSlip) {
        if (!checkSlip || !InSafeZone(inSlip, inSpeed)) {
            return inSpeed * GetExpectedRpmBySpeedMult(inGear);
        }
        return 0.0f;
    }

    float GetExpectedRpmBySpeedMult(const int inGear) {
        switch (inGear) {
            case 0:
                return -375.0f;
            case 1:
                return 425.0f;
            case 2:
                return 275.0f;  // 270 is from grass - different across surfaces?
            case 3:
                return 180.0f;
            case 4:
                return 125.0f;
            case 5:
                return 90.0f;
        }
        return 0.0f;
    }

    vec4 GetGeardownColor() {
        if (expectedTrueRpm < GEARDOWN_RPM_THRESH) {
            const float mult = GetGeardownMult();
            vec4 c = S_ColorUpshiftNormal;
            c.w *= mult;
            return c;
        }
        return vec4();
    }

    float GetGeardownMult() {
        return Math::Min(Math::InvLerp(GEARDOWN_RPM_THRESH, GEARDOWN_RPM_THRESH - 3000, int(expectedTrueRpm)), 1);
    }

    vec4 GetGearupColor() {
        if (expectedTrueRpm > GEARUP_RPM_THRESH) {
            const float mult = GetGearupMult();
            const float pos = GetGearupScore() / GetScoreMax();
            vec4 c = S_ColorUpshiftDanger * pos + S_ColorUpshiftNormal * (1 - pos);
            c.w *= mult;
            return c;
        }
        return vec4();
    }

    float GetGearupMult() {
        return Math::Min(Math::InvLerp(GEARUP_RPM_THRESH + 500, GEARUP_RPM_THRESH + 3000, int(expectedTrueRpm)), 1);;
    }

    float GetGearupScore() {
        if (Time::Now == lastColorFetchTime) {
            return lastColorFetchScore;
        }
        float s = 0.0f;
        for (int i = 0; i < FRAMES_AVERAGED; i++) {
            s += gearupScores[i];
        }
        lastColorFetchScore = Math::Min(s, GetScoreMax());
        lastColorFetchTime = Time::Now;
        return lastColorFetchScore;
    }

    float GetIdealAngle(const float speed) {
        return LerpToMidpoint(idealAngles, speed);
    }

    float GetScoreMax() {
        return SCORE_MAX * FRAMES_AVERAGED;
    }

    void HandleUpdate(const float inSlip, const float inSpeed, const int inGear) {
        const int idx = GetAndIncrementIdx();
        expectedRpm = GetExpectedRpm(inSpeed, inGear, inSlip, true);
        expectedTrueRpm = GetExpectedRpm(inSpeed, inGear, inSlip, false);

        gearupScores[idx] = Math::Min(expectedRpm, SCORE_MAX);
        RenderHud();
    }

    bool InSafeZone(float inSlip, const float inSpeed) {
        inSlip = Math::Abs(inSlip);
        if (inSlip >= LerpToMidpoint(Surface::Ice::GEARUP_1, inSpeed)) {
            return false;
        }
        if (inSlip >= LerpToMidpoint(Surface::Ice::GEARUP_2, inSpeed)) {
            return true;
        }
        if (inSlip >= LerpToMidpoint(Surface::Ice::GEARUP_3, inSpeed)) {
            return false;
        }
        if (inSlip >= LerpToMidpoint(Surface::Ice::GEARUP_4, inSpeed)) {
            return true;
        }
        return false;
    }

    void RenderHud() {
        if (!S_GearHUD) {
            return;
        }
        nvg::BeginPath();
        nvg::RoundedRect(S_GraphOffsetX, S_GraphOffsetY, S_GraphWidth, S_GraphHeight, S_BorderRadius);
        nvg::FillColor(S_ColorBackdrop);
        nvg::Fill();
        nvg::StrokeColor(S_ColorBorder);
        nvg::StrokeWidth(S_BorderWidth);
        nvg::Stroke();

        const float height = S_GraphHeight * GetGearupScore() / GetScoreMax();
        nvg::BeginPath();
        nvg::RoundedRect(S_GraphOffsetX, S_GraphOffsetY + (S_GraphHeight - height), S_GraphWidth, height, S_BorderRadius);
        nvg::FillColor(vec4(1.0f));
        nvg::Fill();
        nvg::StrokeColor(S_ColorBorder);
        nvg::StrokeWidth(S_BorderWidth);
        nvg::Stroke();
    }
}
