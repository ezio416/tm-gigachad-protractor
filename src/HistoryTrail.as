class HistoryTrail {
    HistoryTrail() { }

    HistoryTrailObject[] historyTrailArr(1000);

    int cur_idx = 0;
    uint64 lastUpdateTime;

    int CalcNext(const int offset) {
        return (cur_idx + HISTORY_POINTS + offset) % HISTORY_POINTS;
    }

    float CalculateOpacity() {
        // decide the overall fade of the whole trail based on whether or not the slide is all on the same side
        // e.g., if it's 100/0, 100% - 75/25, 50% - 50/50, 0%.
        float sum = 0.0f;
        HistoryTrailObject@ o;
        for (int i = 0; i < HISTORY_POINTS; i++) {
            o = historyTrailArr[CalcNext(i)];
            sum += o.slip;
        }
        return Math::Abs(sum) / HISTORY_POINTS;
    }

    HistoryTrailObject@ GetAtIdx(const int idx) {
        return historyTrailArr[CalcNext(-idx)];
    }

    void Update(const float slip, const vec4&in color) {
        const uint64 now = Time::Now;
        if (int(now - lastUpdateTime) > (HISTORY_SECONDS / float(HISTORY_POINTS)) * 1000) {
            historyTrailArr[cur_idx].Update(slip, color);
            cur_idx = CalcNext(1);
            lastUpdateTime = now;
        }
    }
}

class HistoryTrailObject {
    float slip;
    vec4 color;

    HistoryTrailObject() { }
    HistoryTrailObject(const float slip, const vec4&in color) {
        this.slip = slip;
        this.color = color;
    }

    void Update(const float slip, const vec4&in color) {
        this.slip = slip;
        this.color = color;
    }
}
