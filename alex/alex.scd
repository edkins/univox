var main = {
var graphics = true;
var prob_table = 1;  // 1: tendencies, 2: triads, 3: pattern
var ww = 1920;
var wh = 1080;
var w;
var colour = 0;
var whitering = false;
var circle_radius = 0;
var cw = 64;
var ch = 36;
var first_time = true;
var cells = Array2D.new(cw, ch);
var time = 0;
var extinction = false;
var tree = false;
var final_fade = false;
var dropcount = 0;

var next_prob = [[],
		[
//-oct                                  same                                     +oct
[10.0,10.0,30.0, 5.0,30.0, 0,  10.0,30.0,10.0,10.0,30.0, 5.0,30.0, 0,  10.0,30.0,10.0],
[ 1.0, 2.0, 5.0, 5.0, 0,   5.0, 5.0,50.0, 2.0,30.0, 0,   5.0, 0,   5.0, 5.0, 5.0, 1.0],
[10.0,10.0,10.0, 0,  10.0,10.0,10.0,10.0,10.0,10.0,10.0, 0,  10.0,10.0,10.0,10.0,10.0],
[ 5.0, 5.0, 0,   5.0, 5.0, 5.0, 5.0,50.0, 5.0, 5.0, 0,   5.0, 5.0, 5.0, 5.0,50.0,10.0],
[10.0, 0,  10.0,10.0,10.0,10.0,10.0,10.0,10.0, 0,  10.0,10.0,10.0,10.0,10.0,10.0,10.0],
[ 0,   1,   1,   1,   1,   1,   1,   1,   0,   1,   1,   1,   1,   1,   1,   1,   0],
[10.0,10.0,10.0,10.0,10.0,10.0,10.0, 0,  10.0,10.0,10.0,10.0,10.0,10.0,10.0, 0,  10.0],
[10.0,50.0, 5.0, 5.0, 5.0, 5.0, 0.0, 5.0,10.0,50.0, 5.0, 5.0, 5.0, 5.0, 0,   5.0,10.0],
		],[
[ 5.0, 5.0,20.0, 5.0,20.0,  0,  5.0,20.0, 5.0, 5.0,20.0, 5.0,20.0, 0,   5.0,20.0, 5.0],
[ 0.0, 5.0,20.0, 5.0, 0,  20.0, 5.0,50.0, 0,   0,  20.0, 5.0, 0,  20.0, 5.0, 5.0, 0.0],
[ 5.0, 5.0,20.0, 0,   5.0,20.0,20.0, 5.0, 5.0, 5.0,20.0, 0,   5.0,20.0,20.0, 5.0, 5.0],
[ 5.0,20.0, 0,   5.0,20.0, 5.0, 20.0,5.0, 5.0, 5.0, 0,  20.0, 5.0,20.0, 5.0,20.0, 5.0],
[20.0, 0,   5.0,20.0, 5.0, 5.0, 5.0, 5.0, 5.0, 0,   0,  20.0,20.0, 5.0, 5.0,20.0,20.0],
[ 0,   1,   1,   1,   1,   1,   1,   1,   0,   1,   1,   1,   1,   1,   1,   1,   0],
[ 0,   0,   0,   0,   0,   0,   0,   0,   5.0,20.0, 0,  20.0, 0,   0,   0,   0,   0],
[ 5.0, 5.0,20.0, 0,  20.0,20.0,  0,  5.0, 5.0, 5.0,20.0, 5.0,20.0, 5.0, 0,  20.0, 5.0],
		],[
[ 5.0,10.0, 5.0,10.0, 5.0, 0,   5.0,10.0, 5.0,10.0, 5.0,10.0, 5.0, 0,   5.0,10.0, 5.0],
[10.0, 5.0,10.0, 5.0, 0,   5.0,10.0, 5.0,10.0, 5.0,10.0, 5.0, 0,   5.0,10.0, 5.0, 5.0],
[ 5.0,10.0, 5.0, 0,   5.0,10.0, 5.0,10.0, 5.0,10.0, 5.0, 0,   5.0,10.0, 5.0, 5.0,10.0],
[10.0, 5.0, 0,   5.0,10.0, 5.0,10.0, 5.0,10.0, 5.0, 0,   5.0,10.0, 5.0, 5.0,10.0, 5.0],
[ 5.0, 0,   5.0,10.0, 5.0,10.0, 5.0,10.0, 5.0, 0,   5.0,10.0, 5.0, 5.0,10.0, 5.0,10.0],
[ 0,   1,   1,   1,   1,   1,   1,   1,   0,   1,   1,   1,   1,   1,   1,   1,   0],
[10.0, 5.0,10.0, 5.0,10.0, 5.0,10.0, 0,  10.0, 5.0,10.0, 5.0, 5.0,10.0, 5.0, 0,   5.0],
[ 5.0,10.0, 5.0,10.0, 5.0,10.0, 0,  10.0, 5.0,10.0, 5.0, 5.0,10.0, 5.0, 0,   5.0,10.0],
]];

var bar_complexity = [
	// little movement, mid-register singing
	(dur:2, movement:2, range:4, speed: 2, complex:0),   // 27
	(dur:2, movement:2, range:8, speed: 4, complex:1, loud:0),   // 28
	(dur:2, movement:3, range:10, complex:1, loud:0),   // 29
	// growth and development, patterns and range expansion
	(dur:2, movement:5, min:-8,max:8, complex:2, flurries:0.2, bias:1, loud:0, white:true),   // 30
	(dur:2, movement:6, min:-8,max:8,complex:3, flurries:0.2, bias:-1, loud:-1),   // 31
	(dur:2, movement:7, min:-8,max:8,complex:4, flurries:0.2, bias:-1, loud:0),   // 32
	(dur:2, movement:8, min:-8,max:8,complex:4, flurries:0.2, bias:-1, loud:1),   // 33
	// peak of solo, high range or alternating very big intervals
	(dur:1, movement:8, min:0,max:8,complex:5, flurries:0.2, bias:1, loud:2, white:true),   // 34
	(dur:1, movement:8, min:0,max:8,complex:5, flurries:0.2, bias:1, loud:2),   // 35
	(dur:1, movement:8, min:0,max:8,complex:6, flurries:0.2, bias:1, loud:2),   // 36
	(dur:1, movement:8, min:0,max:8,complex:6, flurries:0.5, bias:-1, loud:2),   // 37
	// slowing down, low register to audible low rumble
	(dur:2, movement:3, min:-16,max:-5, complex:2, flurries:0.7, loud:1, white:true),   // 38
	(dur:2, movement:1, min:-16,max:-13, complex:2, flurries:0.8, loud:1),   // also 38
	(dur:1, movement:0, min:-16,max:-16, complex:0, speed:1, loud:0)        // last  note is a long one
];

//var buf = Buffer.read(s,Platform.resourceDir ++ '/sounds/alex/Alex voice forte.wav');
//var bufp = Buffer.read(s,Platform.resourceDir ++ '/sounds/alex/Alex voice piano.wav');
var buf = Buffer.read(s,'/home/creo/Public/Creo_Animam/univox/alex/sounds/Alex voice forte.wav');
var bufp = Buffer.read(s,'/home/creo/Public/Creo_Animam/univox/alex/sounds/Alex voice piano.wav');

var voice_gap = 3;
var voice_start = 1;

var voices = SynthDef(\voices, { |freq = 440, degree, sustain = 1, amp = 0.5, amp_middle = 0.5, amp_end = 0.5|
	var actual_sustain = sustain.min(2);
	var start_length = (actual_sustain * 0.1).min(0.05);
	var end_length = (actual_sustain * 0.1).min(0.05);
	var middle_length = actual_sustain - start_length - end_length;
		var env = Env.new([0, amp, amp_middle, amp_end, 0], [start_length, middle_length / 2, middle_length / 2, end_length]);
	var e = (EnvGen.kr(env, doneAction:2) - 0.03).max(0);
	var ep = (EnvGen.kr(env, doneAction:2) * 2).min(0.06 - EnvGen.kr(env) * 2).max(0);
	var start = (voice_gap*(degree+16).min(24).max(0)+voice_start)*44100;
	var phase = LFTri.ar(0.25,-1,44100,start);
	var phasep = LFTri.ar(0.25,-1,44100,start);
	var bufrd = BufRd.ar(2, buf.bufnum, phase);
	var bufrdp = BufRd.ar(2, bufp.bufnum, phasep);
//	Out.ar(0, FreeVerb.ar((bufrd * 80 * e) + (bufrdp * 80 * ep),0.85,0.7), doneAction:2)
	Out.ar(0, (bufrd * 80 * e) + (bufrdp * 80 * ep))
}).add;

var note = {arg degree, dur=1/16, amp=0.1, amp_middle=0.1, amp_end=0.1, legato=1;
	colour = degree;
	if (degree % 8 == 5, {"warning: E".postln});
	(instrument:\voices, stretch:4*60/56,scale:[0,1,4,5,7,8,9,11],root:8,
	dur:dur, amp:amp, amp_middle:amp_middle, amp_end:amp_end, degree: degree, legato:legato)
};

var jump = {arg d, prev_d, min, max, movement, bias_direction;
	var probs;
	var nonzero = false;
	probs = (-8..8).collect({arg i;
		var ok = true;
		ok = ok.and(d + i >= min);
		ok = ok.and(d + i <= max);
		ok = ok.and(i.abs <= movement);
		ok = ok.and((i != 0).or(d != prev_d));  // avoid three identical notes in a row
		if(ok, {
			var prob = next_prob[prob_table][d % 8][i+8];
			if (bias_direction == i.sign, {prob = prob * 2});
			nonzero = true;
			prob
		}, 0)
	});
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

var avoid_long_note = {|degree| degree % 8 == 1};

var do_bar = {arg d, complexity;
	var min, max, t, amp, prev_d, prev_legato, prev_amp_mul;
	if (complexity.min != nil,
		{min = complexity.min; max = complexity.max},
		{
			min = (-4 - complexity.range).max(-16);
			max = (-4 + complexity.range).min(8);
	});
	t = 0;
	//if (d > -4, {d = d - 8},{d = d + 8});
	prev_d = d;
	prev_legato = 1;
	prev_amp_mul = 1;
	while ({t < complexity.dur}, {
		var dur = complexity.dur;
		var amp_end = 0.01;
		var amp_middle;
		var prev_prev_d = prev_d;
		var amp_mul = 1;
		var legato = 1;
		var bias_direction = complexity.bias;
		var amp_mul_target = 1;
		if (min == max, {d = min});
		prev_d = d;
		amp = 0.01;
		amp_end = amp;
		if (complexity.loud != nil, {amp_mul_target = pow(2.0, complexity.loud)});
		amp_mul = 0.5 * amp_mul + (0.5 * amp_mul_target);
		dur = if(complexity.speed != nil, {1/complexity.speed}, {1/4});
		if (complexity.complex >= 1, {dur = [1/2,1,2].choose * dur});
		if (complexity.complex <= 4, {dur = tweak_dur.value(dur, t)});
		if ((complexity.flurries != nil).and{1.0.rand < complexity.flurries}, {dur = 1/32});
		if (avoid_long_note.value(d), {dur = dur.min(1/8)});
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
		whitering = (t < 0.5).and(complexity.white == true);
		note.value(d, dur, amp * amp_mul, amp_middle * amp_mul, amp_end * amp_mul, legato).yield;
		d = jump.value(prev_d, prev_prev_d, min, max, complexity.movement, bias_direction);
		t = t + dur;
		prev_legato = legato;
	});
	d
};

var tune = p{
	var d = -4;

	bar_complexity.do{arg complex; complex.postln; d = do_bar.value(d, complex)};
	final_fade = true;
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

var palette = {|degree, alpha=1, white=false|
	if (white, Color.white, {
	if (degree < -8, {Color.new(1, (degree+16)/8, 0, alpha)  //red to yellow
		},{
		if (degree < 0, {Color.new((0-degree)/8,1,(8+degree)/8, alpha)  //yellow to cyan
			},{
			Color.new(0,(8-degree)/8,1, alpha)  //cyan to blue
		})})})
};


var cellular_redraw_func = {
	var y = 500;
	var z, c;
	var newcells = Array2D.new(cw, ch);
	var add;
	var mul;
	var spacing = if(extinction, 1, 15);
	var cenx, ceny;
    if (first_time, {
		Pen.color = Color.black;
		Pen.addRect(Rect(0,0,ww,wh));
		Pen.perform(\fill);
		first_time = false;
	});



	cw.do {|x|
		ch.do {|y|
			var x0 = (x - 1) % cw;
			var y0 = (y - 1) % ch;
			var x1 = (x + 1) % cw;
			var y1 = (y + 1) % ch;
			var xscale = ww / cw;
			var yscale = wh / ch;
			var value = ((cells[x,y] * 0.6) + (cells[x1,y] * 0.1) + (cells[x,y1] * 0.1) + (cells[x0,y] * 0.1) + (cells[x,y0] * 0.1) + 0.04.rand - if(extinction,0.0225,0));
			newcells[x,y] = value;
			Pen.color = Color.black;
			Pen.fillRect(Rect(xscale * x, yscale * y, xscale, yscale));
			Pen.color = palette.value(-16 + (23 * value));
			value = value * 0.9;
			Pen.fillOval(Rect(xscale * (x - (0.5 * value)), yscale * (y - (0.5 * value)), xscale * value, yscale * value));
		}
	};
	cenx = (cw/2).asInt;
	ceny = (ch/2).asInt;
	newcells[cenx, ceny] = newcells[cenx, ceny].max(0.5);
	if (extinction.not, {
	if (time % spacing == 0, {
		var x,y;
		var border = if(extinction, 0, 5);
		time.postln;
		x = border + (cw-(2*border)).rand;
		y = border + (ch-(2*border)).rand;
		if ((newcells[x,y] > 0.5).or(extinction), {
			(-4..4).do {|i|
			(-4..4).do {|j|
				newcells[(x+i)%cw,(y+j)%ch] = newcells[(x+i)%cw,(y+j)%ch].min(1.0 - pow(1.0.rand,2.0));
			}
		}
		},{
			(-2..2).do {|i|
			(-2..2).do {|j|
				newcells[(x+i)%cw,(y+j)%ch] = newcells[(x+i)%cw,(y+j)%ch].max(pow(1.0.rand,0.5));
			}
		}
		});
	});
	});
	add = if(extinction, 0.0, 0-newcells.minItem);
	mul = if(extinction, 1.0, 1.0 / (newcells.maxItem - newcells.minItem));
	cw.do {|x|
		ch.do {|y|
			cells[x,y] = ((newcells[x,y] + add) * mul).min(1).max(0);
		}
	};
	time = time + 1;
};

var key_down = {|view, char, modifier, s, unicode, keycode|
	if (unicode == 114, {  // right arrow
		if (extinction, {
			if (tree.not, {
				view.frameRate = 60;
				tune.play;
				tree = true
			})
		}, {extinction = true})
	});
};


var tree_redraw_func = {
    // set the Color
	var cx = ww/2;
	var cy = wh/2;
	var intensity = 1;

	if (first_time, {
		Pen.color = Color.black;
		Pen.addRect(Rect(0,0,ww,wh));
		Pen.perform(\fill);
		first_time = false;
	});

	if (final_fade, {intensity = 0.1});

	Pen.color = palette.value(colour, intensity, whitering);
       Pen.strokeOval(
            Rect(cx - circle_radius, cy - circle_radius, 2 * circle_radius, 2 * circle_radius)
    );
	//colour = (colour + 0.001).frac;
	circle_radius = circle_radius + 0.1;
};

var final_fade_redraw_func = {
	(dropcount/50).roundUp.min(50).do {
		var radius = 10 + 10.rand;
		Pen.color = Color.gray(0, 0.1);
		Pen.fillOval(Rect.new(ww.rand - radius, wh.rand - radius, 2*radius, 2*radius));
	};
	dropcount = dropcount + 1;
};

var redraw_func = {
	if (final_fade, {final_fade_redraw_func.value; tree_redraw_func.value},
		{if (tree, tree_redraw_func, cellular_redraw_func)}
	)
};
var view;

cw.do {|x|
	ch.do {|y|
		cells[x,y] = 1.0.rand;
	}
};
/*tune = p{(-16..8).do{|i|
	(0..2).do{|j|
		var amp = 0.02 + (0.02 * j);
		note.value(i,0.5,amp,amp,amp).yield}}};*/
if (graphics, {
	w = Window.new(bounds:Rect(1000,0,ww,wh)).front().fullScreen();
	view = UserView(w, Rect(0,0,ww,wh));
	view.clearOnRefresh = false;
	view.drawFunc = redraw_func;
	view.animate = true;
	view.frameRate = 14;
	view.keyDownAction = key_down;
	view.focus(true);

	//{play_with_graphics.value(tune)}.asRoutine.play;
	//fork {play_with_graphics.value(tune)};
}, {tune.play});
};

s.options.memSize = 65536;
s.waitForBoot(main);
