//https://dev.withsix.com/projects/cca/wiki/Keybinding

_modName = "LTN2";

[_modName, "zoom_in_key", "Zoom in", {_this spawn LTN2_fncZoomIn;}, {}] call CBA_fnc_addKeybind;

[_modName, "zoom_out_key", "Zoom out", {_this spawn LTN2_fncZoomOut;}, {}] call CBA_fnc_addKeybind;

[_modName, "tgp_slew_left", "Slew left", {_this spawn LTN2_fncSlewLeft;}, {}] call CBA_fnc_addKeybind;

[_modName, "tgp_slew_right", "Slew right", {_this spawn LTN2_fncSlewRight;}, {}] call CBA_fnc_addKeybind;

[
	_modName, //Name of the registering mod [String]
	"tgp_slew_up", //Id of the key action. [String]
	"Slew up", //Pretty name, or an array of strings for the pretty name and a tool tip [String]
	{_this spawn LTN2_fncSlewUp;}, //Code for down event, empty string for no code. [Code]
	{} //The keybinding data in the format [DIK, [shift, ctrl, alt]] [Array]
] call CBA_fnc_addKeybind;

[
	_modName, //Name of the registering mod [String]
	"tgp_slew_down", //Id of the key action. [String]
	"Slew down", //Pretty name, or an array of strings for the pretty name and a tool tip [String]
	{_this spawn LTN2_fncSlewDown;}, //Code for down event, empty string for no code. [Code]
	{} //The keybinding data in the format [DIK, [shift, ctrl, alt]] [Array]
] call CBA_fnc_addKeybind;

[
	_modName, //Name of the registering mod [String]
	"tgp_view_reset", //Id of the key action. [String]
	"Reset TGP", //Pretty name, or an array of strings for the pretty name and a tool tip [String]
	{_this call LTN2_fncTgpReset;}, //Code for down event, empty string for no code. [Code]
	{} //The keybinding data in the format [DIK, [shift, ctrl, alt]] [Array]
] call CBA_fnc_addKeybind;

[
	_modName, //Name of the registering mod [String]
	"tgp_lock_ground", //Id of the key action. [String]
	"Lock ground", //Pretty name, or an array of strings for the pretty name and a tool tip [String]
	{_this call LTN2_fncLockGround;}, //Code for down event, empty string for no code. [Code]
	{} //The keybinding data in the format [DIK, [shift, ctrl, alt]] [Array]
] call CBA_fnc_addKeybind;

[
	_modName, //Name of the registering mod [String]
	"tgp_lock_tgt", //Id of the key action. [String]
	"Lock Target", //Pretty name, or an array of strings for the pretty name and a tool tip [String]
	{_this call LTN2_fncLockTgt;}, //Code for down event, empty string for no code. [Code]
	{} //The keybinding data in the format [DIK, [shift, ctrl, alt]] [Array]
] call CBA_fnc_addKeybind;

[
	_modName, //Name of the registering mod [String]
	"tgp_unlock", //Id of the key action. [String]
	"Unlock", //Pretty name, or an array of strings for the pretty name and a tool tip [String]
	{_this call LTN2_fncUnlock;}, //Code for down event, empty string for no code. [Code]
	{} //The keybinding data in the format [DIK, [shift, ctrl, alt]] [Array]
] call CBA_fnc_addKeybind;

[
	_modName, //Name of the registering mod [String]
	"tgp_next_dl", //Id of the key action. [String]
	"Next datalink target/wp", //Pretty name, or an array of strings for the pretty name and a tool tip [String]
	{_this call LTN2_fncTgpNextDL;}, //Code for down event, empty string for no code. [Code]
	{} //The keybinding data in the format [DIK, [shift, ctrl, alt]] [Array]
] call CBA_fnc_addKeybind;

[
	_modName, //Name of the registering mod [String]
	"tgp_prev_dl", //Id of the key action. [String]
	"Previous datalink target/wp", //Pretty name, or an array of strings for the pretty name and a tool tip [String]
	{_this call LTN2_fncTgpPrevDL;}, //Code for down event, empty string for no code. [Code]
	{} //The keybinding data in the format [DIK, [shift, ctrl, alt]] [Array]
] call CBA_fnc_addKeybind;

[
	_modName, //Name of the registering mod [String]
	"tgp_toggle_laser", //Id of the key action. [String]
	"Toggle Laser", //Pretty name, or an array of strings for the pretty name and a tool tip [String]
	{_this call LTN2_fncToggleLaser;}, //Code for down event, empty string for no code. [Code]
	{} //The keybinding data in the format [DIK, [shift, ctrl, alt]] [Array]
] call CBA_fnc_addKeybind;

/*
TGP Slew left
TGP slew right
TGP slew up
TGP slew down
TGP view reset
TGP lock ground
TGP Lock target
TGP Unlock
TGP next datalink target/wp
TGP previous datalink target/wp
TGP toggle laser
*/