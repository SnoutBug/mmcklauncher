# mmcklauncher
A Launcher for KDE Plasma based on a [design by Max McKinney](https://dribbble.com/shots/10499841-Windows-10-Redesign-UI-Design)

#### Dark Theme
![MMcK Launcher Dark Theme](https://raw.githubusercontent.com/SnoutBug/mmcklauncher/main/images/mmck_launcher1.png)
#### Light Theme
![MMcK Launcher Light Theme](https://raw.githubusercontent.com/SnoutBug/mmcklauncher/main/images/mmck_launcher_light.png)
#### Matching current Theme
![MMcK Launcher Matching Theme](https://raw.githubusercontent.com/SnoutBug/mmcklauncher/main/images/mmck_launcher_matching.png)

## Installation

``` Bash
curl -s https://api.github.com/repos/snoutbug/mmcklauncher/releases/latest | grep "com.github.SnoutBug.mmckLauncher.tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -qi -
plasmapkg2 --install com.github.SnoutBug.mmckLauncher.tar.gz
rm com.github.SnoutBug.mmckLauncher.tar.gz
```

### Optional Requirements
Font: [SF Pro Text](https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts/blob/master/SF-Pro-Text-Semibold.otf)

## Upgrade

``` Bash
curl -s https://api.github.com/repos/snoutbug/mmcklauncher/releases/latest | grep "com.github.SnoutBug.mmckLauncher.tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -qi -
plasmapkg2 --upgrade com.github.SnoutBug.mmckLauncher.tar.gz
rm com.github.SnoutBug.mmckLauncher.tar.gz
```

## KDE Store
[store.kde.org/p/1720532](https://store.kde.org/p/1720532/)
