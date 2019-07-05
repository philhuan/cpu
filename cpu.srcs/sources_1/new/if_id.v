
// IF/ID阶段的寄存器
/**
将取指周期的地址暂存
*/
`include "defines.v"

module if_id(

	input	wire										clk,
	input wire										rst,
	
	input wire[`InstAddrBus]			if_pc,
	//pc寄存器的值，即为指令的地址
	input wire[`InstBus]          if_inst,
	//由指令存储器读过来的指令数据
	
	output reg[`InstAddrBus]      id_pc,
	output reg[`InstBus]          id_inst  
	
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
	  end else begin
		  id_pc <= if_pc;
		  id_inst <= if_inst;
		end
	end

endmodule