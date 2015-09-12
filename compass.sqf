_addCtrl =
{
	_type = _this select 0;
	_text = _this select 1;
	_x = (_this select 2);
	_y = (_this select 3);
	_w = (_this select 4);
	_h = (_this select 5);
	_toCreate = (finddisplay 46) ctrlCreate [_type, _ctrlIdCount];
	_ctrlIdCount = _ctrlIdCount + 1;
   
	if(_text != "") then
	{
			_toCreate ctrlSetText _text;
	};
	_toCreate ctrlSetPosition [_x, _y, _w, _h];
   
	_toCreate ctrlCommit 0;
	_controls = _controls + [_toCreate];
   
	_toCreate
};


_mavCurrentTarget = player;
_markerMavCurrentTargetPos = visiblePositionASL _mavCurrentTarget;
_compassSize = 1;

_northLocationX = _markerMavCurrentTargetPos select 0;
_northLocationY = (_markerMavCurrentTargetPos select 1) + _compassSize;
_southLocationX = _markerMavCurrentTargetPos select 0;
_southLocationY = (_markerMavCurrentTargetPos select 1) - _compassSize;
_westLocationX = (_markerMavCurrentTargetPos select 0) - _compassSize;
_westLocationY = _markerMavCurrentTargetPos select 1;
_eastLocationX = (_markerMavCurrentTargetPos select 0) + _compassSize;
_eastLocationY = _markerMavCurrentTargetPos select 1;
	_zLocation = 0;
if (surfaceIsWater [visiblePositionASL _mavCurrentTarget select 0,visiblePositionASL _mavCurrentTarget select 1]) then
{
	_zLocation = visiblePositionASL _mavCurrentTarget select 2;
} else
{
	_zLocation = visiblePosition _mavCurrentTarget select 2;
};

//=====NORTH
_northOnDisplayPos = worldToScreen [_northLocationX,_northLocationY,_zLocation];
_northDisplayText = "N";
hint format["x: %1, y: %2", _northOnDisplayPos select 0, _northOnDisplayPos select 1];
_north = ["RscText", "N", _northOnDisplayPos select 0, _northOnDisplayPos select 1, 0.1, 0.1] call _addCtrl;
		   /*
		   (_dspl displayCtrl 2020662) ctrlSetStructuredText parseText _northDisplayText;
		   (_dspl displayCtrl 2020662) ctrlSetPosition _northOnDisplayPos;
		   (_dspl displayCtrl 2020662) ctrlCommit 0;
 
		   //=====SOUTH
		   _southOnDisplayPos = worldToScreen [_southLocationX,_southLocationY,_zLocation];
		   _southDisplayText = "S";
		   (_dspl displayCtrl 2020663) ctrlSetStructuredText parseText _southDisplayText;
		   (_dspl displayCtrl 2020663) ctrlSetPosition _southOnDisplayPos;
		   (_dspl displayCtrl 2020663) ctrlCommit 0;
 
		   //=====WEST
		   _westOnDisplayPos = worldToScreen [_westLocationX,_westLocationY,_zLocation];
		   _westDisplayText = "W";
		   (_dspl displayCtrl 2020664) ctrlSetStructuredText parseText _westDisplayText;
		   (_dspl displayCtrl 2020664) ctrlSetPosition _westOnDisplayPos;
		   (_dspl displayCtrl 2020664) ctrlCommit 0;
 
		   //=====EAST
		   _eastOnDisplayPos = worldToScreen [_eastLocationX,_eastLocationY,_zLocation];
		   _eastDisplayText = "E";
		   (_dspl displayCtrl 2020665) ctrlSetStructuredText parseText _eastDisplayText;
		   (_dspl displayCtrl 2020665) ctrlSetPosition _eastOnDisplayPos;
		   (_dspl displayCtrl 2020665) ctrlCommit 0;*/