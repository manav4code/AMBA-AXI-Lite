

// AXI4-LITE Slave Module -> Controller


module axi_control_s (
    input clk_i,
    input rst_i,
    
    // Input from Master to Slave
    input           axi_awvalid_i,
    input [31:0]    axi_awaddr_i,
    input 		    axi_wvalid_i,
    input [31:0]    axi_wdata_i,
    input [ 3:0]    axi_wstrb_i,
    input           axi_bready_i,
    input           axi_arvalid_i,
    input [31:0]    axi_araddr_i,
    input           axi_rready_i,
    // Input from Memory to Slave // Read Data
    input [31:0]    mem_rdata_i,

    // Output from Slave to Master
    output          axi_awready_o,
    output          axi_wready_o,
    output          axi_bvalid_o,
    output [ 1:0]   axi_bresp_o,
    output          axi_arready_o,
    output          axi_rvalid_o,
    output [31:0]   axi_rdata_o,
    output [ 1:0]   axi_rresp_o,
    // Output from Slave to Memory
    output [31:0] mem_waddr_o,
    output [31:0] mem_raddr_o,
    output [31:0] mem_wdata_o
);

// Control Registers
// FOR WRITE
reg axi_awready_inhibit_q;
reg axi_wready_inhibit_q;
reg axi_awaddr_inhibit_q;
// FOR READ
reg axi_arready_inhibit_q;
reg axi_araddr_inhibit_q;



////////////////////////////////////////////////////////////
parameter slaveAddress = 20'h00001;
/*
Address Space:
[0x0000 - 0xFFFF]: User Logic Memory Map. This is the memory space that can be accessed by user
*/



// WRITE TRANSACTIONS
always @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
        axi_awready_inhibit_q <= 1'b0;
    end
    else if(axi_awready_o && axi_awvalid_i && !axi_wvalid_i && axi_wready_o) begin
        axi_awready_inhibit_q <= 1'b1;      // Do not take any further valid address since valid data is not placed on Write Channel yet.
    end
    else if(axi_wvalid_i && axi_wready_o)begin
        axi_awready_inhibit_q <= 1'b0;      // Handshake on Write Channel. Can accept further valid address.
    end
end

always @(posedge clk_i or posedge rst_i) begin
    if(rst_i)begin
        axi_wready_inhibit_q <= 1'b0;
    end
    else if(axi_wready_o && axi_wvalid_i && axi_awready_o && !axi_awvalid_i) begin
        axi_wready_inhibit_q <= 1'b1;   // Valid Address not placed yet 
    end
    else if(axi_awvalid_i && axi_awready_o)begin
        axi_wready_inhibit_q <= 1'b0;       // Handshake on Write Address Channel.
    end
end

always @(axi_awaddr_i) begin
    if(axi_awaddr_i > {slaveAddress, 12'hFFF})begin
        axi_awaddr_inhibit_q = 1'b1;
    end
    else axi_awaddr_inhibit_q = 1'b0;
end

assign axi_awready_o = (!axi_awready_inhibit_q);
assign axi_wready_o = (!axi_wready_inhibit_q);

assign mem_waddr_o = (axi_awvalid_i && axi_awready_o && !axi_awaddr_inhibit_q) ? axi_awaddr_i : 'bz;
assign mem_wdata_o = (axi_wready_o && axi_wvalid_i && !axi_awaddr_inhibit_q) ? axi_wdata_i : 'bz;

assign axi_bvalid_o = (axi_wready_o && axi_wvalid_i);
assign axi_bresp_o = (axi_bvalid_o == 1'b0) ? 'bz :
                     ((axi_awaddr_inhibit_q) ? 2'b11 : 2'b00);


// READ TRANSACTIONS
always @(posedge clk_i or posedge rst_i) begin
    if(rst_i)begin
        axi_arready_inhibit_q <= 1'b0;
    end
    else if(axi_arready_o && axi_arvalid_i && !(axi_rvalid_o && axi_rready_i))begin
        axi_arready_inhibit_q <= 1'b1;      // Do not accept any valid address further since valid data is not yet placed on Read Channel.
    end
    else if(axi_rready_i && axi_rvalid_o)begin
        axi_arready_inhibit_q <= 1'b0;
    end
end

always @(axi_araddr_i) begin
    if(axi_araddr_i > {slaveAddress, 12'hFFF})begin
        axi_araddr_inhibit_q = 1'b1;
    end
    else axi_araddr_inhibit_q = 1'b0;
end


assign axi_arready_o = (!axi_arready_inhibit_q);
assign axi_rvalid_o = (axi_arvalid_i && axi_arready_o);
assign mem_raddr_o = (axi_arvalid_i && axi_arready_o && !axi_araddr_inhibit_q) ? axi_araddr_i : 'bz;
assign axi_rdata_o = (axi_rready_i == 1) ? mem_rdata_i : 'bz;

assign axi_rresp_o = axi_rready_i ? ((axi_araddr_inhibit_q) ? 2'b11 : 2'b00) : 2'bz;



endmodule
