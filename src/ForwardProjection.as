class ForwardProjection {
    vec3[][] derivativeArrays;
    int      derivativesMax         = 10;
    int      idx                    = 0;
    int      noodlebobDerivateCount = 4;
    int      noodlebobSmoothing     = 20;
    int      pointCount             = 10;
    vec3[]   prevs;
    int      smoothingMax           = 100;

    ForwardProjection() {
        for (int i = 0; i < derivativesMax; i++) {
            vec3[] arr(smoothingMax);
            derivativeArrays.InsertLast(arr);
        }
    }

    void AddValue(const int d_idx, const vec3&in dx) {
        derivativeArrays[d_idx][idx] = dx;
    }

    vec3 GetDerivative(const int d_idx) {
        vec3 r = 0.0f;
        for (int i = 0; i < noodlebobSmoothing; i++) {
            r += derivativeArrays[d_idx][i];
        }
        return (r / noodlebobSmoothing);
    }

    bool ShouldRender(CSceneVehicleVisState@ visState) {
        return
            S_NoodlebobRoad && IsRoadSurface(visState.FLGroundContactMaterial)
            || S_NoodlebobGrass && IsGrassSurface(visState.FLGroundContactMaterial)
            || S_NoodlebobDirt && IsDirtSurface(visState.FLGroundContactMaterial)
            || S_NoodlebobPlastic && IsPlasticSurface(visState.FLGroundContactMaterial)
            || S_NoodlebobIce && IsIceSurface(visState.FLGroundContactMaterial);
    }

    void UpdateAndRender(CSceneVehicleVisState@ visState) {
        if (!S_Noodlebob || visState.WorldVel.LengthSquared() < 400.0f || !ShouldRender(visState)) {
            return;
        }
        vec3 v = visState.WorldVel * S_NoodlebobScale;

        for (int i = 0; i < noodlebobDerivateCount; i++) {
            AddValue(i, v);
            v = v - GetDerivative(i);
        }

        idx = (idx + 1) % noodlebobSmoothing;
        vec3[] nexts;
        vec3[] vs(noodlebobDerivateCount);

        for (int i = 0; i < noodlebobDerivateCount; i++) {
            vs[i] = GetDerivative(i);
        }
        vec3 pos = visState.Position;
        for (int i = 0; i < S_NoodlebobPoints; i++) {
            pos += vs[0];
            nexts.InsertLast(pos);

            for (int j = 0; j < noodlebobDerivateCount - 1; j++) {
                vs[j] += vs[j + 1];
            }
        }

        nvg::BeginPath();
        nvg::MoveTo(Camera::ToScreenSpace(nexts[S_NoodlebobOffsetStart]));
        for (uint i = S_NoodlebobOffsetStart + 1; i < nexts.Length; i++) {
            nvg::LineTo(Camera::ToScreenSpace(nexts[i]));
        }
        nvg::StrokeColor(S_NoodlebobColor);
        nvg::StrokeWidth(S_NoodlebobWidth);
        nvg::LineCap(nvg::LineCapType::Round);
        nvg::Stroke();
        nvg::ClosePath();
    }
}
