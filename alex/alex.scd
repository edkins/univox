var buf = Buffer.read(s,Platform.resourceDir ++ '/sounds/alex/composite mezzo.wav');

var voices = SynthDef(\voices, { |freq = 440, degree, sustain = 1, amp = 0.5|
	//if(degree <= -8, {
	Out.ar(0, PlayBuf.ar(2, buf.bufnum, 1, 1, (4*(degree+16).min(24).max(0)+8)*44100+0.5) * 0.3 *
		EnvGen.kr(Env.linen(0.01, sustain, 0.01), doneAction:2))
}).add;

var note = {arg degree, dur=1/16, amp=0.1;
	(instrument:\voices, stretch:4*60/56,scale:[0,1,4,5,7,8,9,11],root:8,
	dur:dur, amp:amp * 2, degree: degree)
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
	2.do {
		[
			{state.min = (state.min - 1).max(-16)},
			{state.max = (state.max + 1).max(16)},
			{state.speed = (state.speed * 2).min(32)},
			{state.jump = (state.jump + 1) / 2},
			{state.ajump = (state.ajump + 0.05).max(0.2)},
			{state.rhythm_complexity = (state.rhythm_complexity + 1).min(4)}
		].choose.value
}};

var down = {arg state;
	state.min = (state.min * 0.5) + (-16 * 0.5);
	state.max = (state.max * 0.5) + (-16 * 0.5);
};

var modify = {arg state, bar;
	('build':build, 'down':down)[bar_params.value(bar)].value(state)
};

var jump = {arg d, min, max, j;
	var dir = [1,-1].choose;
	var amount = [1,2,3,4].wchoose([1, j, j * j, j * j * j].normalizeSum);
	d = dir * amount + d;
	if (d > max, {d = d * 0.5 + (max * 0.5)});
	if (d < min, {d = d * 0.5 + (min * 0.5)});
	d.asInteger
};

var ajump = {arg a, j;
	(a + (2*j).rand - j).max(0.05).min(0.2)
};


var rhythm = {arg speed, complexity;
	var dur = 0.5/speed;
	(speed.collect{
			[
				[dur, dur],
				[dur * 0.5, dur * 0.5, dur * 0.5, dur * 0.5],
				[dur * 1.5, dur * 0.5],
				[dur * 0.5, dur * 1.5]
			][(complexity+1).rand]
	}).flatten
};

var state_machine = {arg state;
	var r = rhythm.value(state.speed, state.rhythm_complexity);
	r.do {arg dur;
		state.d = jump.value(state.d, state.min, state.max, state.jump);
		state.a = ajump.value(state.a, state.ajump);
		note.value(state.d, dur, state.a).yield;
}};

var bars_pattern = {arg bars;
	var state = (d:0, a:0.1, min:-3, max:0, speed:2, jump:0, ajump:0, rhythm_complexity:0);
	p{
		bars.do	{arg bar;
			bar.post;
			state.postln;
			modify.value(state, bar);
			state_machine.value(state);
		}
	};
};

var tune = bars_pattern.value((27..38));

tune.play;
