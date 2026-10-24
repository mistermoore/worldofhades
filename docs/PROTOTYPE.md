# Combat prototype decisions

The PRD is the product direction; this document records the first implemented slice.

## Decisions

- Fixed 1-second global cooldown; no automatic attacks or universal dodge.
- Basic Strike always generates Momentum. Cleave spends it; Charge is a free interrupt/reposition tool.
- Attacks face the selected target when activated. Cleave checks range and a frontal dot-product cone.
- Third-person orbit camera, camera-relative movement, bounded handcrafted arena.
- Space begins the encounter; P/Escape pauses. Enemy pressure is staggered at 0/10/18 seconds. No mandatory roles, account, preparation, or persistent power.
- Filled ground telegraphs match the actual frontal cone and ground-blast radius. Cast labels name the attack and response; a HUD banner identifies immediate danger. Lower incoming damage, longer windups, and 20 health on enemy defeat support first-time learning.
- Single-threaded web export avoids cross-origin isolation requirements. Browser testing uses Chromium software WebGL; it is not a representative hardware performance benchmark.
- Combat logic is separate from rendering but currently runs locally. This is not server-authoritative multiplayer.

## Validation commands

`./scripts/dev.sh test` runs the existing headless combat checks with explicit failure exit status. `./scripts/dev.sh build` produces the browser application. `./scripts/dev.sh serve` serves the output. The Godot scene can also be launched headlessly for startup checks.

## Follow-up playtests

Assess impact feedback, whether one-second input rhythm is satisfying, melee readability, first-time targeting, and whether interrupts versus movement create meaningful choices. Tune after human playtesting. Add skeletal animation and directional telegraph meshes before claiming combat polish. Establish hardware/browser FPS measurements and deploy a public browser build separately.

The cloud Chromium smoke test is `node tests/browser_smoke.cjs` with the HTTP server already running. It requires Playwright, Chromium at `/usr/bin/chromium`, and Tesseract; these are available in the prepared cloud environment. It checks rendered HUD text through screenshot OCR after starting, charging, striking, and resetting, and fails on browser runtime errors. Software rendering can advance the capped simulation more slowly than wall time; this check is functional, not a frame-rate measurement.

## Current validation result

Godot 4.6.3 headless combat suite: 19 passed, 0 failed. Web export completed without errors. Chromium WebGL 2 smoke test passed all five rendered-state checks (ready screen, Charge engagement, Strike Momentum generation, reset, pause), with no browser runtime errors. Installation/build instructions were rerun successfully with retained templates. No multiplayer, human combat-feel, or 60 FPS claim is made.
