var next_prob = [
//  -oct                                     same                                    +oct
	[3.0, 5.0,10.0, 9.0, 6.0, 4.0, 6.0, 5.0, 3.0, 5.0,10.0, 9.0, 6.0, 4.0, 6.0, 6.0, 3.0],
	[3.0, 5.0, 5.0, 8.0, 5.0, 8.0, 3,  10.0, 3.0, 5.0, 5.0, 8.0, 5.0, 8.0, 6.0,10.0, 3.0],
	[5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9],
	[5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9],
	[5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9],
	[5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9],
	[5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9],
	[5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9],
];

var bar_complexity = [
	// little movement, mid-register singing
	(dur:1, movement:1, range:2, complex:0),   // 27
	(dur:1, movement:1, range:2, complex:1),   // 28
	(dur:1, movement:3, range:2, complex:1),   // 29
	// growth and development, patterns and range expansion
	(dur:1, movement:3, range:6, complex:2),   // 30
	(dur:1, movement:3, range:12,complex:3),   // 31
	(dur:1, movement:4, range:12,complex:4),   // 32
	(dur:1, movement:5, range:12,complex:5),   // 33
	// peak of solo, high range or alternating very big intervals
	(dur:1, movement:8, range:12,complex:6),   // 34
	(dur:1, movement:8, range:12,complex:6),   // 35
	(dur:1, movement:8, range:12,complex:6),   // 36
	(dur:1, movement:8, range:12,complex:6),   // 37
	// slowing down, low register to audible low rumble
	(dur:1, movement:1, range:2, complex:1),   // 38
	(dur:1, movement:0, range:0, complex:0),   // 38
];

var buf = Buffer.read(s,Platform.resourceDir ++ '/sounds/alex/composite mezzo.wav');

var voices = SynthDef(\voices, { |freq = 440, degree, sustain = 1, amp = 0.5|
	//if(degree <= -8, {
	Out.ar(0, PlayBuf.ar(2, buf.bufnum, 1, 1, (4*(degree+16).min(24).max(0)+0.5)*44100) * amp *
		EnvGen.kr(Env.linen(0.01, sustain.min(1), 0.01), doneAction:2))
}).add;

var note = {arg degree, dur=1/16, amp=0.1;
	(instrument:\voices, stretch:4*60/56,scale:[0,1,4,5,7,8,9,11],root:8,
	dur:dur, amp:amp, degree: degree, legato:1)
};

var bar_params = {arg bar;
	(
		27:'build', //
		28:'build',
		29:'build',
		30:'build', //
		31:'build',
		32:'build',
		33:'build',
		34:'build', //
		35:'down',
		36:'down',
		37:'down',
		38:'down',  //
	)[bar]
};

var build = {arg state;
	/*2.do {
		[
			{state.min = (state.min - 1).max(-16)},
			{state.max = (state.max + 1).max(16)},
			{state.speed = (state.speed * 2).min(32)},
			{state.jump = (state.jump + 1) / 2},
			{state.ajump = (state.ajump + 0.05).max(0.2)},
			{state.rhythm_complexity = (state.rhythm_complexity + 1).min(4)}
		].choose.value
	}*/
};

var down = {arg state;
	state.min = (state.min * 0.5) + (-16 * 0.5);
	state.max = (state.max * 0.5) + (-16 * 0.5);
};

var modify = {arg state, bar;
	('build':build, 'down':down)[bar_params.value(bar)].value(state)
};

var jump = {arg d, min, max, movement;
	var probs;
	probs = (-8..8).collect({arg i; if((d+i >= min).and(d+i <= max).and(i.abs <= movement), next_prob[d % 8][i+8], 0)});
	d = d + (-8..8).wchoose(probs.normalizeSum);
	if (d > max, {d = d * 0.5 + (max * 0.5)});
	if (d < min, {d = d * 0.5 + (min * 0.5)});
	d.asInteger
};

var do_bar = {arg d, complexity;
	var min = (-4 - complexity.range).max(-16);
	var max = (-4 + complexity.range).min(8);
	var t = 0;
	while ({t < complexity.dur}, {
		var dur = complexity.dur;
		var amp = 0.1;
		if (complexity.complex >= 1, {dur = dur / 4});
		if (complexity.complex >= 2, {amp = 2 * amp.rand});
		if (complexity.complex >= 4, {amp = [0,1,1,1,1].choose * amp});
		if (complexity.complex >= 6, {dur = dur.rand});
		dur = dur.min(complexity.dur - t);
		note.value(d, dur, amp).yield;
		d = jump.value(d, min, max, complexity.movement);
		t = t + dur;
	});
	d
};

var tune = p{
	var d = -4;
	(27..38).do{arg bar; bar.postln; d = do_bar.value(d, bar_complexity[bar-27])}
};

tune.play;
