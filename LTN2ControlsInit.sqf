//https://dev.withsix.com/projects/cca/wiki/Keybinding

_modName = "LTN2";

[
	_modName, //Name of the registering mod [String]
	"zoom_in_key", //Id of the key action. [String]
	"Zoom in", //Pretty name, or an array of strings for the pretty name and a tool tip [String]
	{_this call LTN2_fncZoomIn}, //Code for down event, empty string for no code. [Code]
	{}, //Code for up event, empty string for no code. [Code]
	[DIK_NUMPAD8 ,[false, false, false]] //The keybinding data in the format [DIK, [shift, ctrl, alt]] [Array]
] call CBA_fnc_addKeybind;

[
	_modName, //Name of the registering mod [String]
	"zoom_out_key", //Id of the key action. [String]
	"Zoom out", //Pretty name, or an array of strings for the pretty name and a tool tip [String]
	{_this call LTN2_fncZoomOut}, //Code for down event, empty string for no code. [Code]
	{}, //Code for up event, empty string for no code. [Code]
	[DIK_NUMPAD2 ,[false, false, false]] //The keybinding data in the format [DIK, [shift, ctrl, alt]] [Array]
] call CBA_fnc_addKeybind;