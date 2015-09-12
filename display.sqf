LTN2_TGP_TGT = objNull;
LTN2_NULLTGT = true;
LTN2_ZOOM = 0;
LTN2_fncGetTgtCoords =
{
		_tgt_coords = format["%1",[0,0,0]];
		if (!LTN2_NULLTGT) then {
				_tgt_coords = format["%1", getPosASL LTN2_TGP_TGT];
		};
		_tgt_coords
};
 
LTN2_fncGetTgtDist =
{
		private["_tgt_dist","_int_dist"];
		_tgt_dist = format["%1",0];
		if (!LTN2_NULLTGT) then {
				_int_dist = round(air distance LTN2_TGP_TGT);
				if (_int_dist > 10000) then {
					_int_dist = 9999;
				};
				_tgt_dist = format["%1 M", _int_dist];
		};
		_tgt_dist
};

LTN2_fncThreeSixtyHelper = {
	/*
	Param 0: 360° number to work with
	Param 1: Operand + number
	Return: Number between 0-359
	
	Function to add substract angles
	*/
	private["_operand1_num","_operand2_num","_tmp_num","_tmp_mod_num","_ret_num"];
	_operand1_num = _this select 0;
	_operand2_num = _this select 1;
	_tmp_num = _operand1_num + _operand2_num;
	_ret_num = 0;
	if (_tmp_num < 360 && _tmp_num >= 0) then {
		_ret_num = _tmp_num;
	} else {
		_tmp_mod_num = _tmp_num mod 360;
		if (_tmp_mod_num > 0) then {
			_ret_num = _tmp_mod_num;
		} else {
			_ret_num = 360 + _tmp_mod_num;
		};
	};
	_ret_num 
};

LTN2_yaw = 0;
LTN2_pitch = 90;
LTN2_fnc_getCircleCoords = compile preprocessFile "fnc_getCircleCoords.sqf";
LTN2_fncSlewLeft = 
{
	LTN2_yaw = [LTN2_yaw, 1] call LTN2_fncThreeSixtyHelper;
};
LTN2_fncSlewRight = 
{
	LTN2_yaw = [LTN2_yaw, -1] call LTN2_fncThreeSixtyHelper;
};
LTN2_fncSlewUp =
{
		//FIXME MAKE THIS SAFE
		LTN2_pitch = LTN2_pitch - 1
};
LTN2_fncSlewDown =
{
		//FIXME MAKE THIS SAFE
		LTN2_pitch = LTN2_pitch + 1
};
LTN2_fncToggleLaser = {};
LTN2_fncTgpReset = {};
LTN2_fncTgpPrevDL = {};
LTN2_fncTgpNextDL = {};
LTN2_fncLockGround = {};
LTN2_fncLockTgt = {};
LTN2_fncUnlock = {};

LTN2_fncZoomIn = 
{	
	if (LTN2_ZOOM > -0.95) then {
		LTN2_ZOOM = LTN2_ZOOM - 0.025;
	} else {
		LTN2_ZOOM = LTN2_ZOOM;
	};
	//FIXME ugly shit. THERE MUST BE A BETTER WAY!
	if (LTN2_ZOOM < -0.95) then {
		LTN2_ZOOM = -0.95;
	};
};

LTN2_fncZoomOut = 
{
	if (LTN2_ZOOM < 0) then {
		LTN2_ZOOM = LTN2_ZOOM + 0.025;
	} else {
		LTN2_ZOOM = LTN2_ZOOM;
	};
	//FIXME ugly shit. THERE MUST BE A BETTER WAY!
	if (LTN2_ZOOM > 0) then {
		LTN2_ZOOM = 0;
	};
};
		   
_controls = [];
_cameras = [];
LTN2_active = true;
LTN2_laserActive = true;
 
if (hasInterface) then
{
	with currentNamespace do
		{
			waitUntil {time > 0};
			disableSerialization;
			_ctrlIdCount = 1000;
			//time Calculation
			LTN2_fncGetTime =
			{
					_hour = floor daytime;
					_strHour = str(_hour);
					if(_hour < 10) then
					{
							_strHour = format["0%1", _hour];
					};
					_minute = floor ((daytime - _hour) * 60);
					_strMinute = str(_minute);
					if(_minute < 10) then
					{
							_strMinute = format["0%1", _minute];
					};
					_second = floor (((((daytime) - (_hour))*60) - _minute)*60);
					_strSecond = str(_second);
					if(_second < 10) then
					{
							_strSecond = format["0%1", _second];
					};
					_time24 = format ["%1:%2:%3",_strHour,_strMinute,_strSecond];
					_time24
			};
		   
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
		   
			_mainSize = 1;
		   
			_screenWidth = safeZoneW / (5 * _mainSize);
			_screenHeight = safeZoneH / (3 * _mainSize);
			_baseX =  safeZoneX + (safeZoneW - _screenWidth) - 0.01;
			_baseY = safeZoneY + (safeZoneH - _screenHeight) - 0.3;
		   
			///3d Renderer
			_rightRenderSurface = ["RscPicture", "", _baseX,_baseY,_screenWidth,_screenHeight] call _addCtrl;
			_rightRenderSurface ctrlSetText "#(argb,512,512,1)r2t(leftcam,1)";
		   
			///general settings
			_alpha = 0.5;
		   
			///Green Border
			_LeftRightDistance = 0.03;
			_BottomTopDistance = 0.04;
		   
			_leftBorder = _baseX + _LeftRightDistance;
			_rightBorder = _baseX + _screenWidth - _LeftRightDistance;
			_topBorder = _baseY + _BottomTopDistance;
			_bottomBorder = _baseY + _screenHeight - _BottomTopDistance;
		   
			_borderHeight = 0.005;
			_borderWidht = _screenWidth - _LeftRightDistance * 2 - _borderHeight;
			_upperBorderRSC = ["RscText", "", _leftBorder + _borderHeight, _topBorder, _borderWidht + 0.001, _borderHeight] call _addCtrl;
			_upperBorderRSC ctrlSetBackgroundColor [0, 0.5, 0, _alpha];
		   
			_borderWidht = _screenWidth - _LeftRightDistance * 2 - _borderHeight;
			_bottomBorderRSC = ["RscText", "", _leftBorder + _borderHeight - 0.005, _bottomBorder, _borderWidht + 0.01, _borderHeight] call _addCtrl;
			_bottomBorderRSC ctrlSetBackgroundColor [0, 0.5, 0, _alpha];
		   
			_borderHeight = _screenHeight - _BottomTopDistance * 2;
			_borderWidht = 0.005;
			_LeftBorderRSC = ["RscText", "", _leftBorder, _topBorder, _borderWidht, _borderHeight] call _addCtrl;
			_LeftBorderRSC ctrlSetBackgroundColor [0, 0.5, 0, _alpha];
		   
			_borderHeight = _screenHeight - _BottomTopDistance * 2;
			_borderWidht = 0.005;
			_rightBorderRSC = ["RscText", "", _rightBorder, _topBorder, _borderWidht, _borderHeight] call _addCtrl;
			_rightBorderRSC ctrlSetBackgroundColor [0, 0.5, 0, _alpha];
		   
			//Bottom Texts
			_size = 0.025 * (2 - _mainSize);
			_whiteSize = 0.035 * (2 - _mainSize);
			_distance = _screenWidth / 7.1;
			_BottomDistance = 0.003;
			_LeftDistance = 0.01;
			_h = _screenHeight / 16;
		   
			_w = _screenWidth / 11;
			_textX = _baseX + _distance * 0 + _LeftDistance;
			_textY = _baseY + _screenHeight - (_h + _BottomDistance);
			_DIR = ["RscText", "000", _textX, _textY, _w, _h] call _addCtrl;
			_DIR ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_DIR ctrlSetTextColor [0, 1, 0, _alpha];
			_DIR ctrlSetFont "TahomaB";
			_DIR ctrlSetFontHeight _size;
		   
			_w = _screenWidth / 9.5;
			_textX = _baseX + _distance * 1 + _LeftDistance;
			_MSG = ["RscText", "MSG", _textX, _textY, _w, _h] call _addCtrl;
			_MSG ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_MSG ctrlSetTextColor [0, 1, 0, _alpha];
			_MSG ctrlSetFont "TahomaB";
			_MSG ctrlSetFontHeight _size;
		   
			_w = _screenWidth / 9.5;
			_textX = _baseX + _distance * 2 + _LeftDistance;
			_TGP = ["RscText", "TGP", _textX, _textY, _w, _h] call _addCtrl;
			_TGP ctrlSetBackgroundColor [0, 1, 0, _alpha];
			_TGP ctrlSetTextColor [0, 0, 0, _alpha];
			_TGP ctrlSetFont "TahomaB";
			_TGP ctrlSetFontHeight _size;
		   
			_w = _screenWidth / 9.5;
			_textX = _baseX + _distance * 3 + _LeftDistance;
			_CDU = ["RscText", "CDU", _textX, _textY, _w, _h] call _addCtrl;
			_CDU ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_CDU ctrlSetTextColor [0, 1, 0, _alpha];
			_CDU ctrlSetFont "TahomaB";
			_CDU ctrlSetFontHeight _size;
		   
			_w = _screenWidth / 8;
			_textX = _baseX + _distance * 4 + _LeftDistance;
			_STAT = ["RscText", "STAT", _textX, _textY, _w, _h] call _addCtrl;
			_STAT ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_STAT ctrlSetTextColor [0, 1, 0, _alpha];
			_STAT ctrlSetFont "TahomaB";
			_STAT ctrlSetFontHeight _size;
		   
			_w = _screenWidth / 8;
			_textX = _baseX + _distance * 5 + _LeftDistance;
			_DCLT = ["RscText", "DCLT", _textX, _textY, _w, _h] call _addCtrl;
			_DCLT ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_DCLT ctrlSetTextColor [0, 1, 0, _alpha];
			_DCLT ctrlSetFont "TahomaB";
			_DCLT ctrlSetFontHeight _size;
		   
			//left texts
			_textW = _screenWidth / 11;
			_textX = _baseX + (_LeftDistance + 0.01);
			_textY = _baseY + _screenHeight - _screenHeight/2.15;
			_LSS = ["RscText", "LSS", _textX, _textY, _textW, _h] call _addCtrl;
			_LSS ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_LSS ctrlSetTextColor [0, 1, 0, _alpha];
			_LSS ctrlSetFont "TahomaB";
			_LSS ctrlSetFontHeight _size;
		   
			_textW = _screenWidth / 8.5;
			_textX = _baseX + (_LeftDistance + 0.01);
			_textY = _baseY + _screenHeight - _screenHeight/1.75;
			_GAIN = ["RscText", "GAIN", _textX, _textY, _textW, _h] call _addCtrl;
			_GAIN ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_GAIN ctrlSetTextColor [0, 1, 0, _alpha];
			_GAIN ctrlSetFont "TahomaB";
			_GAIN ctrlSetFontHeight _size;
		   
			_textW = _screenWidth / 13;
			_textX = _baseX + (_LeftDistance);
			_textY = _baseY + _screenHeight - _screenHeight/1.35;
			_BRIGHT = ["RscText", "3G", _textX, _textY, _textW, _h] call _addCtrl;
			_BRIGHT ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_BRIGHT ctrlSetTextColor [0, 1, 0, _alpha];
			_BRIGHT ctrlSetFont "TahomaB";
			_BRIGHT ctrlSetFontHeight _size;
		   
			//upper texts
			_textW = _screenWidth / 10;
			_textX = _baseX + _distance * 0 + _LeftDistance;
			_textY = _baseY + _screenHeight / 60;
			_ZOOM = ["RscText", "0Z", _textX, _textY, _textW, _h] call _addCtrl;
			_ZOOM ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_ZOOM ctrlSetTextColor [0, 1, 0, _alpha];
			_ZOOM ctrlSetFont "TahomaB";
			_ZOOM ctrlSetFontHeight _size;
		   
			_textW = _screenWidth / 8.5;
			_textX = _baseX + _distance * 0 + _LeftDistance;
			_textY = _baseY + _screenHeight / 12;
			_NARO = ["RscText", "NARO", _textX, _textY, _textW, _h] call _addCtrl;
			_NARO ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_NARO ctrlSetTextColor [0, 1, 0, _alpha];
			_NARO ctrlSetFont "TahomaB";
			_NARO ctrlSetFontHeight _size;
		   
			_textW = _screenWidth / 8.5;
			_textX = _baseX + _distance * 1 + _LeftDistance;
			_textY = _baseY + _screenHeight / 60;
			_CNTL = ["RscText", "CNTL", _textX, _textY, _textW, _h] call _addCtrl;
			_CNTL ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_CNTL ctrlSetTextColor [0, 1, 0, _alpha];
			_CNTL ctrlSetFont "TahomaB";
			_CNTL ctrlSetFontHeight _size;
		   
			_textW = _screenWidth / 11;
			_textX = _baseX + _distance * 2 + _LeftDistance;
			_AG = ["RscText", "A-G", _textX, _textY, _textW, _h] call _addCtrl;
			_AG ctrlSetBackgroundColor [0, 1, 0, _alpha];
			_AG ctrlSetTextColor [0, 0, 0, _alpha];
			_AG ctrlSetFont "TahomaB";
			_AG ctrlSetFontHeight _size;
		   
			_textW = _screenWidth / 8.5;
			_textX = _baseX + _distance * 3 + _LeftDistance;
			_STBY = ["RscText", "STBY", _textX, _textY, _textW, _h] call _addCtrl;
			_STBY ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_STBY ctrlSetTextColor [0, 1, 0, _alpha];
			_STBY ctrlSetFont "TahomaB";
			_STBY ctrlSetFontHeight _size;
		   
			_textW = _screenWidth / 11;
			_textX = _baseX + _distance * 4 + _LeftDistance;
			_AA = ["RscText", "A-A", _textX, _textY, _textW, _h] call _addCtrl;
			_AA ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_AA ctrlSetTextColor [0, 1, 0, _alpha];
			_AA ctrlSetFont "TahomaB";
			_AA ctrlSetFontHeight _size;
		   
			_textW = _screenWidth / 8.5;
			_textX = _baseX + _distance * 5 + _LeftDistance;
			_TST = ["RscText", "0TST", _textX, _textY, _textW, _h] call _addCtrl;
			_TST ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_TST ctrlSetTextColor [0, 1, 0, _alpha];
			_TST ctrlSetFont "TahomaB";
			_TST ctrlSetFontHeight _size;
		   
			_textW = _screenWidth / 8;
			_textX = _baseX + _distance * 6 + _LeftDistance;
			_WHOT = ["RscText", "WHOT", _textX, _textY, _textW, _h] call _addCtrl;
			_WHOT ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_WHOT ctrlSetTextColor [0, 1, 0, _alpha];
			_WHOT ctrlSetFont "TahomaB";
			_WHOT ctrlSetFontHeight _size;
		   
			_textW = _screenWidth / 8;
			_textY = _baseY + _screenHeight / 12;
			_textX = _baseX + _distance * 6 + _LeftDistance;
			_HEIGHT = ["RscText", "4799", _textX, _textY, _textW, _h] call _addCtrl;
			_HEIGHT ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_HEIGHT ctrlSetTextColor [0, 1, 0, _alpha];
			_HEIGHT ctrlSetFont "TahomaB";
			_HEIGHT ctrlSetFontHeight _size;
		   
			_textW = _screenWidth / 10;
			_textY = _baseY + _screenHeight / 5;
			_textX = _baseX + _distance * 6 + _LeftDistance;
			_LSSe = ["RscText", "LSSe", _textX, _textY, _textW, _h] call _addCtrl;
			_LSSe ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_LSSe ctrlSetTextColor [0, 1, 0, _alpha];
			_LSSe ctrlSetFont "TahomaB";
			_LSSe ctrlSetFontHeight _size;
		   
			_textW = _screenWidth / 10;
			_textY = _baseY + _screenHeight / 3;
			_textX = _baseX + _distance * 6 + _LeftDistance;
			_LSR = ["RscText", "LSR", _textX, _textY, _textW, _h] call _addCtrl;
			_LSR ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_LSR ctrlSetTextColor [0, 1, 0, _alpha];
			_LSR ctrlSetFont "TahomaB";
			_LSR ctrlSetFontHeight _size;
		   
		   
			///General Texts
			//time
			_textW = _screenWidth / 6;
			_textX = _baseX + _LeftDistance;
			_textY = _baseY + _screenHeight - _screenHeight/3.5;
			_TIME = ["RscText", call LTN2_fncGetTime, _textX, _textY, _textW, _h] call _addCtrl;
			_TIME ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_TIME ctrlSetTextColor [0, 1, 0, _alpha];
			_TIME ctrlSetFont "TahomaB";
			_TIME ctrlSetFontHeight _size;
		   
			//Coords
			_textW = _screenWidth / 2.2;
			_textX = (_baseX + _screenWidth / 2) - _textW/2;
			_textY = _baseY + _screenHeight - _screenHeight/6;
			_CORD = ["RscText", call LTN2_fncGetTgtCoords, _textX, _textY, _textW, _h] call _addCtrl;
			_CORD ctrlSetBackgroundColor [0, 0, 0, _alpha];
			_CORD ctrlSetTextColor [0, 1, 0, _alpha];
			_CORD ctrlSetFont "TahomaB";
			_CORD ctrlSetFontHeight _size;
		   
			//Lasing?
			_textW = _screenWidth / 20;
			_textX = (_baseX + _screenWidth / 2) + _textW/2;
			_textY = _baseY + _screenHeight - _screenHeight/3.5;
			_LASER = ["RscText", "L", _textX, _textY, _textW, _h] call _addCtrl;
			_LASER ctrlSetTextColor [1, 1, 1, _alpha];
			_LASER ctrlSetFont "TahomaB";
			_LASER ctrlSetFontHeight _whiteSize;
		   
			//Distance
			_textW = _screenWidth / 6;
			_textX = (_baseX + _screenWidth ) - (_textW + _screenWidth / 8);
			_textY = _baseY + _screenHeight - _screenHeight/3.5;
			_POTDISTANCE = ["RscText", call LTN2_fncGetTgtDist, _textX, _textY, _textW, _h] call _addCtrl;
			_POTDISTANCE ctrlSetTextColor [1, 1, 1, _alpha];
			_POTDISTANCE ctrlSetFont "TahomaB";
			_POTDISTANCE ctrlSetFontHeight _whiteSize;
		   
		   
			///crosshair
			_crosshairLength = 8;
			_crossHairGapSize = 30;
			_crosshairGapWidth = _screenWidth / _crossHairGapSize;
			_crosshairGapHeight = _screenHeight / _crossHairGapSize;
			_crosshairWidth = 0.004;
			_adjust = 0;
		   
			//DistanceScale
			_textW = _screenWidth / 8;
			_textX = (_baseX + _screenWidth / 2) + _crosshairGapWidth + _screenWidth / _crosshairLength;
			_textY = _baseY + _screenHeight/2 - _screenHeight / 20;
			_SCALE = ["RscText", "23M", _textX, _textY, _textW, _h] call _addCtrl;
			_SCALE ctrlSetTextColor [1, 1, 1, _alpha];
			_SCALE ctrlSetFont "TahomaB";
			_SCALE ctrlSetFontHeight _whiteSize;
		   
			//main crosshair
			_crosshairX = _baseX + _screenWidth / 2;
			_crosshairY = ((_baseY + _screenHeight / 2) - _crosshairGapHeight) - _screenHeight / _crosshairLength;
			_crosshairW = _crosshairWidth * 0.6666;
			_crosshairH = _screenHeight / _crosshairLength;
			_upperCrosshair = ["RscText", "", _crosshairX, _crosshairY, _crosshairW, _crosshairH] call _addCtrl;
			_upperCrosshair ctrlSetBackgroundColor [1, 1, 1, _alpha];
		   
			_crosshairX = ((_baseX + _screenWidth / 2) - _crosshairGapWidth) - _screenWidth / _crosshairLength;
			_crosshairY = _baseY + _screenHeight / 2;
			_crosshairW = _screenWidth / _crosshairLength;
			_crosshairH = _crosshairWidth;
			_leftCrosshair = ["RscText", "", _crosshairX, _crosshairY, _crosshairW, _crosshairH] call _addCtrl;
			_leftCrosshair ctrlSetBackgroundColor [1, 1, 1, _alpha];
		   
			_crosshairX = (_baseX + _screenWidth / 2) + _crosshairGapWidth;
			_crosshairY = _baseY + _screenHeight / 2;
			_crosshairW = _screenWidth / _crosshairLength;
			_crosshairH = _crosshairWidth;
			_rightCrosshair = ["RscText", "", _crosshairX, _crosshairY, _crosshairW, _crosshairH] call _addCtrl;
			_rightCrosshair ctrlSetBackgroundColor [1, 1, 1, _alpha];
		   
			_crosshairX = _baseX + _screenWidth / 2;
			_crosshairY = (_baseY + _screenHeight / 2) + _crosshairGapHeight + 0.004;
			_crosshairW = _crosshairWidth * 0.6666;
			_crosshairH = _screenHeight / _crosshairLength;
			_lowerCrosshair = ["RscText", "", _crosshairX, _crosshairY, _crosshairW, _crosshairH] call _addCtrl;
			_lowerCrosshair ctrlSetBackgroundColor [1, 1, 1, _alpha];
		   
			//middle square part
			_squareX = _baseX + _screenWidth / 2 - _crosshairGapWidth;
			_squareY = _baseY + _screenHeight / 2 - _crosshairGapHeight;
			_squareW = _crosshairGapWidth * 2;
			_squareH = _crosshairWidth;
			_upperSquare = ["RscText", "", _squareX, _squareY, _squareW, _squareH] call _addCtrl;
			_upperSquare ctrlSetBackgroundColor [1, 1, 1, _alpha];
		   
			_squareX = _baseX + _screenWidth / 2 - _crosshairGapWidth;
			_squareY = _baseY + _screenHeight / 2 - _crosshairGapHeight + _crosshairWidth;
			_squareW = _crosshairWidth * 0.6666;
			_squareH = _crosshairGapHeight * 2 - _crosshairWidth;
			_leftSquare = ["RscText", "", _squareX, _squareY, _squareW, _squareH] call _addCtrl;
			_leftSquare ctrlSetBackgroundColor [1, 1, 1, _alpha];
		   
			_squareX = _baseX + _screenWidth / 2 - _crosshairGapWidth;
			_squareY = _baseY + _screenHeight / 2 + _crosshairGapHeight;
			_squareW = _crosshairGapWidth * 2;
			_squareH = _crosshairWidth;
			_lowerSquare = ["RscText", "", _squareX, _squareY, _squareW, _squareH] call _addCtrl;
			_lowerSquare ctrlSetBackgroundColor [1, 1, 1, _alpha];
		   
			_squareX = _baseX + _screenWidth / 2 + _crosshairGapWidth - _crosshairWidth * 0.666;
			_squareY = _baseY + _screenHeight / 2 - _crosshairGapHeight + _crosshairWidth;
			_squareW = _crosshairWidth * 0.6666;
			_squareH = _crosshairGapHeight * 2 - _crosshairWidth;
			_rightSquare = ["RscText", "", _squareX, _squareY, _squareW, _squareH] call _addCtrl;
			_rightSquare ctrlSetBackgroundColor [1, 1, 1, _alpha];
		   
			//http://killzonekid.com/arma-scripting-tutorials-3d-compass/
			//drawt hinter UI
		   
			[_TIME, _CORD, _POTDISTANCE, _LASER] spawn 
			{ 
				disableSerialization;
				_timeRsc = _this select 0;
				_cordRsc = _this select 1;
				_potdistanceRsc = _this select 2;
				_laserRsc = _this select 3;
				while {LTN2_active} do
				{
					//keep time updated
					_timeRsc ctrlSetText (call LTN2_fncGetTime);
					
					//LTN2_TGP_TGT <- Target
					_cordRsc ctrlSetText (call LTN2_fncGetTgtCoords);
					
					//Distance to the target
					_potdistanceRsc ctrlSetText (call LTN2_fncGetTgtDist);
					
					//Is laser LTN2_active?
					_laserRsc ctrlShow LTN2_laserActive;
					
					
					sleep 0.5;
				};
			};
		};
};
 
uav = createVehicle ["B_UAV_01_F", getpos air, [], 0, "FLY"];
uav allowdamage false;
createVehicleCrew uav;
uav attachTo [air, [0,0,-1]];
//uav hideObjectGlobal true;
//uav engineOn false;

cam = "camera" camCreate [0,0,0];
cam cameraEffect ["Internal", "Back", "leftcam"];
cam attachTo [uav, [0,0,0], "PiP0_pos"]; //cam attachTo [air, [0,0,-1]];
cam camSetFov 0.1;
_cameras = _cameras + [cam];
"leftcam" setPiPEffect [2];//[7] -> Thermal inverted, [1] -> Nightvision

FOV = 0.1;
XYZ = [0,0,0];
LTN2_MAXZOOM = -2000;
 
_handler = addMissionEventHandler ["Draw3D", {
		_intern_tgt = objNull;
		//XYZ = [(getPosASL air), LTN2_yaw, LTN2_ZOOM * LTN2_MAXZOOM] call LTN2_fnc_getCircleCoords;
		if (LTN2_NULLTGT) then {
			_z = (round abs ((air call BIS_fnc_getPitchBank) select 0)) + LTN2_pitch;
			__x = [LTN2_yaw, getDir air] call LTN2_fncThreeSixtyHelper;
			LTN2_TGP_TGT = [(getPosASL air), __x, (LTN2_ZOOM * LTN2_MAXZOOM) + 5, _z] call LTN2_fnc_getCircleCoords;
		};
		uav lockCameraTo [LTN2_TGP_TGT, [0]];
		if (typename LTN2_TGP_TGT == "OBJECT") then {
			_intern_tgt = getPosASL LTN2_TGP_TGT;
		} else {
			_intern_tgt = LTN2_TGP_TGT;
		};
		if (LTN2_ZOOM != 0) then {
				if (!LTN2_NULLTGT) then {
						diff = (getposasl air) vectorDiff _intern_tgt;
						zooom = [(diff select 0) * LTN2_ZOOM,(diff select 1) * LTN2_ZOOM,(diff select 2) * LTN2_ZOOM];
						uav attachTo [air, zooom];
				} else {
						uav attachTo [air, [0,(LTN2_ZOOM * LTN2_MAXZOOM),-1]];
				}
		} else {
				uav attachTo [air, [0,0,-1]];
		};
		tgt_dist = format["%1 M",(air distance LTN2_TGP_TGT)];
	   
		_dir = (uav selectionPosition "PiP0_pos")  vectorFromTo (uav selectionPosition "PiP0_dir");
		_up = _dir vectorCrossProduct [-(_dir select 1), _dir select 0, 0];
		cam setVectorDirAndUp [[(_dir select 0), _dir select 1, _dir select 2] , _up];
}];
/*
sleep 10;
{
		ctrlDelete _x;
} foreach _controls;

{
		_x cameraEffect ["terminate","back"];
		camDestroy _x;
} foreach _cameras;

LTN2_active = false;

deleteVehicle uav;
removeMissionEventHandler ["Draw3D",_handler];
*/