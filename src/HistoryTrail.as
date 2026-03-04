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

        float opacity, nextOpacity, relFade, strokeWidth, heightOffset, nextRelFade, nextHeightOffset, startTheta, endTheta;
        vec3 startPoint, endPoint, off;

        off.x += S_SimplifiedOffsetX;

        for (int i = (S_Simplified ? -1 : 1); i <= 1; i += 2) {
            off.z = i * S_SimplifiedOffsetZ;
            opacity = S_HistoryStartOpacity;

            for (int j = 1; j < S_HistoryPoints - 2; j++) {
                nextOpacity = opacity * (1.0f - (1.0f / S_HistoryPoints)) ** S_HistoryDecayFactor;  //- (1 / (S_HistoryPoints * 10));

                relFade = Math::InvLerp(0.0f, S_HistoryStartOpacity, opacity);
                strokeWidth = Math::Lerp(S_HistoryWidthMin, S_HistoryWidthMax, relFade);
                heightOffset = Math::Lerp(S_HistoryStartHeight, S_HistoryEndHeight, relFade ** S_HistoryDistanceFactor);

                nextRelFade = Math::InvLerp(0.0f, S_HistoryStartOpacity, nextOpacity);
                nextHeightOffset = Math::Lerp(S_HistoryStartHeight, S_HistoryEndHeight, nextRelFade ** S_HistoryDistanceFactor);

                startTheta = ProcessTheta(GetAtIdx(j).slip);
                endTheta = ProcessTheta(GetAtIdx(j + 1).slip);

                startPoint = ProjectAngle(visState, heightOffset + S_HistoryStartOffset + start + length, startTheta);
                endPoint = ProjectAngle(visState, nextHeightOffset + S_HistoryStartOffset + start + length, endTheta);

                if (S_Simplified) {
                    startPoint = ProjectOffset(visState, startPoint, off);
                    endPoint = ProjectOffset(visState, endPoint, off);
                }

                if (Camera::IsBehind(startPoint) or Camera::IsBehind(endPoint)) {
                    continue;
                }

                nvg::BeginPath();
                nvg::MoveTo(Camera::ToScreenSpace(startPoint));
                nvg::LineTo(Camera::ToScreenSpace(endPoint));
                nvg::StrokeColor(ApplyOpacityToColor(GetAtIdx(j).color, playerFadeOpacity * opacity));
                nvg::StrokeWidth(strokeWidth / (startPoint - Camera::GetCurrentPosition()).Length() * 30.0f);
                nvg::LineCap(nvg::LineCapType::Round);
                nvg::Stroke();
                nvg::ClosePath();

                opacity = nextOpacity;
            }
        }
    }

    void Update(const float slip, const vec4&in color) {
        const uint64 now = Time::Now;

        if (int(now - lastUpdateTime) > (S_HistorySeconds / float(S_HistoryPoints)) * 1000.0f) {
            historyTrailArr[currentIndex].Update(slip, color);
            currentIndex = CalcNext(1);
            lastUpdateTime = now;
        }
    }
}

class HistoryTrailObject {
    vec4  color;
    float slip;

    void Update(const float slip, const vec4&in color) {
        this.slip = slip;
        this.color = color;
    }
}
