#  Wingpanel Disk-Usage Indicator
<h4 align="center">
    <img src="https://img.shields.io/travis/LinArcX/wingpanel-indicator-disk-usage"/>  <img src="https://img.shields.io/github/tag/LinArcX/wingpanel-indicator-disk-usage.svg?colorB=green"/>  <img src="https://img.shields.io/github/repo-size/LinArcX/wingpanel-indicator-disk-usage.svg"/>  <img src="https://img.shields.io/github/languages/top/LinArcX/wingpanel-indicator-disk-usage.svg"/>
</h4>

<h1 align="center">
    <img src="data/assets/shot.png" align="center" width="500"/>
</h1>

## Building and Installation

You'll need the following dependencies:

 - `libglib2.0-dev`
 - `libgranite-dev`
 - `libgtk-3-dev`
 - `libwingpanel-2.0-dev`
 - `meson`
 - `valac`

Run `meson` to configure the build environment and then ninja to build:

```
meson build --prefix=/usr
cd build
ninja
```

To install, use ninja install:

`sudo ninja install`

## Installation
### Void [WIP]

## License
![License](https://img.shields.io/github/license/LinArcX/wingpanel-indicator-disk-usage.svg)
