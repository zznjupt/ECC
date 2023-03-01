/**
 * @brief return modular inverse of opA
 * Reference: "The Montgomery Modular Inverse - Revisited" by E Savas, CK Koç
 *
 * @tparam N bit width of opA and opM, opM should no less than 2^(N-1)
 *
 * @param opA Input of modular inverse.
 * @param opM Modulus of modular inverse.
 */

/* 	2023/2/28
    GP(opM) => opA < opM && opB < opM
*/
module invMod # (
    parameter DATA_WIDTH = 256
) (
	input  wire                     clk,
	input  wire                     rst_n,

	input  wire  [DATA_WIDTH-1:0]   opA,
	input  wire  [DATA_WIDTH-1:0]   opM,

	output reg   [DATA_WIDTH-1:0]   out_data,
	
	input  wire                     in_valid,
	output reg                      out_valid
);

// STATE
parameter IDLE 		= 4'd0;
parameter RD		= 4'd1;
parameter IDLE2 	= 4'd2;
parameter STAGE_1	= 4'd3;
parameter IDLE3 	= 4'd4;
parameter CHECK_R	= 4'd5;
parameter STAGE_2 	= 4'd6;
parameter IDLE4		= 4'd7;
parameter STAGE_3 	= 4'd8;
parameter IDLE5		= 4'd9;
parameter STAGE_4 	= 4'd10;
parameter IDLE6 	= 4'd11;
parameter DONE 		= 4'd12;

reg  [3:0]              state_cs, state_ns;
reg  [DATA_WIDTH-1:0]   u;
reg  [DATA_WIDTH-1:0]   v;
reg  [DATA_WIDTH-1:0]   s;
reg  [DATA_WIDTH-1:0]   r;
reg  [31:0]             k;
reg  [9:0]              cnt;
reg  [DATA_WIDTH-1:0]   opM_reg;

wire                    mp_in_valid;
wire                    mp_out_valid;
wire [DATA_WIDTH-1:0]   mp_out_data;

assign mp_in_valid = (state_cs == IDLE5 && state_ns == STAGE_4) ? 1 : 0;

wire done_stage1;
wire done_stage3;


assign done_stage1 = v == 0;
assign done_stage3 = cnt == k;

monProduct # (.DATA_WIDTH(DATA_WIDTH))
mp1 (
	.clk			(clk), 
	.rst_n			(rst_n),
	.opA			(r[DATA_WIDTH-1:0]),
	.opB			('b1),
	.opM			(opM_reg),
	.in_valid		(mp_in_valid),
	.out_valid		(mp_out_valid),
	.out_data		(mp_out_data)
);

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		state_cs <= IDLE;
	else 
		state_cs <= state_ns;
end

always @(*) begin
	case(state_cs)
		IDLE:		state_ns = (in_valid) ? RD : IDLE;
		RD:			state_ns = IDLE2;
		IDLE2: 		state_ns = (done_stage1) ? IDLE3 : STAGE_1;
		STAGE_1:	state_ns = IDLE2;
		IDLE3:		state_ns = CHECK_R;
		CHECK_R:	state_ns = STAGE_2;
		STAGE_2:	state_ns = IDLE4;
		IDLE4:		state_ns = STAGE_3;
		STAGE_3:	state_ns = (done_stage3) ? IDLE5 : STAGE_3;
		IDLE5:		state_ns = STAGE_4;
		STAGE_4: 	state_ns = (mp_out_valid) ? DONE : STAGE_4;
		DONE:		state_ns = IDLE;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt <= 0;
	else if(state_ns == IDLE)
		cnt <= 0;
	else if(state_ns == STAGE_3)
		cnt <= cnt + 1;
end

reg [DATA_WIDTH-1:0] 	tmp_u;
reg [DATA_WIDTH-1:0] 	tmp_v;
reg [DATA_WIDTH-1+1:0] 	tmp_r;

always @(*) begin
	if(state_ns == STAGE_1) begin
		tmp_u = u - v;
		tmp_v = v - u;
	end else begin
		tmp_u = 0;
		tmp_v = 0;
	end
end

always @(*) begin
	if(state_ns==STAGE_3)
		tmp_r = r + opM_reg;
	else 
		tmp_r = 0 ;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		opM_reg <= 0;
	else if(state_ns == IDLE)
		opM_reg <= 0;
	else if(state_ns == RD)
		opM_reg <= opM;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		u <= 0;
		v <= 0;
		s <= 0;
		r <= 0;
		k <= 0;
	end else if(state_ns == RD) begin
		u <= opM;
		v <= opA;
		s <= 1;
		r <= 0;
		k <= 0;
	end else if(state_ns == STAGE_1) begin
		if(u[0] == 0) begin
			u <= u >> 1;
			s <= s << 1;
		end else if(v[0] == 0) begin
			v <= v >> 1;
			r <= r << 1;
		end else if(u >v ) begin
			u <= tmp_u >> 1;
			r <= r + s;
			s <= s << 1;
		end else begin
			v <= tmp_v >> 1;
			s <= s + r;
			r <= r << 1;
		end
		k <= k + 1;
	end else if(state_ns == CHECK_R) begin
		if(r >= opM_reg)
			r <= r - opM_reg;
	end else if(state_ns == STAGE_2) begin
		r <= opM_reg - r;
		k <= k - 256;
	end else if(state_ns == STAGE_3) begin
		if(r[0] == 1)
			r <= tmp_r >> 1;
		else 
			r <= r >> 1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_valid <= 0;
		out_data <= 0;
	end else if(state_ns == IDLE) begin
		out_valid <= 0;
		out_data <= 0;
	end else if(state_ns == DONE) begin
		out_valid <= 1;
		out_data <= mp_out_data;
	end
end

endmodule