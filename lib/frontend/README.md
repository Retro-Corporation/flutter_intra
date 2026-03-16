# Frontend — Design Engineer Workstation

This folder contains all frontend code for flutter_intra, organized for a
design engineer workflow. Everything outside this folder (database/, features/,
services/, etc.) is backend territory managed by Julian.

## Architecture

The frontend is split into three pillars:

### 1. Design System (`design_system/`)

Maps to our Figma design system. Built using **atomic design** methodology.

| Layer | What lives here | Examples |
|-------|----------------|---------|
| **Foundation** | Raw design tokens — the base everything builds on | Colors, typography, spacing, theme |
| **Atoms** | Smallest indivisible UI elements | Buttons, icons, text widgets, badges |
| **Molecules** | Groups of atoms working together | Input + label, search bar, avatar + name |
| **Organisms** | Complex sections composed of molecules | Nav bar, exercise card, settings panel |
| **Templates** | Page-level layout skeletons (no real data) | Dashboard layout, detail page layout |

Import everything via: `import 'package:flutter_intra/frontend/design_system/design_system.dart';`

### 2. Library (`library/`)

All frontend logic that isn't visual UI.

| Folder | Purpose |
|--------|---------|
| `state/` | Controllers, providers, view models |
| `services/` | Frontend service layer, API adapters |
| `models/` | UI data models |
| `navigation/` | Route definitions, nav logic |
| `utils/` | Helpers, formatters, extensions |

### 3. Pages (`pages/`)

Full screens composed by combining **design system** components + **library** logic.
This is the integration point where visuals meet data.

## Workflow

1. Design in Figma
2. Translate tokens → `foundation/`
3. Build components → `atoms/` → `molecules/` → `organisms/` → `templates/`
4. Wire up logic in `library/`
5. Compose final screens in `pages/`

## TODO — Build Out the Frontend

### Design System

#### Foundation (Design Tokens)
- [ ] Pull color palette from Figma → `foundation/colors.dart`
- [ ] Pull typography scale from Figma → `foundation/typography.dart`
- [ ] Pull spacing/sizing scale from Figma → `foundation/spacing.dart`
- [ ] Build ThemeData from tokens → `foundation/theme.dart`

#### Atoms
- [ ] Create primary button atom
- [ ] Create text/label atoms (heading, body, caption)
- [ ] Create icon atom (if custom icons)
- [ ] Create input field atom
- [ ] Create divider/spacer atoms

#### Molecules
- [ ] Create labeled input field (input atom + label atom)
- [ ] Create search bar molecule
- [ ] Create list item molecule
- [ ] Create avatar + name molecule

#### Organisms
- [ ] Create navigation bar organism
- [ ] Create exercise card organism
- [ ] Create app header organism

#### Templates
- [ ] Create main dashboard layout template
- [ ] Create detail page layout template
- [ ] Create auth page layout template

### Library

#### State
- [ ] Set up state management approach (Provider/Riverpod)
- [ ] Create auth state controller

#### Services
- [ ] Create frontend service interface to backend pose detection
- [ ] Create frontend service interface to backend exercises

#### Models
- [ ] Define UI models for exercise display
- [ ] Define UI models for pose/rep display

#### Navigation
- [ ] Set up route definitions
- [ ] Define navigation flow (auth → home → exercise)

#### Utils
- [ ] Add common formatters (date, duration, reps)

### Pages
- [ ] Build login page using design system components
- [ ] Build sign-up page using design system components
- [ ] Build home/dashboard page
- [ ] Build exercise detail page
- [ ] Build pose detection page (frontend shell)
