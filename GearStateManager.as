class GearStateManager {
    int current_idx;
    array<float>@ gearup_scores;
    array<float>@ frame_times;

    float expectedRpm;
    float expectedTrueRpm;

    int current_gear;

    int GEARUP_RPM_THRESH = 10000;
    int GEARDOWN_RPM_THRESH = 7500;

    int FRAMES_AVERAGED = 100;

    float SCORE_MAX = GEARUP_RPM_THRESH * 1.5;

    GearStateManager() {
        current_idx = 0; 
        @gearup_scores = array<float>(500, 0);
        @frame_times = array<float>(500, 0);
    }

    void renderHud() {
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

        float height = graph_height * getGearupScore() / getScoreMax();
        nvg::BeginPath();
        nvg::RoundedRect(graph_x_offset, graph_y_offset + (graph_height - height), graph_width, height, BorderRadius);
        nvg::FillColor(vec4(1, 1, 1, 1));
        nvg::Fill();
        nvg::StrokeColor(BorderColor);
        nvg::StrokeWidth(BorderWidth);
        nvg::Stroke();


    }

    vec4 getGearupColor() {
        if (expectedTrueRpm > GEARUP_RPM_THRESH) {
            float mult = Math::Min(Math::InvLerp(GEARUP_RPM_THRESH, GEARUP_RPM_THRESH + 3000, expectedTrueRpm), 1);
            vec4 c = NORMAL_UPSHIFT;
            c.w *= mult;
            return c;
        } return vec4(0, 0, 0, 0);
    }

    vec4 getGearupColorProjection() {
        if (getGearupScore() > getScoreMax()) {
            float mult = Math::Min(getGearupScore(), getScoreMax() * 2) / getScoreMax() - 1;
            return vec4(1, 1, 1, 1) - vec4(0, 0.7, .8, 0) * (mult);
        } else {
            vec4 c(1, 1, 1, 1);
            c.w = (Math::Min(getGearupScore(), getScoreMax()) / getScoreMax());
            return c;
        }
    }

    vec4 getGeardownColor() {
        if (expectedTrueRpm < GEARDOWN_RPM_THRESH) {
            float mult = Math::Max(Math::Lerp(GEARDOWN_RPM_THRESH, GEARDOWN_RPM_THRESH - 3000, expectedTrueRpm), 1);
            return NORMAL_UPSHIFT * mult;
        } return vec4(0, 0, 0, 0);
    }

    float getScoreMax() {
        return SCORE_MAX * FRAMES_AVERAGED;
    }

    float getGearupScore() {
        float s = 0;
        for (int i = 0; i < FRAMES_AVERAGED; i++) {
            s += gearup_scores[i];
        }
        return Math::Min(s, getScoreMax());
    }

    int getAndIncrementIdx() {
        int r = current_idx;
        frame_times[r] = g_dt;
        current_idx = (current_idx + 1) % FRAMES_AVERAGED;

        if (current_idx == 0) {
            float sum = 0; 
            for (int i = 0; i < FRAMES_AVERAGED; i++) {
                sum += frame_times[i];
            }
            FRAMES_AVERAGED = MILLISECONDS_AVERAGED / (sum / FRAMES_AVERAGED);
        }
        return r;
    }

    void handleUpdate(float inSlip, float inSpeed, int inGear, float inEngineRpm) {
        int idx = getAndIncrementIdx();
        expectedRpm = getExpectedRpm(inSpeed, inGear, inSlip, true);
        expectedTrueRpm = getExpectedRpm(inSpeed, inGear, inSlip, false);
        
        gearup_scores[idx] = Math::Min(expectedRpm, SCORE_MAX);
        renderHud();
    }

    float geardownLowerLimit() {
        return HALF_PI;
    }

    array<float> getGearDownLines() {
        array<float> lines();
        lines.InsertLast(geardownLowerLimit()); 
        return lines;
    }


    bool inSafeZone(float inSlip, float inSpeed) {
        inSlip = Math::Abs(inSlip);
        if (inSlip >= lerpToMidpoint(ice_gearup_1, inSpeed)) {
            return false;
        }
        if (inSlip >= lerpToMidpoint(ice_gearup_2, inSpeed)) {
            return true;
        }
        if (inSlip >= lerpToMidpoint(ice_gearup_3, inSpeed)) {
            return false;
        }
        if (inSlip >= lerpToMidpoint(ice_gearup_4, inSpeed)) {
            return true;
        }
        return false;
    }

    float getExpectedRpm(float inSpeed, int inGear, float inSlip, bool checkSlip) {
        if (!checkSlip || !inSafeZone(inSlip, inSpeed)) {
            return inSpeed * getExpectedRpmBySpeedMult(inGear);
        }
        return 0;
    }

    float getExpectedRpmBySpeedMult(int inGear) {
        switch (inGear) {
            case 0:
                return -375;
            case 1:
                return 425;
            case 2:
                return 275; // 270 is from grass - different across surfaces?
            case 3:
                return 180;
            case 4:
                return 125;
            case 5:
                return 90;
        }
        return 0;
    }

    array<vec2> idealAngles = {
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


    float getIdealAngle(float speed) {
        return lerpToMidpoint(idealAngles, speed);
    }


}