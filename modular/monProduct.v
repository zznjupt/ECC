/*
 * @brief Montgomery Production of opA and opB and returns opA * opB * opM^-1 mod R
 * Reference: "Efficient architectures for implementing montgomery modular multiplication and RSA modular exponentiation
 * on reconfigurable logic" by Alan Daly, William Marnane
 *
 * @tparam N bit width of opA, opB and opM
 *
 * @param opA Montgomery representation of A
 * @param opB Montgomery representation of B
 * @param opM modulus
 */

module monProduct # (
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
parameter IDLE  = 3'd0;
parameter INPUT = 3'd1;
parameter OP1   = 3'd2;
parameter OP2   = 3'd3;
parameter DONE  = 3'd4;

reg [2:0] state_cs, state_ns;
reg [8:0] cnt;
wire      done_op;

// input register
reg [DATA_WIDTH-1:0] opA_reg;
reg [DATA_WIDTH-1:0] opB_reg;
reg [DATA_WIDTH-1:0] opM_reg;

wire 					a0 ;
wire 					qa ;
wire 					qm ;
wire [DATA_WIDTH-1:0]	addA = (qa == 1'b1) ? opA_reg : 0;
wire [DATA_WIDTH-1:0]	addM = (qm == 1'b1) ? opM_reg : 0;
reg  [DATA_WIDTH-1+2:0]	s;
wire [DATA_WIDTH-1+2:0]	tmp_s;
wire [DATA_WIDTH-1+2:0]	tmp_ss;

assign a0 = opA_reg[0];
assign qa = opB_reg[cnt];
assign qm = s[0] ^ (opB_reg[cnt] & a0);

assign tmp_s 	= s + addA + addM;
assign tmp_ss 	= tmp_s >> 1;
assign done_op 	= cnt == DATA_WIDTH;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		state_cs <= IDLE;
	else
		state_cs <= state_ns;
end

always @(*) begin
	case(state_cs)
		IDLE:	 state_ns = (in_valid) ? INPUT : IDLE;
		INPUT:	 state_ns = OP1;
		OP1:	 state_ns = (done_op) ? OP2 : OP1;
		OP2:	 state_ns = DONE;
		DONE:	 state_ns = IDLE;
		// default: state_ns = IDLE;
	endcase
end

always @(posedge clk or  negedge rst_n) begin
	if(!rst_n)
		s <= 0;
	else if(state_ns == IDLE)
		s <= 0;
	else if(state_ns == OP2) begin
		if(s > opM_reg)
			s <= s - opM_reg;
	end else if(state_ns == OP1)
		s <= tmp_ss;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt <= 0;
	else if(state_ns == IDLE)
		cnt <= 0;
	else if(state_ns == OP1)
		cnt <= cnt + 1;
end

// input
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		opA_reg <= 0;
		opB_reg <= 0;
		opM_reg <= 0;
	end else if(state_ns == IDLE) begin
		opA_reg <= 0;
		opB_reg <= 0;
		opM_reg <= 0;
	end else if(state_ns == INPUT) begin
		opA_reg <= opA;
		opB_reg <= opB;
		opM_reg <= opM;
	end	
end

// output
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_data <= 0;
		out_valid <= 0;
	end else if(state_ns == DONE) begin
		out_data <= s;
		out_valid <= 1;
	end else begin
		out_data <= 0;
		out_valid <= 0;
	end
end

endmodule