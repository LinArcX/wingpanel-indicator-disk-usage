#  Wingpanel Disk-Usage Indicator
<h4 align="center">
    <img src="https://img.shields.io/travis/LinArcX/wingpanel-indicator-disk-usage"/>  <img src="https://img.shields.io/github/tag/LinArcX/wingpanel-indicator-disk-usage.svg?colorB=green"/>  <img src="https://img.shields.io/github/repo-size/LinArcX/wingpanel-indicator-disk-usage.svg"/>  <img src="https://img.shields.io/github/languages/top/LinArcX/wingpanel-indicator-disk-usage.svg"/>
</h4>

<h1 align="center">
    <img src="data/assets/wingpanel-indicator-disk-usage.png" align="center" width="400"/>
</h1>

## Building and Installation

You'll need the following dependencies:

 - `libglib2.0-dev`
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

### Distributions
#### Void [[WIP](https://github.com/void-linux/void-packages/pull/21155)]

## Donate
- Monero: `48VdRG9BNePEcrUr6Vx6sJeVz6EefGq5e2F5S9YV2eJtd5uAwjJ7Afn6YeVTWsw6XGS6mXueLywEea3fBPztUbre2Lhia7e`
<img src="data/assets/donate/monero.png" align="center" />

## License
![License](https://img.shields.io/github/license/LinArcX/wingpanel-indicator-disk-usage.svg)
