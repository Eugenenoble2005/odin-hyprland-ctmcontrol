scan-protocol:
    odin build shared/wayland/scanner
    mkdir protocols
    ./scanner client /usr/share/wayland/wayland.xml protocols
    ./scanner client /usr/share/hyprland-protocols/protocols/hyprland-ctm-control-v1.xml protocols

run:
    odin run . -collection:shared=shared    
