bool isIceSurface(EPlugSurfaceMaterialId surface) {
  return (surface_override == "ice") || (surface_override == "") && 
    ICE_ENABLED && (surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Ice ||
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::RoadIce ||
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Snow);
}

bool isPlasticSurface(EPlugSurfaceMaterialId surface) {
  return (surface_override == "plastic") || (surface_override == "") && 
    PLASTIC_ENABLED && surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Plastic;
}

bool isDirtSurface(EPlugSurfaceMaterialId surface) {
  return (surface_override == "dirt") || (surface_override == "") && 
    DIRT_ENABLED && (surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Dirt ||
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::DirtRoad);
}

bool isTarmacSurface(EPlugSurfaceMaterialId surface) {
  return (surface_override == "tarmac") || (surface_override == "") && 
    (surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Concrete ||
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Asphalt ||
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::RoadSynthetic ||
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::TechMagnetic ||
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::TechSuperMagnetic);
}

bool isGrassSurface(EPlugSurfaceMaterialId surface) {
    return (surface_override == "grass") || (surface_override == "") && 
    GRASS_ENABLED && (surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Grass ||
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Green);
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

float normalizeAcc(float acc, CSceneVehicleVisState @ visState) {
  if (visState.WorldVel.LengthSquared() == 0) {
    return 0;
  }
  float carAngle = visState.WorldVel.y / visState.WorldVel.Length();
  if (ENABLE_GRAVITY) {
    if (carAngle == 0) {
      return acc;
    }
    return acc + (GRAVITY_VALUE / 100 * Math::Sin(carAngle * HALF_PI));
  }
  else {
    return acc;
  }
}

float calcVecAngle(vec3 vec1, vec3 vec2) {
  if (vec1.Length() <= 0 || vec2.Length() <= 0) {
    return 0;
  }
  float angle = Math::Acos(Math::Dot(vec1, vec2) / (vec1.Length() * vec2.Length())) - HALF_PI;
  return angle;
}

float apply_derivative(float target, float current, float start, float dx) {
  float base = Math::Abs((start - target)) / (2 ** (4 + TRANSITION_BASE_FACTOR));

    if (dx == 0) {
        if (current < target) {
            return base / (8);
        } else {
            return -base / (8);
        }
    }
    float mid_bound = (start + target) / 2;
    float next = dx + base;
    float prev = dx - base; 

      if (current < target) {
        if ((current + next) < mid_bound) {
          return next; 
        } else {
          return prev;
        }
      } else {
        if ((current + next) > mid_bound) {
          return prev;
        } else {
          return next;
        }
      }
  }

int getInvertSlip() {
  if (INVERT_SLIP) {
    return 1;
  } else {
    return -1;
  }
}

float calculateSlip(CSceneVehicleVisState@ visState) {
  vec3 aim = visState.Left;
  vec3 vel = visState.WorldVel;

  float slipAngle = calcVecAngle(aim, vel); 

  if (visState.FLIcing01 > 0 && isIceSurface(visState.FLGroundContactMaterial)) {
      slipAngle = normalizeSlipAngle(slipAngle, visState.FrontSpeed);
  }

  slipAngle *= getInvertSlip();
  return slipAngle;
}