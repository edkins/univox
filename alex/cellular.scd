var ww = 1920;
var wh = 1080;
var cw = 64;
var ch = 36;
var w = Window.new(bounds:Rect(0,0,ww,wh)).front;
var first_time = true;
var cells = Array2D.new(cw, ch);
var time = 0;
var extinction = false;

var palette = {|degree|
	if (degree < -8, {Color.new(1, (degree+16)/8, 0)  //red to yellow
		},{
		if (degree < 0, {Color.new((0-degree)/8,1,(8+degree)/8)  //yellow to cyan
			},{
			Color.new(0,(8-degree)/8,1)  //cyan to blue
})})
};

var redraw_func = {
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
		extinction = true;
	});
};

var view = UserView(w, Rect(0,0,ww,wh));

cw.do {|x|
	ch.do {|y|
		cells[x,y] = 1.0.rand;
	}
};

view.clearOnRefresh = false;
view.drawFunc = redraw_func;
view.animate = true;
view.frameRate = 14;
view.keyDownAction = key_down;
