
float simple_noise(float value){
	return fract(sin(value + 0.546) * 143758.5453);
}

float ease_in_out(float value){
	float inv = 1.0 - value;
	float ein = value * value;
	float eout = 1.0 - (inv * inv);
	return mix(ein, eout, value);
}

float perlin1d(float value){
	float fraction = fract(value);
	float interpolator = ease_in_out(fraction);
	
	float previousCellInclination = simple_noise(floor(value)) * 2. - 1.;
    float previousCellLinePoint = previousCellInclination * fraction;

    float nextCellInclination = simple_noise(ceil(value)) * 2. - 1.;
    float nextCellLinePoint = nextCellInclination * (fraction - 1.);

    return mix(previousCellLinePoint, nextCellLinePoint, interpolator);
}