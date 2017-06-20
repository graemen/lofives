// ----------------------------------------------------------------------------------------------
//   This file is part of LoFives - osc glove instrument software
//
//   LoFives is free software: you can redistribute it and/or modify it under the terms
//   of the GNU General Public License as published by the Free Software Foundation, either
//   version 3 of the license, or any later version.
//
//   LoFives is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
//   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//   See the GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License along with
//   LoFives.  If not, see http://www.gnu.org/licenses/
//
//
//   Copyright 2017 LOlux productions (www.lolux.net)
//
//   Developed by :
//
//       graeme@lolux.net
//
// ----------------------------------------------------------------------------------------------


s = Server.local;
s.boot;

"=== LoFives ===".postln;

s.waitForBoot({


	var synthGloves;
	var run = true;

	// OSC server
	var setOSC, sendOSC;
	var oscTx = NetAddr.new("127.0.0.1", 8000);
	var oscInterval = 0.1;

	// each hand''s sesnors are stored in an array of 5 items
	// raw_left_hand = [ [fuseq] [fuse] [gyr] [acc] [mag]  ]
	//                      0       1     2     3     4
	// each sensor is an array of 9 items [x,y,z,minx,miny,minz,maxx,maxy,maxz]
	//                                     0,1,2,  3,  4,   5,    6,   7,   8
	// we have raw hands and new hands :-)

	var left_hand_raw = [[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0]];

	var left_hand_new = [[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0]];

	var right_hand_raw = [[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0]];

	var right_hand_new = [[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0],[0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,1.0]];


	var sensor = 0;
	var hand = 0;

	var rPitchSpec, lPitchSpec, rYawSpec, lYawSpec, rRollSpec, lRollSpec;
	var newrPitchSpec, newrYawSpec, newrRollSpec;
	var newlPitchSpec, newlYawSpec, newlRollSpec;


	//GUI ////////////////////////////////////////////////////////////////////////////////////////////
	var win;
	var numPitch, numYaw, numRoll, newPitch, newYaw, newRoll;
	var knobPitch, knobPitchNum, knobPitchLabel, knobPitchSpec;
	var knobPitchMin, knobPitchNumMin, knobPitchLabelMin, knobPitchSpecMin;
	var knobRoll, knobRollNum, knobRollLabel, knobRollSpec;
	var knobYaw, knobYawNum, knobYawLabel, knobYawSpec;
	var knobRollMin, knobRollNumMin, knobRollLabelMin, knobRollSpecMin;
	var knobYawMin, knobYawNumMin, knobYawLabelMin, knobYawSpecMin;
	var knobHand, knobHandSpec, knobHandLabel, knobHandNum;
	var knobSensorNum, knobSensorLabel, knobSensorSpec, knobSensor;
	var txtStatus, labMin, labMax;
	var butPitch, togPitch, butRoll, togRoll, butYaw, togYaw, butRanVoice, togRanVoice;
	var butOpen, butSave;
	var rawNumLabel, knobsLabel, newNumLabel;
	var titleLabel, footerLabel, helpLabel;

	var fileSave, fileOpen, line;

	var yrow1 = 20;
	var yrow2 = 200; // moved to after 6 and before 7
	var yrow3 = 270;
	var yrow4 = 300; //380
	var yrow5 = 440; //518
	var yrow6 = 480; //560
	var yrow7 = 620;
	var yrow8 = 680;
	var yrow9 = 740;

	var xcol1 = 50;
	var xcol2 = 230;
	var xcol3 = 380;
	var xcol4 = 560;
	var xcol5 = 740;
	var xcol6 = 940;
	var xcol7 = 1140;

	var xs = 35;
	var ys = 30;
	var szK = 140;
	var szNx = 70;
	var szNy = 25;
	var szSld = 130;

	var titleFont = Font("Mono", 30, bold: true);
	var defaultFont =Font("Mono", 20, bold: true);
	var phraseFont = Font("Mono", 16, bold: true);
	var butFont = Font("Mono", 20, bold: true);
	var statusFont = Font("Mono", 20, bold: false);

	var defaultColor = Color.new255(0,0,0);
	var defaultBackColor = Color.new255(0,0,0);
	var defaultStringColor = Color.green;
	var inStringColor = Color.red;
	var defaultBtnColor = Color.new255(255,0,0);
	var defaultAlpha = 1.0;

	Window.closeAll;
	win = Window.new("LoFives", Rect(0, 0, 950, 800));

	win.onClose = {

		// stop processing
		run=false;

		OSCdef(\rfusqx).disable;
		OSCdef(\rfusqx).disable;
		OSCdef(\rfusqx).disable;
		OSCdef(\rfusx).disable;
		OSCdef(\rfusx).disable;
		OSCdef(\rfusx).disable;
		OSCdef(\rgyrx).disable;
		OSCdef(\rgyry).disable;
		OSCdef(\rgyrz).disable;
		OSCdef(\raccx).disable;
		OSCdef(\raccy).disable;
		OSCdef(\raccz).disable;
		OSCdef(\rmagx).disable;
		OSCdef(\rmagy).disable;
		OSCdef(\rmagz).disable;

		OSCdef(\lfusqx).disable;
		OSCdef(\lfusqx).disable;
		OSCdef(\lfusqx).disable;
		OSCdef(\lfusx).disable;
		OSCdef(\lfusx).disable;
		OSCdef(\lfusx).disable;
		OSCdef(\lgyrx).disable;
		OSCdef(\lgyry).disable;
		OSCdef(\lgyrz).disable;
		OSCdef(\laccx).disable;
		OSCdef(\laccy).disable;
		OSCdef(\laccz).disable;
		OSCdef(\lmagx).disable;
		OSCdef(\lmagy).disable;
		OSCdef(\lmagz).disable;

		// stop osc functions and server
		oscTx.sendMsg("/gx/status", "LoFives OFF");

		s.freeAll;
		Window.closeAll;
		"lux> LoFives OFF".postln;
		0.exit;
	};

	win.front;
	win.background = Color.new255(80,80,80);
	win.alpha = defaultAlpha;

	titleLabel = StaticText.new(win, Rect(xcol1, yrow1, szK*2, szNy*2));
	titleLabel.string = "LOFives";
	titleLabel.align = \left;
	titleLabel.font = titleFont;
	titleLabel.stringColor = Color.new(255,255,255);

	helpLabel = StaticText.new(win, Rect(xcol1, yrow2-75, 230, 580));
	helpLabel.string = "Start by moving the gloves through every possible range of motion.\n\nThis will initialise the raw in max and min values sent by the gloves.\n\nSelect each sensor in turn and set new max and min values.\n\nThis will remap the sensor readings to lie between the new max and min. \n\nThese should match the max and min values of the control you want the sensor to map in your music softs.\n\nNew remapped sensor values are sent out to localhost port 8000 (127.0.0.1:8000).\n\nOpen and save buttons are to load and store settings.";
	helpLabel.align = \left;
	helpLabel.font = phraseFont;
	helpLabel.stringColor = Color.new(255,255,255);

	footerLabel = StaticText.new(win, Rect(xcol1, yrow9, 240, szNy));
	footerLabel.string = "LOlux Studio";
	footerLabel.align = \left;
	footerLabel.font = phraseFont;
	footerLabel.stringColor = Color.new(255,255,255);


	rawNumLabel = StaticText.new(win, Rect(xcol2, yrow2, szK, 25));
	rawNumLabel.string = "IN";
	rawNumLabel.align = \right;
	rawNumLabel.font = defaultFont;
	rawNumLabel.stringColor = inStringColor;

	//readings from osc
	numPitch = StaticText.new(win, Rect(xcol3, yrow2, szK, szNy));
	numPitch.background = defaultColor;
	numPitch.alpha = defaultAlpha;
	numPitch.align = \center;
	numPitch.string = "-";
	numPitch.font = defaultFont;
	numPitch.stringColor = inStringColor;

	//readings from osc
	numYaw = StaticText.new(win, Rect(xcol4, yrow2, szK, szNy));
	numYaw.background = defaultColor;
	numYaw.alpha = defaultAlpha;
	numYaw.align = \center;
	numYaw.string = "-";
	numYaw.font = defaultFont;
	numYaw.stringColor = inStringColor;

	//readings from osc
	numRoll = StaticText.new(win, Rect(xcol5, yrow2, szK, szNy));
	numRoll.background = defaultColor;
	numRoll.alpha = defaultAlpha;
	numRoll.align = \center;
	numRoll.string = "-";
	numRoll.font = defaultFont;
	numRoll.stringColor = inStringColor;

	// rmap label
	knobsLabel = StaticText.new(win, Rect(xcol2, yrow3, szK, 25));
	knobsLabel.string = "Remap";
	knobsLabel.align = \right;
	knobsLabel.font = defaultFont;
	knobsLabel.stringColor = defaultStringColor;

	// Pitch Knob /////////////////////////////////////////////////////////
	knobPitchSpec = ControlSpec(0, 180, 'lin', 1, 1, " ");
	knobPitch = Knob.new(win, Rect(xcol3, yrow4, szK, szK))
	.action = {arg v;
		var max = knobPitchSpec.map(v.value);
		knobPitchNum.string = max;
		right_hand_new[sensor][6] = max;

	};
	knobPitch.value = knobPitchSpec.unmap(knobPitchSpec.default);

	knobPitchNum = StaticText.new(win, Rect((xcol3+xs), yrow5, szNx, szNy));
	knobPitchNum.background = defaultColor;
	knobPitchNum.alpha = defaultAlpha;
	knobPitchNum.align = \center;
	knobPitchNum.string = knobPitchSpec.default;
	knobPitchNum.font = defaultFont;
	knobPitchNum.stringColor = defaultStringColor;

	knobPitchSpecMin = ControlSpec(0, -180, 'lin', 1, 0, " ");
	knobPitchMin = Knob.new(win, Rect(xcol3, yrow6, szK, szK))
	.action = {arg v;
		var min = knobPitchSpecMin.map(v.value);
		knobPitchNumMin.string = min;
		right_hand_new[sensor][3] = min;
	};
	knobPitchMin.value = knobPitchSpecMin.unmap(knobPitchSpecMin.default);

	knobPitchNumMin = StaticText.new(win, Rect((xcol3+xs), yrow7, szNx, szNy));
	knobPitchNumMin.background = defaultColor;
	knobPitchNumMin.alpha = defaultAlpha;
	knobPitchNumMin.align = \center;
	knobPitchNumMin.string = knobPitchSpecMin.default;
	knobPitchNumMin.font = defaultFont;
	knobPitchNumMin.stringColor = defaultStringColor;

	knobPitchLabel = StaticText.new(win, Rect(xcol3, yrow3, szK, 25));
	knobPitchLabel.string = "X Axis";
	knobPitchLabel.align = \center;
	knobPitchLabel.font = defaultFont;
	knobPitchLabel.stringColor = defaultStringColor;


	// Roll Knob /////////////////////////////////////////////////////////
	knobRollSpec = ControlSpec(0, 180, 'lin', 1, 1, " ");
	knobRoll = Knob.new(win, Rect(xcol5, yrow4, szK, szK))
	.action = {arg v;
		var max = knobRollSpec.map(v.value);
		knobRollNum.string = max;
		right_hand_new[sensor][8] = max;
	};
	knobRoll.value = knobRollSpec.unmap(knobRollSpec.default);

	knobRollNum = StaticText.new(win, Rect((xcol5+xs), yrow5, szNx, szNy));
	knobRollNum.background = defaultColor;
	knobRollNum.alpha = defaultAlpha;
	knobRollNum.align = \center;
	knobRollNum.string = knobRollSpec.default;
	knobRollNum.font = defaultFont;
	knobRollNum.stringColor = defaultStringColor;

	knobRollSpecMin = ControlSpec(0, -180, 'lin', 1, 0, " ");
	knobRollMin = Knob.new(win, Rect(xcol5, yrow6, szK, szK))
	.action = {arg v;
		var min = knobRollSpecMin.map(v.value);
		knobRollNumMin.string = min;
		right_hand_new[sensor][5] = min;
	};
	knobRollMin.value = knobRollSpecMin.unmap(knobRollSpecMin.default);

	knobRollNumMin = StaticText.new(win, Rect((xcol5+xs), yrow7, szNx, szNy));
	knobRollNumMin.background = defaultColor;
	knobRollNumMin.alpha = defaultAlpha;
	knobRollNumMin.align = \center;
	knobRollNumMin.string = knobRollSpecMin.default;
	knobRollNumMin.font = defaultFont;
	knobRollNumMin.stringColor = defaultStringColor;

	knobRollLabel = StaticText.new(win, Rect(xcol5, yrow3, szK, 25));
	knobRollLabel.string = "Z Axis";
	knobRollLabel.align = \center;
	knobRollLabel.font = defaultFont;
	knobRollLabel.stringColor = defaultStringColor;

	// Yaw Knob /////////////////////////////////////////////////////////
	knobYawSpec = ControlSpec(0, 180, 'lin', 1, 1, " ");
	knobYaw = Knob.new(win, Rect(xcol4, yrow4, szK, szK))
	.action = {arg v;
		var max = knobYawSpec.map(v.value);
		knobYawNum.string = max;
		right_hand_new[sensor][7] = max;
	};
	knobYaw.value = knobYawSpec.unmap(knobYawSpec.default);

	knobYawNum = StaticText.new(win, Rect((xcol4+xs), yrow5, szNx, szNy));
	knobYawNum.background = defaultColor;
	knobYawNum.alpha = defaultAlpha;
	knobYawNum.align = \center;
	knobYawNum.string = knobYawSpec.default;
	knobYawNum.font = defaultFont;
	knobYawNum.stringColor = defaultStringColor;

	knobYawSpecMin = ControlSpec(0, -180, 'lin', 1, 0, " ");
	knobYawMin = Knob.new(win, Rect(xcol4, yrow6, szK, szK))
	.action = {arg v;
		var min = knobYawSpecMin.map(v.value);
		knobYawNumMin.string = min;
		right_hand_new[sensor][4] = min;
	};
	knobYawMin.value = knobYawSpecMin.unmap(knobYawSpecMin.default);

	knobYawNumMin = StaticText.new(win, Rect((xcol4+xs), yrow7, szNx, szNy));
	knobYawNumMin.background = defaultColor;
	knobYawNumMin.alpha = defaultAlpha;
	knobYawNumMin.align = \center;
	knobYawNumMin.string = knobYawSpecMin.default;
	knobYawNumMin.font = defaultFont;
	knobYawNumMin.stringColor = defaultStringColor;

	knobYawLabel = StaticText.new(win, Rect(xcol4, yrow3, szK, 25));
	knobYawLabel.string = "Y Axis";
	knobYawLabel.align = \center;
	knobYawLabel.font = defaultFont;
	knobYawLabel.stringColor = defaultStringColor;

	//
	labMax = StaticText.new(win, Rect(xcol2, yrow5, szK, 25));
	labMax.string = "Max";
	labMax.align = \right;
	labMax.font = defaultFont;
	labMax.stringColor = defaultStringColor;

	labMin = StaticText.new(win, Rect(xcol2, yrow7, szK, 25));
	labMin.string = "Min";
	labMin.align = \right;
	labMin.font = defaultFont;
	labMin.stringColor = defaultStringColor;

	newNumLabel = StaticText.new(win, Rect(xcol2, yrow8, szK, 25));
	newNumLabel.string = "OUT";
	newNumLabel.align = \right;
	newNumLabel.font = defaultFont;
	newNumLabel.stringColor = defaultStringColor;

	//readings from osc
	newPitch = StaticText.new(win, Rect(xcol3, yrow8, szK, szNy));
	newPitch.background = defaultColor;
	newPitch.alpha = defaultAlpha;
	newPitch.align = \center;
	newPitch.string = "-";
	newPitch.font = defaultFont;
	newPitch.stringColor = defaultStringColor;

	//readings from osc
	newYaw = StaticText.new(win, Rect(xcol4, yrow8, szK, szNy));
	newYaw.background = defaultColor;
	newYaw.alpha = defaultAlpha;
	newYaw.align = \center;
	newYaw.string = "-";
	newYaw.font = defaultFont;
	newYaw.stringColor = defaultStringColor;

	//readings from osc
	newRoll = StaticText.new(win, Rect(xcol5, yrow8, szK, szNy));
	newRoll.background = defaultColor;
	newRoll.alpha = defaultAlpha;
	newRoll.align = \center;
	newRoll.string = "-";
	newRoll.font = defaultFont;
	newRoll.stringColor = defaultStringColor;

	//right hand
	OSCdef(\rfusqx, { arg msg, time, addr, recvPort; right_hand_raw[0][0] = msg[1] }, '/gx/r/fusqX');
	OSCdef(\rfusqy, { arg msg, time, addr, recvPort; right_hand_raw[0][1] = msg[1] }, '/gx/r/fusqY');
	OSCdef(\rfusqz, { arg msg, time, addr, recvPort; right_hand_raw[0][2] = msg[1] }, '/gx/r/fusqZ');
	//OSCdef(\fuseqa, { arg msg, time, addr, recvPort; { msg[1].postln}.defer(0); }, '/gx/r/fusqA');

	OSCdef(\rfusx, { arg msg, time, addr, recvPort; right_hand_raw[1][0] = msg[1] }, '/gx/r/fusX');
	OSCdef(\rfusy, { arg msg, time, addr, recvPort; right_hand_raw[1][1] = msg[1] }, '/gx/r/fusY');
	OSCdef(\rfusz, { arg msg, time, addr, recvPort; right_hand_raw[1][2] = msg[1] }, '/gx/r/fusZ');

	OSCdef(\rgyrx, { arg msg, time, addr, recvPort; right_hand_raw[2][0] = msg[1] }, '/gx/r/gyrX');
	OSCdef(\rgyry, { arg msg, time, addr, recvPort; right_hand_raw[2][1] = msg[1] }, '/gx/r/gyrY');
	OSCdef(\rgyrz, { arg msg, time, addr, recvPort; right_hand_raw[2][2] = msg[1] }, '/gx/r/gyrZ');

	OSCdef(\raccx, { arg msg, time, addr, recvPort; right_hand_raw[3][0] = msg[1] }, '/gx/r/accX');
	OSCdef(\raccy, { arg msg, time, addr, recvPort; right_hand_raw[3][1] = msg[1] }, '/gx/r/accY');
	OSCdef(\raccz, { arg msg, time, addr, recvPort; right_hand_raw[3][2] = msg[1] }, '/gx/r/accZ');

	OSCdef(\rmagx, { arg msg, time, addr, recvPort; right_hand_raw[4][0] = msg[1] }, '/gx/r/magX');
	OSCdef(\rmagy, { arg msg, time, addr, recvPort; right_hand_raw[4][1] = msg[1] }, '/gx/r/magY');
	OSCdef(\rmagz, { arg msg, time, addr, recvPort; right_hand_raw[4][2] = msg[1] }, '/gx/r/magZ');

	//left hand
	OSCdef(\lfusqx, { arg msg, time, addr, recvPort; left_hand_raw[0][0] = msg[1] }, '/gx/l/fusqX');
	OSCdef(\lfusqy, { arg msg, time, addr, recvPort; left_hand_raw[0][1] = msg[1] }, '/gx/l/fusqY');
	OSCdef(\lfusqz, { arg msg, time, addr, recvPort; left_hand_raw[0][2] = msg[1] }, '/gx/l/fusqZ');
	//OSCdef(\fuseqa, { arg msg, time, addr, recvPort; { msg[1].postln}.defer(0); }, '/gx/l/fusqA');

	OSCdef(\lfusx, { arg msg, time, addr, recvPort; left_hand_raw[1][0] = msg[1] }, '/gx/l/fusX');
	OSCdef(\lfusy, { arg msg, time, addr, recvPort; left_hand_raw[1][1] = msg[1] }, '/gx/l/fusY');
	OSCdef(\lfusz, { arg msg, time, addr, recvPort; left_hand_raw[1][2] = msg[1] }, '/gx/l/fusZ');

	OSCdef(\lgyrx, { arg msg, time, addr, recvPort; left_hand_raw[2][0] = msg[1] }, '/gx/l/gyrX');
	OSCdef(\lgyry, { arg msg, time, addr, recvPort; left_hand_raw[2][1] = msg[1] }, '/gx/l/gyrY');
	OSCdef(\lgyrz, { arg msg, time, addr, recvPort; left_hand_raw[2][2] = msg[1] }, '/gx/l/gyrZ');

	OSCdef(\laccx, { arg msg, time, addr, recvPort; left_hand_raw[3][0] = msg[1] }, '/gx/l/accX');
	OSCdef(\laccy, { arg msg, time, addr, recvPort; left_hand_raw[3][1] = msg[1] }, '/gx/l/accY');
	OSCdef(\laccz, { arg msg, time, addr, recvPort; left_hand_raw[3][2] = msg[1] }, '/gx/l/accZ');

	OSCdef(\lmagx, { arg msg, time, addr, recvPort; left_hand_raw[4][0] = msg[1] }, '/gx/l/magX');
	OSCdef(\lmagy, { arg msg, time, addr, recvPort; left_hand_raw[4][1] = msg[1] }, '/gx/l/magY');
	OSCdef(\lmagz, { arg msg, time, addr, recvPort; left_hand_raw[4][2] = msg[1] }, '/gx/l/magZ');

	OSCdef(\rfusqx).enable;
	OSCdef(\rfusqx).enable;
	OSCdef(\rfusqx).enable;
	OSCdef(\rfusx).enable;
	OSCdef(\rfusx).enable;
	OSCdef(\rfusx).enable;
	OSCdef(\rgyrx).enable;
	OSCdef(\rgyry).enable;
	OSCdef(\rgyrz).enable;
	OSCdef(\raccx).enable;
	OSCdef(\raccy).enable;
	OSCdef(\raccz).enable;
	OSCdef(\rmagx).enable;
	OSCdef(\rmagy).enable;
	OSCdef(\rmagz).enable;

	OSCdef(\lfusqx).enable;
	OSCdef(\lfusqx).enable;
	OSCdef(\lfusqx).enable;
	OSCdef(\lfusx).enable;
	OSCdef(\lfusx).enable;
	OSCdef(\lfusx).enable;
	OSCdef(\lgyrx).enable;
	OSCdef(\lgyry).enable;
	OSCdef(\lgyrz).enable;
	OSCdef(\laccx).enable;
	OSCdef(\laccy).enable;
	OSCdef(\laccz).enable;
	OSCdef(\lmagx).enable;
	OSCdef(\lmagy).enable;
	OSCdef(\lmagz).enable;


	//Sensor Knob /////////////////////////////////////////////////////
	knobSensor = ListView(win,Rect(xcol4+25, yrow1, 300, szK))
	.items_([ "Fuse Pose Q", "Fuse Pose", "Gyroscope", "Accelerometer", "Magnetometer" ])
	.font_(defaultFont)
    .background_(Color.white)
    .hiliteColor_(Color.grey)
	.selectedStringColor_(Color.green)
	.selectionMode_(\single)
    .action_({ arg sbs;
		sensor = sbs.value;
		if (hand == 0, {
			{knobPitch.valueAction = knobPitchSpec.unmap(right_hand_new[sensor][6])}.defer(0);
			{knobPitchMin.valueAction = knobPitchSpecMin.unmap(right_hand_new[sensor][3])}.defer(0);
			{knobYaw.valueAction = knobYawSpec.unmap(right_hand_new[sensor][7])}.defer(0);
			{knobYawMin.valueAction = knobYawSpecMin.unmap(right_hand_new[sensor][4])}.defer(0);
			{knobRoll.valueAction = knobRollSpec.unmap(right_hand_new[sensor][8])}.defer(0);
			{knobRollMin.valueAction = knobRollSpecMin.unmap(right_hand_new[sensor][5])}.defer(0);

		});
		if (hand == 1, {
			{knobPitch.valueAction = knobPitchSpec.unmap(left_hand_new[sensor][6])}.defer(0);
			{knobPitchMin.valueAction = knobPitchSpecMin.unmap(left_hand_new[sensor][3])}.defer(0);
			{knobYaw.valueAction = knobYawSpec.unmap(left_hand_new[sensor][7])}.defer(0);
			{knobYawMin.valueAction = knobYawSpecMin.unmap(left_hand_new[sensor][4])}.defer(0);
			{knobRoll.valueAction = knobRollSpec.unmap(left_hand_new[sensor][8])}.defer(0);
			{knobRollMin.valueAction = knobRollSpecMin.unmap(left_hand_new[sensor][5])}.defer(0);
		});
    });


	knobSensorLabel = StaticText.new(win, Rect(xcol2, yrow1, szK, 25));
	knobSensorLabel.string = "Sensor";
	knobSensorLabel.align = \right;
	knobSensorLabel.font = defaultFont;
	knobSensorLabel.stringColor = defaultStringColor;

	knobHand = ListView(win,Rect(xcol3, yrow1, 200, szK))
	.items_([ "Right Hand", "Left Hand" ])
	.font_(defaultFont)
    .background_(Color.white)
    .hiliteColor_(Color.grey)
	.selectedStringColor_(Color.green)
	.selectionMode_(\single)
    .action_({ arg sbs;
		hand = sbs.value;
    });

	// Open and Save presets //////////////////////////////////////////////////
	butOpen = Button(win, Rect(xcol3+100, yrow9, 120, xs))
        .states_([
            ["Open", Color.black],
		    ["Open", Color.red]
        ])
        .action_({ arg butt;
		if (butt.value == 1, {
			// open a csv file and restore left and right hand arrays, one each line
			Dialog.openPanel({arg path;
				fileOpen = CSVFileReader.readInterpret(path).postcs;
				line = 0;
				for (0, 4, {arg sensor;
					for (0,8, {arg val;
						left_hand_raw[sensor][val] = fileOpen[line][val];
					});
					line = line + 1;
				});

				for (0, 4, {arg sensor;
					for (0,8, {arg val;
						right_hand_raw[sensor][val] = fileOpen[line][val];
					});
					line = line + 1;
				});

				for (0, 4, {arg sensor;
					for (0,8, {arg val;
						left_hand_new[sensor][val] = fileOpen[line][val];
					});
					line = line + 1;
				});

				for (0, 4, {arg sensor;
					for (0,8, {arg val;
						right_hand_new[sensor][val] = fileOpen[line][val];
					});
					line = line + 1;
				});

			});

			});
		});
	butOpen.font = butFont;


	butSave = Button(win, Rect(xcol4+100, yrow9, 120, xs))
        .states_([
            ["Save", Color.black],
		    ["Save", Color.red]
        ])
        .action_({ arg butt;
		if (butt.value == 1, {
			// save the left and right hand arrays to a file
			Dialog.savePanel({arg path;
				fileSave = File(path, "w");
				left_hand_raw.do({ |sensor, index|
					fileSave.write("" ++ sensor[0] ++ "," ++ sensor[1] ++ "," ++ sensor[2] ++ ",");
					fileSave.write("" ++ sensor[3] ++ "," ++ sensor[4] ++ "," ++ sensor[5] ++ ",");
					fileSave.write("" ++ sensor[6] ++ "," ++ sensor[7] ++ "," ++ sensor[8] ++ "\n");
					});
				right_hand_raw.do({ |sensor, index|
					fileSave.write("" ++ sensor[0] ++ "," ++ sensor[1] ++ "," ++ sensor[2] ++ ",");
					fileSave.write("" ++ sensor[3] ++ "," ++ sensor[4] ++ "," ++ sensor[5] ++ ",");
					fileSave.write("" ++ sensor[6] ++ "," ++ sensor[7] ++ "," ++ sensor[8] ++ "\n");
					});
				left_hand_new.do({ |sensor, index|
					fileSave.write("" ++ sensor[0] ++ "," ++ sensor[1] ++ "," ++ sensor[2] ++ ",");
					fileSave.write("" ++ sensor[3] ++ "," ++ sensor[4] ++ "," ++ sensor[5] ++ ",");
					fileSave.write("" ++ sensor[6] ++ "," ++ sensor[7] ++ "," ++ sensor[8] ++ "\n");
					});
				right_hand_new.do({ |sensor, index|
					fileSave.write("" ++ sensor[0] ++ "," ++ sensor[1] ++ "," ++ sensor[2] ++ ",");
					fileSave.write("" ++ sensor[3] ++ "," ++ sensor[4] ++ "," ++ sensor[5] ++ ",");
					fileSave.write("" ++ sensor[6] ++ "," ++ sensor[7] ++ "," ++ sensor[8] ++ "\n");
					});
				fileSave.close;
			});
		});
		});
	butSave.font = butFont;


	//Simple Synth
	SynthDef(\gloves, { arg out=0, freq=400, osc=0, amp=1.0;
		var gloves = (SinOsc.ar(freq: freq));
		Out.ar(out, gloves);
	}).add;



	"lux> LoFives ON".postln;
    // fork this block
	{
		"lux> receiving...".postln;
		oscTx.sendMsg("/gx/status", "LoFives ON");
		"lux> transmitting...".postln;

		//main vem loop
		{run}.while({


			// poll interval for sending osc
			wait(oscInterval);

			// left hand
			if (hand == 1, {
			    //update display
				{numPitch.string = left_hand_raw[sensor][0].trunc(0.001)}.defer(0);
				{numYaw.string = left_hand_raw[sensor][1].trunc(0.001)}.defer(0);
				{numRoll.string = left_hand_raw[sensor][2].trunc(0.001)}.defer(0);

			    // update min and max
				if (left_hand_raw[sensor][0] > left_hand_raw[sensor][6], {left_hand_raw[sensor][6] = left_hand_raw[sensor][0]});
				if (left_hand_raw[sensor][0] < left_hand_raw[sensor][3], {left_hand_raw[sensor][3] = left_hand_raw[sensor][0]});
				if (left_hand_raw[sensor][1] > left_hand_raw[sensor][7], {left_hand_raw[sensor][7] = left_hand_raw[sensor][1]});
				if (left_hand_raw[sensor][1] < left_hand_raw[sensor][4], {left_hand_raw[sensor][4] = left_hand_raw[sensor][1]});
				if (left_hand_raw[sensor][2] > left_hand_raw[sensor][8], {left_hand_raw[sensor][8] = left_hand_raw[sensor][2]});
				if (left_hand_raw[sensor][2] < left_hand_raw[sensor][5], {left_hand_raw[sensor][5] = left_hand_raw[sensor][2]});
			    //map raw values to new range
			    lPitchSpec = ControlSpec(left_hand_raw[sensor][3],left_hand_raw[sensor][6], \lin, 0.01, 0, "");
				lYawSpec = ControlSpec(left_hand_raw[sensor][4],left_hand_raw[sensor][7], \lin, 0.01, 0, "");
				lRollSpec = ControlSpec(left_hand_raw[sensor][5],left_hand_raw[sensor][8], \lin, 0.01, 0, "");

				newrPitchSpec = ControlSpec(right_hand_new[sensor][3], right_hand_new[sensor][6], \lin, 0.01, 0, "");
				newrYawSpec = ControlSpec(right_hand_new[sensor][4], right_hand_new[sensor][7], \lin, 0.01, 0, "");
				newrRollSpec = ControlSpec(right_hand_new[sensor][5], right_hand_new[sensor][8], \lin, 0.01, 0, "");

				//map raw values to new range want to be able to set the final output spec...
				// this maps values to 0 to 1
				left_hand_raw[sensor][0] = newlPitchSpec.map(lPitchSpec.unmap(left_hand_raw[sensor][0]));
				left_hand_raw[sensor][1] = newlPitchSpec.map(lYawSpec.unmap(left_hand_raw[sensor][1]));
				left_hand_raw[sensor][2] = newlPitchSpec.map(lRollSpec.unmap(left_hand_raw[sensor][2]));

				{newPitch.string = left_hand_new[sensor][0].trunc(0.001)}.defer(0);
				{newYaw.string = left_hand_new[sensor][1].trunc(0.001)}.defer(0);
				{newRoll.string = left_hand_new[sensor][2].trunc(0.001)}.defer(0);

			});

			//right hand
			if (hand == 0, {
			    //update display
			    {numPitch.string = right_hand_raw[sensor][0].trunc(0.001)}.defer(0);
				{numYaw.string = right_hand_raw[sensor][1].trunc(0.001)}.defer(0);
				{numRoll.string = right_hand_raw[sensor][2].trunc(0.001)}.defer(0);

			    // update min and max
				if (right_hand_raw[sensor][0] > right_hand_raw[sensor][6], {right_hand_raw[sensor][6] = right_hand_raw[sensor][0]});
				if (right_hand_raw[sensor][0] < right_hand_raw[sensor][3], {right_hand_raw[sensor][3] = right_hand_raw[sensor][0]});
				if (right_hand_raw[sensor][1] > right_hand_raw[sensor][7], {right_hand_raw[sensor][7] = right_hand_raw[sensor][1]});
				if (right_hand_raw[sensor][1] < right_hand_raw[sensor][4], {right_hand_raw[sensor][4] = right_hand_raw[sensor][1]});
				if (right_hand_raw[sensor][2] > right_hand_raw[sensor][8], {right_hand_raw[sensor][8] = right_hand_raw[sensor][2]});
				if (right_hand_raw[sensor][2] < right_hand_raw[sensor][5], {right_hand_raw[sensor][5] = right_hand_raw[sensor][2]});

	    		rPitchSpec = ControlSpec(right_hand_raw[sensor][3],right_hand_raw[sensor][6], \lin, 0.01, 0, "");
				rYawSpec = ControlSpec(right_hand_raw[sensor][4],right_hand_raw[sensor][7], \lin, 0.01, 0, "");
				rRollSpec = ControlSpec(right_hand_raw[sensor][5],right_hand_raw[sensor][8], \lin, 0.01, 0, "");

				newrPitchSpec = ControlSpec(right_hand_new[sensor][3], right_hand_new[sensor][6], \lin, 0.01, 0, "");
				newrYawSpec = ControlSpec(right_hand_new[sensor][4], right_hand_new[sensor][7], \lin, 0.01, 0, "");
				newrRollSpec = ControlSpec(right_hand_new[sensor][5], right_hand_new[sensor][8], \lin, 0.01, 0, "");

				//map raw values to new range want to be able to set the final output spec...
				// this maps values to 0 to 1
				right_hand_new[sensor][0] = newrPitchSpec.map(rPitchSpec.unmap(right_hand_raw[sensor][0]) );
				right_hand_new[sensor][1] = newrYawSpec.map(rYawSpec.unmap(right_hand_raw[sensor][1]));
				right_hand_new[sensor][2] = newrRollSpec.map(rRollSpec.unmap(right_hand_raw[sensor][2]));

				{newPitch.string = right_hand_new[sensor][0].trunc(0.001)}.defer(0);
				{newYaw.string = right_hand_new[sensor][1].trunc(0.001)}.defer(0);
				{newRoll.string = right_hand_new[sensor][2].trunc(0.001)}.defer(0);


			});


			// send remapped sensors out as osc
			oscTx.sendMsg("/gx/r/fusqx", right_hand_new[0][0] );
			oscTx.sendMsg("/gx/r/fusqy", right_hand_new[0][1] );
			oscTx.sendMsg("/gx/r/fusqz", right_hand_new[0][2] );

			oscTx.sendMsg("/gx/r/fusx", right_hand_new[1][0] );
			oscTx.sendMsg("/gx/r/fusy", right_hand_new[1][1] );
			oscTx.sendMsg("/gx/r/fusz", right_hand_new[1][2] );

			oscTx.sendMsg("/gx/r/gyrx", right_hand_new[2][0] );
			oscTx.sendMsg("/gx/r/gyry", right_hand_new[2][1] );
			oscTx.sendMsg("/gx/r/gyrz", right_hand_new[2][2] );

			oscTx.sendMsg("/gx/r/accx", right_hand_new[3][0] );
			oscTx.sendMsg("/gx/r/accy", right_hand_new[3][1] );
			oscTx.sendMsg("/gx/r/accz", right_hand_new[3][2] );

			oscTx.sendMsg("/gx/r/magx", right_hand_new[4][0] );
			oscTx.sendMsg("/gx/r/magy", right_hand_new[4][1] );
			oscTx.sendMsg("/gx/r/magz", right_hand_new[4][2] );

			oscTx.sendMsg("/gx/l/fusqx", left_hand_new[0][0] );
			oscTx.sendMsg("/gx/l/fusqy", left_hand_new[0][1] );
			oscTx.sendMsg("/gx/l/fusqz", left_hand_new[0][2] );

			oscTx.sendMsg("/gx/l/fusx", left_hand_new[1][0] );
			oscTx.sendMsg("/gx/l/fusy", left_hand_new[1][1] );
			oscTx.sendMsg("/gx/l/fusz", left_hand_new[1][2] );

			oscTx.sendMsg("/gx/l/gyrx", left_hand_new[2][0] );
			oscTx.sendMsg("/gx/l/gyry", left_hand_new[2][1] );
			oscTx.sendMsg("/gx/l/gyrz", left_hand_new[2][2] );

			oscTx.sendMsg("/gx/l/accx", left_hand_new[3][0] );
			oscTx.sendMsg("/gx/l/accy", left_hand_new[3][1] );
			oscTx.sendMsg("/gx/l/accz", left_hand_new[3][2] );

			oscTx.sendMsg("/gx/l/magx", left_hand_new[4][0] );
			oscTx.sendMsg("/gx/l/magy", left_hand_new[4][1] );
			oscTx.sendMsg("/gx/l/magz", left_hand_new[4][2] );

			//synthGloves = Synth(\gloves,[\freq, luxSecFreq, \amp, luxAmp]).run(luxSigSin);

		});
	}.fork;
});



