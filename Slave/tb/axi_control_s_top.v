module axi_control_s_top (
    input clk_i,
    input rst_i,
    
    // Input from Master to Slave
    input           axi_awvalid_i,
    input [31:0]    axi_awaddr_i,
    input 		    axi_wvalid_i,
    input [31:0]    axi_wdata_i,
    input [3:0]     axi_wstrb_i,
    input           axi_bready_i,
    input           axi_arvalid_i,
    input [31:0]    axi_araddr_i,
    input           axi_rready_i,
    

    // Output from Slave to Master
    output            axi_awready_o,
    output            axi_wready_o,
    output            axi_bvalid_o,
    output [1:0]      axi_bresp_o,
    output            axi_arready_o,
    output            axi_rvalid_o,
    output [31:0]     axi_rdata_o,
    output [1:0]      axi_rresp_o
);

wire [31:0] mem_rdata_w;
wire [31:0] mem_raddr_w;
wire [31:0] mem_waddr_w;
wire [31:0] mem_wdata_w;

axi_control_s SLAVE(
    // Inputs
    .clk_i(clk_i),
    .rst_i(clk_i),
    // From MEMORY
    .mem_rdata_i(mem_rdata_w),
    // To AXI SLAVE Controller
    .axi_awvalid_i(axi_awvalid_i),
    .axi_awaddr_i(axi_awaddr_i),
    .axi_wvalid_i(axi_wvalid_i),
    .axi_wdata_i(axi_wdata_i),
    .axi_wstrb_i(axi_wstrb_i),
    .axi_bready_i(axi_bready_i),
    .axi_arvalid_i(axi_arvalid_i),
    .axi_araddr_i(axi_araddr_i),
    .axi_rready_i(axi_rready_i),

    // To AXI Master
    .axi_awready_o(axi_awready_o),
    .axi_wready_o(axi_wready_o),
    .axi_bvalid_o(axi_bvalid_o),
    .axi_bresp_o(axi_bresp_o),
    .axi_arready_o(axi_arready_o),
    .axi_rvalid_o(axi_rvalid_o),
    .axi_rdata_o(axi_rdata_o),
    .axi_rresp_o(axi_rresp_o),
    // To MEMORY
    .mem_waddr_o(mem_waddr_w),
    .mem_raddr_o(mem_raddr_w),
    .mem_wdata_o(mem_wdata_w)
);

mem_p MEMORY(
    // Inputs
    .clk_i(clk_i),
    // From AXI CONTROLLER
    .axi_w_addr_i(mem_waddr_w),
    .axi_w_data_i(mem_wdata_w),

    .axi_r_addr_i(mem_raddr_w),
    
    // From PERIPHERAL
    .p_addr_i(),
    .p_w_data_i(),
    .p_op_i(),

    // Outputs
    // To AXI CONTROLLER
    .axi_r_data_o(mem_rdata_w),
    // To PERIPHERAL
    .p_r_data_o()
);


    
endmodule