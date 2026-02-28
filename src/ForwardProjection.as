class ForwardProjection {
    vec3[][] derivativeArrays;
    vec3[] prevs;

    int NUM_DERIVATIVES_MAX = 10;
    int NUM_SMOOTHING_MAX = 100;

    ForwardProjection() {
        for (int i = 0; i < NUM_DERIVATIVES_MAX; i++) {
            vec3[] arr(NUM_SMOOTHING_MAX);
            derivativeArrays.InsertLast(arr);
        }
    }

    int NUM_DERIVATIVES = 4;
    int SMOOTHING = 20;
    int NUM_POINTS = 10;
    int idx = 0;

    void AddValue(int d_idx, vec3 dx) {
        derivativeArrays[d_idx][idx] = dx;
    }

    vec3 GetDerivative(int d_idx) {
        vec3 r = 0.0f;
        for (int i = 0; i < SMOOTHING; i++) {
            r += derivativeArrays[d_idx][i];
        }
        return (r / SMOOTHING);
    }

    bool ShouldRender(CSceneVehicleVisState@ visState) {
        return
            NOODLEBOB_TARMAC && IsTarmacSurface(visState.FLGroundContactMaterial)
            || NOODLEBOB_GRASS && IsGrassSurface(visState.FLGroundContactMaterial)
            || NOODLEBOB_DIRT && IsDirtSurface(visState.FLGroundContactMaterial)
            || NOODLEBOB_PLASTIC && IsPlasticSurface(visState.FLGroundContactMaterial)
            || NOODLEBOB_ICE && IsIceSurface(visState.FLGroundContactMaterial);
    }

    void UpdateAndRender(CSceneVehicleVisState@ visState) {
        if (!ENABLE_NOODLEBOB || visState.WorldVel.LengthSquared() < 400.0f || !ShouldRender(visState)) {
            return;
        }
        vec3 v = visState.WorldVel * NOODLEBOB_SCALE;

        for (int i = 0; i < NUM_DERIVATIVES; i++) {
            AddValue(i, v);
            v = v - GetDerivative(i);
        }

        idx = (idx + 1) % SMOOTHING;
        vec3[] nexts;
        vec3[] vs(NUM_DERIVATIVES);

        for (int i = 0; i < NUM_DERIVATIVES; i++) {
            vs[i] = GetDerivative(i);
        }
        vec3 pos = visState.Position;
        for (int i = 0; i < NUM_NOODLEBOB_POINTS; i++) {
            pos += vs[0];
            nexts.InsertLast(pos);

            for (int j = 0; j < NUM_DERIVATIVES - 1; j++) {
                vs[j] += vs[j + 1];
            }
        }

        nvg::BeginPath();
        nvg::MoveTo(Camera::ToScreenSpace(nexts[NOODLEBOB_START_OFFSET]));
        for (uint i = NOODLEBOB_START_OFFSET + 1; i < nexts.Length; i++) {
            nvg::LineTo(Camera::ToScreenSpace(nexts[i]));
        }
        nvg::StrokeColor(NOODLEBOB_COLOR);
        nvg::StrokeWidth(NOODLEBOB_WIDTH);
        nvg::LineCap(nvg::LineCapType::Round);
        nvg::Stroke();
        nvg::ClosePath();
    }
}
