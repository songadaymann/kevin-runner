# Kevin Runner Progress

This file is a running log of what we've built and learned while getting a Babylon.js endless runner prototype working (Kevin runs **toward the camera**). This is being built as a **music video game** - a game synced to a specific song.

## Current State (What Works)

### Core Gameplay
- Babylon scene runs from `index.html`
- Kevin is Mixamo-rigged and plays:
  - **Running** continuously
  - **Attack combos** (2 punches + 2 kicks) cycling on each tap/space press
  - Attack animations slowed down for better visual impact
- Front-facing runner camera: locked, fixed framing facing Kevin
- Kevin turns slightly when moving left/right (visual polish)
- Cryptopunk enemies spawn and run toward Kevin
- **Hitbox collision**: Kevin's punch/kick destroys punks on contact
- **Ragdoll physics**: Punks fly away with crazy spin, bouncing, and a chance to fly toward camera
- **Hit feedback**: Camera shake + screen flash on each hit
- Score counters: KILLS (punches) and HITS (enemies hitting Kevin)

### Visual Style - 80s Retro/Synthwave/Tron
- **Custom shader grid ground**: Glowing neon grid that scrolls infinitely
- **Tron shapes**: Glowing boxes, cylinders, toruses, arches, pyramids on the sides
- **Custom shader skybox**: Gradient with stars and horizon glow
- **Setting sun**: Classic 80s sun with scan lines behind Kevin
- **Multiple background types**:
  - City: Buildings with randomly lit blue/red windows
  - Hills: Wavy ribbon shapes (vector mountains)
  - Crystals: Glowing crystal formations
  - Pyramids: Geometric pyramid shapes
  - Spirals: Rotating torus knots
  - Minimal: Just the grid and shapes
- **Beat syncing**: Grid, glow, shapes, and windows pulse to 135 BPM (1/8th notes)
- **Dynamic color schemes**: Colors change per song section
- **CRT scanline overlay**: Post-process effect with vignette
- **Glitch effect**: Post-process glitch for the final chorus

### Song Timeline System
The game follows a 2:36 song with distinct sections:
1. **INTRO** (0-14s): Camera animation, text overlays, no enemies
2. **VERSE 1** (14-28s): City background, gradual enemy intro
3. **CHORUS 1** (28-42s): Hills background, faster spawns
4. **VERSE 2** (42-56s): Crystals background
5. **CHORUS 2** (56-71s): Pyramids background, intense
6. **BRIDGE** (71-101s): Spirals, close camera with swing, pink/green theme
7. **BREAKDOWN** (101-113s): Minimal, pulled back camera, few enemies
8. **FINAL CHORUS** (113-136s): Cycling backgrounds, max chaos, glitch effect
9. **OUTRO** (136-156s): Cycling colors, enemies fade out

### Intro Sequence
- "TAP TO START" overlay gates music playback
- Camera animates from close → far → gameplay position
- Text overlays introduce the game:
  - "This is Kevin." / "tap/space to punch"
  - "You might remember him." / "tap/space in a row for combos"
  - "He's back to get his revenge." / "kill as many cryptopunks as you can"
- Player movement disabled during intro
- First enemy spawn at ~15 seconds

## Controls

- **Move**: `A` / `D` or `←` / `→` (continuous left/right)
- **Punch/Kick**: `Space` or tap anywhere on canvas
- **Mobile**: Swipe/drag to move, tap to attack

## Files and Asset Layout

### Main Files
- `index.html` - Complete game (single file)
- `optimize-models.sh` - Script to decimate and compress GLB models

### Kevin Assets
- `assets/kevin/glb/kevin_mixamo_withskin_optimized.glb` - Main character model (optimized)
- `assets/kevin/glb/kevin_mixamo_running_anim.glb` - Running animation
- `assets/kevin/glb/kevin_mixamo_punch1_anim.glb` - Punch 1
- `assets/kevin/glb/kevin_mixamo_punch2_anim.glb` - Punch 2
- `assets/kevin/glb/kevin_mixamo_kick1_anim.glb` - Kick 1
- `assets/kevin/glb/kevin_mixamo_kick2_anim.glb` - Kick 2

### Cryptopunk Enemies
All in `assets/punks/[name]/` folders with `*_optimized.glb` versions:
- `alienPunk` - Green alien
- `beaniePunk` - Beanie wearing punk
- `greenPunk` - Green hair punk
- `hoodyPunk` - Hoodie punk
- `myPunk` - Original punk
- `zombiePunk` - Zombie punk

Each has running animation baked in.

### Audio
- `assets/sound/kevin.mp3` - The song (2:36)

## Technical Achievements

### Custom Shader Materials
- **Grid ground**: GLSL shader that draws major/minor grid lines with emissive glow, scrolls with time
- **Skybox**: GLSL shader that creates gradient background with stars and horizon glow
- Both integrate with GlowLayer for bloom effects

### Animation Retargeting
- Mixamo animations loaded from separate GLB files
- `buildAnimationGroupForSkeleton()` matches bone names and creates new AnimationGroup on Kevin's skeleton
- Upper-body masking for attack overlay (spine, arms, hands only)
- Attack animations cycle: punch1 → kick1 → punch2 → kick2 → repeat

### Fake Ragdoll Physics
- Punks enter "flying" mode on hit
- Manual physics simulation: velocity, angular velocity, gravity, damping
- Floor bouncing with velocity reduction
- Random chance to fly toward camera (comedy effect)
- Higher launch angles and more spin for exaggerated effect

### Model Optimization
Used `gltf-transform` CLI to reduce model sizes:
- Decimation: 50% polygon reduction
- Draco compression
- WebP texture compression
- Various cleanup passes (prune, weld, dedup, etc.)

Results:
- Punk models: 8-23MB → 1.2-2.2MB each
- Kevin: 19MB → 7.9MB

### Beat Syncing System
```javascript
const beatTime = 60 / BPM / 2; // 1/8th notes at 135 BPM
const beatPhase = (gameTime % beatTime) / beatTime;
const beatPulse = 1 + Math.sin(beatPhase * Math.PI * 2) * BEAT_PULSE_INTENSITY;
```
Applied to: grid emissive, shape emissive, window colors, glow layer intensity

### Rear Fog Effect
Objects (buildings, hills, shapes) fade out as they pass behind Kevin using visibility property animation.

## Configuration (debug_options)

Key configurable values in `debug_options`:
- `SCROLL_SPEED`: Ground scroll speed (12)
- `MOVE_SPEED_X`: Player movement speed (12)
- `ENEMY_SPEED`: Base punk run speed (8)
- `ENEMY_SCALE`: Punk size (3)
- `CAMERA_FREE_LOOK`: false (player has no camera control)
- `CRT_ENABLED`: true (scanline effect)
- `INTRO_ENABLED`: true (intro sequence)
- `MUSIC_ENABLED`: true
- `BPM`: 135
- `SONG_SECTIONS`: Full timeline array

## Lessons Learned

### Babylon.js Gotchas
- GLB models use `rotationQuaternion`, not `rotation.y` - use `Quaternion.FromEulerAngles()`
- `GlowLayer` doesn't work with `GridMaterial` - need custom shader with emissive output
- `camera.inputs.clear()` isn't enough to fully disable camera - also need `camera.detachControl()`
- Child meshes (like windows on buildings) need to be hidden/shown separately from parent

### Mixamo Pipeline
- Download "With Skin" for base model, "Without Skin" for animations
- Check "In Place" for locomotion animations
- Convert FBX to GLB with `assimp export input.fbx output.glb`
- Bone names are consistent across Mixamo models (`mixamorig:BoneName`)

### Performance
- Model optimization is crucial - raw Meshy/Mixamo exports are huge
- Keep enemy count reasonable per section (3-15 depending on intensity)
- Use visibility = 0 instead of disposing for recyclable objects

## What's Next

- [ ] Polish hit detection timing
- [ ] Add more enemy variety/behaviors
- [ ] Final audio sync adjustments
- [ ] Mobile touch controls polish
- [ ] Deploy to mann.cool/kevin

---
