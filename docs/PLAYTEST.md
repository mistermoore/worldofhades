# Tactical combat iteration

## Pass 1: hold ground, respond to important mechanics

The prior encounter taught the player to move for virtually every damaging attack. That conflicted with the intended WoW-like rhythm. Basic hits now apply modest pressure without warning zones; heavy attacks demand an occasional interrupt or reposition. Only one enemy special can be telegraphed at once.

Automatic Strike and Charge no longer use the shared power global cooldown. This protects the player's ability to respond. Charge still has its own eight-second cooldown, so spending it to close a gap has an opportunity cost.

The first automated pacing check cleared the pack in 12.1 seconds before specials mattered. Increasing base enemy health to 300/200/180 and reducing on-kill recovery to 8 gave the encounter time to express its mechanics.

Deterministic trial-1 scenarios after tuning:

| Policy | Clear time | Health remaining | Basic damage | Heavy damage |
| --- | ---: | ---: | ---: | ---: |
| Approach targets, hold ground, spend Charge on travel | 25.1s | 104 | 26 | 54 |
| Approach targets, hold ground, reserve Charge for casts | 22.2s | 128 | 26 | 30 |

Both policies take normal hits and can win. The tactical policy loses less health and earns vulnerability windows. Neither bot dodges ground mechanics. They are repeatable sanity checks, not human difficulty or fun measurements.

## Pass 2: powers should create different decisions

ME3 multiplayer is a useful reference for powers that set up other powers and for distinct roles within a squad. This prototype adopts that interaction idea without adding shooter controls, equipment grinding, or multiplayer before it is implemented.

- **Second Wind:** 45 healing plus 18 Guard for six seconds. Guard absorbs damage first, creating a short window to hold ground. It refreshes rather than stacks.
- **Lightning Bolt:** primes an enemy for five seconds. Charge or Cleave consumes the primer for a 24-damage area tech burst within 3.5m. Use positioning to catch nearby enemies.
- **Rending Slash:** applies the existing bleed. Cleave consumes it for an immediate 26-damage rupture, trading future damage for a finisher now.

Deterministic trial-2 policies cleared with each reward: Second Wind in 30.1s with 22 damage absorbed; lightning in 20.1s with four combos; bleed in 22.1s with four ruptures. These agents make prescribed choices and are not an optimal-play or balance claim. Reward numbers remain playtest values.

## Human playtest goals

1. Can you hold your ground and accept ordinary hits without feeling punished?
2. Are heavy attacks infrequent and clear enough that responding feels deliberate?
3. Can you interrupt when you intend, without waiting for the basic attack?
4. Do Guard, tech bursts, and ruptures encourage different decisions?
5. Is spending Charge for movement versus saving it an interesting choice?

Keep the camera/control scheme stable during these tests. Watch for a reward that makes every other choice irrelevant, attacks that feel unavoidable despite correct responses, or a build that is functional but dull. The result line separates basic/heavy damage, interrupts, and combos to aid discussion.

Future cooperative tests should let one player prime and another detonate, and establish revive/role interactions before expanding equipment or persistent progression.

## Validation

`./scripts/dev.sh test` runs 31 combat, 12 movement, 35 reward, and 27 tactical checks (105 total). Tactical checks exercise basic versus special pressure, non-overlapping casts, independent basic/interrupt recovery, combo expiry/consumption/area damage, Guard absorption/expiry, and completion with every reward.
