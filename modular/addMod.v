/*
 * @brief return (opA + opB) mod opM
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
module addMod # (
    parameter DATA_WIDTH = 256
) (
    input  wire                     clk,

    input  wire [DATA_WIDTH-1:0]    opA,
    input  wire [DATA_WIDTH-1:0]    opB,
    input  wire [DATA_WIDTH-1:0]    opM,
    
    output wire [DATA_WIDTH-1:0]    out_data
);

wire [DATA_WIDTH-1+1:0] out_data_reg;
assign out_data_reg = opA + opB;
assign out_data     = (out_data_reg >= opM) ? out_data_reg - opM : out_data_reg;

endmodule