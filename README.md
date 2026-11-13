# ChessCards (v1, SpriteKit)

A two-player, turn-based card battler where **each card is a chess piece**, built in Swift and SpriteKit for Challenge 4 at the Apple Developer Academy.

> The project continues in Godot: **[ChessCards 2.0](https://github.com/Bttaleb/chessCards2.0)**.

<!-- Add a gameplay GIF or screenshot here -->

## How it plays

- Each player is dealt a hand of piece cards (pawn, knight, bishop, rook, queen, king). Every piece type has base **attack**, **defense** and **abilities**.
- Players take turns placing cards into their **battle slots** by dragging them from the hand.
- When both sides are set, the **combat phase** resolves slot against slot with animated attacks, and health bars and points update.
- A turn banner and round indicator show whose move it is and which round you're in.

## How it's built

| File | Responsibility |
|---|---|
| `GameScene.swift` | Layout, touch handling (drag and drop), dealing hands, running combat sequences |
| `Turn.swift` (`TurnManager`) | Turn order and phases; tells the scene when to switch players, start combat and begin a round |
| `CardData.swift` | Piece stats built from a `PieceType` |
| `Card.swift`, `Battle.swift` | Card sprites and `BattleSlot` nodes that track occupancy and owner |
| `CombatDisplay.swift`, `CombatAnimations.swift` | Combat results and attack animations |
| `HealthBar.swift`, `PointTrackerView.swift`, `turnBanner.swift` | HUD elements |

The game state is driven by a **delegate pattern**: `TurnManager` owns the rules and phases, and `GameScene` reacts to callbacks such as `didSwitchTo`, `didEnterPhase` and `didCompleteCombat`.

## Running it

Open `myGame/myGame.xcodeproj` in Xcode and run on an iPhone or iPad simulator.

## Built with

Swift · SpriteKit · UIKit
