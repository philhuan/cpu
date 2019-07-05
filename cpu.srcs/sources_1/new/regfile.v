
//通用寄存器，共32个
`include "defines.v"

module regfile(

	input wire clk,
	input wire	rst,
	
	//写端口
	input wire we,
	//写使能信号，只有此输入为1，寄存器才接受修改数据
	input wire[`RegAddrBus] waddr,
	input wire[`RegBus] wdata,
	
	//读端口1
	input wire re1,
	//第一个读端口是否可读
	input wire[`RegAddrBus] raddr1,
	//要读的寄存器地址
	output reg[`RegBus] rdata1,
	//读取的数据
	
	//读端口2
	input wire re2,
	input wire[`RegAddrBus]			  raddr2,
	output reg[`RegBus]           rdata2
	
);

	reg[`RegBus]  regs[0:`RegNum-1];

	always @ (posedge clk) begin
		if (rst == `RstDisable) 
		begin
			if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
				regs[waddr] <= wdata;
			end
		end
	end
	
	//读接口1
	always @ (*) begin
		if(rst == `RstEnable) begin	//复位
			  rdata1 <= `ZeroWord;
	  end else if(raddr1 == `RegNumLog2'h0) begin	
			//取$0时，直接给出0
	  		rdata1 <= `ZeroWord;
	  end else if((raddr1 == waddr) && (we == `WriteEnable) 
	  	            && (re1 == `ReadEnable)) begin
		  //如果写的同时读，并且可读可写，直接返回要写的数据
		  //此处解决RAW数据冲突（相隔2条指令的）
	  	  rdata1 <= wdata;
	  end else if(re1 == `ReadEnable) begin
		  //普通可读情况下，读取寄存器
	      rdata1 <= regs[raddr1];
	  end else begin
		  //其他情况，直接返回0
	      rdata1 <= `ZeroWord;
	  end
	end

	//读接口2
	//此接口与上面的读接口相似
	always @ (*) begin
		if(rst == `RstEnable) begin
			  rdata2 <= `ZeroWord;
	  end else if(raddr2 == `RegNumLog2'h0) begin
	  		rdata2 <= `ZeroWord;
	  end else if((raddr2 == waddr) && (we == `WriteEnable) 
	  	            && (re2 == `ReadEnable)) begin
	  	  rdata2 <= wdata;
	  end else if(re2 == `ReadEnable) begin
	      rdata2 <= regs[raddr2];
	  end else begin
	      rdata2 <= `ZeroWord;
	  end
	end

endmodule