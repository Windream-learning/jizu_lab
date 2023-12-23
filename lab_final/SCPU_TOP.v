module SCPU_TOP(
    input clk,
    input rstn,
    input [15:0]sw_i,
    output [7:0]disp_seg_o,
    output [7:0]disp_an_o
    );

    reg [31:0]clkdiv;
    wire Clk_CPU;
    wire Clk_display;


    // Clk_CPU初始�?
    always @(posedge clk or negedge rstn) begin
            if(!rstn) clkdiv <= 0;
                else clkdiv <= clkdiv + 1'b1;
    end

    assign Clk_display = (sw_i[15]) ? clkdiv[27] : clkdiv[25];
    assign Clk_CPU = (sw_i[1]) ? 1'b0 : Clk_display;


    // rom显示模块
    wire [31:0]instr;

`define NPCOp_normol 3'b000
`define NPCOp_beq 3'b001

    reg [5:0]rom_addr;
    always @(posedge Clk_CPU or negedge rstn) begin
        if(!rstn) rom_addr = 6'b000000;
        else if(sw_i[14] == 1'b1)
            if (rom_addr == 6'b111111) rom_addr = 6'b000000;
            else 
                case(NPCOp)
                    `NPCOp_normol: rom_addr = rom_addr + 1'b1;
                    `NPCOp_beq: rom_addr = rom_addr + (immout >> 2);
                endcase
        else rom_addr = rom_addr;    
    end
    

    // reg显示模块
    reg [31:0]reg_data;
    reg [4:0]reg_addr;
    
    always @(posedge Clk_display or negedge rstn) begin
        if(!rstn) reg_addr = 5'b00000;
        else if(sw_i[13] == 1'b1) begin
                if(reg_addr == 5'b11111) reg_addr = 5'b00000;
                else reg_addr = reg_addr + 1'b1;
                reg_data = U_RF.rf[reg_addr];
        end
        else reg_data = reg_data;
    end


    // alu显示模块
    reg [2:0]alu_addr;
    reg [31:0]alu_disp_data;

    always @(posedge Clk_display or negedge rstn)
        if(!rstn) alu_addr = 3'b000;
        else if(sw_i[12] == 1'b1) begin
            alu_addr = alu_addr + 1'b1;
            case(alu_addr)
                3'b001: alu_disp_data = U_alu.A;
                3'b010: alu_disp_data = U_alu.B;
                3'b011: alu_disp_data = U_alu.C;
                3'b100: alu_disp_data = U_alu.Zero;
                default: alu_disp_data = 32'hFFFFFFFF;
            endcase
        end
        else alu_disp_data = alu_disp_data;


    // dm显示模块
    reg [31:0]dmem_data;
    parameter DM_DATA_NUM = 7;
    reg [5:0]dmem_addr;

    always @(posedge Clk_display or negedge rstn)
        if(!rstn) dmem_addr = 6'd0;
        else if(sw_i[11] == 1'b1) begin
            if(dmem_addr == DM_DATA_NUM) begin
                dmem_addr = 6'd0;
                dmem_data = 32'hFFFFFFFF;
            end
            else begin
                dmem_data = U_DM.dmem[dmem_addr][7:0];
                dmem_addr = dmem_addr + 1'b1;
            end
        end
        else dmem_data = dmem_data;


    // 传入�?发板的显示模�
    reg [31:0]display_data;
    
    always @(sw_i) begin
        if(sw_i[0] == 0) begin
            case(sw_i[14:11])
                4'b1000 : display_data = instr;
                4'b0100 : display_data = reg_data;
                4'b0010 : display_data = alu_disp_data;
                4'b0001 : display_data = dmem_data;
                default : display_data = instr;
            endcase
        end
            else display_data = instr;
    end


    // 声明部分
    wire [31:0]inst_in;
    wire [6:0]Op;
    wire [6:0]Funct7;
    wire [2:0]Funct3;
    wire RegWrite;
    wire MemWrite;
    wire [2:0]EXTOp;
    wire [4:0]ALUOp;
    wire ALUSrc;
    wire [2:0]DMType;
    wire [1:0]WDSel;
    wire [4:0]rs1;
    wire [4:0]rs2;
    wire [4:0]rd;
    reg [31:0]WD;
    wire [31:0]RD1;
    wire [31:0]RD2;
    wire [31:0]aluout;
    wire Zero;
    wire [31:0]dout;
    wire [4:0]iimm_shamt;
    wire [11:0]iimm;
    wire [11:0]simm;
    wire [11:0]bimm;
    // wire [19:0]uimm;
    // wire [19:0]jimm;
    wire [31:0]immout;

    
    // 传入control部分
    // Decode
    assign inst_in = instr;

    assign Op = inst_in[6:0];  // op
    assign Funct7 = inst_in[31:25]; // funct7
    assign Funct3 = inst_in[14:12]; // funct3
    assign rs1 = inst_in[19:15];  // rs1
    assign rs2 = inst_in[24:20];  // rs2
    assign rd = inst_in[11:7];  // rd
    assign iimm_shamt = inst_in[24:20]; // slli指令立即�?
    assign iimm = inst_in[31:20]; // addi 指令立即数，lw指令立即�?
    assign simm = {inst_in[31:25], inst_in[11:7]}; // sw指令立即�?
    assign bimm = {inst_in[31], inst_in[7], inst_in[30:25], inst_in[11:8]}; // beq指令立即�?
    // assign uimm = inst_in[31:12]; // lui指令立即�?
    // assign jimm = {inst_in[31], inst_in[19:12], inst_in[20], inst_in[30:21]}; // jal指令立即�?
    

    // alu mux
    wire [31:0]B;
    assign B = (ALUSrc) ? immout : RD2;


    // wd mux
`define WDSel_FromALU 2'b00
`define WDSel_FromMEM 2'b01

    always @*
    begin
        case(WDSel)
            `WDSel_FromALU: WD<=aluout;
            `WDSel_FromMEM: WD<=dout;
            //`WDSel_FromPC: WD<=PC_out+4;
        endcase
    end

    // 例化部分
    dist_mem_im U_IM(
        .a(rom_addr),
        .spo(instr)
    );
    
    RF U_RF(
        .RFWr(RegWrite),
        .sw_i(sw_i),
        .A1(rs1),
        .A2(rs2),
        .A3(rd),
        .WD(WD),
        .RD1(RD1),
        .RD2(RD2)
    );
    
    alu U_alu(
        .A(RD1),
        .B(B),
        .ALUOp(ALUOp),
        .C(aluout),
        .Zero(Zero)
    );

    dm U_DM(
        .clk(Clk_CPU),
        .DMWr(MemWrite),
        .addr(aluout[5:0]),
        .din(RD2),
        .DMType(DMType),
        .dout(dout)
    );

    EXT U_EXT(
        .iimm_shamt(iimm_shamt),
        .iimm(iimm),
        .simm(simm),
        .bimm(bimm),
        // .uimm(uimm),
        // .jimm(jimm),
        .EXTOp(EXTOp),
        .immout(immout)
    );

    ctrl U_CTRL(
        .Op(Op),
        .Funct3(Funct3),
        .Funct7(Funct7),
        .Zero(Zero),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .EXTOp(EXTOp),
        .ALUOp(ALUOp),
        .NPCOp(NPCOp),
        .ALUSrc(ALUSrc),
        .DMType(DMType),
        .WDSel(WDSel)
    );
    
    seg7x16 u_seg7x16(
        .clk(clk),
        .rstn(rstn),
        .i_data(display_data),
        .disp_mode(sw_i[0]),
        .o_seg(disp_seg_o),
        .o_sel(disp_an_o)
        );
endmodule