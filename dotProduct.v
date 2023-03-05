module dotProduct # (
    parameter DATA_WIDTH = 256
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire [DATA_WIDTH-1:0]    Px,
    input  wire [DATA_WIDTH-1:0]    Py,
    input  wire [DATA_WIDTH-1:0]    k,
    output reg  [DATA_WIDTH-1:0]    Rx,
    output reg  [DATA_WIDTH-1:0]    Ry,
    input  wire                     in_valid,
    output reg                      out_valid
);


parameter IDLE  = 4'd0;
parameter RD	= 4'd1;
parameter IDLE2	= 4'd2;
parameter ADD1	= 4'd3;
parameter IDLE3	= 4'd4;
parameter ADD2 	= 4'd5;
parameter IDLE4	= 4'd6;
parameter DONE	= 4'd7;

reg [3:0] state_cs, state_ns;
reg [9:0] cnt;

reg [DATA_WIDTH-1:0] Px_reg;
reg [DATA_WIDTH-1:0] Py_reg;
reg [DATA_WIDTH-1:0] k_reg;

wire done_add;
wire add_Mult;
assign add_Mult = (k_reg[cnt]) ? 1 : 0;
assign done_add = (cnt == DATA_WIDTH) ? 1 : 0;

reg  [DATA_WIDTH-1:0]   add_Px;
reg  [DATA_WIDTH-1:0]   add_Py;
reg  [DATA_WIDTH-1:0]   add_Qx;
reg  [DATA_WIDTH-1:0]   add_Qy;
wire [DATA_WIDTH-1:0]   add_Rx;
wire [DATA_WIDTH-1:0]   add_Ry;
reg 		            add_in_valid;
wire 		            add_out_valid;

add # (.DATA_WIDTH(DATA_WIDTH)) 
a1 (
	.clk        (clk),
	.rst_n      (rst_n),
	.Px         (add_Px),
	.Py         (add_Py),
	.Qx         (add_Qx),
	.Qy         (add_Qy),
	.Rx         (add_Rx),
	.Ry         (add_Ry),
	.in_valid   (add_in_valid),
	.out_valid  (add_out_valid)
);

always @(*) begin
	if((state_cs != ADD1 && state_ns == ADD1) || (state_cs != ADD2 && state_ns == ADD2))
		add_in_valid = 1;
	else
		add_in_valid = 0;
end

always @(*) begin
	if(state_ns == ADD1)begin
		add_Px = Px_reg;
		add_Py = Py_reg;
		add_Qx = Rx;
		add_Qy = Ry;
	end else if(state_ns == ADD2) begin
		add_Px = Px_reg;
		add_Py = Py_reg;
		add_Qx = Px_reg;
		add_Qy = Py_reg;
	end else begin
		add_Px = 0;
		add_Py = 0;
		add_Qx = 0;
		add_Qy = 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		state_cs <= IDLE;
	else
		state_cs <= state_ns;
end

always @(*) begin
	case(state_cs)
		IDLE:	state_ns = (in_valid) ? RD:IDLE;
		RD:		state_ns = IDLE2;
		IDLE2:	begin
			if(done_add)
				state_ns = IDLE4;
			else if(add_Mult)
				state_ns = ADD1;
			else
				state_ns = ADD2;
		end
		ADD1:	state_ns = (add_out_valid) ? IDLE3 : ADD1;
		IDLE3:	state_ns = ADD2;
		ADD2:	state_ns = (add_out_valid) ? IDLE2 : ADD2;
		IDLE4:	state_ns = DONE;
		DONE:	state_ns = IDLE;
		// default:state_ns = IDLE;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt <= 0;
	else if(state_ns == IDLE)
		cnt <= 0;
	else if(state_cs == ADD2 && state_ns == IDLE2)
		cnt <= cnt+1;
end

// register
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		Px_reg <= 0;
		Py_reg <= 0;
		k_reg <= 0;
	end else if(state_ns == IDLE) begin
		Px_reg <= 0;
		Py_reg <= 0;
		k_reg <= 0;
	end else if(state_cs == ADD2 && add_out_valid) begin
		Px_reg <= add_Rx;
		Py_reg <= add_Ry;
	end else if(state_ns == RD) begin
		Px_reg <= Px;
		Py_reg <= Py;
		k_reg <= k;
	end
end

// output
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out_valid <= 0;
		Rx <= 0;
		Ry <= 0;
	end else if(state_ns == IDLE) begin
		out_valid <= 0;
		Rx <= 0;
		Ry <= 0;
	end else if(state_cs == ADD1 && add_out_valid) begin
		Rx <= add_Rx;
		Ry <= add_Ry;
	end else if(state_ns == DONE) begin
		out_valid <= 1;		
	end
end

endmodule