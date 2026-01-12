`timescale 1ns / 1ps

module tb_VSCPU;
    parameter SIZE = 14;
    parameter DEPTH = 16384; // 2^14

    reg clk;
    reg rst;
    wire wrEn;
    wire [SIZE-1:0] addr_toRAM;
    wire [31:0] data_toRAM;
    wire [31:0] data_fromRAM;

    // Instantiate the CPU
    VSCPU uut (
        .clk(clk),
        .rst(rst),
        .data_fromRAM(data_fromRAM),
        .wrEn(wrEn),
        .addr_toRAM(addr_toRAM),
        .data_toRAM(data_toRAM)
    );

    // Instantiate the RAM
    blram #(SIZE, DEPTH) memory (
        .clk(clk),
        .rst(rst),
        .we(wrEn),
        .addr(addr_toRAM),
        .din(data_toRAM),
        .dout(data_fromRAM)
    );

    // Clock Generation
    initial begin
        clk = 1;
        forever #5 clk = ~clk; // 10ns period
    end

    // Test Sequence
    initial begin
        // 1. Reset
        rst = 1;
        #15;
        rst = 0;

        // 2. Run Simulation
        // We need enough time to reach PC = 55. 
        // 60 instructions * 10ns * 4 cycles/instr = ~2400ns. 
        // Let's run for 5000ns to be safe.
        #5000;
        
        $finish;
    end

    // -----------------------------------------------------------------------
    // PRE-LOADING MEMORY (The exact Program from Page 2 of PDF)
    // -----------------------------------------------------------------------
    initial begin
        // Format: {Opcode(3), Imm(1), A(14), B(14)}
        
        // --- INSTRUCTIONS ---
        // 0: CPi 110 3
        memory.mem[0] = {3'b100, 1'b1, 14'd110, 14'd3}; 
        // 1: ADD 100 101
        memory.mem[1] = {3'b000, 1'b0, 14'd100, 14'd101};
        // 2: MUL 100 102
        memory.mem[2] = {3'b101, 1'b0, 14'd100, 14'd102};
        // 3: SRLi 102 1
        memory.mem[3] = {3'b010, 1'b1, 14'd102, 14'd1};
        // 4: CP 104 100
        memory.mem[4] = {3'b100, 1'b0, 14'd104, 14'd100};
        // 5: ADDi 104 5
        memory.mem[5] = {3'b000, 1'b1, 14'd104, 14'd5};
        // 6: NAND 104 108
        memory.mem[6] = {3'b001, 1'b0, 14'd104, 14'd108};
        // 7: NANDi 104 5
        memory.mem[7] = {3'b001, 1'b1, 14'd104, 14'd5};
        // 8: SRL 108 102
        memory.mem[8] = {3'b010, 1'b0, 14'd108, 14'd102};
        // 9: MULi 108 3
        memory.mem[9] = {3'b101, 1'b1, 14'd108, 14'd3};
        // 10: ADD 110 103
        memory.mem[10] = {3'b000, 1'b0, 14'd110, 14'd103};
        // 11: CP 112 110
        memory.mem[11] = {3'b100, 1'b0, 14'd112, 14'd110};
        // 12: LT 112 111
        memory.mem[12] = {3'b011, 1'b0, 14'd112, 14'd111};
        // 13: BZJ 111 112 (Jump to Mem[112] if Mem[111]==0)
        memory.mem[13] = {3'b110, 1'b0, 14'd112, 14'd111}; // A=112 (Target), B=111 (Cond)
        // 14: BZJi 101 11 (Jump to PC+11 if Mem[101]==0)
        memory.mem[14] = {3'b110, 1'b1, 14'd101, 14'd11}; // A=Unused, B=101 (Cond)
        
        // ... Gap in instructions ...

        // 19: MULi 101 3
        memory.mem[19] = {3'b101, 1'b1, 14'd101, 14'd3};
        // 20: CP 105 102
        memory.mem[20] = {3'b100, 1'b0, 14'd105, 14'd102};
        // 21: LTi 105 2
        memory.mem[21] = {3'b011, 1'b1, 14'd105, 14'd2};
        // 22: BZJ 113 105 (Jump to Mem[105] if Mem[113]==0)
        memory.mem[22] = {3'b110, 1'b0, 14'd105, 14'd113}; // Note: BZJ A, B -> B is Cond
        
        // ... Gap ...

        // 35: BZJi 111 53 (Jump to PC+53 if Mem[111]==0)
        memory.mem[35] = {3'b110, 1'b1, 14'd111, 14'd53};

        // ... Gap ...

        // 54: CPIi 114 111 (Mem[Mem[114]] = 111) ... Wait, CPIi A B -> Mem[Mem[A]] = Imm(B)
        // Check PDF Opcode for CPIi: A is pointer, B is Imm. 
        // PDF: "CPIi 114 111". A=114, Imm=111.
        memory.mem[54] = {3'b111, 1'b1, 14'd114, 14'd111};
        
        // 55: CPI 121 102 (Mem[Mem[121]] = Mem[102])
        memory.mem[55] = {3'b111, 1'b0, 14'd121, 14'd102};

        // --- DATA SECTION (Initial Values from Page 2) ---
        memory.mem[100] = 32'd5;
        memory.mem[101] = 32'd8;
        memory.mem[102] = 32'd16;
        memory.mem[103] = 32'hFFFFFFFF; // 4294967295 (-1)
        memory.mem[108] = 32'd65543;
        memory.mem[111] = 32'd1;
        memory.mem[113] = 32'd35;
        memory.mem[114] = 32'd120;
    end

endmodule

// ----------------------------------------------------------------
// MEMORY MODULE (BRAM) - Include here to be safe
// ----------------------------------------------------------------
module blram(clk, rst, we, addr, din, dout);
    parameter SIZE = 14, DEPTH = 2**SIZE;
    input clk;
    input rst;
    input we;
    input [SIZE-1:0] addr;
    input [31:0] din;
    output reg [31:0] dout;
    
    reg [31:0] mem [DEPTH-1:0];

    always @(posedge clk) begin
        if (we)
            mem[addr] <= din;
        
        dout <= mem[addr];
    end
endmodule