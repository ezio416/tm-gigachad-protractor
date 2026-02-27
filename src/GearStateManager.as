class GearStateManager {
    int current_idx;
    float[]@ gearup_scores;
    float[]@ frame_times;

    float expectedRpm;
    float expectedTrueRpm;

    int current_gear;

    int GEARUP_RPM_THRESH = 10000;
    int GEARDOWN_RPM_THRESH = 7500;

    int FRAMES_AVERAGED = 100;

    float SCORE_MAX = GEARUP_RPM_THRESH * 1.5;

    uint64 lastColorFetchTime = 0;
    float lastColorFetchScore = 0;

    GearStateManager() {
        current_idx = 0;
        @gearup_scores = array<float>(500, 0);
        @frame_times = array<float>(500, 0);
    }

    int GetAndIncrementIdx() {
        int r = current_idx;
        frame_times[r] = g_dt;
        current_idx = (current_idx + 1) % FRAMES_AVERAGED;

        if (current_idx == 0) {
            float sum = 0;
            for (int i = 0; i < FRAMES_AVERAGED; i++) {
                sum += frame_times[i];
            }
            FRAMES_AVERAGED = int(MILLISECONDS_AVERAGED / (sum / FRAMES_AVERAGED));
        }
        return r;
    }

    float GetExpectedRpm(float inSpeed, int inGear, float inSlip, bool checkSlip) {
        if (!checkSlip || !InSafeZone(inSlip, inSpeed)) {
            return inSpeed * GetExpectedRpmBySpeedMult(inGear);
        }
        return 0;
    }

    float GetExpectedRpmBySpeedMult(int inGear) {
        switch (inGear) {
            case 0:
                return -375;
            case 1:
                return 425;
            case 2:
                return 275;  // 270 is from grass - different across surfaces?
            case 3:
                return 180;
            case 4:
                return 125;
            case 5:
                return 90;
        }
        return 0;
    }

    vec4 GetGeardownColor() {
        if (expectedTrueRpm < GEARDOWN_RPM_THRESH) {
            float mult = GetGeardownMult();
            vec4 c = NORMAL_UPSHIFT;
            c.w *= mult;
            return c;
        }
        return vec4(0, 0, 0, 0);
    }

    float GetGeardownMult() {
        return Math::Min(Math::InvLerp(GEARDOWN_RPM_THRESH, GEARDOWN_RPM_THRESH - 3000, int(expectedTrueRpm)), 1);
    }

    vec4 GetGearupColor() {
        if (expectedTrueRpm > GEARUP_RPM_THRESH) {
            float mult = GetGearupMult();
            float pos = GetGearupScore() / GetScoreMax();
            vec4 c = DANGER_UPSHIFT * pos + NORMAL_UPSHIFT * (1 - pos);
            c.w *= mult;
            return c;
        }
        return vec4(0, 0, 0, 0);
    }

    float GetGearupMult() {
        return Math::Min(Math::InvLerp(GEARUP_RPM_THRESH + 500, GEARUP_RPM_THRESH + 3000, int(expectedTrueRpm)), 1);;
    }

    float GetGearupScore() {
        if (Time::Now == lastColorFetchTime) {
            return lastColorFetchScore;
        }
        float s = 0;
        for (int i = 0; i < FRAMES_AVERAGED; i++) {
            s += gearup_scores[i];
        }
        lastColorFetchScore = Math::Min(s, GetScoreMax());
        lastColorFetchTime = Time::Now;
        return lastColorFetchScore;
    }

    float GetIdealAngle(float speed) {
        return LerpToMidpoint(idealAngles, speed);
    }

    float GetScoreMax() {
        return SCORE_MAX * FRAMES_AVERAGED;
    }

    void HandleUpdate(float inSlip, float inSpeed, int inGear, float inEngineRpm) {
        int idx = GetAndIncrementIdx();
        expectedRpm = GetExpectedRpm(inSpeed, inGear, inSlip, true);
        expectedTrueRpm = GetExpectedRpm(inSpeed, inGear, inSlip, false);

        gearup_scores[idx] = Math::Min(expectedRpm, SCORE_MAX);
        RenderHud();
    }

    bool InSafeZone(float inSlip, float inSpeed) {
        inSlip = Math::Abs(inSlip);
        if (inSlip >= LerpToMidpoint(ice_gearup_1, inSpeed)) {
            return false;
        }
        if (inSlip >= LerpToMidpoint(ice_gearup_2, inSpeed)) {
            return true;
        }
        if (inSlip >= LerpToMidpoint(ice_gearup_3, inSpeed)) {
            return false;
        }
        if (inSlip >= LerpToMidpoint(ice_gearup_4, inSpeed)) {
            return true;
        }
        return false;
    }

    void RenderHud() {
        if (!RENDER_GEAR_HUD) {
            return;
        }
        nvg::BeginPath();
        nvg::RoundedRect(graph_x_offset, graph_y_offset, graph_width, graph_height, BorderRadius);
        nvg::FillColor(BackdropColor);
        nvg::Fill();
        nvg::StrokeColor(BorderColor);
        nvg::StrokeWidth(BorderWidth);
        nvg::Stroke();

        float height = graph_height * GetGearupScore() / GetScoreMax();
        nvg::BeginPath();
        nvg::RoundedRect(graph_x_offset, graph_y_offset + (graph_height - height), graph_width, height, BorderRadius);
        nvg::FillColor(vec4(1, 1, 1, 1));
        nvg::Fill();
        nvg::StrokeColor(BorderColor);
        nvg::StrokeWidth(BorderWidth);
        nvg::Stroke();
    }

    vec2[] idealAngles = {
        vec2(0, 1.47),
        vec2(40, 1.47),
        vec2(50, 1.4),
        vec2(57, 1.35),
        vec2(64, 1.3),
        vec2(70, 1.24),
        vec2(76, 1.2),
        vec2(84, 1.24),
        vec2(90, 1.25),
        vec2(100, 1.27),
        vec2(130, 1.35),
        vec2(150, 1.4)
    };
}
