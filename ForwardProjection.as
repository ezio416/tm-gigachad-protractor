class ForwardProjection {

    array<array<vec3>> derivativeArrays;
    array<vec3> prevs;
    
    int NUM_DERIVATIVES_MAX = 10;
    int NUM_SMOOTHING_MAX = 100;

    ForwardProjection() {
        for (int i = 0; i < NUM_DERIVATIVES_MAX; i++) {
            array<vec3> arr(NUM_SMOOTHING_MAX);
            derivativeArrays.InsertLast(arr);
        }
    }

    int NUM_DERIVATIVES = 4;
    int SMOOTHING = 20;
    int NUM_POINTS = 10;
    int idx = 0;

    vec3 getDerivative(int d_idx) {
        vec3 r = 0; 
        for (int i = 0; i < SMOOTHING; i++) {
            r += derivativeArrays[d_idx][i];
        }
        return (r / SMOOTHING);
    }

    void addValue(int d_idx, vec3 dx) {
        derivativeArrays[d_idx][idx] = dx;
    }

    bool shouldRender(CSceneVehicleVisState@ visState) {
        return 
            NOODLEBOB_TARMAC && isTarmacSurface(visState.FLGroundContactMaterial)
            || NOODLEBOB_GRASS && isGrassSurface(visState.FLGroundContactMaterial)
            || NOODLEBOB_DIRT && isDirtSurface(visState.FLGroundContactMaterial)
            || NOODLEBOB_PLASTIC && isPlasticSurface(visState.FLGroundContactMaterial)
            || NOODLEBOB_ICE && isIceSurface(visState.FLGroundContactMaterial);
    }

    void updateAndRender(CSceneVehicleVisState@ visState) {
        if (!ENABLE_NOODLEBOB || visState.WorldVel.LengthSquared() < (20 ** 2) || !shouldRender(visState)) {
            return;
        }
        vec3 v = visState.WorldVel * NOODLEBOB_SCALE;


        for (int i = 0; i < NUM_DERIVATIVES; i++) {
            addValue(i, v);
            v = v - getDerivative(i);
        }

        idx = (idx + 1) % SMOOTHING;
        array<vec3> nexts;
        array<vec3> vs(NUM_DERIVATIVES);

        for (int i = 0; i < NUM_DERIVATIVES; i++) {
            vs[i] = getDerivative(i);
        }
        vec3 pos = visState.Position;
        for (int i = 0; i < NUM_NOODLEBOB_POINTS; i++) {
            pos += vs[0];
            nexts.InsertLast(pos);

            for (int i = 0; i < NUM_DERIVATIVES - 1; i++) {
                vs[i] += vs[i + 1];
            }
        }

        nvg::BeginPath();
        nvg::MoveTo(Camera::ToScreenSpace(nexts[NOODLEBOB_START_OFFSET]));
        for (int i = NOODLEBOB_START_OFFSET + 1; i < nexts.Length; i++) {
            nvg::LineTo(Camera::ToScreenSpace(nexts[i]));
        }
        nvg::StrokeColor(NOODLEBOB_COLOR);
        nvg::StrokeWidth(NOODLEBOB_WIDTH);
        nvg::LineCap(nvg::LineCapType::Round);
        nvg::Stroke();
        nvg::ClosePath();
    }

    

}