/*
 *	(C) 2022 J. R. Sharp
 *	
 *	AM test pattern generator
 *
 *	See LICENSE.txt for software license
 */

module am_gen
(
	input CLK,
	input RSTb,
	output reg one_bit_rf
);

/* Carrier */

wire [39:0] phase_inc = 40'h2656abde3; // 936 kHz
wire signed [15:0] sin;
wire signed [15:0] cos;

nco nco0
(
	CLK,
	RSTb,

	phase_inc,

	sin,
	cos
);

/* Modulation */

/* phase inc =>  print("%x" % int(1e3 / (a / (1<<40)))) where a is the clock rate */
wire [39:0] phase_inc_mod = 40'ha7c5ac; // 1 kHz
wire signed [15:0] sin_mod;
wire signed [15:0] cos_mod;

nco nco1
(
	CLK,
	RSTb,

	phase_inc_mod,

	sin_mod,
	cos_mod
);

/* State machine */

reg signed [15:0] cos_q;
reg signed [15:0] cos_mod_q;

wire signed [15:0] mod_scale = 16'hccc;
wire signed [31:0] mod_scaled;

mult m0 (mod_scale, cos_mod_q, mod_scaled);

reg signed [15:0] cos_mod_scaled;
reg signed [15:0] cos_mod_plus_dc;

wire signed [31:0] mod_wave;

mult m1 (cos_mod_plus_dc, cos_q, mod_wave);

reg signed [15:0] mod_wave_q;

wire signed [15:0] noise_val;

reg [9:0] count = 10'd0;

always @(posedge CLK) count += 1;

noiseTable noise0 (CLK, count, noise_val);

reg signed [15:0] mod_wave_q_noise;

always @(posedge CLK)
begin
	cos_mod_q <= cos_mod;
	cos_q <= cos;
	cos_mod_scaled <= mod_scaled[31:16];
	cos_mod_plus_dc <= cos_mod_scaled + 16'h2ccc;
	mod_wave_q <= mod_wave[31:16];
	mod_wave_q_noise <= mod_wave_q + noise_val;
	one_bit_rf <= (mod_wave_q_noise > 0) ? 1'b1 : 1'b0;
end

endmodule
