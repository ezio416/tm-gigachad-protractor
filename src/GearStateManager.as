class GearStateManager {
    int     currentIndex        = 0;
    float   expectedRpm;
    float   expectedTrueRpm     = 0.0f;
    int     framesAveraged      = 100;
    float[] frameTimes(500);
    float[] gearupScores(500);
    uint64  lastColorFetchTime  = 0;
    float   lastColorFetchScore = 0.0f;

    int GetAndIncrementIdx() {
        const int ret = currentIndex;
        frameTimes[ret] = g_dt;
        currentIndex = (currentIndex + 1) % framesAveraged;

        if (currentIndex == 0) {
            float sum = 0.0f;
            for (int i = 0; i < framesAveraged; i++) {
                sum += frameTimes[i];
            }

            framesAveraged = int(S_MsAveraged / (sum / framesAveraged));
        }

        return ret;
    }

    float GetGearupScore() {
        if (Time::Now == lastColorFetchTime) {
            return lastColorFetchScore;
        }

        float score = 0.0f;
        for (int i = 0; i < framesAveraged; i++) {
            score += gearupScores[i];
        }

        lastColorFetchScore = Math::Min(score, GetScoreMax());
        lastColorFetchTime = Time::Now;

        return lastColorFetchScore;
    }

    float GetScoreMax() {
        return SCORE_MAX * framesAveraged;
    }

    void HandleUpdate(const float inSlip, const float inSpeed, const int inGear) {
        const int idx = GetAndIncrementIdx();
        expectedRpm = GetExpectedRpm(inSpeed, inGear, inSlip, true);
        expectedTrueRpm = GetExpectedRpm(inSpeed, inGear, inSlip, false);

        gearupScores[idx] = Math::Min(expectedRpm, SCORE_MAX);
        RenderHud();
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

const uint  GEARDOWN_RPM_THRESH = 7500;
const uint  GEARUP_RPM_THRESH   = 10000;
const float SCORE_MAX           = 15000.0f;

float GetExpectedRpm(const float inSpeed, const int inGear, const float inSlip, const bool checkSlip) {
    if (!checkSlip or !Surface::Ice::InSafeZone(inSlip, inSpeed)) {
        return inSpeed * GetExpectedRpmBySpeedMult(inGear);
    }

    return 0.0f;
}

float GetExpectedRpmBySpeedMult(const int inGear) {
    switch (inGear) {
        case 0: return -375.0f;
        case 1: return 425.0f;
        case 2: return 275.0f;  // 270 is from grass - different across surfaces?
        case 3: return 180.0f;
        case 4: return 125.0f;
        case 5: return 90.0f;
    }

    return 0.0f;
}
