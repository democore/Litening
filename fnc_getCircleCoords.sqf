/*
Param 0: Center Point
Param 1: Angle
Param 2: Zoom	
Return type: array Position

This function calculates a point around the center.
Depending on the angle off center.
*/
private["_center","_angle","_zoom","_px","_py","_ret_pos"];
_center = _this select 0;
_angle = _this select 1;
_zoom = _this select 2;
_angle2 = _this select 3;

_px = _zoom * (cos _angle) * (sin _angle2) + (_center select 0);
_py = _zoom * (sin _angle) * (sin _angle2) + (_center select 1);
_pz = _zoom * (cos _angle2) + (_center select 2);
_ret_pos = [_px, _py, _pz - 1];
_ret_pos
