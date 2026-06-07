# Product Requirement Document (PRD)

## Project Name: [

## 1. Document Control & Overview

- **Target LLM/Agent Role:** Lead Product Manager Agent / Architecture Agent
    
- **Version:** 1.0
    
- **Game Type:** Single-Player Casual Arcade Mobile Game
    
- **Core Mechanics:** Multi-gesture input (Tap, Long Press, Drag) mapping to variable scoring matrices.
    

## 2. Executive Summary & Game Loop

### 2.1 High-Level Concept

A fast-paced, high-score-driven mobile arcade game where players interact with rapidly appearing screen targets using specific physical gestures. Correct interactions yield points and combo multipliers; incorrect or missed interactions deplete the player's life/timer.

### 2.2 Core Game Loop

1. **Spawn:** Targets appear on screen based on a dynamic difficulty algorithm.
    
2. **Identify:** Player recognizes the target type and its associated gesture requirement.
    
3. **Execute:** Player performs the action (Tap, Hold, or Drag).
    
4. **Evaluate:** System checks input accuracy, calculates score, updates UI, and triggers audiovisual feedback.
    
5. **Escalate:** Game speed/density increases until a lose condition is met.
    

## 3. Input Mechanics & Target Matrix

This section dictates the precise input-to-output logic that the engineering agents must implement.

| **Target ID**      | **Visual Asset Placeholder**                             | **Required Gesture**       | **Success Condition**                              | **Failure Condition**                 | **Score Reward** |
| ------------------ | -------------------------------------------------------- | -------------------------- | -------------------------------------------------- | ------------------------------------- | ---------------- |
| **TG-01 (Pop)**    | Blue Sphere                                              | **Single Tap**             | Registered lift-up inside bounds within lifetimer. | Lifetimer expires OR Dragged.         | +10 Points       |
| **TG-02 (Heavy)**  | Gold Square                                              | **Double Tap**             | Two distinct taps inside bounds within 300ms.      | Single tap only OR Lifetimer expires. | +25 Points       |
| **TG-03 (Charge)** | Green Anchor                                             | **Long Press** (Hold 1.5s) | Continuous touch held for 1500ms.                  | Touch released < 1500ms.              | +50 Points       |
| **TG-04 (Trash)**  | Red jagged line (length and segments randomly generated) | **Drag**                   | Touch down on target ->follow along the line       | Released outside line OR Tapped.      | +40 Points       |

### 3.1 Input Overlap & Conflict Resolution

- **Simultaneous Spawns:** System must support multi-touch processing (minimum 2 independent touch inputs tracked concurrently).
    
- **Gesture Priority:** Drag-an registration must have a movement threshold (e.g., >10 pixels vector delta) to prevent it from being misread as a Single Tap.
    

## 4. Technical Architecture Requirements (For Coding Agents)

### 4.1 Target Spawning System (`SpawnerManager`)

- **Spawn Logic:** Targets must spawn within a safe-zone rectangle bounding box: `(x1: 5%, y1: 10%)` to `(x2: 95%, y2: 85%)` of screen resolution to avoid UI overlapping.
    
- **Collision Detection:** New targets cannot spawn within a radius of `R` pixels of an existing active target.
    

### 4.2 Scoring & Multiplier Engine (`ScoreManager`)

- **Base Score formula:**
    
    $$\text{Final Score} = \text{Base Score} \times \text{Current Multiplier}$$
    
- **Combo Multiplier:** Increments by $+1x$ for every 5 consecutive successful hits. Resets to $1x$ on any failure condition.
    

### 4.3 State Machine States

The game must operate strictly under the following states:

- `INIT`: Bootstrapping assets and local saving states.
    
- `MAIN_MENU`: Idle state awaiting player "Start" input.
    
- `GAMEPLAY`: Core loop active; timers running; input listener active.
    
- `PAUSE`: Interruption state; freeze all game timers and object velocities.
    
- `GAME_OVER`: Evaluation state; write high score to local storage; display ad/retry UI.
    

## 5. UI & UX Mockup Blueprint

The UI layout should remain lightweight to optimize rendering performance.

Plaintext

```
+-------------------------------------------------------------+
| [Score: 012450]                  [Combo: 4x]     [|| Pause] |
+-------------------------------------------------------------+
|                                                             |
|         (TG-01: Tap)                                        |
|                                                             |
|                                     [TG-03: Hold 1.2s...]   |
|                                                             |
|    [TG-04: Drag] ------->                                   |
|                                                             |
+-------------------------------------------------------------+
| [=================== Lifetimer / Health Bar =============]  |
| [=================== [TRASH BIN ZONE] ===================]  |
+-------------------------------------------------------------+
```

## 6. Game Progression & Balance Constants

Agents should expose these parameters in a central configuration file (e.g., `Config.json` or `GameConfig.cs`) for easy tuning:

JSON

```
{
  "initial_spawn_rate": 1.5, 
  "minimum_spawn_rate": 0.4,
  "difficulty_ramp_delay_seconds": 10.0,
  "spawn_rate_reduction_step": 0.05,
  "player_max_lives": 3
}
```

## 7. Acceptance Criteria for Testing Agents (QA)

Before declaring the feature/game complete, the QA agent suite must validate:

- [ ] **Verification 01:** Tapping a `TG-03 (Charge)` target instantly breaks the combo multiplier and registers a failure.
    
- [ ] **Verification 02:** Dragging `TG-04` to anywhere _except_ the designated Trash Bin Zone returns the target to its origin point or inflicts a life penalty.
    
- [ ] **Verification 03:** Frame rate remains stable at $\ge 60\text{ FPS}$ on standard mobile profiles during dense spawning phases (>10 targets on screen).
    
- [ ] **Verification 04:** App accurately saves the highest score locally using persistent data pathways (`PlayerPrefs` / local sandbox storage) across app restarts.