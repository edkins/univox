var ww = 1920;
var wh = 1080;
var cw = 96;
var ch = 54;
var w = Window.new(bounds:Rect(0,0,ww,wh)).front;
var first_time = true;
var cells = Array2D.new(cw, ch);
var time = 0;

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
	var add = 0-cells.minItem;
	var mul = 1.0 / (cells.maxItem - cells.minItem);
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
			var value = ((cells[x,y] * 0.6) + (cells[x1,y] * 0.1) + (cells[x,y1] * 0.1) + (cells[x0,y] * 0.1) + (cells[x,y0] * 0.1) + 0.025.rand + add) * mul;
			newcells[x,y] = value;
			Pen.color = Color.black;
			Pen.fillRect(Rect(xscale * x, yscale * y, xscale, yscale));
			Pen.color = palette.value(-16 + (23 * value));
			Pen.fillOval(Rect(xscale * x, yscale * y, xscale * value, yscale * value));
		}
	};
	if (time % 3 == 0, {
		var x = cw.rand;
		var y = ch.rand;
		newcells[x,y] = 0.9;
	});
	cells = newcells;
	time = time + 1;
};

var view = UserView(w, Rect(0,0,ww,wh));

cw.do {|x|
	ch.do {|y|
		cells[x,y] = if(1.0.rand < 0.1, 1, 0);
	}
};

view.clearOnRefresh = false;
view.drawFunc = redraw_func;
view.animate = true;
view.frameRate = 10;

