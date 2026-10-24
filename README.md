# World of Hades — Combat Lab

First playable encounter for the [product requirements](docs/PRD.md). Godot 4.6.3, GDScript, Compatibility renderer, single-threaded WebAssembly export. No accounts or external assets required.

## Play

Open `project.godot` in Godot 4.6.3 and run the project, or build and serve the browser export:

```sh
scripts/dev.sh test
scripts/dev.sh build
scripts/dev.sh serve
```

The server listens on port 8000. Serve the exported folder over HTTP; opening the HTML directly does not work. WebGL 2 is required. Install matching Godot web export templates before building. Cloud paths for writable Godot data and caches are configured in `scripts/dev.sh`.

- Space: begin or resume. P or Escape: pause. Enemies wait while paused.
- WASD: camera-relative movement. Hold right mouse and drag: camera orbit. Scroll: zoom. C: reset camera.
- Tab: cycle living targets.
- 1 — Strike: 18 damage, generates 15 Momentum, 2.8m range.
- 2 — Cleave: 38 damage in a frontal cone, costs 30 Momentum, 4s cooldown.
- 3 — Charge: 12 damage, closes distance and interrupts, 13m range, 8s cooldown.
- R or Restart: return to the ready screen with a fresh encounter. All abilities trigger a 1s global cooldown.

The opening is staggered: Ashguard immediately, Ember Seer after 10 seconds, and Cinder Acolyte after 18 seconds. Each defeated enemy restores up to 20 health.

The Ashguard pursues and telegraphs a frontal attack with a filled cone: move outside it or behind the enemy. Enemy casts give at least 2.4 seconds to respond. A banner warns when you are standing in danger. Health/Momentum bars, target distance, floating damage/healing, and a hit flash show what is happening.

The Ember Seer marks your location before an area blast: leave the circle or interrupt. The Cinder Acolyte heals surviving enemies: prioritize or interrupt it. Clear all three to win; zero health ends the encounter.

## Architecture

`scripts/combat.gd` is a rendering-independent, command-driven simulation. Ability data, resource rules, targeting, enemy decisions, and outcome resolution live there. `scripts/arena.gd` owns input, procedural 3D scenery, camera, and HUD. Simulation tests run without a renderer.

Godot is selected over Bevy for this milestone because its integrated 3D editor, camera/UI tooling, and GDScript iteration favor a solo developer. Bevy offers stronger Rust/ECS foundations but requires more integration for this small first encounter. This prototype does not yet validate animation workflows or multiplayer latency; reconsider the choice if those tests expose constraints.

## Scope and next work

This is a solo, greybox combat prototype. Multiplayer, upgrades, complete dungeons, animation assets, audio, and performance targets remain unimplemented/unmeasured. Geometric characters deliberately keep the initial implementation independent of art assets. The next milestone should playtest combat feel, then introduce authoritative networking before expanding content.

See `docs/PROTOTYPE.md` for decisions and validation.

## Hosted demo

Play at **https://mistermoore.github.io/worldofhades/** in a desktop browser with WebGL 2.

Pushing to `main` runs `.github/workflows/pages.yml`: it installs checksum-verified Godot 4.6.3, runs combat tests, exports the release browser build, and deploys to GitHub Pages. The workflow can also be started manually from GitHub Actions. The public demo is solo only; no accounts or backend services are needed. Check the workflow's deployment result before expecting an update to appear.
