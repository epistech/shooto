SMG Ultra
===================
(Formerly Shooto, Spaceship MiniGolf).

This is a first CoronaSDK game-in-progress. 

Notes
------
It's a work in progress, but it has end-states, score tracking, advancement, levels, a high-score tracker and music. So that's something.

I'd like it to be a little bit more complex and interesting than it is so far. Perhaps with some semblance of a story, even!

Lots of significant, but little, changes as described in updates section below. I also figured out how to create some designed levels, which might be fun for a future update.

## To-do
- Start designing a tutorial/set of instructions on how to play.
- Cleanup directory and remove excess/old files (music, sprite sheets, PSDs, in particular).
- Create brief instructions.

## Future
- Stage-select screen
- Longer courses (maybe? maybe not…)
- Refactor like wow.

## Known Issues

### 0.96 (2015/12/09)
- All New Art!
— Blackhole
— Ball
— Bumpers
— Ship TK
- Level design schema in place; 5 levels designed.
- Fixed mute button reset
- Changed color of power-ups/lasers by type
- Animated collision to make it more obvious the end-of-level sequence.

### 0.94a (2015/11/16)
- Set audio volume to 0.5
- changed bounce points to sometimes spawn "powerups" which work the same, except for that's now how you upgrade your lasers.
- added an in-app mute button
- Fixes for actually running on Android
- New distro certificate means this can be pushed out to TestFlight
- Added a splash screen that shows up at launch

### 0.92
- Set music to 0.75
- Bounce points now "upgrade" to different bullet types that cycle through a list.
- Removed inclusion of iAds plugin so that the Corona dailies can compile an OSX build.
- Added OSX icon files and window settings

### 0.91b
- Almost ready for a 1.0 release! Submit this sucker Sunday, 7/26!?
* Changed badguy into a new fancy sprite, which had a couple of effects. It's a lot heavier, for one.
* Removed "SHOOTO" text, because it was confusing people.
* Changed scoring to increase values as a per-level multiplier.
* Added file-writing for high-score tracking.
* Added music back in, with a longer loop.
* Added iAds code for monetization.
* Updated the end-of-play/end-of-level text to create apparent advancement.

### 0.7a1
- Make a "black hole" sprite to aim at.
- Boxes now vanish on hit

### 0.6
- Fixed scoring bugs
- fixed splash screens
- new animated sprite for main ship

### 0.5
- Added music
- Added highscore feature


Will Not Fix
------------
- Figure out how to multi-touch turn the ship so that it can aim in different directions.
