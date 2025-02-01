Odin clone of hyprsunset , a wayland client to control the output CTM of wayland compositors that implement hyprland-ctm-control-manager-v1

This is a simple example of a practical wayland client written in odin,
It is a port of https://www.github.com/hyprwm/hyprsunset to odin.

# Running
Clone recursively 
```
git clone https://www.github.com/eugenenoble2005/odin-hyprland-ctmcontrol.git --recursive
```
Scan protocols whenever needed and run with just:
```
just scan-protocol
just run
```

# DEPENDENCIES 
Other than the standard wayland libraries, you will need to have hyprland-protocols(https://www.github.com/hyprwm/hyprland-protocols) installed. The program will build run on any setup but the ctm effect will only be realised on hyprland or a compositor that implements ctm control

