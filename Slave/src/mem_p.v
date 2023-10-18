/*
Interface:
axi_*_i -> Inputs from AXI
axi_*_o -> Outputs  to AXI

p_*_i -> Inputs from Peripheral
p_*_o -> Outputs  to Peripheral

*/


module mem_p(
    input         clk_i,

    input  [31:0] axi_w_addr_i,
    input  [31:0] axi_w_data_i,

    input  [31:0] axi_r_addr_i,
    
    input  [31:0] p_addr_i,
    input  [31:0] p_w_data_i,
    input  [ 1:0] p_op_i,

    output [31:0] axi_r_data_o,
    
    output [31:0] p_r_data_o
);

reg [31:0] memory [4095:0];         // 4K x 4B -> 16KB

always @(posedge clk_i) begin
     // AXI Write Operation
    memory[axi_w_addr_i[11:0]] <= axi_w_data_i;

    if(p_op_i == 2'b10)             // Peripheral Write Operation
        memory[p_addr_i] <= p_w_data_i;
end

// AXI Read Operation
assign axi_r_data_o = memory[axi_r_addr_i[11:0]];
assign p_r_data_o = (p_op_i == 2'b01) ? memory[p_addr_i]  : 'bz;

endmodule
