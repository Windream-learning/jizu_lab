module SCPU_TOP(
    input clk,
    input rstn,
    input [15:0]sw_i,
    output [7:0]disp_seg_o,
    output [7:0]disp_an_o
    );

    reg [31:0]clkdiv;
    wire Clk_CPU;

    // Clk_CPU初始化
    always @(posedge clk or negedge rstn) begin
            if(!rstn) clkdiv <= 0;
                else clkdiv <= clkdiv + 1'b1;
    end

    assign Clk_CPU = (sw_i[15]) ? clkdiv[27] : clkdiv[25];

    // 矩形变换与贪吃蛇编码模块
    reg [63:0]display_data;

    reg [5:0]led_data_addr;
    reg [63:0]led_disp_data;
    parameter LED_DATA_NUM0 = 19;
    parameter LED_DATA_NUM1 = 48;

    reg [63:0]LED_DATA0[18:0];
    reg [63:0]LED_DATA1[47:0];
    initial begin
        LED_DATA0[0] = 64'hC6F6F6F0C6F6F6F0;
        LED_DATA0[1] = 64'hF9F6F6CFF9F6F6CF;
        LED_DATA0[2] = 64'hFFC6F0FFFFC6F0FF;
        LED_DATA0[3] = 64'hFFC0FFFFFFC0FFFF;
        LED_DATA0[4] = 64'hFFA3FFFFFFA3FFFF;
        LED_DATA0[5] = 64'hFFFFA3FFFFFFA3FF;
        LED_DATA0[6] = 64'hFFFF9CFFFFFF9CFF;
        LED_DATA0[7] = 64'hFF9EBCFFFF9EBCFF;
        LED_DATA0[8] = 64'hFF9CFFFFFF9CFFFF;
        LED_DATA0[9] = 64'hFFC0FFFFFFC0FFFF;
        LED_DATA0[10] = 64'hFFA3FFFFFFA3FFFF;
        LED_DATA0[11] = 64'hFFA7B3FFFFA7B3FF;
        LED_DATA0[12] = 64'hFFC6F0FFFFC6F0FF;
        LED_DATA0[13] = 64'hF9F6F6CFF9F6F6CF;
        LED_DATA0[14] = 64'h9EBEBEBC9EBEBEBC;
        LED_DATA0[15] = 64'h2737373327373733;
        LED_DATA0[16] = 64'h505454EC505454EC;
        LED_DATA0[17] = 64'h744454F8744454F8;
        LED_DATA0[18] = 64'h0062080000620800;

        LED_DATA1[0] = 64'hFFFFFFFEFEFEFEFE;
        LED_DATA1[1] = 64'hFFFEFEFEFEFEFFFF;
        LED_DATA1[2] = 64'hDEFEFEFEFFFFFFFF;
        LED_DATA1[3] = 64'hCEFEFEFFFFFFFFFF;
        LED_DATA1[4] = 64'h42FFFFFFFFFFFFFF;
        LED_DATA1[5] = 64'h41FEFFFFFFFFFFFF;
        LED_DATA1[6] = 64'hF1FCFFFFFFFFFFFF;
        LED_DATA1[7] = 64'hFDF8F7FFFFFFFFFF;
        LED_DATA1[8] = 64'hFFF8F3FFFFFFFFFF;
        LED_DATA1[9] = 64'hFFFBF1FEFFFFFFFF;
        LED_DATA1[10] = 64'hFFFFF9F1FFFFFFFF;
        LED_DATA1[11] = 64'hFFFFFDF8F7FFFFFF;
        LED_DATA1[12] = 64'hFFFFFFF9F1FFFFFF;
        LED_DATA1[13] = 64'hFFFFFFFFF1FCFFFF;
        LED_DATA1[14] = 64'hFFFFFFFFF9F8FFFF;
        LED_DATA1[15] = 64'hFFFFFFFFFFF8F3FF;
        LED_DATA1[16] = 64'hFFFFFFFFFFFBF1FE;
        LED_DATA1[17] = 64'hFFFFFFFFFFFFF9BC;
        LED_DATA1[18] = 64'hFFFFFFFFFFFFBDBC;
        LED_DATA1[19] = 64'hFFFFFFFFBFBFBFBD;
        LED_DATA1[20] = 64'hFFFFBFBFBFBFBFFF;
        LED_DATA1[21] = 64'hFFBFBFBFBFBFFFFF;
        LED_DATA1[22] = 64'hAFBFBFBFFFFFFFFF;
        LED_DATA1[23] = 64'hA7B7FFFFFFFFFFFF;
        LED_DATA1[24] = 64'hA7F7F7FFFFFFFFFF;
        LED_DATA1[25] = 64'hF7F7F7F7F7FFFFFF;
        LED_DATA1[26] = 64'hFFFFF7F7F7F7F7FF;
        LED_DATA1[27] = 64'hFFFFFFF7F7F7F7F7;
        LED_DATA1[28] = 64'hFFFFFFFFFFF7F7F1;
        LED_DATA1[29] = 64'hFFFFFFFFFFFFF7F0;
        LED_DATA1[30] = 64'hFFFFFFFFFFFFFF88;
        LED_DATA1[31] = 64'hFFFFFFFFFFFFE7CE;
        LED_DATA1[32] = 64'hFFFFFFFFFFFFC7CF;
        LED_DATA1[33] = 64'hFFFFFFFFFFEEC7FF;
        LED_DATA1[34] = 64'hFFFFFFFFF7CEDFFF;
        LED_DATA1[35] = 64'hFFFFFFFFC7CFFFFF;
        LED_DATA1[36] = 64'hFFFFFFFEC7EFFFFF;
        LED_DATA1[37] = 64'hFFFFFFCECFFFFFFF;
        LED_DATA1[38] = 64'hFFFFE7E6FFFFFFFF;
        LED_DATA1[39] = 64'hFFFFEFCFFFFFFFFF;
        LED_DATA1[40] = 64'hFFEEC7FFFFFFFFFF;
        LED_DATA1[41] = 64'hF7CEDFFFFFFFFFFF;
        LED_DATA1[42] = 64'hA7AFFFFFFFFFFFFF;
        LED_DATA1[43] = 64'hAFBFBFBFFFFFFFFF;
        LED_DATA1[44] = 64'hBFBFBFBFBFFFFFFF;
        LED_DATA1[45] = 64'hFFFFBFBFBFBFBFFF;
        LED_DATA1[46] = 64'hFFFFBFBFBFBFBFFF;
        LED_DATA1[47] = 64'hFFFFFFFFBFBFBFBD;
    end

    // 矩形变换与贪吃蛇显示模块
    always @(posedge Clk_CPU or negedge rstn) begin
        if(!rstn) begin
            led_data_addr = 6'd0;
            led_disp_data = 64'b1;
        end
            else if(sw_i[0] == 1'b1) begin
                    if(sw_i[2] == 1'b0) begin
                        if(led_data_addr == LED_DATA_NUM0) begin
                            led_data_addr = 6'd0;
                            led_disp_data = 64'b1;
                        end
                        led_disp_data = LED_DATA0[led_data_addr];
                    end
                    else begin
                        if(led_data_addr == LED_DATA_NUM1) begin
                            led_data_addr = 6'd0;
                            led_disp_data = 64'b1;
                        end
                        led_disp_data = LED_DATA1[led_data_addr];
                    end
                    led_data_addr = led_data_addr + 1'b1;
            end
                else led_data_addr = led_data_addr;
    end

    // rom显示模块
    wire [31:0]instr;

    reg [5:0]rom_addr;
    always @(posedge Clk_CPU or negedge rstn) begin
        if(!rstn) rom_addr = 6'b000000;
        else if(sw_i[14] == 1'b1)
            if (rom_addr == 6'b111111) rom_addr = 6'b000000;
            else rom_addr = rom_addr + 1'b1;
        else rom_addr = rom_addr;    
    end
    

    // reg显示模块
    reg [31:0]reg_data;
    reg [4:0]reg_addr;
    
    always @(posedge Clk_CPU or negedge rstn) begin
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

    always @(posedge Clk_CPU or negedge rstn)
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
    parameter DM_DATA_NUM = 16;
    reg [5:0]dmem_addr;

    always @(posedge Clk_CPU or negedge rstn)
        if(!rstn) dmem_addr = 6'd0;
        else if(sw_i[11] == 1'b1) begin
            dmem_addr = dmem_addr + 1'b1;
            dmem_data = U_DM.dmem[dmem_addr][7:0];
            if(dmem_addr == DM_DATA_NUM) begin
                dmem_addr = 6'd0;
                dmem_data = 32'hFFFFFFFF;
            end
        end
        else dmem_data = dmem_data;


    // 传入开发板的显示模块
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
            else display_data = led_disp_data;
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
    // wire [4:0]iimm_shamt;
    wire [11:0]iimm;
    wire [11:0]simm;
    // wire [11:0]bimm;
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
    // assign iimm_shamt = inst_in[24:20]; // slli指令立即数
    assign iimm = inst_in[31:20]; // addi 指令立即数，lw指令立即数
    assign simm = {inst_in[31:25], inst_in[11:7]}; // sw指令立即数
    // assign bimm = {inst_in[31], inst_in[7], inst_in[30:25], inst_in[11:8]}; // beq指令立即数
    // assign uimm = inst_in[31:12]; // lui指令立即数
    // assign jimm = {inst_in[31], inst_in[19:12], inst_in[20], inst_in[30:21]}; // jal指令立即数
    

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

    
    dist_mem_im U_IM(
        .a(rom_addr),
        .spo(instr)
    );
    
    RF U_RF(
        .clk(Clk_CPU),
        .rstn(rstn),
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
        .clk(Clk_CPU),
        .rstn(rstn),
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
        .clk(Clk_CPU),
        // .iimm_shamt(iimm_shamt),
        .iimm(iimm),
        .simm(simm),
        // .bimm(bimm),
        // .uimm(uimm),
        // .jimm(jimm),
        .EXTOp(EXTOp),
        .immout(immout)
    );

    ctrl U_CTRL(
        .Op(Op),
        .Funct3(Funct3),
        .Funct7(Funct7),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .EXTOp(EXTOp),
        .ALUOp(ALUOp),
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