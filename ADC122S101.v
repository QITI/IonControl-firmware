//////////////////////////////////////////////////////////////////
//    IonControl 1.0:  Copyright 2016 Sandia Corporation              
//    This Software is released under the GPL license detailed    
//    in the file "license.txt" in the top-level pyGSTi directory 
//////////////////////////////////////////////////////////////////

// 12-bit ADC from National Semiconductor: ADC122S101
// Reference voltage (V_A) connected on Maryland board: 3.3V generated by TI REF2933

module ADC122S101(
	input wire clk, 
	output reg adcs = 1, // CS_bar (pin1)
	output wire adclk,   // SCLK (pin8)
	output wire addin,   // DIN (pin6)
	input wire addout,   // DOUT (pin7)
	input wire ADCRead, 
	input wire [7:0] ADCControl, 
	output reg [15:0] ADCData = 0, 
	output reg ADCDataReady = 0);

	reg [7:0] Control = 0;
	assign addin = Control[7];
	reg newData =0;
	reg [6:0] state = 0;
	assign adclk = ~state[1];
	reg [15:0] ADCData_internal = 0;
	
	always @(negedge clk) begin
		if (ADCDataReady) ADCDataReady <= 1'b0;
		if (ADCRead) begin
			Control <= ADCControl;
			newData <= 1'b1;
			state <= 7'h0;
		end
		else if (newData) begin
			state <= state + 7'h1;
			if (state == 7'h0) adcs <= 1'b0;
			if (state == 7'b1000010) begin
				adcs <= 1'b1;
				newData <= 1'b0;
				ADCDataReady <= 1'b1;
				ADCData <= ADCData_internal;
			end
			if (state[1:0] == 2'b01)
				if (state[6:1] != 6'b000000) Control[7:0] <= {Control[6:0], Control[7]};
			if (state[1:0] == 2'b00)
				if (state[6:1] != 6'b000000) ADCData_internal[15:0] <= {ADCData_internal[14:0], addout};

		end
	end

endmodule
