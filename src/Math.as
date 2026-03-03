const float TWO_PI     = Math::PI * 2.0f;
const float HALF_PI    = Math::PI * 0.5f;
const float THIRD_PI   = Math::PI / 3.0f;
const float QUARTER_PI = HALF_PI  * 0.5f;
const float SIXTH_PI   = THIRD_PI * 0.5f;

float ApproximateSideSpeed(const vec2[]&in data, const float speed) {
    if (data.Length == 0) {
        return 0.0f;
    }

    vec2 lower = data[0];
    vec2 upper = data[data.Length - 1];

    vec2 entry;
    for (uint i = 0; i < data.Length; i++) {
        entry = data[i];

        if (entry.x < speed and entry.x > lower.x) {
            lower = entry;
        }

        if (entry.x > speed and entry.x < upper.x) {
            upper = entry;
        }
    }

    return Math::Lerp(lower.y, upper.y, Math::InvLerp(lower.x, upper.x, speed));
}

float CalcAngle(const vec3&in v1, const vec3&in v2) {
    return IsPreview() ? S_PreviewSlip : Math::Angle(v1, v2);
}

float CalcVecAngle(const vec3&in v1, const vec3&in v2) {
    if (v1.Length() == 0.0f or v2.Length() == 0.0f) {
        return 0.0f;
    }

    return Math::Acos(Math::Dot(v1, v2) / (v1.Length() * v2.Length())) - HALF_PI;
}

float GetSideSpeedAngle(const float vel, const float target_sidespeed) {
    return Math::Asin(target_sidespeed / vel);
}

float LerpToMidpoint(const vec2[]&in points, const float c) {
    if (points.Length < 2) {
        return 0.0f;
    }

    vec2 lower = points[0];
    if (c < lower.x) {
        return lower.y;
    }

    vec2 upper = points[points.Length - 1];
    if (c > upper.x) {
        return upper.y;
    }

    upper = points[1];

    for (uint i = 1; i < points.Length - 1; i++) {
        if (points[i].x >= c) {
            break;
        }

        lower = points[i];
        upper = points[i + 1];
    }

    return Math::Lerp(lower.y, upper.y, Math::InvLerp(lower.x, upper.x, c));
}

float NormalizeSlipAngle(float slipAngle, const float frontSpeed) {
    const float polarity = slipAngle < 0.0f ? -1.0f : 1.0f;
    slipAngle = Math::Abs(slipAngle);
    return polarity * (frontSpeed < 0.0f ? Math::PI - slipAngle : slipAngle);
}
