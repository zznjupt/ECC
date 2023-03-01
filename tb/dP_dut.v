`timescale 1ns/10ps
`define CYCLE_TIME 10
`define End_CYCLE  100000000

module dP_dut # (
    parameter DATA_WIDTH = 256
) (
    output reg                      clk,
    output reg                      rst_n,
    output reg  [DATA_WIDTH-1:0]    Px,
    output reg  [DATA_WIDTH-1:0]    Py,
    output reg  [DATA_WIDTH-1:0]    k,
    input  wire [DATA_WIDTH-1:0]    Rx,
    input  wire [DATA_WIDTH-1:0]    Ry,
    output reg                      in_valid,
    input  wire                     out_valid
);

integer     patcount;
parameter   PATNUM = 1;

integer     golden_read;
integer     i, j, a, gap;

integer     counter;
integer     curr_cycle, cycles, total_cycles;

reg [DATA_WIDTH-1:0] Px_reg;
reg [DATA_WIDTH-1:0] Py_reg;
reg [DATA_WIDTH-1:0] k_reg;
reg [DATA_WIDTH-1:0] Rx_reg;
reg [DATA_WIDTH-1:0] Ry_reg;


reg [31:0] clock;

// clock
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		clock <= 0;
	else
		clock <= clock+1;
end

initial  begin
 #`End_CYCLE ;
 	$display("-----------------------------------------------------\n");
 	$display("Error!!! Somethings' wrong with your code ...!\n");
 	$display("-------------------------FAIL------------------------\n");
 	$display("-----------------------------------------------------\n");
 	$finish;
end

initial begin
	// read file
	golden_read = $fopen("C:\\Users\\ZZ\\Desktop\\project_2\\dP.txt", "r");
	
	// initial signal
	in_valid = 0;
	
	Px = 'bx;
	Py = 'bx;
	k = 'bx;
	// reset task
	reset_task;

	for(patcount = 0; patcount < PATNUM; patcount = patcount+1) begin
		load_input;
		//if(1)begin
		input_task;
		check_answer;
		@(negedge clk);
		//end
	end	
	$display("Pass\n");
	$finish;
end

task reset_task ;  begin
	#(20); rst_n = 0;
	#(20);
	if(0)begin
		reset_fail;
	end
	#(20);rst_n = 1;
	#(6); release clk;
end endtask

task reset_fail ; begin
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$display ("                                                  Oops! Reset is Wrong                						             ");
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;
end endtask

task load_input; begin
	a = $fscanf(golden_read, "%h\n", Px_reg );
	a = $fscanf(golden_read, "%h\n", Py_reg );
	a = $fscanf(golden_read, "%h\n", k_reg );
	a = $fscanf(golden_read, "%h\n", Rx_reg );
	a = $fscanf(golden_read, "%h\n", Ry_reg );
end endtask

task input_task;begin
	@(negedge clk);
	in_valid = 1;
	Px = Px_reg;
	Py = Py_reg;
	k  = k_reg;


	@(negedge clk);
	in_valid = 0;
	Px = 'bx;
	Py = 'bx;
	k = 'bx;

end endtask

task check_answer;begin
	// wait out_valid raise
	while(out_valid==0) begin
		@(negedge clk);
	end
	
	// check answer
	if(Rx!==Rx_reg || Ry!==Ry_reg)begin
		$display ("----------------------------------------------------------------------");
		$display ("  FAIL %2d\n                						                     ",patcount);
		$display ("  Oops! Your Answer is Wrong                						     ");
		$display ("  [Correct Rx]     %h\n                 					             ",Rx_reg);
		$display ("  [Your Answer Rx] %h\n                 						         ",Rx);
		$display ("  [Correct Ry]     %h\n                 					             ",Ry_reg);
		$display ("  [Your Answer Ry] %h\n                 						         ",Ry);
		$display ("--------------------------------------------------------------------- ");
		$finish;
	end
	else begin
		$display("\033[1;32mPass \033[1;0mNo. %2d\n",patcount);
		$display ("  [Your Answer Rx] %h\n                 						         ",Rx);
		$display ("  [Your Answer Ry] %h\n                 						         ",Ry);
		$display ("----------------------------------------------------------------------");
	end
end endtask



endmodule