const uint DERIVATIVES_MAX = 10;
const uint SMOOTHING_MAX   = 100;

vec3[][] derivativeArrays(DERIVATIVES_MAX);
int      forwardProjectionIndex = 0;

void AddValue(const int dIndex, const vec3&in dx) {
    derivativeArrays[dIndex][forwardProjectionIndex] = dx;
}

vec3 GetDerivative(const int d_idx) {
    vec3 r;
    for (int i = 0; i < S_NoodlebobSmoothing; i++) {
        r += derivativeArrays[d_idx][i];
    }

    return r / S_NoodlebobSmoothing;
}

bool ShouldRenderProjection(const EPlugSurfaceMaterialId surface) {
    return false
        or (S_NoodlebobRoad    and Surface::Road::Is(surface))
        or (S_NoodlebobDirt    and Surface::Dirt::Is(surface))
        or (S_NoodlebobGrass   and Surface::Grass::Is(surface))
        or (S_NoodlebobPlastic and Surface::Plastic::Is(surface))
        or (S_NoodlebobIce     and Surface::Ice::Is(surface))
    ;
}

void UpdateAndRenderProjection(CSceneVehicleVisState@ visState) {
    if (false
        or !S_Noodlebob
        or visState.WorldVel.LengthSquared() < 400.0f
        or !ShouldRenderProjection(visState.FLGroundContactMaterial)
    ) {
        return;
    }

    vec3 v = visState.WorldVel * S_NoodlebobScale;

    for (int i = 0; i < S_NoodlebobDerivateCount; i++) {
        AddValue(i, v);
        v -= GetDerivative(i);
    }

    forwardProjectionIndex = (forwardProjectionIndex + 1) % S_NoodlebobSmoothing;

    vec3[] nexts(S_NoodlebobPoints);
    vec3[] vs(S_NoodlebobDerivateCount);

    for (int i = 0; i < S_NoodlebobDerivateCount; i++) {
        vs[i] = GetDerivative(i);
    }

    vec3 pos = visState.Position;
    for (int i = 0; i < S_NoodlebobPoints; i++) {
        pos += vs[0];
        nexts[i] = pos;

        for (int j = 0; j < S_NoodlebobDerivateCount - 1; j++) {
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
