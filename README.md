# love2d-MineSweeper-Game
simple, no frills minesweeper game to help me learn code

 ![minesweeper](https://user-images.githubusercontent.com/83201905/152622870-624c71af-cb98-4a37-92dd-49ff89672a6d.png)

  
### Features:
- auto clearing empty sections
- flagging
- win/loss detection
- when clicking on a number with an adequate number of flags in it's area, it will clear all non-flagged boxes
- timer

# Installation
## Prerequisites
 - [LÖVE Game Engine](https://love2d.org/)

## Run
- On Windows/Linux with LÖVE installed you can double-click `MineSweeper.love` to run the game.
- Alternatively, simply run love.exe, giving the game's folder as an argument
  - Example (windows):
"C:\Program Files\LOVE\love.exe" "C:\games\MineSweeperFolder"
- for Mac OS X and more, please refer to [LÖVE's wiki instructions](https://love2d.org/wiki/Getting_Started)


# Usage
## controls:
  - uncover box: left-click
  - flag box: right-click
  - newgame/reset: middle-click
