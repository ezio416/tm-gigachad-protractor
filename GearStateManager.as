class GearStateManager {
    int FRAMES_AVERAGED, GEARUP_RPM_THRESH, GEARDOWN_RPM_THRESH;
    float SCORE_MAX;

    int current_idx;
    array<float> gearup_scores();
    array<float> gearup_true_scores();
    array<float> geardown_scores(); 
    array<float> geardown_true_scores();

    float expectedRpm;
    float expectedTrueRpm;

    int current_gear;

    GearStateManager() {
        SCORE_MAX = 2000;
        FRAMES_AVERAGED = 5;
        GEARUP_RPM_THRESH = 10500;
        GEARDOWN_RPM_THRESH = 7500;

        current_idx = 0; 

        gearup_scores = array<float>(FRAMES_AVERAGED, 0);
        gearup_true_scores = array<float>(FRAMES_AVERAGED, 0);
        geardown_scores = array<float>(FRAMES_AVERAGED, 0);
        geardown_true_scores = array<float>(FRAMES_AVERAGED, 0);
    }

    /** 
     * This method doesn't *do* anything! 
     * It just watches in_gear to decide if a gear change was "expected" or not. 
     */
    void handleGearAnalysis(int in_gear, float in_slip) {
        in_slip = Math::Abs(in_slip);
        if (in_gear == current_gear) {
            return;
        }

        if (in_gear > current_gear) {
            if (getGearupTrueScore() > getScoreMax()) {
                print("Expected gearup");
            } else {
                if (in_slip < gearupUpperLimit() && in_slip > gearupLowerLimit()) {
                    print("Unexpected gearup! Gearup score:\t" + tostring(getGearupScore()) + "\tSlip:\t" + tostring(in_slip));
                } else {
                    print("Expeted gearup" + "\tSlip:\t" + tostring(in_slip));
                }
            }
        }
        current_gear = in_gear;
    }

    vec4 getGearupColor() {
        if (getGearupScore() > getScoreMax()) {
            float mult = Math::Min(getGearupScore(), getScoreMax() * 2) / getScoreMax() - 1;
            return NORMAL_UPSHIFT * (1 - mult) + DANGER_UPSHIFT * mult;
        } else {
            return NORMAL_UPSHIFT * (Math::Min(getGearupScore(), getScoreMax()) / getScoreMax());
        }
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

    vec4 getGeardownColorProjection() {
        if (getGeardownScore() > getScoreMax()) {
            float mult = Math::Min(getGeardownScore(), getScoreMax() * 2) / getScoreMax() - 1;
            return vec4(1, 1, 1, 1) - vec4(0, 0.7, .8, 0) * (mult);
        } else {
            vec4 c(1, 1, 1, 1);
            c.w = (Math::Min(getGeardownScore(), getScoreMax()) / getScoreMax());
            return c;
        }
    }

    float getScoreMax() {
        return SCORE_MAX * FRAMES_AVERAGED;
    }

    float getGearupScore() {
        float s = 0;
        for (int i = 0; i < FRAMES_AVERAGED; i++) {
            s += gearup_scores[i];
        }
        return s;
    }

    float getGearupTrueScore() {
        float s = 0;
        for (int i = 0; i < FRAMES_AVERAGED; i++) {
            s += gearup_true_scores[i];
        }
        return s;
    }

    
    float getGeardownScore() {
        float s = 0;
        for (int i = 0; i < FRAMES_AVERAGED; i++) {
            s += geardown_scores[i];
        }
        return s;
    }

    int getAndIncrementIdx() {
        int r = current_idx;
        current_idx = (current_idx + 1) % 5;
        return r;
    }

    void handleUpdate(float inSlip, float inSpeed, int inGear, float inEngineRpm) {
        int idx = getAndIncrementIdx();
        expectedRpm = getExpectedRpm(inSpeed, inGear, inSlip, false);
        expectedTrueRpm = getExpectedRpm(inSpeed, inGear, inSlip, true);
        
        if (expectedRpm > GEARUP_RPM_THRESH) {
            gearup_scores[idx] = Math::Max(expectedRpm, GEARUP_RPM_THRESH) - GEARUP_RPM_THRESH;
            gearup_true_scores[idx] = Math::Max(expectedTrueRpm, GEARUP_RPM_THRESH) - GEARUP_RPM_THRESH;
            geardown_scores[idx] = 0;
            geardown_true_scores[idx] = 0;

        } else if (expectedRpm < GEARDOWN_RPM_THRESH) {
            geardown_scores[idx] = GEARDOWN_RPM_THRESH - Math::Min(expectedRpm, GEARDOWN_RPM_THRESH);
            geardown_true_scores[idx] = GEARDOWN_RPM_THRESH - Math::Min(expectedTrueRpm, GEARDOWN_RPM_THRESH);
            gearup_scores[idx] = 0;
            gearup_true_scores[idx] = 0;
        } else {
            gearup_scores[idx] = 0;
            gearup_true_scores[idx] = 0;
            geardown_scores[idx] = 0;
            geardown_true_scores[idx] = 0;
        }

        // handleGearAnalysis(inGear, inSlip);

    }

    float gearupLowerLimit() {
        return 1.49;
    }

    float gearupUpperLimit() {
        return lerpToMidpoint(ice_gearup_upper, getGearupScore());
    }

    float geardownLowerLimit() {
        return HALF_PI;
    }

    array<float> getGearUpLines() {
        array<float> lines();
        lines.InsertLast(gearupLowerLimit()); 
        lines.InsertLast(gearupUpperLimit()); 
        return lines;
    }

    array<float> getGearDownLines() {
        array<float> lines();
        lines.InsertLast(geardownLowerLimit()); 
        return lines;
    }


    bool isInSlipWindow(float inSlip) {
        inSlip = Math::Abs(inSlip);
        if (inSlip <= gearupLowerLimit()) {
            return true;
        } else if (inSlip >= gearupUpperLimit()) {
            return true;
        }
        return false;
    }

    float getExpectedRpm(float inSpeed, int inGear, float inSlip, bool checkSlip) {
        if (!checkSlip || isInSlipWindow(inSlip)) {
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

    float lerpToMidpoint(array<vec2> points, float c) {
        vec2 lower = points[0];
        vec2 upper = points[1];

        for (int i = 1; i < points.Length - 1; i++) {
            if (points[i].x < c) {
                lower = points[i];
                upper = points[i + 1];
            } else {
                break;
            }
        }
        float pos = Math::InvLerp(lower.x, upper.x, c);
        return Math::Lerp(lower.y, upper.y, pos);
    }
}