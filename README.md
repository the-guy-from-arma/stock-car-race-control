# Stock Car Race Control for BeamNG.drive

Run a stock car race with up to 14 drivers, including you. Race Control handles the rolling start, automatic flags and restarts, pit speed and repairs, and player recovery. The HUD shows the running order, flags, car condition, and tow options. The main-menu career board tracks training, sponsors, and race results in your local profile.

## Install

1. **Close BeamNG.drive.** Use BeamNG.drive 0.40.6, the version used for development testing.
2. **Download Race Control and both required vehicle ZIPs.** Add the other vehicle downloads if you want the Durango pace car or blowover physics.
3. **Download the tracks you want to race.** Install all six to run the full career calendar.
4. **Open your BeamNG user folder.** In the BeamNG launcher, select **Manage User Folder → Open in Explorer**. Open the `mods` folder or create it there.
5. **Copy each ZIP into `mods` without unzipping it.** If you have an earlier version, close the game and replace the old ZIPs with the same filenames. This release includes the Daytona route from the older `Daytona_Gen7_Oval.zip`. Disable that older companion mod and any separate patches for these same maps to avoid duplicate layouts or waypoints.
6. **Launch the game and check the Mod Manager.** Enable the downloads. Open **Stock Car Career** from the main menu for training and race day. For a standalone race, load one of the tracks in Freeroam and spawn a BSC Gen 7 car. If the HUD is missing, open **Pause → System → HUD Apps**, edit the Freeroam layout, and add **Stock Car Race Control**.
7. **Set your race length and opponent count, then select Start race.** AI drives the opening pace lap. You get control at green. Check **Stock Car Career** after finishing a career event to see the updated calendar and results.

See the [BeamNG manual installation guide](https://documentation.beamng.com/tutorials/mods/installing-mods/) for help finding your user folder.

## Downloads

### Race Control and cars

| ZIP | What it does |
| --- | --- |
| [Daytona_Race_Control.zip](https://github.com/the-guy-from-arma/stock-car-race-control/releases/download/v0.1.0/Daytona_Race_Control.zip) | Required. Race logic, HUD, career board, routes, and driver setups. |
| [BSC_cupgen7.zip](https://github.com/the-guy-from-arma/stock-car-race-control/releases/download/v0.1.0/BSC_cupgen7.zip) | Required. Base Gen 7 stock cars. |
| [cupgen7_expansion.zip](https://github.com/the-guy-from-arma/stock-car-race-control/releases/download/v0.1.0/cupgen7_expansion.zip) | Required. Supplies parts used by the Daytona setups. |
| [flanje_dodge_durango.zip](https://github.com/the-guy-from-arma/stock-car-race-control/releases/download/v0.1.0/flanje_dodge_durango.zip) | Optional. Durango Pursuit pace car. BeamNG’s LeGran police car is the fallback. |
| [BSC_vehicle_blowover_addon.zip](https://github.com/the-guy-from-arma/stock-car-race-control/releases/download/v0.1.0/BSC_vehicle_blowover_addon.zip) | Optional. Adds blowover support for compatible cars. |

The ambulance and rollback use vehicles included with BeamNG.drive.

### Tracks

| Track | ZIP |
| --- | --- |
| Daytona International Speedway | [BSC_daytonaspeedway.zip](https://github.com/the-guy-from-arma/stock-car-race-control/releases/download/v0.1.0/BSC_daytonaspeedway.zip) |
| Lone Star Speedway | [lonestar_speedway.zip](https://github.com/the-guy-from-arma/stock-car-race-control/releases/download/v0.1.0/lonestar_speedway.zip) |
| Martinsville Speedway | [2FastRacing-Martinsville.zip](https://github.com/the-guy-from-arma/stock-car-race-control/releases/download/v0.1.0/2FastRacing-Martinsville.zip) |
| Bristol Motor Speedway | [2FastRacing-BristolMotorspeedway.zip](https://github.com/the-guy-from-arma/stock-car-race-control/releases/download/v0.1.0/2FastRacing-BristolMotorspeedway.zip) |
| Phoenix Raceway | [2FastRacing-Phoenix.zip](https://github.com/the-guy-from-arma/stock-car-race-control/releases/download/v0.1.0/2FastRacing-Phoenix.zip) |
| Newport Speedway Oval | [tbd_newport_speedway_oval.zip](https://github.com/the-guy-from-arma/stock-car-race-control/releases/download/v0.1.0/tbd_newport_speedway_oval.zip) |

Verify your downloads against [SHA256SUMS.txt](https://github.com/the-guy-from-arma/stock-car-race-control/releases/download/v0.1.0/SHA256SUMS.txt) if a ZIP fails to load.

## During a race

- Under caution, line up behind the pace car or the car indicated by the HUD. Caution AI takes over after you hold the moving lineup and returns control at green.
- After a wreck or spin, you can steer and reverse yourself. Choose **Keep driving**, or select **Request tow** and stop so the crew can take you to your pit box.
- Stop in the marked pit box to repair, refuel, or serve a pit-speed penalty. Follow the HUD’s pit speed and black flag prompts.

## Build the Race Control ZIP

Run `python build_mod.py`. The script packages the `mod/` contents at the archive root and writes `dist/Daytona_Race_Control.zip`.

## Credits

Original credits and source pages are listed in [CREDITS.md](CREDITS.md). This is a community mod for BeamNG.drive.
