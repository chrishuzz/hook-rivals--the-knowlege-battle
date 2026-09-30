# Anime Island Fishing — Godot 4 (3D)

A small 3D fishing game: you stand on a beach island, cast a rod out into
the sea, wait for a bite, then play a tension-bar minigame to reel the fish
in. Which fish bites is picked from a weighted rarity table.

## Requirements
- **Godot 4.2 or newer** (uses `CharacterBody3D`, `RigidBody3D.freeze`, etc.)

## Setup
1. Open Godot 4, choose **Import**, and select the `project.godot` file in
   this folder.
2. Press **Play** (F5). `scenes/Main.tscn` is already set as the main scene.

## Controls
| Action | Key |
|---|---|
| Move | `W A S D` |
| Jump | `Space` |
| Look around | Mouse |
| Hold to charge cast power / release to cast | `Left Click` |
| Hook the fish when it bites | `Left Click` (timing matters!) |
| Reel in (hold to reduce tension) | `Left Click` (hold) |
| Free the mouse cursor | `Esc` |

Input actions (`move_forward`, `fish_action`, etc.) are registered **in
code** by `scripts/Bootstrap.gd`, so nothing needs to be configured in
Project Settings — it works the moment you open the project.

## How the fishing loop works
1. **Cast** — hold Left Click to charge power (watch the power bar), release
   to send the bobber arcing out over the water.
2. **Wait** — once the bobber lands and floats, a random delay begins based
   on which fish (secretly) decided to approach.
3. **Bite** — the bobber dips hard. You have a short window to click and
   set the hook — rarer/harder fish give you less time.
4. **Reel** — a tension bar fights against you (the fish pulling). Hold
   Left Click to reel, but don't overdo it — tension that hits either end
   snaps the line. Keep it inside the green target zone to fill the catch
   progress bar. Fill it to land the fish.

## Fish variety & chances (`scripts/FishDatabase.gd`)
Eight species across four rarity tiers, each with its own spawn weight,
weight-in-kg range, point value, and reel difficulty:

| Rarity | Fish | Spawn weight | Points | Difficulty |
|---|---|---|---|---|
| Common | Anchovy, Herring, Reef Tuna | 30 / 28 / 22 | 5 / 8 / 12 | Low |
| Uncommon | Mackerel, Yellowtail Snapper | 12 / 10 | 20 / 28 | Medium |
| Rare | Swordfish, Blue Marlin | 4 / 3 | 75 / 90 | High |
| Legendary | Golden Koi | 1 | 250 | Very high |

Chances are just `weight / total_weight`, so with the numbers above the
Golden Koi shows up roughly 1 in 110 casts. Tune any of this by editing the
`FishType.new(...)` lines — add new species, change weights, or adjust
`difficulty` (which controls both the bite-timing window and how hard the
fish fights in the reel minigame).

## About the visuals
The three reference images you sent (a tropical island, a stylized anime
fisherman, a low-poly silver fish) were used as a **style guide**, not as
importable assets — a 2D picture doesn't contain 3D model data, so it can't
be auto-converted into a game-ready mesh. Instead everything here is built
from primitive Godot meshes in a similar palette/spirit:
- **Island**: sandy cylinder platform + green sphere "hill" + three
  palm trees (cylinder trunk + squashed sphere leaves), matching the
  beach-and-jungle-peak look of the island reference.
- **Water**: a custom animated shader (`shaders/water.gdshader`) blending
  a bright turquoise shallow color into a deeper blue, with simple
  vertex-displacement waves.
- **Character**: an orange-jacketed capsule-based figure (first-person, so
  you mostly see the rod), echoing the orange coat in the fisherman
  reference.
- **Fish**: represented via the catch log/UI rather than unique meshes per
  species, to keep scope manageable — see "Next steps" below.

## Known limitations / good next steps
- The hill is decorative and has no collision, so you can walk through its
  base — give it a `CollisionShape3D` if you want it solid.
- Fish aren't visually modeled underwater; you only see the bobber. Adding
  a low-poly fish mesh (a scaled/colored capsule + fin, similar to image 3)
  that pops up near the bobber during the bite/reel states would be a nice
  next step — `FishType` already carries a `color` field for this.
- Currently one fishing spot (anywhere facing the water works). You could
  add multiple `Area3D` "fishing zones" with different fish tables per
  zone (e.g. deep sea vs. reef) for more variety.
- No save/load — catches reset when you close the game.
