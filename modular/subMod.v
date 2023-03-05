/*
 * @brief return (opA - opB) mod opM
 *
 * @tparam N bit width of opA, opB and opM
 *
 * @param opA Product input, should be less than opM
 * @param opB Product input, should be less than opM
 * @param opM Modulus
 */
 
/* 	2023/2/28
    GP(opM) => opA < opM && opB < opM
*/ 
module subMod # (
    parameter DATA_WIDTH = 256
) (
    input  wire                     clk,

    input  wire [DATA_WIDTH-1:0]    opA,
    input  wire [DATA_WIDTH-1:0]    opB,
    input  wire [DATA_WIDTH-1:0]    opM,

    output reg  [DATA_WIDTH-1:0]    out_data
);

reg [DATA_WIDTH-1+1:0] sum;
wire larger;
assign larger = opA > opB;

always @(*) begin
	if(larger)
		sum = opA - opB;
	else 
		sum = opA + opM;
end

always @(*) begin
	if(larger)
		out_data <= sum;
	else 
		out_data <= sum - opB;
end


endmodule