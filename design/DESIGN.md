# Anchor - Habit & Focus - Design System

Bright, modern iOS productivity app: habit tracker, Screen Time app blocking, focus timer.
Calm, disciplined, premium. Light theme.

## Color (use ONLY these colors; no default violet/indigo, no flat neutral grey)
- Background: #FCF4FC (tinted near-white)
- Surface (cards, sheets): #FFFFFF
- Surface alt (grouped rows): #F7EEF7
- Accent / primary (aubergine): #4A154B - primary buttons (white label), active tab, key data, hero numerals
- Accent tint: #E6DEE6 - selected fills, badges
- Accent pressed: #3F1240
- Support (gold): #ECB22E - streak flame, progress tracks, charts highlight, FAB; dark #1E0C1F label on it, never white
- Text primary: #1E0C1F, secondary: #5E4A5F, tertiary/placeholder: #8F7D90
- Border / divider: #EADCEA
- Success #16A34A, Warning #D97706, Danger #DC2626

## Typography
- UI + body: Lato. Display (hero titles, big numerals like streak count and timer): Gloock.
- Display 32/700 -0.02em; Title 20/600; Body 16/400; Label 14/500; Caption 13/500 in #5E4A5F.
- Numerals in stats use tabular Lato; timer and streak hero numbers use Gloock.

## Frame + safe areas
- 393x852 iPhone. Keep top ~59px (status bar 9:41) and bottom ~34px (home indicator) clear of tappable content.

## Shape, spacing, elevation, icons
- Radius: card 20, control 14, input 12, pill 999.
- 8pt spacing scale (4, 8, 12, 16, 24, 32); screen edge padding 20px; generous whitespace.
- Elevation: soft only, card = 0 1px 2px rgba(30,12,31,.04) + 0 8px 24px rgba(30,12,31,.06). No hard shadows.
- Icons: ONE set, rounded outline (Lucide style), 24px, 1.75 stroke. Never mix filled and outline.

## Controls (one spec, reuse everywhere)
- Primary button: pill, #4A154B fill, white Lato 600 label; pressed #3F1240; disabled #E6DEE6 fill with #8F7D90 label.
- Secondary button: pill, white fill, 1.5px #4A154B border, #4A154B label.
- Text input: 12px radius, #EADCEA border; focus 2px #4A154B ring; error #DC2626 border + caption.
- Card: white, 20px radius, soft shadow.
- Chip: pill, #F3EAF3 fill, #4A154B text; selected #4A154B fill with white text.
- Toggle: on = #4A154B track; habit check circle: done = #4A154B filled with white check.

## Shared components
### Bottom tab bar (identical on every screen that shows nav)
Exactly five tabs in this order: Today (check-circle icon), Focus (timer icon), Blocks (shield icon), Insights (bar-chart icon), Profile (user icon).
Flat white bar, hairline #EADCEA top border, no gradient. Active tab: #4A154B icon + label with a small #ECB22E dot above the icon. Inactive: #8F7D90 icon + label. Never rename, reorder, add or remove tabs.
Full-screen, modal, onboarding, auth, paywall, live session and shield screens show NO tab bar.

## Gradient + focal rules
- Soft 2-stop gradient #4A154B -> #6B2A5E with a warm #ECB22E glow only on hero surfaces: onboarding hero, paywall hero card, today streak card, focus live background, shield background. Tab bar stays flat. Max two gradient moments per screen.
- Every screen has ONE bold focal element (streak card, big timer ring, big stat number) that owns the visual weight; everything else stays quiet.

## Imagery
Real photography only; empty states and onboarding also use real photos or flat 2D vector art. NO 3D renders, claymorphism, isometric, CGI or glossy plastic objects. Warm natural light, calm desk / home scenes, subtle aubergine and gold accents in the set.
