Product Requirements Document

Project: Untitled Cooperative Dungeon Roguelite

Version: 0.1
Status: Initial product definition
Platform: Desktop web browser
Technology direction: WebAssembly-compatible 3D engine
Game type: Third-person cooperative dungeon roguelite
Players: 1–4

⸻

1. Product Vision

Create a cooperative multiplayer roguelite that captures the tactical combat, character-building, and social experience of World of Warcraft dungeons without requiring the ongoing time commitment of an MMORPG.

Players begin each run with a simple combat archetype—Melee, Ranged, or Magic—and develop increasingly specialized characters through upgrades earned during dungeon encounters.

Each run presents a distinct combination of abilities, synergies, enemies, and tactical challenges.

The intended experience is the best 40 minutes of a WoW dungeon, with the build experimentation of Hades, playable with friends on a Tuesday night.

Core product promise

Four friends should be able to open their browsers, form a party, complete two satisfying dungeon runs, and finish within 90 minutes.

No mandatory preparation, grinding, or persistent power disadvantage should prevent an infrequent player from participating.

2. Product Goals

Primary goals

G1. Deliver satisfying tactical combat

Combat should reward ability selection, resource management, positioning, target prioritization, and group coordination without requiring constant reflex-based dodging.

G2. Enable emergent character builds

Players should develop recognizable and mechanically distinct specializations through choices made during gameplay.

G3. Create meaningful cooperative gameplay

Players should benefit from coordinating abilities, positioning, interrupts, defensive capabilities, and complementary builds.

G4. Respect player time

A complete dungeon run should take approximately 30–45 minutes, including upgrade selection.

G5. Maximize replayability

Randomized encounters, upgrade combinations, and emergent party compositions should make repeated runs meaningfully different.

G6. Minimize barriers to participation

Players should be able to join friends without installing software, maintaining a character, or completing prerequisite content.

Non-goals

The initial product will not attempt to provide:

* A persistent open world.
* Traditional MMO leveling.
* Persistent item-level progression.
* Large-scale multiplayer encounters.
* Competitive PvP.
* A player economy.
* Extensive crafting systems.
* Dozens of predefined classes.
* Photorealistic graphics.
* Mobile-first gameplay.

3. Target Audience and Use Cases

Primary audience

Players who enjoy MMORPG dungeon combat but cannot or do not want to maintain a regular MMO commitment.

Particularly:

* Former or casual WoW players.
* Small groups of friends with limited gaming time.
* Players who enjoy character builds and theorycrafting.
* Roguelite players interested in cooperative gameplay.

Primary use case

Four friends have approximately 90 minutes available to play together.

They open the game, join a party, select starting archetypes, and enter a dungeon.

Over the course of the run, their characters evolve through upgrades. The group adapts its tactics to the capabilities it develops.

After completing or failing the dungeon, players can immediately begin another run with different builds.

Secondary use cases

Solo play: A player completes a scaled dungeon independently.

Two-player cooperative play: Two friends develop complementary builds without requiring specific roles.

Experimental play: A player deliberately explores unusual combinations of abilities and mechanics.

High-difficulty play: Experienced groups attempt more challenging encounters using their accumulated game knowledge.

4. Core Gameplay Loop

The primary gameplay loop is:

1. Form a party.
2. Select a starting archetype.
3. Enter a dungeon.
4. Complete an encounter.
5. Receive and select an upgrade.
6. Adapt the character build and party strategy.
7. Complete increasingly difficult encounters.
8. Defeat the final boss or fail the run.
9. Review results and optionally begin another run.

Run duration

Target: 35–40 minutes
Acceptable range: 30–45 minutes

Session duration

Target: Two runs within 90 minutes, including party setup and intermission.

Run structure

The initial design uses three acts.

Stage	Approximate duration	Purpose
Setup	1 minute	Select archetype
Act I	8–10 minutes	Establish build direction
Act II	10–12 minutes	Develop synergies
Act III	12–15 minutes	Exploit mature build
Final boss	4–5 minutes	Test build and coordination

Timing includes ordinary encounters, upgrade decisions, and act bosses.

The run should contain approximately 8–12 meaningful upgrade decisions.

Players should establish a recognizable build within the first 10 minutes and have sufficient time to enjoy their mature build before the final encounter.

5. Combat System

5.1 Combat philosophy

Combat is primarily tactical rather than reflex-driven.

The game should preserve the decision-making depth of WoW while increasing the importance of positioning and movement.

Players should continuously evaluate:

* Which enemy to target.
* Which ability to use.
* Where to position themselves.
* Whether to interrupt or control an enemy.
* How to coordinate with teammates.
* When to use defensive or offensive cooldowns.

The optimal strategy should rarely be to remain stationary and execute an identical rotation indefinitely.

5.2 Combat controls

Property	Initial specification
Camera	Third-person, behind character
Movement	WASD
Camera control	Mouse
Targeting	Tab targeting
Abilities	Keyboard hotkeys
Global cooldown	Approximately 1 second
Active ability slots	6–8 maximum
Auto-attacks	Disabled initially
Basic attacks	Active abilities
Universal dodge roll	None
Movement abilities	Archetype/build-specific
Enemy attack avoidance	Positioning and movement

The global cooldown, ability count, and absence of auto-attacks are prototype assumptions requiring playtesting.

5.3 Positioning

Positioning should matter throughout ordinary encounters, not only during boss mechanics.

Supported mechanics should include:

Directional attacks: Abilities with frontal cones, line attacks, and area effects.

Flanking: Bonuses or secondary effects based on attacking from advantageous positions.

Enemy formations: Encounters that reward grouping, separating, or repositioning enemies.

Line of sight: Terrain and obstacles affecting ranged attacks and spells.

Area denial: Persistent environmental hazards or enemy effects that influence movement.

Range management: Meaningful differences between melee, ranged, and magic combat.

Movement should generally involve deliberate repositioning rather than constant evasive maneuvers.

5.4 Ability system

Abilities should be implemented using composable mechanics.

An ability may contain:

* Targeting rules.
* Resource costs.
* Cooldowns.
* Damage or healing effects.
* Status effects.
* Movement effects.
* Threat modifications.
* Event triggers.
* Conditional modifiers.

The system must support upgrades that modify existing abilities without requiring entirely new implementations.

Example:

Base ability: Cleave

* Deals damage to enemies in a frontal cone.

Upgrade: Gathering Force

* Cleave pulls affected enemies toward the player.

Upgrade: Burning Edge

* Cleave applies burning damage.

Upgrade: Combustion

* Enemies killed while burning explode.

These effects should compose predictably.

5.5 Auto-attacks

The initial prototype will not include automatic attacks.

Basic attacks will be explicitly activated and may generate resources or trigger other effects.

This decision will be evaluated against:

* Combat responsiveness.
* Input frequency.
* Rotation satisfaction.
* Animation quality.
* Perceived downtime.

Auto-attacks may be introduced if they improve combat rhythm without reducing meaningful player decisions.

6. Starting Archetypes

Players select one of three archetypes at the beginning of each run.

Archetypes establish the character’s fundamental combat mechanics but do not determine a fixed class or specialization.

6.1 Melee

Identity: Close-range combat, momentum, durability, and engagement control.

Core resource: Momentum.

Starting capabilities:

* Basic melee attack.
* Resource-consuming heavy attack.
* Engagement or repositioning ability.

Potential specializations:

* Defensive tank.
* Berserker.
* Assassin.
* Elemental bruiser.
* Melee support.

6.2 Ranged

Identity: Physical ranged damage, precision, positioning, and sustained pressure.

Core resource: Focus.

Starting capabilities:

* Basic ranged attack.
* Resource-consuming precision attack.
* Repositioning ability.

Potential specializations:

* Archer.
* Gunslinger.
* Trapper.
* Beastmaster.
* Ranged support.

6.3 Magic

Identity: Spellcasting, resource management, area control, and magical utility.

Core resource: Arcane energy.

Starting capabilities:

* Basic offensive spell.
* Resource-consuming powerful spell.
* Repositioning or defensive spell.

Potential specializations:

* Elementalist.
* Healer.
* Summoner.
* Control mage.
* Spellblade.

6.4 Archetype design requirements

AR-01: Each archetype must remain mechanically distinct throughout a run.

AR-02: Every archetype must have a viable baseline damage capability.

AR-03: Every archetype must support multiple specialization paths.

AR-04: Cross-archetype upgrades must be possible.

AR-05: Cross-archetype upgrades should integrate with the character’s existing resource system wherever practical.

AR-06: Starting archetype selection must not permanently restrict the player to a traditional tank, healer, or DPS role.

7. Emergent Build System

7.1 Design philosophy

Character specialization emerges through upgrades acquired during gameplay.

Players do not select a predefined class specialization at the beginning of a run.

The upgrade system should produce recognizable character fantasies through combinations of abilities and modifiers.

Core principle: Every build should be functional, most should be viable, and some should be spectacular.

7.2 Upgrade categories

Foundation upgrades

Introduce new capabilities or mechanics.

Examples:

* Shield mastery.
* Fire magic.
* Summoning.
* Healing.
* Poison.
* Stealth.

Synergy upgrades

Strengthen or connect existing mechanics.

Examples:

* Critical hits restore resources.
* Burning enemies take increased melee damage.
* Blocking generates momentum.
* Healing an ally increases their damage.

Transformation upgrades

Fundamentally change an ability’s behavior.

Examples:

* Chain Lightning becomes a chain heal.
* Charge creates a shockwave.
* Shield Block reflects damage.
* Summoned creatures inherit the player’s status effects.

Transformation upgrades should create especially noticeable changes in gameplay.

7.3 Upgrade selection

At major reward points, players receive three upgrade choices.

The initial proposed selection model provides:

1. Synergy: Reinforces existing build mechanics.
2. Expansion: Introduces a compatible new capability.
3. Wildcard: Offers an unusual or transformative option.

The system should avoid offering upgrades that are unusable or mechanically incompatible with the current character.

7.4 Build gravity

Every upgrade is associated with descriptive tags.

Example:

Shield Mastery

* Melee
* Defense
* Block
* Threat

Flame Aura

* Magic
* Fire
* Area Damage

Combustion

* Fire
* Explosion
* Damage

Existing upgrades influence the probability of future upgrade offers.

Players investing in fire mechanics should become more likely to encounter compatible fire upgrades.

However, unrelated upgrades must remain possible to encourage experimentation.

Requirements

BG-01: Upgrade offers must consider the player’s current abilities and mechanics.

BG-02: Players must not receive upgrades that cannot function with their current build.

BG-03: Upgrade selection must preserve opportunities to pivot into new specializations.

BG-04: Early specialization should not make later encounters mathematically impossible.

BG-05: Some runs should produce unusually powerful combinations.

BG-06: Build development should involve meaningful decisions rather than purely random accumulation.

7.5 Gameplay-influenced progression

Proposed feature requiring validation.

Player behavior may influence future upgrade probabilities.

Examples:

* Frequent healing increases the probability of support-related offers.
* Effective blocking increases the probability of defensive offers.
* Repeated fire damage increases the probability of fire-related offers.
* Frequent flanking increases the probability of mobility-related offers.

This system must not reward repetitive, unproductive behavior or make players feel compelled to farm specific actions.

The initial prototype should use acquired upgrades as the primary input to build gravity. Gameplay-based influence can be tested later.

8. Cooperative Multiplayer

8.1 Party structure

The game supports 1–4 players.

The initial target experience is a four-player cooperative dungeon.

Players should be able to form parties through a lightweight invitation or join-code system.

8.2 Flexible party roles

The game will not require predefined tank, healer, and DPS assignments.

Instead, builds develop capabilities across five dimensions:

Capability	Function
Damage	Defeat enemies
Defense	Mitigate damage and protect allies
Healing	Restore health and provide sustain
Control	Interrupt, disable, or reposition enemies
Support	Enhance allied capabilities

Specialized roles should be valuable without becoming mandatory.

Requirements

MP-01: A party must be able to enter a dungeon without a designated tank or healer.

MP-02: Encounter difficulty must scale appropriately for party size.

MP-03: Players must be able to develop complementary builds.

MP-04: Cooperative ability interactions should create meaningful strategic opportunities.

MP-05: No player should become functionally irrelevant because another player acquires a particularly powerful build.

MP-06: Players should not require equivalent historical playtime to participate effectively together.

8.3 Threat and enemy targeting

The combat system should support enemy attention and threat mechanics.

However, traditional MMO threat tables are not necessarily required for every enemy.

Different enemy types may use different targeting behaviors.

Examples:

* Melee enemies pursue the nearest threatening player.
* Predatory enemies prioritize vulnerable targets.
* Defensive enemies respond strongly to taunts.
* Casters prioritize targets based on encounter mechanics.

Threat manipulation should be a meaningful capability for defensive builds.

8.4 Cooperative synergies

Some upgrades should affect teammates or interact with allied abilities.

Examples:

Conductive Armor

* Enemies attacking the player become vulnerable to lightning damage.

Frozen Ground

* Frost effects slow enemies and increase damage from physical ranged attacks.

Battlefield Medic

* Healing an ally grants that ally temporary resource generation.

The design should encourage players to discuss upgrade choices and adapt their strategies together.

9. Dungeon and Encounter Design

9.1 Dungeon philosophy

Dungeons should resemble condensed WoW dungeon experiences.

The emphasis is on:

* Enemy packs with complementary mechanics.
* Tactical positioning.
* Target prioritization.
* Interrupts and crowd control.
* Elite encounters.
* Boss fights.
* Escalating difficulty.

The game should not resemble an endless arena survival mode.

9.2 Encounter composition

Enemy packs should create tactical problems through combinations of relatively simple enemy behaviors.

Example encounter:

Enemy A: Bruiser

* Pursues nearby players.
* Uses frontal attacks.

Enemy B: Caster

* Channels dangerous spells.
* Vulnerable to interrupts.

Enemy C: Support

* Buffs nearby enemies.
* Encourages target prioritization.

The challenge emerges from their interaction.

9.3 Boss encounters

Boss fights should generally last 2–5 minutes.

Boss mechanics may include:

* Positioning requirements.
* Interruptible abilities.
* Add management.
* Area denial.
* Defensive cooldown checks.
* Target switching.
* Coordinated damage windows.

Bosses should test the party’s developed capabilities without requiring a specific composition.

9.4 Procedural variation

The long-term design should support variation in:

* Encounter order.
* Enemy composition.
* Dungeon modifiers.
* Upgrade rewards.
* Optional challenges.
* Boss combinations.

Fully procedural level geometry is not required.

Handcrafted rooms assembled into varied encounter sequences are preferred initially because they provide greater control over combat quality.

10. Progression and Replayability

10.1 Run-specific progression

Most character power is acquired during the current dungeon run.

Run-specific upgrades are reset when the run ends.

10.2 Permanent progression

Permanent progression should primarily expand available options.

Examples:

* New upgrade families.
* Additional archetype variations.
* Cosmetic customization.
* New dungeons.
* Difficulty tiers.
* Achievements.

Permanent progression should not create substantial raw-power disparities between players.

10.3 Difficulty progression

Players should be able to select increasingly challenging dungeon tiers.

Higher tiers may introduce:

* Stronger enemies.
* Additional mechanics.
* More complex encounter combinations.
* Dungeon modifiers.
* New reward opportunities.

Difficulty should reward mastery, coordination, and build knowledge.

11. User Experience

11.1 Browser-first access

The game should launch in a modern desktop browser without requiring a traditional installation.

Initial platform support should prioritize desktop operating systems with keyboard and mouse.

11.2 Fast party formation

Players should be able to create or join a party with minimal friction.

Account creation should not be mandatory for the earliest prototype.

11.3 Readable combat

The UI must clearly communicate:

* Current target.
* Health and resources.
* Ability cooldowns.
* Enemy cast progress.
* Status effects.
* Important positional threats.
* Party health.
* Upgrade effects.

Visual clarity should take precedence over elaborate effects.

11.4 Upgrade comprehension

Players must be able to understand why an upgrade is relevant to their current build.

Upgrade descriptions should communicate:

* The mechanic being changed.
* Relevant existing synergies.
* Newly enabled possibilities.

Players should not need external guides to make informed decisions.

12. Technical Architecture

12.1 Platform

Target: Desktop browser using WebAssembly-compatible technology.

The engine choice remains open.

Primary candidates:

* Bevy with Rust.
* Godot with web export.

12.2 Networking

The game should use an authoritative multiplayer simulation.

The server is responsible for:

* Combat resolution.
* Enemy AI.
* Health and resources.
* Upgrade generation.
* Encounter progression.
* Authoritative player state.

Clients are responsible for:

* Rendering.
* Input collection.
* Animation.
* Audio.
* User interface.
* Appropriate client-side prediction.

The authoritative server does not need to execute in WebAssembly.

12.3 Game systems

The architecture should separate:

Combat engine: Resolves abilities, resources, damage, healing, and status effects.

Upgrade engine: Defines upgrades and modifies combat behavior.

Encounter engine: Manages enemies, objectives, and progression.

Networking layer: Synchronizes multiplayer state.

Presentation layer: Renders characters, effects, animations, and UI.

12.4 Data-driven design

Abilities, upgrades, and enemies should be defined primarily through structured data and reusable mechanics.

This is particularly important for supporting a large number of interacting upgrades.

12.5 Performance targets

Initial targets, subject to prototype validation:

* 60 FPS on a representative modern desktop.
* Four simultaneous players.
* Approximately 10–30 active enemies during ordinary encounters.
* Responsive input and ability feedback.
* Acceptable performance in major desktop browsers.

Networking latency targets and browser hardware requirements must be established during prototyping.

13. MVP Definition

The first milestone is a playable combat prototype, not a complete roguelite.

Milestone 1: Combat prototype

Scope

* One arena.
* One playable archetype: Melee.
* Three basic abilities.
* Three enemy types.
* Tab targeting.
* Resource generation and spending.
* Basic positioning mechanics.
* Health, damage, and cooldowns.

Success criteria

* Combat feels responsive.
* Target selection is intuitive.
* Positioning affects combat outcomes.
* Ability selection involves meaningful decisions.

Milestone 2: Build prototype

Scope

* Approximately 15–20 upgrades.
* Three-option upgrade selection.
* Foundation and synergy upgrades.
* At least three viable build directions.
* One transformation upgrade per build direction.

Success criteria

* Players can produce mechanically distinct builds.
* Upgrade combinations function correctly.
* Players experience meaningful differences between runs.
* No common upgrade path produces an unusable character.

Milestone 3: Cooperative prototype

Scope

* Two-player networking.
* Two playable archetypes.
* Shared encounters.
* Enemy targeting.
* Cooperative ability interactions.
* Server-authoritative combat.

Success criteria

* Two players can complete encounters reliably.
* Multiplayer combat remains responsive.
* Coordination creates advantages beyond independent damage output.

Milestone 4: Vertical slice

Scope

* Three starting archetypes.
* Four-player multiplayer.
* One complete dungeon.
* Three acts.
* Multiple bosses.
* Approximately 50 upgrades.
* 30–45-minute run duration.
* Basic run results and restart flow.

Success criteria

* Four players can complete a full session.
* Builds develop recognizable identities.
* Runs provide meaningful variation.
* Players voluntarily want to begin another run.

14. Product Success Metrics

Initial metrics should focus on gameplay quality rather than commercial performance.

Metric	Initial target
Typical successful run	30–45 minutes
Party setup time	Under 5 minutes
Meaningful upgrades per run	8–12
Maximum active abilities	6–8
Supported party size	1–4
Completed runs per 90-minute session	2
Combat performance	Target 60 FPS
Build diversity	Multiple viable specializations per archetype

Qualitative playtesting should evaluate:

Combat satisfaction: Does using abilities feel good?

Decision quality: Are players making interesting choices during encounters?

Build excitement: Do players anticipate and enjoy upgrade selections?

Cooperation: Does playing with friends create meaningful tactical opportunities?

Replayability: Do players want to start another run?

Time commitment: Does the game deliver a complete experience within the intended session?

15. Major Product Risks

R1. Combat lacks physical responsiveness

Tab-target combat without auto-attacks may feel disconnected or repetitive.

Mitigation: Prototype basic attack timing, animations, and ability feedback before expanding content.

R2. Upgrade interactions become unmanageable

A large combinatorial upgrade system may create bugs and balancing problems.

Mitigation: Build a composable, event-driven combat architecture with automated tests.

R3. Emergent roles create impossible encounters

Parties may lack sufficient healing, defense, or damage.

Mitigation: Guarantee baseline archetype competence and design encounters that support multiple solutions.

R4. Multiplayer complexity delays development

Networking, synchronization, and latency handling may consume substantial engineering effort.

Mitigation: Build the combat simulation independently of rendering and introduce authoritative multiplayer before expanding the game substantially.

R5. Runs become repetitive

A limited set of enemies and rooms may not sustain replayability.

Mitigation: Prioritize enemy interactions, build variety, and encounter modifiers over raw content volume.

R6. Browser limitations compromise quality

Performance, asset loading, or browser compatibility may create friction.

Mitigation: Establish a browser performance baseline early and test representative hardware.

16. Open Product Decisions

The following questions remain unresolved.

Combat

1. Should the global cooldown be fixed or vary by archetype?
2. Should melee abilities require facing the target?
3. How much casting should be possible while moving?
4. Should basic attacks always generate resources?
5. Do auto-attacks improve combat feel?

Builds

6. How strongly should build gravity influence upgrade probabilities?
7. Should player behavior influence upgrade selection?
8. Can players replace active abilities during a run?
9. Should upgrade choices be individual or sometimes shared by the party?
10. How much control should players have over changing build direction?

Multiplayer

11. How should healing and defensive capabilities be distributed?
12. Should players be able to revive fallen teammates?
13. What happens when a player disconnects?
14. Can players join an active run?
15. How should difficulty scale with party size?

Dungeon design

16. How much dungeon geometry should be randomized?
17. Should encounters include optional objectives?
18. Should failed runs grant any progression?
19. How should dungeon difficulty adapt to unusually powerful builds?
20. How much variation should exist between bosses?

17. Guiding Design Principles

These principles should govern future product decisions.

1. Respect the player’s time.
A complete session should deliver meaningful gameplay without requiring preparation or ongoing maintenance.

2. Preserve tactical depth.
Simplify unnecessary complexity without eliminating interesting decisions.

3. Make builds emerge through play.
Starting archetypes establish identity; upgrades create specialization.

4. Avoid dead-end builds.
Players should be able to develop functional characters regardless of early upgrade decisions.

5. Reward cooperation.
The game should be more interesting with friends, not merely easier.

6. Make positioning meaningful, not frantic.
Movement should reward tactical awareness rather than constant reflex execution.

7. Prioritize mechanical transformations over numerical upgrades.
The most exciting upgrades should change how players fight.

8. Preserve accessibility across playtime differences.
Friends should be able to play together regardless of how frequently they log in.

9. Favor concentrated gameplay over content volume.
A small number of excellent encounters is preferable to a large number of repetitive encounters.

10. Build the combat system before building the game around it.
The first objective is to establish a compelling combat loop. Everything else depends on it.

⸻

18. Immediate Next Steps

The project should proceed through three initial activities.

Step 1: Define the combat prototype

Specify:

* Melee movement and targeting.
* Three starting abilities.
* Resource generation.
* Global cooldown behavior.
* Three enemy behaviors.
* Positioning mechanics.

Step 2: Select the technology stack

Evaluate Bevy and Godot specifically against:

* Browser deployment.
* Third-person character controls.
* Animation workflow.
* Multiplayer architecture.
* Data-driven combat implementation.
* Solo-developer productivity.

Step 3: Build the first playable encounter

The first deliverable should be a browser-playable arena containing one character and three enemies.

The prototype succeeds when positioning, targeting, and ability usage combine to produce enjoyable tactical combat.

The immediate objective is not to create a dungeon. It is to establish a combat system worth building a dungeon around.