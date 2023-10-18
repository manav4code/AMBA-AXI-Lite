module axi_control_s_top_tb;

// For Module Instantiation
parameter slaveAddress = 32'h00001000;

reg clk_i;
reg rst_i;

reg            axi_awvalid_tb_i;
reg [31:0]     axi_awaddr_tb_i;
reg            axi_wvalid_tb_i;
reg [31:0]     axi_wdata_tb_i;
reg [3:0]      axi_wstrb_tb_i;
reg            axi_bready_tb_i;
reg            axi_arvalid_tb_i;
reg [31:0]     axi_araddr_tb_i;
reg            axi_rready_tb_i;

wire             axi_awready_tb_o;
wire             axi_wready_tb_o;
wire             axi_bvalid_tb_o;
wire [1:0]       axi_bresp_tb_o;
wire             axi_arready_tb_o;
wire             axi_rvalid_tb_o;
wire [31:0]      axi_rdata_tb_o;
wire [1:0]       axi_rresp_tb_o;


wire write_complete_tb_w;

axi_control_s_top DUT (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .axi_awvalid_i(axi_awvalid_tb_i),
        .axi_awaddr_i(axi_awaddr_tb_i),
        .axi_wvalid_i(axi_wvalid_tb_i),
        .axi_wdata_i(axi_wdata_tb_i),
        .axi_wstrb_i(axi_wstrb_tb_i),
        .axi_bready_i(axi_bready_tb_i),
        .axi_arvalid_i(axi_arvalid_tb_i),
        .axi_araddr_i(axi_araddr_tb_i),
        .axi_rready_i(axi_rready_tb_i),
        .axi_awready_o(axi_awready_tb_o),
        .axi_wready_o(axi_wready_tb_o),
        .axi_bvalid_o(axi_bvalid_tb_o),
        .axi_bresp_o(axi_bresp_tb_o),
        .axi_arready_o(axi_arready_tb_o),
        .axi_rvalid_o(axi_rvalid_tb_o),
        .axi_rdata_o(axi_rdata_tb_o),
        .axi_rresp_o(axi_rresp_tb_o)
);

reg awvalid_inhibit_tb_q;
reg wvalid_inhibit_tb_q;
reg [11:0] mem_address;

initial begin

    $dumpfile("sim.vcd");
    $dumpvars(0, axi_control_s_top_tb);

    $monitor("Time: %t\nawready = %b\nwready = %b\nbvalid = %b\nbresp = %b\narready = %b\nrvalid = %b\nrdata = %h\nrresp = %b\n--------------------------------------------------------------- \nmem_rdata_w = %b\nmem_raddr_w = %b\nmem_waddr_w = %b\nmem_wdata_w = %b\n\n", $time, axi_awready_tb_o, axi_wready_tb_o, axi_bvalid_tb_o, axi_bresp_tb_o, axi_arready_tb_o, axi_rvalid_tb_o, axi_rdata_tb_o, axi_rresp_tb_o, DUT.mem_rdata_w, DUT.mem_raddr_w, DUT.mem_waddr_w, DUT.mem_wdata_w);

    clk_i = 0;

    rst_i = 1;
    #5 rst_i = 0;

    // Write Cycle
    // Write to an address followed by read to the same address
    @(posedge clk_i);
    $display("Write Transaction on Illegal Address:\nAsserting AWADDR and AWVALID");
    mem_address = 'b1010;
    axi_awaddr_tb_i = (slaveAddress | mem_address | {1'b1,{31{1'b0}}});
    axi_awvalid_tb_i = 1;

    // Placing Data on WRITE CHANNEL i.e. WDATA and Asserting WVALID.
    axi_wdata_tb_i = 'hFF;
    axi_wvalid_tb_i = 1;
    
    // Illegal Address
    @(posedge clk_i);
    $display("Write Transaction on Legal Address");
    axi_awaddr_tb_i = slaveAddress | mem_address;

    // Read Transaction
    @(posedge clk_i);
    // De-Asserting all the Write Channel Signals
    axi_awaddr_tb_i = 0;
    axi_awvalid_tb_i = 0;
    axi_wvalid_tb_i = 0;

    $display("Read Transaction on Address -> %b", (slaveAddress | mem_address));
    axi_araddr_tb_i = slaveAddress | mem_address;
    axi_arvalid_tb_i = 1;
    axi_rready_tb_i = 1;

    // Simultaneous Read-Write @ same location
    @(posedge clk_i);
    $display("Read-Write on same location, simultaneously");
    // Placing the Address on Read-Write Channels
    axi_araddr_tb_i = (slaveAddress | mem_address);
    axi_awaddr_tb_i = (slaveAddress | mem_address);
    // Asserting all the control signals
    axi_awvalid_tb_i = 1;
    axi_arvalid_tb_i = 1;

    // Placing Write Data, Data read must previous value.
    axi_wdata_tb_i = 'hAA;
    axi_wvalid_tb_i = 1;

    axi_rready_tb_i = 1;


    @(posedge clk_i);
    axi_rready_tb_i = 0;

    @(posedge clk_i);
    $finish(0);

end

always #5 clk_i = ~clk_i;



endmodule

/*
always@(posedge clk_i)begin
    if(write_complete_tb_w)begin
        if(axi_bresp_tb_o == 0) begin
            $display("Transaction Over for Write with response: %b", axi_bresp_tb_o);
            $display("Address @ %b -> Data: %b", axi_awaddr_tb_i, DUT.MEMORY.memory[0]);
            $finish(0); 
        end
    end
end


always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    awvalid_inhibit_tb_q <= 1'b0;  // On reset, set AWVALID
else if (axi_awvalid_tb_i && axi_awready_tb_o && axi_wvalid_tb_i && !axi_wready_tb_o)
    awvalid_inhibit_tb_q <= 1'b1;  // No write channel Handshake, inhibit AWVALID since no new valid Address can be placed on Write Address Channel.
else if (axi_wvalid_tb_i && axi_wready_tb_o)
    awvalid_inhibit_tb_q <= 1'b0;  // Successful write operation, set AWVALID

always @ (posedge clk_i or posedge rst_i)
if (rst_i)          // On reset, set WVALID
    wvalid_inhibit_tb_q <= 1'b0;
else if (axi_wvalid_tb_i && axi_wready_tb_o && axi_awvalid_tb_i && !axi_awready_tb_o)
    wvalid_inhibit_tb_q <= 1'b1;               // Inhibit if No Handshake
else if (axi_awvalid_tb_i && axi_awready_tb_o)    // Write Address Channel Handshake
    wvalid_inhibit_tb_q <= 1'b0;


always@(*)begin
    axi_awvalid_tb_i = !awvalid_inhibit_tb_q;
    axi_awaddr_tb_i = slaveAddress;
    axi_wvalid_tb_i = !wvalid_inhibit_tb_q;
    axi_wdata_tb_i = {16{2'b10}};
    axi_bready_tb_i = 1'b1;
end


assign write_complete_tb_w = (awvalid_inhibit_tb_q || axi_awready_tb_o) &&
                          (wvalid_inhibit_tb_q || axi_wready_tb_o);


endmodule
*/