
//指令指针寄存器PC       
`include "defines.v"

module pc_reg(

	input wire clk,
	input wire rst,
	
	//来自译码阶段的信息
	input wire                    branch_flag_i,
	//是否发生转移
	input wire[`RegBus]           branch_target_address_i,
	//转移到的新地址
	
	output reg[`InstAddrBus] pc,
	output reg ce
);

	always @ (posedge clk) begin
		if (ce == `ChipDisable) begin
			pc <= 32'h00000000;
		end else if(branch_flag_i == `Branch)
		begin
		//跳转指令控制pc改变
			pc <= branch_target_address_i;
		end
		else  begin
	 		pc <= pc + 4'h4;
		end
	end
	
	
	
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ce <= `ChipDisable;
		end else begin
			ce <= `ChipEnable;
		end
	end

endmodule