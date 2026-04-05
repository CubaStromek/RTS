# 🎮 RTS Game — Project Brief for Claude Code

## Přehled projektu

Vytváříme 2D real-time strategii (RTS) v enginu **Godot 4** s perspektivou shora (top-down).
Hra bude zasazena do středověkého prostředí. Cílem je funkční prototyp s core RTS mechanikami.

Projekt vzniká ve spolupráci s Claude Code — architekturu a design rozhodnutí dělá člověk, implementaci píše Claude Code.

---

## Tech Stack

| Komponenta | Volba |
|---|---|
| Engine | Godot 4.x (nejnovější stabilní) |
| Primární jazyk | GDScript (logika, UI, signály) |
| Výkonnostní části | C# (pohyb jednotek, AI, pathfinding) |
| Assety (placeholder) | Kenney.nl — Top-Down / Strategy pack (CC0) |
| Verzování | Git |

---

## Struktura projektu

```
rts_game/
├── project.godot
├── scenes/
│   ├── main/
│   │   ├── Main.tscn          # Root scéna, vstupní bod
│   │   └── Main.gd
│   ├── units/
│   │   ├── Unit.tscn          # Základní jednotka (reusable)
│   │   ├── Unit.gd
│   │   ├── Soldier.tscn       # Extend Unit
│   │   └── Worker.tscn        # Extend Unit
│   ├── buildings/
│   │   ├── Building.tscn      # Základní budova
│   │   ├── Barracks.tscn
│   │   └── TownHall.tscn
│   ├── map/
│   │   ├── GameMap.tscn       # Tilemap + terrain
│   │   └── GameMap.gd
│   └── ui/
│       ├── HUD.tscn           # Hlavní herní UI
│       ├── SelectionBox.tscn  # Gumička výběru
│       └── Minimap.tscn
├── scripts/
│   ├── systems/
│   │   ├── SelectionSystem.gd     # Multi-select logika
│   │   ├── CommandSystem.gd       # Příkazy jednotkám
│   │   ├── ResourceSystem.gd      # Suroviny (zlato, dřevo)
│   │   └── FogOfWarSystem.gd      # Mlha války
│   ├── managers/
│   │   ├── GameManager.gd         # Globální autoload
│   │   ├── UnitManager.gd
│   │   └── BuildingManager.gd
│   └── utils/
│       └── Utils.gd
├── resources/
│   ├── UnitData.tres          # Resource soubory pro data
│   └── BuildingData.tres
└── assets/
    ├── sprites/               # PNG sprity (Kenney placeholder)
    ├── sounds/
    └── fonts/
```

---

## Core Mechaniky (MVP)

### 1. Kamera
- Pohyb pomocí WASD / šipek + scroll na okrajích obrazovky
- Zoom kolečkem myši (min/max limit)
- Ortogonální projekce (2D top-down)

### 2. Výběr jednotek
- Klik = výběr jedné jednotky
- Drag = gumička (SelectionBox) pro multi-select
- Shift+klik = přidat/odebrat z výběru
- Ctrl+číslo = uložit skupinu, číslo = recall skupiny
- Vybrané jednotky jsou vizuálně zvýrazněny (zelený kruh pod nimi)

### 3. Pohyb jednotek
- Pravý klik na terén = příkaz Move
- Jednotky používají Godot **NavigationAgent2D** pro pathfinding
- Formation movement — jednotky se nehrnou na jedno místo, rozestaví se
- Animace pohybu (alespoň 4 směry pokud assety dovolí)

### 4. Boj
- Pravý klik na nepřátelskou jednotku = příkaz Attack
- Automatický útok na nepřítele v dosahu (aggro range)
- Parametry: HP, útok, dosah, rychlost útoku, rychlost pohybu
- Vizuální HP bar nad jednotkou
- Smrt = jednotka zmizí + efekt (particles nebo jednoduchý fade)

### 5. Budovy
- Klik na budovu = zobrazí se info panel a frontu výroby
- Kasárna: vyrábí vojáky (queue)
- Town Hall: vyrábí dělníky
- Budovy mají HP, lze je útočit a zničit

### 6. Suroviny
- 2 typy: **Zlato** a **Dřevo**
- Zobrazeny v HUD (top bar)
- Dělník může těžit (pravý klik na resource node)
- Budovy/jednotky stojí suroviny

### 7. UI / HUD
- Top bar: zlato, dřevo, počet jednotek / limit
- Bottom panel: informace o vybrané entitě (HP, stats, fronta výroby)
- Minimap (pravý dolní roh) — jednoduchý overhead view
- Cursor se mění dle kontextu (move, attack, harvest)

### 8. Mlha války (Fog of War)
- Neprozkoumaná území jsou tmavá
- Prozkoumané ale momentálně neviditelné = šedá
- Viditelnost = radius kolem vlastních jednotek a budov

---

## Signálový systém (Godot Events)

Projekt komunikuje výhradně přes **signály** — žádné přímé reference mezi nesouvisejícími systémy.

```
unit_selected(unit: Unit)
unit_deselected(unit: Unit)
unit_died(unit: Unit)
unit_command_issued(units: Array[Unit], command: Dictionary)
building_trained(building: Building, unit_type: String)
resource_changed(type: String, amount: int)
entity_info_requested(entity: Node)
```

---

## Autoload Singletony (Project Settings → Autoload)

| Jméno | Soubor | Popis |
|---|---|---|
| `GameManager` | scripts/managers/GameManager.gd | Globální stav hry |
| `UnitManager` | scripts/managers/UnitManager.gd | Evidence všech jednotek |
| `SelectionSystem` | scripts/systems/SelectionSystem.gd | Kdo je vybraný |
| `CommandSystem` | scripts/systems/CommandSystem.gd | Zpracování příkazů |
| `ResourceSystem` | scripts/systems/ResourceSystem.gd | Suroviny |

---

## Fáze vývoje

### Fáze 1 — Foundation (začínáme zde)
- [ ] Základní Godot projekt, struktura složek
- [ ] Kamera s pohybem a zoomem
- [ ] Placeholder mapa (tilemap, jednoduchý terén)
- [ ] Jedna jednotka s pohybem (NavigationAgent2D)
- [ ] Základní výběr (klik + gumička)
- [ ] Pravý klik = pohyb

### Fáze 2 — Core Loop
- [ ] Více jednotek, formation movement
- [ ] Bojový systém (HP, útok, smrt)
- [ ] Kasárna — výroba jednotek z fronty
- [ ] Základní UI (HUD, info panel)
- [ ] Suroviny (zlato, dřevo)

### Fáze 3 — Rozšíření
- [ ] Fog of War
- [ ] Minimap
- [ ] AI oponent (jednoduchý — útočí vlnami)
- [ ] Zvuky
- [ ] Více typů jednotek a budov

### Fáze 4 — Polish
- [ ] Skutečné assety (nahrazení placeholderů)
- [ ] Animace, particles, efekty
- [ ] Balancing
- [ ] Win/lose podmínky

---

## Coding Conventions

- Každý soubor má odpovědnost za **jednu věc** (Single Responsibility)
- Komentáře v **angličtině** (kompatibilita s Godot dokumentací)
- Signály pojmenovat jako události v minulém čase (`unit_died`, ne `unit_die`)
- Konstanty `VELKE_PISMENA`, proměnné `snake_case`, třídy `PascalCase`
- Žádné `get_node()` cestami — používat `@onready var` a typed references
- Vyhnout se `_process()` kde stačí signály

---

## Placeholder Assety

Než budou vlastní assety, použij:

1. **Kenney.nl** — stáhnout "Tiny Town" nebo "Strategy" pack
   - https://kenney.nl/assets/tiny-town
   - https://kenney.nl/assets/strategy
2. Alternativně — **barevné obdélníky a kolečka** generované přímo v GDScriptu:

```gdscript
# Placeholder jednotka — zelené kolečko
func _draw():
    draw_circle(Vector2.ZERO, 16, Color.GREEN)
    draw_arc(Vector2.ZERO, 18, 0, TAU, 32, Color.DARK_GREEN, 2)
```

---

## Jak pracovat s Claude Code

1. **Vždy začni popisem co chceš** — nejen "udělej pohyb", ale "implementuj NavigationAgent2D pohyb pro Unit.gd, jednotka se má pohybovat na pozici danou pravým klikem, s formation offsetem pro skupiny"
2. **Jeden úkol najednou** — Claude Code je nejlepší na konkrétní, ohraničené tasky
3. **Poskytni kontext** — pokud se mění existující soubor, ukaž jeho aktuální obsah
4. **Reviewer role** — po každé implementaci zkontroluj kód, zeptej se na vysvětlení čehokoliv nejasného
5. **Iterativní přístup** — nejdřív rozjeď, pak optimalizuj

---

## První příkaz pro Claude Code

```
Vytvoř základní strukturu Godot 4 projektu pro 2D RTS hru podle tohoto briefu.
Začni s:
1. Složkovou strukturou (scenes/, scripts/, assets/)
2. Main.tscn + Main.gd jako vstupní bod
3. Kamerou v Camera2D s pohybem WASD a zoomem kolečkem myši
4. Prázdnou TileMap s jednoduchým zeleným pozadím jako placeholder mapy

Použij GDScript. Nepoužívej žádné pluginy ani addony.
```
