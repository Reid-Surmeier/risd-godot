extends RefCounted
## Verified source dispatch; locally synthesized timbres remain an adaptation.
const BASES = {"Grass":0x4201,"Path":0x4202,"Stone":0x4203,"Wood":0x4204,"Leaves":0x4205,"Snow":0x4206,"Sand":0x4208,"Water":0x4209,"Bridge":0x420a,"Indoor":0x4204}
const SHAPES = {"Grass":[150.0,.10,.025,.12],"Path":[195.0,.08,.012,.08],"Stone":[360.0,.075,.008,.035],"Wood":[240.0,.13,.008,.025],"Leaves":[130.0,.14,.045,.32],"Snow":[100.0,.13,.035,.20],"Sand":[115.0,.12,.025,.15],"Water":[420.0,.16,.045,.35],"Bridge":[220.0,.14,.01,.03],"Indoor":[240.0,.13,.008,.025],"Skid":[600.0,.24,.10,.40],"DoorLatch":[900.0,.075,.012,.12],"DoorCreak":[180.0,.24,.05,.09],"DoorShut":[95.0,.16,.025,.13]}
var streams := {}
var rng := RandomNumberGenerator.new()
var previous_special := false
func _init() -> void:
	rng.seed=4129
	for ground in SHAPES:
		for dash in [false,true]:
			for variant in 4:streams[key(ground,dash,variant)]=synthesize(ground,dash,variant)
func key(ground: String, dash: bool, variant: int) -> String:return ground+str(dash)+str(variant)
func synthesize(ground: String, dash: bool, variant: int) -> AudioStreamWAV:
	var shape: Array=SHAPES[ground]
	var rate := 22050
	var duration: float=shape[1]
	var count := int(duration*rate)
	var data := PackedByteArray();data.resize(count*2)
	var low := 0.0
	for i in count:
		var t := float(i)/rate
		low=lerpf(low,rng.randf_range(-1,1),.12 if ground!="Water" else .3)
		var attack := minf(1,t/.002)
		var body := sin(TAU*(float(shape[0])*(1+variant*.025)*t-50*t*t))*exp(-t/(duration*.21))
		var detail := low*exp(-t/float(shape[2]))*float(shape[3])
		var value := attack*(body*.32+detail)*(1.12 if dash else 1.0)
		data.encode_s16(i*2,int(clampf(value,-.95,.95)*32767))
	var stream := AudioStreamWAV.new();stream.format=AudioStreamWAV.FORMAT_16_BITS;stream.mix_rate=rate;stream.data=data
	return stream
func step(ground: String, gait: String, foot: String, inside: bool) -> Dictionary:
	var special := rng.randi_range(0,3)==3 and not previous_special
	previous_special=special
	var variant := (1 if foot=="Left" else 0)+(2 if special else 0)
	var dash := gait=="Dash"
	var gain: float={"Walk":.6,"Run":.8,"Dash":1.0}.get(gait,.6)*( .9 if inside else 1.0)
	return {"id":BASES[ground]+(40 if dash else 0)+(10 if foot=="Left" else 0)+(20 if special else 0),"bank":ground,"variant":variant,"dash":dash,"gain":gain,"pitch":1.0,"stream":streams[key(ground,dash,variant)]}
