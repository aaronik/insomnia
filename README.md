# Insomnia

A tiny native macOS menu bar switch that keeps your display and Mac awake. Gray with the knob on the left means **off**; green with the knob on the right means **on**. Click to toggle; right-click for **Quit Insomnia**. There is no Dock icon or visible app name in the menu bar.

## Requirements

macOS 13 or later and the Swift Command Line Tools (`xcode-select --install`). Full Xcode is not required. The build script targets your Mac's architecture (Apple silicon or Intel).

## Install from source

```sh
git clone https://github.com/Aaronik/insomnia.git
cd insomnia
./build.sh
open -g build/Insomnia.app
```

For a permanent installation, copy the built app into your Applications folder and launch that copy instead:

```sh
mkdir -p ~/Applications
ditto build/Insomnia.app ~/Applications/Insomnia.app
open -g ~/Applications/Insomnia.app
```

You can add the installed app in **System Settings → General → Login Items** to launch at login. To update, quit Insomnia, rebuild, and replace the installed app. Don't launch both copies at once.

This repository distributes source code, not a notarized binary. `build.sh` creates an ad-hoc-signed app bundle locally.

## Build and checks

```sh
swift build       # checks the Swift package
./build.sh       # produces build/Insomnia.app
codesign --verify --strict build/Insomnia.app
```

Alternatively, open `Insomnia.xcodeproj` in Xcode and run its `Insomnia` target. To verify that the toggle acquired the power assertion, run `pmset -g assertions` while it is on and look for `Insomnia is keeping the display awake`. Clicking again or quitting releases it.

## How it works and limitations

Insomnia uses Apple's `PreventUserIdleDisplaySleep` IOKit assertion. While enabled, this prevents idle display sleep and thereby idle system sleep. It does not override manual locking or sleeping, a closed laptop lid, low battery, or system policy. Screen saver behavior is separately controlled by macOS settings and is not guaranteed to be suppressed. Insomnia does not simulate input or control Slack presence; Slack may still show you as away. macOS removes the assertion if the process exits unexpectedly. Keeping the display awake uses extra power.
