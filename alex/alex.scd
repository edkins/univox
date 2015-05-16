var next_prob = [
//  -oct                                     same                                    +oct
	[3.0, 5.0,10.0, 9.0, 6.0, 4.0, 6.0, 5.0, 3.0, 5.0,10.0, 9.0, 6.0, 4.0, 6.0, 6.0, 3.0],
	[3.0, 5.0, 5.0, 8.0, 5.0, 8.0, 3.0,10.0, 3.0, 5.0, 5.0, 8.0, 5.0, 8.0, 6.0,10.0, 3.0],
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
	(dur:2, movement:1, range:2, complex:1),   // 28
	(dur:2, movement:3, range:2, complex:1),   // 29
	// growth and development, patterns and range expansion
	(dur:2, movement:3, range:6, complex:2),   // 30
	(dur:2, movement:3, range:12,complex:3),   // 31
	(dur:2, movement:4, range:12,complex:4),   // 32
	(dur:2, movement:5, range:12,complex:4),   // 33
	// peak of solo, high range or alternating very big intervals
	(dur:1, movement:8, range:12,complex:5),   // 34
	(dur:1, movement:8, range:12,complex:5),   // 35
	(dur:1, movement:8, range:12,complex:6),   // 36
	(dur:1, movement:8, range:12,complex:6),   // 37
	// slowing down, low register to audible low rumble
	(dur:4, movement:1, min:-16,max:-13, complex:2, flurries:1),   // 38
];

/*var buf = Buffer.read(s,Platform.resourceDir ++ '/sounds/alex/composite mezzo.wav');
var voice_gap = 4;
var voice_start = 0.5;*/
var buf = Buffer.read(s,Platform.resourceDir ++ '/sounds/alex/Alex voice forte.wav');
var voice_gap = 3;
var voice_start = 0;

var voices = SynthDef(\voices, { |freq = 440, degree, sustain = 1, amp = 0.5, amp_end = 0.5|
	var env = Env.new([0, amp, amp_end, 0], [0.01, sustain.min(1), 0.01]);
	Out.ar(0, PlayBuf.ar(2, buf.bufnum, 1, 1, (voice_gap*(degree+16).min(24).max(0)+voice_start)*44100) * 4 * EnvGen.kr(env), doneAction:2)
}).add;

var note = {arg degree, dur=1/16, amp=0.1, amp_end=0.1;
	(instrument:\voices, stretch:4*60/56,scale:[0,1,4,5,7,8,9,11],root:8,
	dur:dur, amp:amp, amp_end:amp_end, degree: degree, legato:1)
};

var jump = {arg d, prev_d, min, max, movement;
	var probs;
	var nonzero = false;
	probs = (-8..8).collect({arg i;
		var ok = true;
		ok = ok.and(d + i >= min);
		ok = ok.and(d + i <= max);
		ok = ok.and(i.abs <= movement);
		ok = ok.and((i != 0).or(d != prev_d));  // avoid three identical notes in a row
		if(ok, {nonzero = true; next_prob[d % 8][i+8]}, 0)});
	if (nonzero,
	{
		d = d + (-8..8).wchoose(probs.normalizeSum);
			if (d > max, {d = d * 0.5 + (max * 0.5)});
			if (d < min, {d = d * 0.5 + (min * 0.5)});
			d.asInteger
	}, {
		if (d > max, max, min)
	});
};

var do_bar = {arg d, complexity;
	var min, max, t, amp, prev_d;
	if (complexity.min != nil,
		{min = complexity.min; max = complexity.max},
		{
			min = (-4 - complexity.range).max(-16);
			max = (-4 + complexity.range).min(8);
	});
	t = 0;
	amp = 0.1;
	prev_d = d;
	while ({t < complexity.dur}, {
		var dur = complexity.dur;
		var amp_end = amp;
		var prev_prev_d = prev_d;
		var amp_mul = 1;
		prev_d = d;
		if (complexity.complex >= 1, {dur = 1 / 4});
		if (complexity.flurries != nil, {dur = dur / 8});
		if (complexity.complex >= 2, {amp_end = 0.2.rand});
		if (complexity.complex >= 3, {amp_mul = [0,1,1,1,1].choose});
		if (complexity.complex >= 5, {dur = [dur / 4, dur / 2, dur, dur * 2].choose});
		//if (complexity.complex >= 6, {dur = dur * 0.25 + (dur.rand * 0.75)});
		dur = dur.min(complexity.dur - t);
		note.value(d, dur, amp * amp_mul, amp_end * amp_mul).yield;
		d = jump.value(prev_d, prev_prev_d, min, max, complexity.movement);
		t = t + dur;
		amp = amp_end;
	});
	d
};

var tune = p{
	var d = -4;
	bar_complexity.do{arg complex; complex.postln; d = do_bar.value(d, complex)}
};

//tune = p{(-16..8).do{arg i; note.value(i,1/2).yield}};

tune.play;
