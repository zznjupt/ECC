/**
 * @brief return (opA * opB) mod opM
 *
 * @tparam N bit width of opA, opB and opM
 *
 * @param opA Product input, should be less than opM
 * @param opB Product input, should be less than opM
 * @param opM Modulus, should be larger than 2^(N-1)
 */

/* 	2023/2/28
    GP(opM) => opA < opM && opB < opM
*/
module productMod # (
    parameter DATA_WIDTH = 256
) (
	input  wire                     clk,
	input  wire                     rst_n,
	
	input  wire  [DATA_WIDTH-1:0]   opA,
	input  wire  [DATA_WIDTH-1:0]   opB,
	input  wire  [DATA_WIDTH-1:0]   opM,

	output reg   [DATA_WIDTH-1:0]   out_data,
	
	input  wire                     in_valid,
	output reg                      out_valid
);
// STATE
parameter IDLE 		= 3'd0;
parameter STAGE_1 	= 3'd1;
parameter COMPARE 	= 3'd2;
parameter STAGE_2 	= 3'd3;
parameter DONE 		= 3'd4;

reg [2:0] state_cs, state_ns;
reg [7:0] cnt;

reg [DATA_WIDTH-1+1:0]  compare_reg;
reg [DATA_WIDTH-1:0]    opA_reg;
reg [DATA_WIDTH-1:0]    opB_reg;
reg [DATA_WIDTH-1:0]    opM_reg;

wire all_done;
assign all_done = cnt == DATA_WIDTH-1;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		state_cs <= IDLE;
	else 
		state_cs <= state_ns;
end

always @(*) begin
	case(state_cs)
		IDLE:    state_ns = (in_valid) ? STAGE_1 : IDLE;
		STAGE_1: state_ns = COMPARE;
		COMPARE: state_ns = STAGE_2;
		STAGE_2: state_ns = (all_done) ? DONE : STAGE_1;
		DONE: 	 state_ns = IDLE;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt <= 0;
	else if(state_ns == IDLE)
		cnt <= 0;
	else if(state_cs == STAGE_2 && state_ns == STAGE_1)
		cnt <= cnt + 1;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		opA_reg <= 0;
		opB_reg <= 0;
		opM_reg <= 0;
	end else if(state_ns==IDLE) begin
		opA_reg <= 0;
		opB_reg <= 0;
		opM_reg <= 0;
	end else if(in_valid) begin
		opA_reg <= opA;
		opB_reg <= opB;
		opM_reg <= opM;
	end
end

wire [DATA_WIDTH-1+1:0] compare_shift = {compare_reg[DATA_WIDTH-1:0], 1'b0};

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		compare_reg <= 0;
	else if(state_ns == IDLE)
		compare_reg <= 0;
	else if(state_ns == STAGE_1) begin
		if(compare_shift > opM_reg)
            compare_reg <= compare_shift - opM_reg;
		else 
			compare_reg <= compare_shift;
	end else if(state_ns==COMPARE) begin
		if(opB_reg[DATA_WIDTH-1 - cnt])
			compare_reg <= compare_reg + opA_reg;
	end else if(state_ns == STAGE_2)begin
		if(compare_reg > opM_reg)
			compare_reg <= compare_reg - opM_reg;
	end
end

// output
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_data  <= 0;
		out_valid <= 0;
	end else if(state_ns == IDLE) begin
		out_data  <= 0;
		out_valid <= 0;
	end else if(state_ns == DONE) begin
		out_data  <= compare_reg[DATA_WIDTH-1:0];
		out_valid <= 1;
	end
end


endmodule