class HistoryTrail {
    HistoryTrail() {}

    array<HistoryTrailObject> historyTrailArr(1000);

    int cur_idx = 0;
    uint64 lastUpdateTime;

    HistoryTrailObject@ getAtIdx(int idx) {
        return historyTrailArr[calcNext(-idx)]; 
    }

    void update(float slip, vec4 color) {
        uint64 now = Time::Now;
        print((HISTORY_SECONDS / float(HISTORY_POINTS)) * 1000);
        if ((now - lastUpdateTime) > (HISTORY_SECONDS / float(HISTORY_POINTS)) * 1000) {
            historyTrailArr[cur_idx].update(slip, color);
            cur_idx = calcNext(1);
            lastUpdateTime = now;
        }
    }

    int calcNext(int offset) {
        return (cur_idx + HISTORY_POINTS + offset) % HISTORY_POINTS; 
    }

    float calculateOpacity() {
        // decide the overall fade of the whole trail based on whether or not the slide is all on the same side 
        // e.g., if it's 100/0, 100% - 75/25, 50% - 50/50, 0%. 
        float sum;
        HistoryTrailObject@ o;
        for (int i = 0; i < HISTORY_POINTS; i++) {
            o = historyTrailArr[calcNext(i)];
            sum += o.slip;
        }
        return Math::Abs(sum) / HISTORY_POINTS;
    }

}

class HistoryTrailObject {
    float slip;
    vec4 color;

    HistoryTrailObject() {}
    HistoryTrailObject(float slip, vec4 color) {
        this.slip = slip;
        this.color = color;
    }

    void update(float slip, vec4 color) {
        this.slip = slip;
        this.color = color;
    }

}