module ctrl( 
    input [6:0]Op,  //opcode
    input [6:0]Funct7,  //funct7 
    input [2:0]Funct3,    // funct3 
    //input Zero,
    output RegWrite, // control signal for register write
    output MemWrite, // control signal for memory write
    output [2:0]EXTOp,    // control signal to signed extension
    output [4:0]ALUOp,    // ALU opertion
    //output [2:0] NPCOp,    // next pc operation
    output ALUSrc,   // ALU source for b
    output [2:0]DMType, //dm r/w type
    output [1:0]WDSel    // (register) write data selection  (MemtoReg)
    );

    //操作码（op funct7 funct3）确定具体操作指令类型 
    //R_type:
    wire rtype = ~Op[6] & Op[5] & Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; //0110011
    wire i_add = rtype&~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // add 0000000 000
    wire i_sub = rtype&~Funct7[6]&Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // sub 0100000 000
    wire i_sll = rtype&~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&Funct3[0]; // sub 0000000 001
    wire i_slt = rtype&~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&Funct3[1]&~Funct3[0]; // slt 0000000 010
    wire i_sltu = rtype&~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&Funct3[1]&Funct3[0]; // sltu 0000000 011
    wire i_xor = rtype&~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&Funct3[2]&~Funct3[1]&~Funct3[0]; // xor 0000000 100
    wire i_srl = rtype&~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&Funct3[2]&~Funct3[1]&Funct3[0]; // srl 0000000 101
    wire i_sra = rtype&~Funct7[6]&Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&Funct3[2]&~Funct3[1]&Funct3[0]; // sra 0100000 101
    wire i_or = rtype&~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&Funct3[2]&Funct3[1]&~Funct3[0]; // or 0000000 110
    wire i_and = rtype&~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&Funct3[2]&Funct3[1]&Funct3[0]; // and 0000000 111

    //i_l type  
    wire itype_l = ~Op[6] & ~Op[5] & ~Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; //0000011
    wire i_lb = itype_l & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; //lb 000
    wire i_lh = itype_l & ~Funct3[2] & ~Funct3[1] & Funct3[0];  //lh 001
    wire i_lw = itype_l & ~Funct3[2] & Funct3[1] & ~Funct3[0];  //lw 010
    wire i_lbu = itype_l & Funct3[2] & ~Funct3[1] & ~Funct3[0]; //lbu 100
    wire i_lhu = itype_l & Funct3[2] & ~Funct3[1] & Funct3[0]; //lhu 101
    
    // i_i type
    wire itype_r = ~Op[6] & ~Op[5] & Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; //0010011
    wire i_addi = itype_r & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // addi 000 func3
    wire i_slti = itype_r & ~Funct3[2] & Funct3[1] & ~Funct3[0]; // slti 010 func3
    wire i_sltiu = itype_r & ~Funct3[2] & Funct3[1] & Funct3[0]; // sltiu 011 func3
    wire i_xori = itype_r & Funct3[2] & ~Funct3[1] & ~Funct3[0]; // xori 100 func3
    wire i_ori = itype_r & Funct3[2] & Funct3[1] & ~Funct3[0]; // ori 110 func3
    wire i_andi = itype_r & Funct3[2] & Funct3[1] & Funct3[0]; // andi 111 func3
    // i_is type 有shamt字段的指令
    wire itype_rs = itype_r & ~Funct3[1] & Funct3[0]; // func3为001和101
    wire i_slli = itype_rs & ~Funct3[2]; // slli 001 func3
    wire i_srli_srai = itype_rs & Funct3[3]; // srli/srai 101 func3

    // s type
    wire stype = ~Op[6] & Op[5] & ~Op[4] & ~Op[3] & ~Op[2] & Op[1] & Op[0]; //0100011
    wire i_sw = stype & ~Funct3[2] & Funct3[1] & ~Funct3[0]; // sw 010
    wire i_sb = stype & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // sb 000
    wire i_sh = stype & ~Funct3[2] & ~Funct3[1] & Funct3[0]; // sh 001

    // sb type
    wire sbtype = Op[6] & Op[5] & ~Op[4] & ~Op[3] & Op[2] & Op[1] & Op[0]; //1100111
    wire i_beq = sbtype & ~Funct3[2] & ~Funct3[1] & ~Funct3[0]; // beq 000
    wire i_bne = sbtype & ~Funct3[2] & ~Funct3[1] & Funct3[0]; // bne 001
    wire i_blt = sbtype & Funct3[2] & ~Funct3[1] & ~Funct3[0]; // blt 100
    wire i_bge = sbtype & Funct3[2] & ~Funct3[1] & Funct3[0]; // bge 101
    wire i_bltu = sbtype & Funct3[2] & Funct3[1] & ~Funct3[0]; // bltu 110
    wire i_bgeu = sbtype & Funct3[2] & Funct3[1] & Funct3[0]; // bgeu 111

    //操作指令生成控制信号（写、MUX选择）
    assign RegWrite   = rtype | itype_r | itype_l  ; // register write
    assign MemWrite   = stype;              // memory write
    assign ALUSrc     = itype_r | stype | itype_l ; // ALU B is from instruction immediate
    //mem2reg=wdsel ,WDSel_FromALU 2'b00  WDSel_FromMEM 2'b01
    assign WDSel[0] = itype_l;   
    assign WDSel[1] = 1'b0;


    //操作指令生成运算类型aluop
    //ALUOp_nop 5'b00000
    //ALUOp_lui 5'b00001
    //ALUOp_auipc 5'b00010
    //ALUOp_add 5'b00011
    assign ALUOp[0]= i_add | i_addi | stype | itype_l ;
    assign ALUOp[1]= i_add | i_addi | stype | itype_l ;

    //操作指令生成常数扩展操作
    assign EXTOp[0] = stype;
    assign EXTOp[1] = itype_l | itype_r; 
    assign EXTOp[2] = 1'b0;

    //根据具体S和i_L指令生成DataMem数据操作类型编码
    //dm_word 3'b000
    //dm_halfword 3'b001
    //dm_halfword_unsigned 3'b010
    //dm_byte 3'b011
    //dm_byte_unsigned 3'b100
    assign DMType[2] = i_lbu;
    assign DMType[1] = i_lb | i_sb | i_lhu;
    assign DMType[0] = i_lh | i_sh | i_lb | i_sb;

endmodule
