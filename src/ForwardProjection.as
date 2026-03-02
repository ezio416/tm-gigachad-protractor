class ForwardProjection {
    uint     DERIVATIVES_MAX        = 10;
    uint     SMOOTHING_MAX          = 100;

    vec3[][] derivativeArrays(DERIVATIVES_MAX);
    int      index                  = 0;
    int      noodlebobDerivateCount = 4;
    int      noodlebobSmoothing     = 20;

    ForwardProjection() {
        for (uint i = 0; i < DERIVATIVES_MAX; i++) {
            derivativeArrays[i] = vec3[](SMOOTHING_MAX);
        }
    }

    void AddValue(const int dIndex, const vec3&in dx) {
        derivativeArrays[dIndex][index] = dx;
    }

    vec3 GetDerivative(const int d_idx) {
        vec3 r;
        for (int i = 0; i < noodlebobSmoothing; i++) {
            r += derivativeArrays[d_idx][i];
        }
        return (r / noodlebobSmoothing);
    }

    bool ShouldRender(const EPlugSurfaceMaterialId surface) {
        return false
            or (S_NoodlebobRoad    and IsRoadSurface(surface))
            or (S_NoodlebobDirt    and IsDirtSurface(surface))
            or (S_NoodlebobGrass   and IsGrassSurface(surface))
            or (S_NoodlebobPlastic and IsPlasticSurface(surface))
            or (S_NoodlebobIce     and IsIceSurface(surface))
        ;
    }

    void UpdateAndRender(CSceneVehicleVisState@ visState) {
        if (false
            or !S_Noodlebob
            or visState.WorldVel.LengthSquared() < 400.0f
            or !ShouldRender(visState.FLGroundContactMaterial)
        ) {
            return;
        }

        vec3 v = visState.WorldVel * S_NoodlebobScale;

        for (int i = 0; i < noodlebobDerivateCount; i++) {
            AddValue(i, v);
            v -= GetDerivative(i);
        }

        index = (index + 1) % noodlebobSmoothing;

        vec3[] nexts(S_NoodlebobPoints);
        vec3[] vs(noodlebobDerivateCount);

        for (int i = 0; i < noodlebobDerivateCount; i++) {
            vs[i] = GetDerivative(i);
        }

        vec3 pos = visState.Position;
        for (int i = 0; i < S_NoodlebobPoints; i++) {
            pos += vs[0];
            nexts[i] = pos;

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
