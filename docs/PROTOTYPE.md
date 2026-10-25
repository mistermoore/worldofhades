# Combat prototype decisions

The PRD is the product direction; this document records the first implemented slice.

## Decisions

- Manual powers share a 1-second global cooldown; basic Strike and Charge are independent. Strike is automatic on the selected target in melee range. No universal dodge.
- Basic Strike always generates Momentum. Cleave spends it; Charge is a free interrupt/reposition tool.
- Attacks face the selected target when activated. Cleave checks range and a frontal dot-product cone.
- Third-person shoulder camera with mouse orbit, W/S forward/back, Q/E strafe, A/D turn, and a bounded handcrafted arena.
- Space begins the encounter; P/Escape pauses. Enemy pressure is staggered at 0/10/18 seconds. No mandatory roles, account, preparation, or persistent power.
- Filled ground telegraphs match the actual frontal cone and ground-blast radius. Cast labels name the attack and response; a HUD banner identifies immediate danger. Lower incoming damage, longer windups, and 8 health on enemy defeat support first-time learning.
- Single-threaded web export avoids cross-origin isolation requirements. Browser testing uses Chromium software WebGL; it is not a representative hardware performance benchmark.
- Combat logic is separate from rendering but currently runs locally. This is not server-authoritative multiplayer.

## Validation commands

`./scripts/dev.sh test` runs the existing headless combat checks with explicit failure exit status. `./scripts/dev.sh build` produces the browser application. `./scripts/dev.sh serve` serves the output. The Godot scene can also be launched headlessly for startup checks.

## Follow-up playtests

Assess impact feedback, whether one-second input rhythm is satisfying, melee readability, first-time targeting, and whether interrupts versus movement create meaningful choices. Tune after human playtesting. Add skeletal animation and directional telegraph meshes before claiming combat polish. Establish hardware/browser FPS measurements and deploy a public browser build separately.

The cloud Chromium smoke test is `node tests/browser_smoke.cjs` with the HTTP server already running. It requires Playwright, Chromium at `/usr/bin/chromium`, and Tesseract; these are available in the prepared cloud environment. It checks rendered HUD text through screenshot OCR after starting, charging, striking, and resetting, and fails on browser runtime errors. Software rendering can advance the capped simulation more slowly than wall time; this check is functional, not a frame-rate measurement.

## Current validation result

Godot 4.6.3 headless combat suite: 29 passed, 0 failed. Web export completed without errors. Chromium WebGL 2 smoke test passed all five rendered-state checks (ready screen, Charge engagement, Strike Momentum generation, reset, pause), with no browser runtime errors. Installation/build instructions were rerun successfully with retained templates. No multiplayer, human combat-feel, or 60 FPS claim is made.

## Mouse steering

Hold both mouse buttons to move forward relative to the camera while mouse movement steers it. Right-drag alone orbits without adding forward motion. Releasing either button stops mouse-driven movement; WASD remains available. Right-drag captures the pointer so the screen edge does not limit steering. Right-button release, pause, restart, focus loss, and encounter completion restore the cursor. `node tests/mouse_controls.cjs` checks mouse movement/release and pointer capture in Chromium against the running local server.

## Automatic basic attack

Strike automatically attacks the selected living enemy in melee range, at most once per second, generating Momentum. No activation key is needed. Changing targets arms Strike on the new target and clears queued manual actions; it does not reset the attack cadence. Out of range, it waits without chasing. After a kill, select another living enemy with Tab. Pause suspends simulation. Cleave and reward commands share the power cooldown; automatic Strike and Charge remain independent.

The combat suite checks automatic cadence, default activation, manual ability priority, target switching, range, and target death. `node tests/auto_attack.cjs` verifies Momentum generation without pressing 1, the new-target HUD state, and pause in Chromium.

## Keyboard movement and shoulder camera

W/S move forward/backward, Q/E strafe without changing facing, and A/D turn the character and camera together. Mouse steering remains available. The default camera is 7.5 metres back with a lower pitch, a right-shoulder offset, and a forward-looking aim point. Scroll adjusts distance; C and restart restore the default view. Headless movement tests exercise the actual key events, turn direction, position, strafe facing, pause, and shoulder placement. They run alongside combat tests locally and in the Pages build.

## Deployment freshness

GitHub Pages exports commit-specific JS, WASM and PCK filenames (`game-<sha>.*`). `scripts/prepare_web.py` checks that those assets exist, adds a visible build badge, and copies the generated HTML to the stable root index. This makes new HTML load new assets rather than reusing an earlier binary under the same filename. An already-open page must still reload; its build badge identifies the loaded version. The commit-specific HTML is also available for checking a particular deployment directly.

## Placeholder sword animation

Swords pivot at the grip through a short windup, downward slice, and recovery. Player Strike (including auto-Strike), Cleave, and Charge trigger the visual; Cleave has a longer swing. The Ashguard swings when its frontal attack resolves. Animation is presentation-only and does not change damage timing, range, or cooldowns. Pause freezes sword motion; restart returns weapons to rest.

## Two-encounter reward prototype

The first victory offers three mutually exclusive active abilities: Second Wind (self-heal), Lightning Bolt (ranged magic damage), or Rending Slash (physical hit with a non-stacking five-second bleed). The selected ability occupies key 4 and uses the Melee archetype's Momentum. It persists into a second encounter, which has 25% more enemy health. Selection restores up to 40 health, grants 30 Momentum, and resets cooldowns. The second victory completes the run; restart returns to Trial 1 with no reward.

The presentation adds healing pulses, a lightning bolt, bleed ticks/status, enemy healing beams and a blast orb/pulse. The bruiser raises its sword during its cast. Charge interrupts open a three-second +25% damage window, with a burst and EXPOSED status. Damage still resolves in the simulation independently of visual effects. These are initial playtest numbers.

Reward tests exercise unlock rules, resources, cooldowns, range, heal capping, bleed expiry/kills, interrupt vulnerability, all three reward buttons, slot 4 activation, and restart. The browser reward-screen check uses an isolated temporary copy that starts at victory; the shipped game has no victory shortcut.

Validation for the reward milestone: 29 combat + 12 movement + 35 reward checks passed (76 total). An isolated browser fixture verified all three reward cards, selection into Trial 2, and casting Lightning with key 4, with no runtime errors. Human playtesting is still needed for reward balance and encounter feel.

## Tactical iteration

The latest pass separates basic chip damage from infrequent heavy mechanics and prevents overlapping special casts. Basic hits are affordable pressure, not dodge failures. Automatic attacks no longer compete with manual powers for the shared cooldown; Charge can interrupt immediately. Enemies have more health so the encounter lasts long enough for these decisions to happen. Reward branches now provide short-term Guard, lightning primers/area detonations, or bleed/rupture finishers. See PLAYTEST.md for measured scenarios and human playtest goals.
