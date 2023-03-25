bool isIceSurface(EPlugSurfaceMaterialId surface) {
    return 
      surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Ice ||
      surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Concrete ||
      surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::RoadIce ||
      surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Snow;
}


bool isPlasticSurface(EPlugSurfaceMaterialId surface) {
  return 
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Plastic || 
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Rubber ||  // found on edges of some plastic items, e.g., the mesh roof decor thing
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Water;  // ??? is this a good fit? 
}

bool isDirtSurface(EPlugSurfaceMaterialId surface) {
  return 
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Dirt ||
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::DirtRoad;
}

bool isTarmacSurface(EPlugSurfaceMaterialId surface) {
  return
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Concrete ||
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Asphalt ||
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::RoadSynthetic ||
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::TechMagnetic ||
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::TechSuperMagnetic || 
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::ResonantMetal;
}

bool isGrassSurface(EPlugSurfaceMaterialId surface) {
    return surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Grass ||
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Green;
}

bool isPlasticDirtOrGrass(EPlugSurfaceMaterialId surface) {
  return isPlasticSurface(surface) ||
    isDirtSurface(surface) ||
    isGrassSurface(surface);
}

bool isSupportedSurface(EPlugSurfaceMaterialId surface) {
  return isPlasticSurface(surface) ||
    isIceSurface(surface) ||
    isDirtSurface(surface) ||
    isGrassSurface(surface);
}

vec4 ApplyOpacityToColor(vec4 inColor, float opacity) {
  vec4 outColor = inColor;
  outColor.w = Math::Min(opacity, outColor.w);
  outColor.w = Math::Max(outColor.w, 0);

  return outColor;
}

float normalizeSlipAngle(float slipAngle, float frontSpeed) {
  int polarity;
  float ret;

  if (slipAngle < 0) {
    polarity = -1;
  } else {
    polarity = 1;
  }

  slipAngle = Math::Abs(slipAngle);

  if (frontSpeed < 0) {
    ret = 2 * HALF_PI - slipAngle;
  } else {
    ret = slipAngle;
  }
  return ret * polarity;
}


float calcVecAngle(vec3 vec1, vec3 vec2) {
  if (vec1.Length() == 0 || vec2.Length() == 0) {
    return 0;
  }
  float angle = Math::Acos(Math::Dot(vec1, vec2) / (vec1.Length() * vec2.Length())) - HALF_PI;
  return angle;
}


float getTargetThetaMultFactor(CSceneVehicleVisState@ visState) {
  if (visState.FLIcing01 > 0) {
    return 1;
  }

  if (visState.FrontSpeed < 0) {
    return BACKWARDS_TM;
  }

  if (SIMPLIFIED_VIEW) {
    return 1;
  }

  float sum = 
    getThetaMultForSurface(visState.FLGroundContactMaterial)
    + getThetaMultForSurface(visState.FRGroundContactMaterial)
    + getThetaMultForSurface(visState.RLGroundContactMaterial)
    + getThetaMultForSurface(visState.RRGroundContactMaterial);
  return sum / 4;

}

float getSlipTotal(CSceneVehicleVisState@ visState) {
    return visState.FLSlipCoef + visState.FRSlipCoef + visState.RLSlipCoef + visState.RRSlipCoef;
}

float getSideSpeedAngle(float vel, float target_sidespeed) {
    return Math::Asin(target_sidespeed / vel);
}

float getThetaMultForSurface(EPlugSurfaceMaterialId surface) {
  if (isIceSurface(surface)) {
    return 1;
  }
  if (isDirtSurface(surface)) {
    return DIRT_TM;
  }
  if (isTarmacSurface(surface)) {
    return TARMAC_TM;
  }
  if (isGrassSurface(surface)) {
    return GRASS_TM;
  }
  if (isPlasticSurface(surface)) {
    return PLASTIC_TM; 
  }
  return -1000;
}

CSmArenaClient@ getPlayground() {
    return cast < CSmArenaClient > (GetApp().CurrentPlayground);
}


int getPlayerStartTime() {
    if(getPlayer() !is null)
        return getPlayer().StartTime;
    else return 0;
}


CSmPlayer@ getPlayer() {
auto playground = getPlayground();
if (playground!is null) {
    if (playground.GameTerminals.Length > 0) {
        CGameTerminal @ terminal = cast < CGameTerminal > (playground.GameTerminals[0]);
        CSmPlayer @ player = cast < CSmPlayer > (terminal.GUIPlayer);
        if (player!is null) {
            return player;
        }   
    }
}
return null;
}

float lerpToMidpoint(array<vec2> points, float c) {
    vec2 lower = points[0];
    vec2 upper = points[1];

    for (int i = 1; i < points.Length - 1; i++) {
        if (points[i].x < c) {
            lower = points[i];
            upper = points[i + 1];
        } else {
            break;
        }
    }
    float pos = Math::InvLerp(lower.x, upper.x, c);
    return Math::Lerp(lower.y, upper.y, pos);
}

float approximateSideSpeed(const array<vec2> data, float speed) {
    vec2 lower = data[0];
    vec2 upper = data[data.Length - 1];
    for (uint i = 0; i < data.Length; i++) {
        vec2 entry = data[i];
        if (entry.x < speed && entry.x > lower.x) {
            lower = entry;
        }
        if (entry.x > speed && entry.x < upper.x) {
            upper = entry;
        }
    }
    float t = Math::InvLerp(lower.x, upper.x, speed);
    float interpolated = Math::Lerp(lower.y, upper.y, t);
    return interpolated;
}

vec4 getColor(int idx) {
    switch (idx) {
        case 0:
            return COLOR_100;
        case 1:
            return COLOR_90;
        case 2:
            return COLOR_50;
        case 3:
            return COLOR_0;
    }
    return COLOR_0;
}

bool isPreview() {
  return PREVIEW_DIRT || PREVIEW_GRASS || PREVIEW_ICE || PREVIEW_PLASTIC || PREVIEW_TARMAC;
}

float previewSlip(float in_slip) {
  if (isPreview()) {
    return PREVIEW_SLIP;
  } else {
    return in_slip;
  }
}