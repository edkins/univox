var ww = 1920;
var wh = 1080;
var cw = 100;
var ch = 100;
var w = Window.new(bounds:Rect(0,0,ww,wh)).front;
var first_time = true;
var cells = Array2D.new(cw, ch);

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
			var value = (cells[x,y] * 0.7) + (cells[x1,y] * 0.1) + (cells[x,y1] * 0.1) + (cells[x0,y] * 0.1) + (cells[x,y0] * 0.1) + 0.01.rand - 0.005 - 0.01;
			newcells[x,y] = value;
			Pen.color = Color.green(value * 3);
			Pen.fillRect(Rect(xscale * x, yscale * y, xscale, yscale));
		}
	};
	cells = newcells;
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

