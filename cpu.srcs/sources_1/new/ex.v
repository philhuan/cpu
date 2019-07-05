
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
	output reg wreg_o,
	//是否有要写入的目的寄存器
	output reg[`RegBus] wdata_o
	//要写入的目的寄存器的值
	
);

	reg[`RegBus] arithmeticres;
	///算术运算结果
	wire ov_sum;
	//是否溢出
	wire[`RegBus] result_sum;
	//加法的结果

	wire[`RegBus] reg1_i_not;
	//第一个操作数取反
	
	

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
	
		always @ (*) begin
		if(rst == `RstEnable) begin
			arithmeticres <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_ADD_OP, `EXE_ADDI_OP:		
				begin
					arithmeticres <= result_sum; 
				end
				
				default:				begin
					arithmeticres <= `ZeroWord;
				end
			endcase
		end
	end
	
	assign reg1_i_not = ~reg1_i;
	
	assign result_sum = reg1_i + reg2_i;		
	
	//判断是否溢出，两正加得负，或者两负加得正
	assign ov_sum = ((!reg1_i[31] && !reg2_i[31]) && result_sum[31]) ||
									((reg1_i[31] && reg2_i[31]) && (!result_sum[31]));  

//输出结果
 always @ (*) 
 begin
	 wd_o <= wd_i;	 
	 
	 //溢出不写如目的寄存器
	 if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP)) 
	 && (ov_sum == 1'b1)) 
	 begin
	 	wreg_o <= `WriteDisable;
	 end else 
	 begin
	  wreg_o <= wreg_i;
	 end
	 case ( alusel_i ) 
	 	`EXE_RES_LOGIC:		
		begin
	 		wdata_o <= logicout;
	 	end
		`EXE_RES_ARITHMETIC:	
		begin
	 		wdata_o <= arithmeticres;
	 	end
	 	default:					
		begin
	 		wdata_o <= `ZeroWord;
	 	end
	 endcase
 end	

endmodule