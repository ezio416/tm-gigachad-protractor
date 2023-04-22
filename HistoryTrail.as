class HistoryTrail {
    HistoryTrail() {}

    array<HistoryTrailObject> historyTrailArr(1000);

    int cur_idx = 0;
    // HISTORY_MAX is a user-configurable setting. 

    HistoryTrailObject@ getAtIdx(int idx) {
        return historyTrailArr[calcNext(-idx)]; 
    }

    void update(float slip, vec4 color) {
        historyTrailArr[cur_idx].update(slip, color);
        cur_idx = calcNext(1);
    }

    int calcNext(int offset) {
        return (cur_idx + HISTORY_MAX + offset) % HISTORY_MAX; 
    }

    float calculateOpacity() {
        // decide the overall fade of the whole trail based on whether or not the slide is all on the same side 
        // e.g., if it's 100/0, 100% - 75/25, 50% - 50/50, 0%. 
        float sum;
        HistoryTrailObject@ o;
        for (int i = 0; i < HISTORY_MAX; i++) {
            o = historyTrailArr[calcNext(i)];
            sum += o.slip;
        }
        return Math::Abs(sum) / HISTORY_MAX;
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