
/**
指令存储器
当pc模块检测到rst为0时，将ce置为1，此模块就根据addr输出对应地址的数据，
此数据被IF/ID模块存储
*/
`include "defines.v"

module inst_rom(
	input wire ce, 
	//指令存储器使能，由pc模块控制
	input wire[`InstAddrBus]			addr,
	//
	output reg[`InstBus]					inst
	
);

	reg[`InstBus]  inst_mem[0:`InstMemNum-1];
	
    initial begin
//      inst_mem[0]=32'h34011100;
//      inst_mem[1]=32'h34020020;
//      inst_mem[2]=32'h3403ff00;
//      inst_mem[3]=32'h3404ffff;
    end
	

	initial $readmemh ("D:/code/fpga/cpu/inst_rom.data", inst_mem );


	always @ (*) begin
		if (ce == `ChipDisable) begin
			inst <= `ZeroWord;
	  end else begin
		  inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
		end
	end

endmodule