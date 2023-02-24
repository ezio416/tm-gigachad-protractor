bool isIceSurface(EPlugSurfaceMaterialId surface) {
    return 
      surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Ice ||
      surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Concrete ||
      surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::RoadIce ||
      surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Snow;
}


bool isPlasticSurface(EPlugSurfaceMaterialId surface) {
<<<<<<< HEAD
  return 
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Plastic || 
    surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Rubber; // found on edges of some plastic items, e.g., the mesh roof decor thing
=======
  return surface == CSceneVehicleVisState::EPlugSurfaceMaterialId::Plastic;
>>>>>>> 7c045c4a0ba802ba17f54670ed928da119438bc9
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

  float sum = 
    getThetaMultForSurface(visState.FLGroundContactMaterial)
    + getThetaMultForSurface(visState.FRGroundContactMaterial)
    + getThetaMultForSurface(visState.RLGroundContactMaterial)
    + getThetaMultForSurface(visState.RRGroundContactMaterial);
  return sum / 4;

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
    return getPlayer().StartTime;
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
