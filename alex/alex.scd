var ww = 1920;
var wh = 1080;
var w = Window.new(bounds:Rect(0,0,ww,wh)).front;
var colour = 0;
var circle_radius = 0;

var next_prob = [
//  -oct                                     same                                    +oct
	[3.0, 5.0,10.0, 9.0, 6.0, 4.0, 6.0, 5.0, 3.0, 5.0,10.0, 9.0, 6.0, 4.0, 6.0, 6.0, 3.0],
	[3.0, 5.0, 4.0, 9.0, 6.0, 4.0, 6.0, 5.0, 3.0, 5.0,10.0, 9.0, 6.0,10.0, 6.0, 6.0, 3.0],
	[4.0, 6.0, 6.0, 7.0, 9.0, 4.0, 4.0, 5.0, 6.0, 4.0,10.0, 5.0, 6.0, 4.0, 7.0, 4.0, 9.0],
	[3.0, 7.0, 4.0, 6.0, 7.0, 0.0, 6.0, 5.0, 8.0, 8.0,10.0, 2.0, 5.0,10.0, 6.0, 7.0, 6.0],
	[3.0, 5.0,10.0, 9.0, 6.0, 4.0, 6.0, 5.0, 6.0, 5.0,10.0, 9.0, 3.0, 4.0, 6.0, 6.0, 3.0],
	[4.0, 7.0,10.0, 9.0, 6.0, 4.0, 6.0, 5.0, 3.0, 5.0,10.0, 9.0, 6.0, 4.0, 2.0, 6.0, 4.0],
	[5.0, 6.0,10.0, 5.0, 6.0, 5.0, 6.0, 5.0, 4.0, 7.0,10.0, 2.0, 6.0, 4.0, 8.0, 6.0, 5.0],
	[5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9, 5.9],
];

var bar_complexity = [
	// little movement, mid-register singing
	(dur:2, movement:2, range:4, speed: 2, complex:0),   // 27
	(dur:2, movement:2, range:8, speed: 4, complex:1),   // 28
	(dur:2, movement:3, range:10, complex:1),   // 29
	// growth and development, patterns and range expansion
	(dur:2, movement:3, range:12, complex:2, flurries:0.2),   // 30
	(dur:2, movement:3, range:12,complex:3, flurries:0.2),   // 31
	(dur:2, movement:4, range:12,complex:4, flurries:0.2),   // 32
	(dur:2, movement:5, range:12,complex:4, flurries:0.2),   // 33
	// peak of solo, high range or alternating very big intervals
	(dur:1, movement:8, range:12,complex:5, flurries:0.2),   // 34
	(dur:1, movement:8, range:12,complex:5, flurries:0.2),   // 35
	(dur:1, movement:8, range:12,complex:6, flurries:0.2),   // 36
	(dur:1, movement:8, range:12,complex:6, flurries:0.5),   // 37
	// slowing down, low register to audible low rumble
	(dur:2, movement:3, min:-16,max:-5, complex:2, flurries:0.7),   // 38
	(dur:2, movement:1, min:-16,max:-13, complex:2, flurries:0.8),   // also 38
	(dur:1, movement:0, min:-16,max:-16, complex:0, speed:1)        // last  note is a long one
];

/*var buf = Buffer.read(s,Platform.resourceDir ++ '/sounds/alex/composite mezzo.wav');
var voice_gap = 4;
var voice_start = 0.5;*/
//var buf = Buffer.read(s,Platform.resourceDir ++ '/sounds/alex/Alex voice forte.wav');
var buf = Buffer.read(s,'/home/creo/Public/Creo_Animam/univox/alex/sounds/Alex voice forte.wav');

var voice_gap = 3;
var voice_start = 1;

var voices = SynthDef(\voices, { |freq = 440, degree, sustain = 1, amp = 0.5, amp_middle = 0.5, amp_end = 0.5|
	var env = Env.new([0, amp, amp_middle, amp_end, 0], [0.01, sustain / 2 - 0.025, sustain / 2 - 0.025, 0.01]);
	var start = (voice_gap*(degree+16).min(24).max(0)+voice_start)*44100;
	var phase0 = LFTri.ar(1,0,0.25*44100,start);
	var env0 = SinOsc.kr(1.0, 1.57);
	var phase1 = LFTri.ar(1,1,0.25*44100,start);
	var env1 = SinOsc.kr(1.0, 0);
	var bufrd = (BufRd.ar(2, buf.bufnum, phase0) * env0) + (BufRd.ar(2, buf.bufnum, phase1) * env1);
	Out.ar(0, bufrd * 40 * EnvGen.kr(env), doneAction:2)
}).add;

var note = {arg degree, dur=1/16, amp=0.1, amp_middle=0.1, amp_end=0.1, legato=1;
	colour = degree;
	(instrument:\voices, stretch:4*60/56,scale:[0,1,4,5,7,8,9,11],root:8,
	dur:dur, amp:amp, amp_middle:amp_middle, amp_end:amp_end, degree: degree, legato:legato)
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

var tweak_dur = {arg dur, t;
	var t0 = 4 * t;
	var t1 = 4 * (t + dur);
	if (t0.floor != t1.floor, t1.floor / 4 - t, dur)
};

var do_bar = {arg d, complexity;
	var min, max, t, amp, prev_d, prev_legato;
	if (complexity.min != nil,
		{min = complexity.min; max = complexity.max},
		{
			min = (-4 - complexity.range).max(-16);
			max = (-4 + complexity.range).min(8);
	});
	t = 0;
	prev_d = d;
	prev_legato = 1;
	while ({t < complexity.dur}, {
		var dur = complexity.dur;
		var amp_end = 0.01;
		var amp_middle;
		var prev_prev_d = prev_d;
		var amp_mul = 1;
		var legato = 1;
		prev_d = d;
		amp = 0.01;
		amp_end = amp;
		dur = if(complexity.speed != nil, {1/complexity.speed}, {1/4});
		if (complexity.complex >= 1, {dur = [1/2,1,2].choose * dur});
		if (complexity.complex <= 4, {dur = tweak_dur.value(dur, t)});
		if ((complexity.flurries != nil).and{1.0.rand < complexity.flurries}, {dur = 1/32});
		if ((complexity.complex >= 2).and(1.0.rand < 0.2), {
			amp = 0.02.rand;
			amp_end = 0.02.rand;
		});
		amp_middle = (amp + amp_end) / 2;
		dur = dur.min(complexity.dur - t);
		if ((complexity.complex >= 3).and(dur >= 0.25).and(prev_legato == 1), {legato = [0.5,0.75,0.75,1].choose});
		//if (complexity.complex >= 3, {amp_mul = [0,1,1,1,1].choose});
		//if (complexity.complex >= 5, {dur = [dur / 4, dur / 2, dur, dur * 2].choose});
		//if (complexity.complex >= 6, {dur = dur * 0.25 + (dur.rand * 0.75)});
		if (dur > 0.25, {amp_middle = amp_middle * 2});
		note.value(d, dur, amp * amp_mul, amp_middle * amp_mul, amp_end * amp_mul, legato).yield;
		d = jump.value(prev_d, prev_prev_d, min, max, complexity.movement);
		t = t + dur;
		prev_legato = legato;
	});
	d
};

var tune = p{
	var d = -4;

	bar_complexity.do{arg complex; complex.postln; d = do_bar.value(d, complex)}
};

var create_draw_func = {|note|
	{
	Pen.color = Color.green(rrand(0.0, 1), rrand(0.0, 0.5));
    Pen.addRect(
            Rect(20, 20, (w.bounds.width-40).rand, (w.bounds.height-40).rand)
        );
    Pen.perform([\stroke, \fill].choose);
	}
};

var play_with_graphics = {|t|
	var ok = true;
	var stream = t.asStream;
	while({ok},
	{
		var next = stream.next;
			if (next == nil, {ok = false}, {next.play;
				w.drawFunc = create_draw_func.value(next);
				(next.dur*next.stretch).wait
			});
	})
};

var palette = {|degree|
	if (degree < -8, {Color.new(1, (degree+16)/8, 0)  //red to yellow
		},{
		if (degree < 0, {Color.new((0-degree)/8,1,(8+degree)/8)  //yellow to cyan
			},{
			Color.new(0,(8-degree)/8,1)  //cyan to blue
})})
};

var first_time = true;
var redraw_func = {
    // set the Color
	var cx = ww/2;
	var cy = wh/2;

	if (first_time, {
		Pen.color = Color.black;
		Pen.addRect(Rect(0,0,ww,wh));
		Pen.perform(\fill);
		first_time = false;
	});

	Pen.color = palette.value(colour);
       Pen.strokeOval(
            Rect(cx - circle_radius, cy - circle_radius, 2 * circle_radius, 2 * circle_radius)
    );
	//colour = (colour + 0.001).frac;
	circle_radius = circle_radius + 0.1;
};

var view = UserView(w, Rect(0,0,ww,wh));
view.clearOnRefresh = false;
view.drawFunc = redraw_func;
view.animate = true;
view.frameRate = 60;

//{play_with_graphics.value(tune)}.asRoutine.play;
//fork {play_with_graphics.value(tune)};
tune.play;