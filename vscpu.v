module VSCPU (clk, rst, data_fromRAM, wrEn, addr_toRAM, data_toRAM);

input clk, rst;
input [31:0] data_fromRAM;
output reg wrEn;
output reg [13:0] addr_toRAM;
output reg [31:0] data_toRAM;

reg [2:0] st, stN;
reg [13:0] PC, PCN;
reg [31:0] IW, IWN;
reg [31:0] R1, R1N;

// Opcode Parameters
parameter OP_ADD_SUB = 3'b000; // ADD, ADDi, SUB, SUBi
parameter OP_NAND    = 3'b001;
parameter OP_SRL     = 3'b010;
parameter OP_LT      = 3'b011;
parameter OP_CP      = 3'b100;
parameter OP_MUL     = 3'b101;
parameter OP_BZJ     = 3'b110;
parameter OP_CPI     = 3'b111;

always @(posedge clk) begin
    st <= stN;
    PC <= PCN;
    IW <= IWN;
    R1 <= R1N;
end

always @ * begin
    // Default values to prevent latches
    stN = st;
    PCN = PC;
    IWN = IW;
    R1N = R1;
    wrEn = 1'b0;
    addr_toRAM = 14'h0;
    data_toRAM = 32'h0;

    if (rst) begin
        stN = 3'd0;
        PCN = 14'd0;
    end
    else begin
        case (st)
            // --------------------------------------------------------
            // S0: FETCH STATE
            // --------------------------------------------------------
            3'd0: begin
                addr_toRAM = PC;
                stN = 3'd1;
            end

            // --------------------------------------------------------
            // S1: DECODE & OPERAND FETCH
            // --------------------------------------------------------
            3'd1: begin
                IWN = data_fromRAM; // Latch Instruction Word

                case (data_fromRAM[31:29])
                    OP_ADD_SUB, OP_NAND, OP_SRL, OP_LT, OP_MUL, OP_CP, OP_CPI: begin
                        // If im=0 (bit 28 is 0), we need to read Operand B from memory address IW[13:0]
                        if (data_fromRAM[28] == 1'b0) begin
                            addr_toRAM = data_fromRAM[13:0]; // Read B
                            stN = 3'd2;
                        end
                        else begin
                            // If im=1 (Immediate)
                            // CPi (im=1) doesn't read memory.
                            if (data_fromRAM[31:29] == OP_CP) begin
                                stN = 3'd2;
                            end else begin
                                // For SUBi, ADDi, etc., we need to read A (destination) to modify it.
                                // For CPIi, we need to read A (pointer).
                                addr_toRAM = data_fromRAM[27:14]; // Read A
                                stN = 3'd2;
                            end
                        end
                    end
                    OP_BZJ: begin
                         // BZJ (im=0): Jump to A if Mem[B]==0. We need to read B.
                         addr_toRAM = data_fromRAM[13:0]; // Read B
                         stN = 3'd2;
                    end
                endcase
            end

            // --------------------------------------------------------
            // S2: EXECUTE / MEMORY ACCESS
            // --------------------------------------------------------
            3'd2: begin
                case (IW[31:29])
                    // --- ADD / ADDi / SUB / SUBi ---
                    OP_ADD_SUB: begin
                        // If bit 13 is 1, it is SUB/SUBi.
                        if (IW[13] == 1'b1) begin 
                            if (IW[28] == 1'b0) begin // SUB (Mem[A] = Mem[A] - Mem[B])
                                R1N = data_fromRAM; // Store Mem[B]
                                addr_toRAM = IW[27:14]; // Read Mem[A]
                                stN = 3'd3;
                            end else begin // SUBi (Mem[A] = Mem[A] - Imm)
                                wrEn = 1;
                                addr_toRAM = IW[27:14];
                                data_toRAM = data_fromRAM - (~IW[13:0]);
                                PCN = PC + 1;
                                stN = 3'd0;
                            end
                        end 
                        // If bit 13 is 0, it is ADD/ADDi.
                        else begin 
                            if (IW[28] == 1'b0) begin // ADD
                                R1N = data_fromRAM; // Store Mem[B]
                                addr_toRAM = IW[27:14]; // Read Mem[A]
                                stN = 3'd3;
                            end else begin // ADDi
                                wrEn = 1;
                                addr_toRAM = IW[27:14];
                                data_toRAM = data_fromRAM + IW[13:0]; 
                                PCN = PC + 1;
                                stN = 3'd0;
                            end
                        end
                    end

                    // --- NAND / NANDi ---
                    OP_NAND: begin
                         if (IW[28] == 0) begin // NAND
                             R1N = data_fromRAM;
                             addr_toRAM = IW[27:14];
                             stN = 3'd3;
                         end else begin // NANDi
                             wrEn = 1;
                             addr_toRAM = IW[27:14];
                             data_toRAM = ~(data_fromRAM & {18'b0, IW[13:0]});
                             PCN = PC + 1;
                             stN = 3'd0;
                         end
                    end

                    // --- SRL / SRLi ---
                    OP_SRL: begin
                         if (IW[28] == 0) begin // SRL
                             R1N = data_fromRAM;
                             addr_toRAM = IW[27:14];
                             stN = 3'd3;
                         end else begin // SRLi
                             wrEn = 1;
                             addr_toRAM = IW[27:14];
                             data_toRAM = data_fromRAM >> IW[13:0];
                             PCN = PC + 1;
                             stN = 3'd0;
                         end
                    end

                    // --- LT / LTi ---
                    OP_LT: begin
                         if (IW[28] == 0) begin // LT
                             R1N = data_fromRAM;
                             addr_toRAM = IW[27:14];
                             stN = 3'd3;
                         end else begin // LTi
                             wrEn = 1;
                             addr_toRAM = IW[27:14];
                             data_toRAM = (data_fromRAM < IW[13:0]) ? 1 : 0;
                             PCN = PC + 1;
                             stN = 3'd0;
                         end
                    end

                    // --- MUL / MULi ---
                    OP_MUL: begin
                         if (IW[28] == 0) begin // MUL
                             R1N = data_fromRAM;
                             addr_toRAM = IW[27:14];
                             stN = 3'd3;
                         end else begin // MULi
                             wrEn = 1;
                             addr_toRAM = IW[27:14];
                             data_toRAM = data_fromRAM * IW[13:0];
                             PCN = PC + 1;
                             stN = 3'd0;
                         end
                    end

                    // --- CP / CPi ---
                    OP_CP: begin
                         if (IW[28] == 0) begin // CP: Mem[A] = Mem[B]
                             wrEn = 1;
                             addr_toRAM = IW[27:14];
                             data_toRAM = data_fromRAM; 
                             PCN = PC + 1;
                             stN = 3'd0;
                         end else begin // CPi: Mem[A] = Imm
                             wrEn = 1;
                             addr_toRAM = IW[27:14];
                             data_toRAM = IW[13:0];
                             PCN = PC + 1;
                             stN = 3'd0;
                         end
                    end

                    // --- CPI / CPIi ---
                    OP_CPI: begin
                         if (IW[28] == 0) begin // CPI: Mem[Mem[A]] = Mem[B]
                             R1N = data_fromRAM; // Store Mem[B]
                             addr_toRAM = IW[27:14]; // Read Mem[A]
                             stN = 3'd3;
                         end else begin // CPIi: Mem[Mem[A]] = Imm
                             // data_fromRAM is Mem[A] (the pointer)
                             wrEn = 1;
                             addr_toRAM = data_fromRAM[13:0]; // Write to address found in Mem[A]
                             data_toRAM = IW[13:0];
                             PCN = PC + 1;
                             stN = 3'd0;
                         end
                    end

                    // --- BZJ / BZJi ---
                    OP_BZJ: begin
                        // data_fromRAM is Mem[B] (Condition)
                        if (data_fromRAM == 0) begin
                            if (IW[28] == 0) PCN = IW[27:14]; // BZJ: Jump to A
                            else PCN = PC + IW[13:0];       // BZJi: Jump to PC + Imm
                        end else begin
                            PCN = PC + 1;
                        end
                        stN = 3'd0;
                    end
                endcase
            end

            // --------------------------------------------------------
            // S3: WRITE BACK (For Reg-Reg Operations)
            // --------------------------------------------------------
            3'd3: begin
                wrEn = 1;
                // For CPI, the address is slightly different (Indirect)
                if (IW[31:29] == OP_CPI) begin
                     // data_fromRAM holds Mem[A] (Pointer)
                     addr_toRAM = data_fromRAM[13:0];
                     data_toRAM = R1; // R1 holds Mem[B]
                end
                else begin
                     addr_toRAM = IW[27:14]; // Standard destination A
                     case (IW[31:29])
                         OP_ADD_SUB: begin
                             // Check for SUB (bit 13=1)
                             if (IW[13]) data_toRAM = data_fromRAM - (~R1); // SUB
                             else        data_toRAM = data_fromRAM + R1; // ADD
                         end
                         OP_NAND: data_toRAM = ~(data_fromRAM & R1);
                         OP_SRL:  data_toRAM = data_fromRAM >> R1;
                         OP_LT:   data_toRAM = (data_fromRAM < R1) ? 1 : 0;
                         OP_MUL:  data_toRAM = data_fromRAM * R1;
                     endcase
                end
                PCN = PC + 1;
                stN = 3'd0;
            end
        endcase
    end
end
endmodule