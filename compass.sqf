if (hasInterface) then
{
	with currentNamespace do
		{
			while {active} do
			{
			waitUntil {time > 0};
			disableSerialization;
			_ctrlIdCount = 12301;
			_controls = [];
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
_mavCurrentTarget = air;
_markerMavCurrentTargetPos = visiblePositionASL _mavCurrentTarget;
_compassSize = 3;

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
hint format["x: %1, y: %2", _northOnDisplayPos select 0, _northOnDisplayPos select 1];
_north = ["RscText", "N", 0, 0, 0.1, 0.1] call _addCtrl;
//=====NORTH
_northOnDisplayPos = worldToScreen [_northLocationX,_northLocationY,_zLocation];
_northDisplayText = "<t align='LEFT' valign='TOP' color='#FF0000' size='1.2' >N</t>";
_north ctrlSetStructuredText parseText _northDisplayText;
_north ctrlSetPosition _northOnDisplayPos;
_north ctrlCommit 0;

//=====SOUTH
_southOnDisplayPos = worldToScreen [_southLocationX,_southLocationY,_zLocation];
_southDisplayText = "<t align='LEFT' valign='TOP' color='#00FF00' size='1.2' >S</t>";
_south = ["RscText", "S", 0, 0, 0.1, 0.1] call _addCtrl;
_south ctrlSetStructuredText parseText _southDisplayText;
_south ctrlSetPosition _southOnDisplayPos;
_south ctrlCommit 0;

//=====WEST
_westOnDisplayPos = worldToScreen [_westLocationX,_westLocationY,_zLocation];
_westDisplayText = "<t align='LEFT' valign='TOP' color='#00FF00' size='1.2' >W</t>";
_west = ["RscText", "W", 0, 0, 0.1, 0.1] call _addCtrl;
_west ctrlSetStructuredText parseText _westDisplayText;
_west ctrlSetPosition _westOnDisplayPos;
_west ctrlCommit 0;

//=====EAST
_eastOnDisplayPos = worldToScreen [_eastLocationX,_eastLocationY,_zLocation];
_eastDisplayText = "<t align='LEFT' valign='TOP' color='#00FF00' size='1.2' >E</t>";
_east = ["RscText", "E", 0, 0, 0.1, 0.1] call _addCtrl;
_east ctrlSetStructuredText parseText _eastDisplayText;
_east ctrlSetPosition _eastOnDisplayPos;
_east ctrlCommit 0;

sleep 0.1;
{
		ctrlDelete _x;
} foreach _controls;
};
};
};