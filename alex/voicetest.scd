var buf = Buffer.read(s,Platform.resourceDir ++ '/sounds/alex/Alex voice forte.wav');
var voice_gap = 3;
var voice_start = 1;
var degree = 0;
var start = (voice_gap*(degree+16).min(24).max(0)+voice_start)*44100;

/*
{
	var trigger0 = Impulse.kr(1.0);
	var env0 = SinOsc.kr(1.0, -1.5708, 0.5, 0.5);
	var trigger1 = Impulse.kr(1.0, 0.5);
	var env1 = SinOsc.kr(1.0, 1.5708, 0.5, 0.5);
	(PlayBuf.ar(2, buf.bufnum, 1, trigger0, start) * env0) + (PlayBuf.ar(2, buf.bufnum, 1, trigger1, start) * env1)
}.play
*/


{
	var phase0 = LFTri.ar(1,0,0.25*44100,start);
	var env0 = SinOsc.kr(1.0, 1.57);
	var phase1 = LFTri.ar(1,1,0.25*44100,start);
	var env1 = SinOsc.kr(1.0, 0);
	(BufRd.ar(2, buf.bufnum, phase0) * env0) + (BufRd.ar(2, buf.bufnum, phase1) * env1)
}.play
