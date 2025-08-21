
Estructura del proyecto:
```
res://
│
├─ assets/           # Imágenes, sprites, audio, iconos
│   ├─ characters/
│   ├─ backgrounds/
│   ├─ ui/
│   └─ sounds/
│
├─ i18n/             # JSONs de textos, traducciones
│   ├─ menu_labels.json
│   └─ characters_moods.json
│
├─ scenes/           # Escenas principales y modulares
│   ├─ CafeLevel1.tscn        # Escena del nivel base
│   ├─ CafeLevel2.tscn        # Futuro nivel 2
│   ├─ MinigamePanel.tscn     # Escena superpuesta para minijuegos
│   └─ UI/
│       ├─ LifeTimer.tscn
│       └─ ButtonsPanel.tscn
│
├─ scripts/          # Scripts GDScript
│   ├─ characters/
│   ├─ ui/
│   └─ levels/
│       ├─ CafeLevel1.gd
│       └─ MinigamePanel.gd
│
└─ project.godot
```
