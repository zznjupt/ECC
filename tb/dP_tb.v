module dP_tb();

wire clk;
wire rst_n;
wire [255:0]Px;
wire [255:0]Py;
wire [255:0]k;
wire [255:0]Rx;
wire [255:0]Ry;
wire in_valid;
wire out_valid;

dotProduct #(256)
U_dotProduct (
	.clk        (clk),
	.rst_n      (rst_n),
	.Px         (Px),
	.Py         (Py),
	.k          (k),
	.Rx         (Rx),
	.Ry         (Ry),
	.in_valid   (in_valid),
	.out_valid  (out_valid)
);


dP_dut #(256) 
U_dut (
	.clk        (clk),
	.rst_n      (rst_n),
	.Px         (Px),
	.Py         (Py),
	.k          (k),
	.Rx         (Rx),
	.Ry         (Ry),
	.in_valid   (in_valid),
	.out_valid  (out_valid)
);


 initial begin
 	$fsdbDumpfile("dotProduct.fsdb");
 	// $fsdbDumpvars(0,"+mda");
 	$fsdbDumpvars();
 end

endmodule