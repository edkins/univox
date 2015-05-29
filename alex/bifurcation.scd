var ww = 1920;
var wh = 1080;
var w = Window.new(bounds:Rect(0,0,ww,wh)).front;
var colour = 0;
var x = 0;
var first_time = true;

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
    if (first_time, {
		Pen.color = Color.black;
		Pen.addRect(Rect(0,0,ww,wh));
		Pen.perform(\fill);
		first_time = false;
	});

	c = -2 + (x / 250);
	z = 0;
	50.do {|i|
		Pen.color = palette.value((i % 24) - 16);
		z = z * z + c;
		y = 500 + (z * 250);
		Pen.fillRect(Rect(y, x, 1, 1));
	};
	x = x + 1;
};

var view = UserView(w, Rect(0,0,ww,wh));
view.clearOnRefresh = false;
view.drawFunc = redraw_func;
view.animate = true;
view.frameRate = 60;

