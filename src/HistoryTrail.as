class HistoryTrail {
    int                  currentIndex = 0;
    HistoryTrailObject[] historyTrailArr(1000);
    uint64               lastUpdateTime;

    int CalcNext(const int offset) {
        return (currentIndex + S_HistoryPoints + offset) % S_HistoryPoints;
    }

    float CalculateOpacity() {
        // decide the overall fade of the whole trail based on whether or not the slide is all on the same side
        // e.g., if it's 100/0, 100% - 75/25, 50% - 50/50, 0%.
        float sum = 0.0f;
        HistoryTrailObject@ o;
        for (int i = 0; i < S_HistoryPoints; i++) {
            o = historyTrailArr[CalcNext(i)];
            sum += o.slip;
        }
        return Math::Abs(sum) / S_HistoryPoints;
    }

    HistoryTrailObject@ GetAtIdx(const int idx) {
        return historyTrailArr[CalcNext(-idx)];
    }

    void Update(const float slip, const vec4&in color) {
        const uint64 now = Time::Now;
        if (int(now - lastUpdateTime) > (S_HistorySeconds / float(S_HistoryPoints)) * 1000) {
            historyTrailArr[currentIndex].Update(slip, color);
            currentIndex = CalcNext(1);
            lastUpdateTime = now;
        }
    }
}

class HistoryTrailObject {
    float slip;
    vec4  color;

    void Update(const float slip, const vec4&in color) {
        this.slip = slip;
        this.color = color;
    }
}
