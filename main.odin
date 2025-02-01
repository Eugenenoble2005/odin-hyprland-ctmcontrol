package ctmcontrol
import "core:c"
import "core:fmt"
import "core:math"
import "core:os"
import protocols "protocols"
import wl "shared:wayland"

hyprland_ctm_control_manager_v1: ^protocols.hyprland_ctm_control_manager_v1
wl_output: ^protocols.wl_output
listener: protocols.wl_registry_listener = {global_add, global_remove}

global_add :: proc(
	data: rawptr,
	registry: ^protocols.wl_registry,
	name: c.uint32_t,
	interface: cstring,
	version: c.uint32_t,
) {
	if interface == protocols.hyprland_ctm_control_manager_v1_interface.name {
		hyprland_ctm_control_manager_v1 = (^protocols.hyprland_ctm_control_manager_v1)(
			protocols.wl_registry_bind(
				registry,
				name,
				&protocols.hyprland_ctm_control_manager_v1_interface,
				version,
			),
		)
	} else if interface == protocols.wl_output_interface.name {
		wl_output = (^protocols.wl_output)(
			protocols.wl_registry_bind(registry, name, &protocols.wl_output_interface, version),
		)
	}
}

global_remove :: proc(data: rawptr, wl_registry: ^protocols.wl_registry, name: c.uint32_t) {}

die :: proc(text: string) {
	fmt.println(text)
	os.exit(0)
}
main :: proc() {
	display := wl.display_connect(nil)
	defer wl.display_disconnect(display)
	if display == nil do die("Could not connect to a wayland compositor")
	fmt.println("Connection to wayland compositor has been established")

	registry := protocols.wl_display_get_registry(display)
	protocols.wl_registry_add_listener(registry, &listener, nil)
	wl.display_roundtrip(display)
	if hyprland_ctm_control_manager_v1 == nil {
		die("Compositor does not implement Hyprland Ctm Control. Are you running on Hyprland?")
	}
	defer protocols.hyprland_ctm_control_manager_v1_destroy(hyprland_ctm_control_manager_v1)
	KELVIN: f64 = 2500
	mat := matrixForKelvin(KELVIN)
	fmt.println("CTM MATRIX HAS BEEN CALCULATED AS:", mat)
	fmt.printfln("Applying Temperature of %f to display", KELVIN)
	apply_ctm(&mat)
	protocols.hyprland_ctm_control_manager_v1_commit(hyprland_ctm_control_manager_v1)
	for wl.display_dispatch(display) != -1 {}
}
apply_ctm :: proc(mat: ^matrix[3, 3]f64) {
	protocols.hyprland_ctm_control_manager_v1_set_ctm_for_output(
		hyprland_ctm_control_manager_v1,
		wl_output,
		wl.FixedFromDouble(mat[0][0]),
		wl.FixedFromDouble(mat[0][1]),
		wl.FixedFromDouble(mat[0][2]),
		wl.FixedFromDouble(mat[1][0]),
		wl.FixedFromDouble(mat[1][1]),
		wl.FixedFromDouble(mat[1][2]),
		wl.FixedFromDouble(mat[2][0]),
		wl.FixedFromDouble(mat[2][1]),
		wl.FixedFromDouble(mat[2][2]),
	)
}
matrixForKelvin :: proc(temp: f64) -> matrix[3, 3]f64 {
	temp := temp
	r, g, b: f64
	r = 1.0
	g = 1.0
	b = 1.0
	temp = temp / 100
	if temp <= 66 {
		r = 255
		g = math.clamp(99.4708025861 * math.ln_f64(temp) - 161.1195681661, 0.0, 255.0)
		if temp <= 19 do b = 0
		else {
			b = math.clamp(math.ln_f64(temp - 10) * 138.5177312231 - 305.0447927307, 0.0, 255.0)
		}
	} else {
		r = math.clamp(329.698727446 * (math.pow(temp - 60, -0.1332047592)), 0.0, 255.0)
		g = math.clamp(329.698727446 * (math.pow(temp - 60, -0.1332047592)), 0.0, 255.0)
		b = 255
	}
	return matrix[3, 3]f64{
		r / 255.0, 0, 0, 
		0, g / 255.0, 0, 
		0, 0, b / 255.0, 
	}
}
