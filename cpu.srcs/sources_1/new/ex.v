
//执行阶段
`include "defines.v"

module ex(

	input wire										rst,
	
	//送到执行阶段的信息
	input wire[`AluOpBus]         aluop_i,
	//运算子类型
	input wire[`AluSelBus]        alusel_i,
	//运算类型
	input wire[`RegBus]           reg1_i,
	input wire[`RegBus]           reg2_i,
	//操作数1，2
	input wire[`RegAddrBus]       wd_i,
	//要写入的目的寄存器地址
	input wire                    wreg_i,
	//是否有要写入的目的寄存器

	
	output reg[`RegAddrBus]       wd_o,
	//最终要写入的目的寄存器地址
	output reg                    wreg_o,
	//是否有要写入的目的寄存器
	output reg[`RegBus]						wdata_o
	//要写入的目的寄存器的值
	
);

	//运算
	reg[`RegBus] logicout;
	always @ (*) begin
		if(rst == `RstEnable) 
		begin
			logicout <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_OR_OP:			
				begin
					logicout <= reg1_i | reg2_i;
				end
				`EXE_AND_OP:		
				begin
					logicout <= reg1_i & reg2_i;
				end
				default:				
				begin
					logicout <= `ZeroWord;
				end
			endcase
		end    //if
	end      //always

//输出结果
 always @ (*) begin
	 wd_o <= wd_i;	 	 	
	 wreg_o <= wreg_i;
	 case ( alusel_i ) 
	 	`EXE_RES_LOGIC:		
		begin
	 		wdata_o <= logicout;
	 	end
	 	default:					
		begin
	 		wdata_o <= `ZeroWord;
	 	end
	 endcase
 end	

endmodule