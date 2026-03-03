class HistoryTrail {
    int                  currentIndex   = 0;
    HistoryTrailObject[] historyTrailArr(1000);
    uint64               lastUpdateTime = 0;

    int CalcNext(const int offset) {
        return (currentIndex + S_HistoryPoints + offset) % S_HistoryPoints;
    }

    HistoryTrailObject@ GetAtIdx(const int idx) {
        return historyTrailArr[CalcNext(-idx)];
    }

    void Render(CSceneVehicleVisState@ visState, const float start, const float length) {
        if (S_Simplified and camera != CameraMode::External) {
            return;
        }

        float opacity, next_opacity, rel_fade, stroke_width, height_offset, next_rel_fade, next_height_offset, start_theta, end_theta;
        vec3 start_p, end_p, off;

        off.x += S_SimplifiedOffsetX;

        for (int i = (S_Simplified ? -1 : 1); i <= 1; i += 2) {
            off.z = i * S_SimplifiedOffsetZ;
            opacity = S_HistoryStartOpacity;

            for (int j = 1; j < S_HistoryPoints - 2; j++) {
                next_opacity = opacity * (1.0f - (1.0f / S_HistoryPoints)) ** S_HistoryDecayFactor;  //- (1 / (S_HistoryPoints * 10));

                rel_fade = Math::InvLerp(0.0f, S_HistoryStartOpacity, opacity);
                stroke_width = Math::Lerp(S_HistoryWidthMin, S_HistoryWidthMax, rel_fade);
                height_offset = Math::Lerp(S_HistoryStartHeight, S_HistoryEndHeight, rel_fade ** S_HistoryDistanceFactor);

                next_rel_fade = Math::InvLerp(0.0f, S_HistoryStartOpacity, next_opacity);
                next_height_offset = Math::Lerp(S_HistoryStartHeight, S_HistoryEndHeight, next_rel_fade ** S_HistoryDistanceFactor);

                start_theta = ProcessTheta(GetAtIdx(j).slip);
                end_theta = ProcessTheta(GetAtIdx(j + 1).slip);

                start_p = ProjectAngle(visState, height_offset + S_HistoryStartOffset + start + length, start_theta);
                end_p = ProjectAngle(visState, next_height_offset + S_HistoryStartOffset + start + length, end_theta);

                if (S_Simplified) {
                    start_p = ProjectOffset(visState, start_p, off);
                    end_p = ProjectOffset(visState, end_p, off);
                }

                if (Camera::IsBehind(start_p) or Camera::IsBehind(end_p)) {
                    continue;
                }

                nvg::BeginPath();
                nvg::MoveTo(Camera::ToScreenSpace(start_p));
                nvg::LineTo(Camera::ToScreenSpace(end_p));
                nvg::StrokeColor(ApplyOpacityToColor(GetAtIdx(j).color, playerFadeOpacity * opacity));
                nvg::StrokeWidth(stroke_width / (start_p - Camera::GetCurrentPosition()).Length() * S_HistoryPerspectiveConstant);
                nvg::LineCap(nvg::LineCapType::Round);
                nvg::Stroke();
                nvg::ClosePath();

                opacity = next_opacity;
            }
        }
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
