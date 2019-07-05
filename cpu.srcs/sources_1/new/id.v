
//译码阶段
`include "defines.v"
/**
对指令进行译码，得到运算类型，子类型，源操作数，目的操作数，操作数是寄存器的话还要读寄存器
*/

module id(

	
	input wire rst,
	input wire[`InstAddrBus] pc_i,	
	//由IF/ID读过来的指令地址（PC值）
	input wire[`InstBus] inst_i,
	//由IF/ID读过来的指令数据（来自指令ROM）

	input wire[`RegBus] reg1_data_i,
	//regfile模块第一个读接口输出的数据
	input wire[`RegBus] reg2_data_i,
	//regfile模块第二个读接口输出的数据
	
	//处于执行阶段的指令要写入的目的寄存器信息
	input wire ex_wreg_i,
	//执行阶段是否要写入目的寄存器
	input wire[`RegBus] ex_wdata_i,
	input wire[`RegAddrBus] ex_wd_i,
	//要写入的地址和数据
	
	//处于访存阶段的指令要写入的目的寄存器信息
	input wire mem_wreg_i,
	//访存阶段是否要写入目的寄存器
	input wire[`RegBus] mem_wdata_i,
	input wire[`RegAddrBus] mem_wd_i,
	//要写入的地址和数据

	//送到regfile的信息
	output reg reg1_read_o,
	//regfile端口1可读
	output reg reg2_read_o,     
	output reg[`RegAddrBus] reg1_addr_o,
	//regfile读取的地址
	output reg[`RegAddrBus] reg2_addr_o, 	      
	
	//送到执行阶段的信息
	output reg[`AluOpBus] aluop_o,
	//运算的子类型
	output reg[`AluSelBus] alusel_o,
	//运算的类型
	output reg[`RegBus] reg1_o,
	output reg[`RegBus] reg2_o,
	//两个源操作数
	output reg[`RegAddrBus] wd_o,
	//目的寄存器地址
	output reg wreg_o,
	//是否有要写入的
	
	output reg                    branch_flag_o,
	output reg[`RegBus]           branch_target_address_o
	//当前译码的指令是不是在延迟槽内
);

  wire[5:0] op = inst_i[31:26];	
  //指令码
  wire[4:0] op2 = inst_i[10:6];
  wire[5:0] op3 = inst_i[5:0];
  //功能码
  wire[4:0] op4 = inst_i[20:16];
  reg[`RegBus]	imm;
  //指令是否有效
  reg instvalid;
  wire[`RegBus] pc_plus_4;
  assign pc_plus_4 = pc_i +4;
  
  wire[`RegBus] imm_sll2_signedext;  
  assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00 };
 
	always @ (*) begin	
		if (rst == `RstEnable) begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			instvalid <= `InstValid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm <= 32'h0;
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;
			
			
	  end else begin
			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= inst_i[15:11];
			wreg_o <= `WriteDisable;
			instvalid <= `InstInvalid;	   
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[25:21];
			reg2_addr_o <= inst_i[20:16];		
			imm <= `ZeroWord;			
			branch_target_address_o <= `ZeroWord;
			branch_flag_o <= `NotBranch;	
			
		  case (op)
		    `EXE_SPECIAL_INST:		begin
		    	case (op2)
		    		5'b00000:			begin
		    			case (op3)
		    				//R类
		    				`EXE_AND:	
							begin
		    					wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_AND_OP;
		  						alusel_o <= `EXE_RES_LOGIC;	  
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;	
		  						instvalid <= `InstValid;	
							end  
							//R类
							`EXE_ADD: 
							begin
								wreg_o <= `WriteEnable;		
								aluop_o <= `EXE_ADD_OP;
		  						alusel_o <= `EXE_RES_ARITHMETIC;		
								reg1_read_o <= 1'b1;	
								reg2_read_o <= 1'b1;
		  						instvalid <= `InstValid;	
							end
						    default:	begin
						    end
						  endcase
						 end
						default: begin
						end
					endcase	
					end	
			//I类指令：
		  	`EXE_ORI:			
			begin                        //ORI指令
				//需要写寄存器
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_OR_OP;
				//子类型为EXE_OR_OP
		  		alusel_o <= `EXE_RES_LOGIC;
				//类型为EXE_RES_LOGIC
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;
				//访问寄存器标志
				imm <= {16'h0, inst_i[15:0]};	
				//取出立即数
				wd_o <= inst_i[20:16];
				//取目的寄存器
				instvalid <= `InstValid;	
		  	end 
			//I类指令：
			`EXE_ADDI:			
			begin
		  		wreg_o <= `WriteEnable;		
				aluop_o <= `EXE_ADDI_OP;
		  		alusel_o <= `EXE_RES_ARITHMETIC; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b0;	  	
				imm <= {{16{inst_i[15]}}, inst_i[15:0]};		
				wd_o <= inst_i[20:16];		  	
				instvalid <= `InstValid;	
			end
			//J类指令
			`EXE_J:			
			begin
		  		wreg_o <= `WriteDisable;		
				aluop_o <= `EXE_J_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; reg1_read_o <= 1'b0;	
				reg2_read_o <= 1'b0;
			    branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
			    branch_flag_o <= `Branch;
			   
			    instvalid <= `InstValid;	
			end
			//I类指令
			`EXE_BEQ:			
			begin
		  		wreg_o <= `WriteDisable;		
				aluop_o <= `EXE_BEQ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH; 
				reg1_read_o <= 1'b1;	
				reg2_read_o <= 1'b1;
		  		instvalid <= `InstValid;	
		  		if(reg1_o == reg2_o) 
				begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= `Branch;
			    		  	
			    end
				end
			
		    default:			
			begin
				
		    end
		  endcase		  //case op			
		end       //if
	end         //always
	

	//读寄存器
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg1_o <= `ZeroWord;
	  end  else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg1_addr_o)) begin
			reg1_o <= ex_wdata_i; 
		end else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg1_addr_o)) begin
			reg1_o <= mem_wdata_i; 			
	  end else if(reg1_read_o == 1'b1) begin
	  	reg1_o <= reg1_data_i;	
		//需要访问寄存器，取寄存器值
	  end else if(reg1_read_o == 1'b0) begin
	  	reg1_o <= imm;			
		//立即数直接赋值
	  end else begin
	    reg1_o <= `ZeroWord;
	  end
	end
	
	always @ (*) begin
		if(rst == `RstEnable) begin
			reg2_o <= `ZeroWord;
	  end else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1) 
								&& (ex_wd_i == reg2_addr_o)) begin
			//要读取的寄存器就是执行阶段要写的寄存器，直接把执行阶段的值ex_wdata_i作为reg1_o的值
			reg2_o <= ex_wdata_i; 
		end else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1) 
								&& (mem_wd_i == reg2_addr_o)) begin
			//如果要读取的寄存器是执行阶段要写入的寄存器，直接将访存的结果mem_wdata_i作为reg1_o的值
			reg2_o <= mem_wdata_i;			
	  end else if(reg2_read_o == 1'b1) begin
	  	reg2_o <= reg2_data_i;
	  end else if(reg2_read_o == 1'b0) begin
	  	reg2_o <= imm;
	  end else begin
	    reg2_o <= `ZeroWord;
	  end
	end

endmodule