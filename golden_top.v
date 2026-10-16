//--------------------------------------------------------------------------//
// Title:       golden_top.v                                                //
// Rev:         Rev 5                                                       //
// Created:     July 22, 2015                                             //
//--------------------------------------------------------------------------//
// Description: Cyclone V SX SoC pinout and IO Standard example design      //              					                        //
//--------------------------------------------------------------------------//
// Revision History:                                                        //
// Rev 0:       1st cut                                                      //
//----------------------------------------------------------------------------
//------ 1 ------- 2 ------- 3 ------- 4 ------- 5 ------- 6 ------- 7 ------7
//------ 0 ------- 0 ------- 0 ------- 0 ------- 0 ------- 0 ------- 0 ------8
//----------------------------------------------------------------------------
//Copyright 2012 Altera Corporation. All rights reserved.  Altera products  
//are protected under numerous U.S. and foreign patents, maskwork rights,     
//copyrights and other intellectual property laws.                            
//                                                                            
//This reference design file, and your use thereof, is subject to and         
//governed by the terms and conditions of the applicable Altera Reference     
//Design License Agreement.  By using this reference design file, you         
//indicate your acceptance of such terms and conditions between you and       
//Altera Corporation.  In the event that you do not agree with such terms and 
//conditions, you may not use the reference design file. Please promptly      
//destroy any copies you have made.                                           
//                                                                            
//This reference design file being provided on an "as-is" basis and as an                                             
//accommodation and therefore all warranties, representations or guarantees   
//of any kind (whether express, implied or statutory) including, without      
//limitation, warranties of merchantability, non-infringement, or fitness for 
//a particular purpose, are specifically disclaimed.  By making this          
//reference design file available, Altera expressly does not recommend,       
//suggest or require that this reference design file be used in combination   
//with any other product not provided by Altera.                              
//                                                                            

//`define ENABLE_FPGA_USER_IO
`define ENABLE_FPGA_GPLL_CLK
//`define ENABLE_HPS
//`define ENABLE_DDR3_HPS
//`define ENABLE_DDR3_FPGA
`define ENABLE_FPGA_ETHERNET
//`define ENABLE_SDI_XCVR
`define ENABLE_I2C_FPGA
`define ENABLE_MAX_FPGA
//`define ENABLE_HSMA_XCVR      
//`define ENABLE_HSMA_LVDS
//`define 	ENABLE_HSMA_CMOS 
//`define ENABLE_PCIE_XCVR

module golden_top (
	
//HPS	
`ifdef	ENABLE_HPS
//HPS-CLK-INPUT 3.3 V LVCMOS
   input          clk_osc1,        
   input          clk_osc2,            

//HPS-Reset 3.3 V LVCMOS
   inout          mictor_rstn,         
   input          hps_resetn,          

//HPS-User-IO
   input  [3:0]   user_dipsw_hps,      //1.5V
   output [3:0]   user_led_hps,        //3.3V LVCMOS
   input  [1:0]   user_pb_hps,         //1.5V

//HPS-UART 3.3 V LVCMOS
   input          uart_rx,            
   output         uart_tx,            

//HPS-I2C 3.3 V LVCMOS
   inout          i2c_scl_hps,         
   inout          i2c_sda_hps,         
	
//HPS-SPI-Bus
   output         spi_csn,             //3.3V    //Slave Sel 0 - LTC Analog
   input          spi_miso,            //3.3V    //Master Input
   output         spi_mosi,            //3.3V    //Master Output 
   output         spi_sck,             //3.3V    //Clock Output 

//HPS-QSPI-Flash
   output         qspi_clk,            //3.3V    //Clock
   inout [3:0]    qspi_io,             //3.3V    //Data
   output         qspi_ss0,            //3.3V    //Select
	
//HPS-SD-Card-Flash
   output         sd_clk,              //3.3V    
   inout          sd_cmd,              //3.3V    
   output         sd_pwren,            //3.3V    
   //inout  [3:0]   sd_dat,            //3.3V    
   inout  [7:0]   sd_dat,              //3.3V    

//HPS-USB-OTG
  	 input          usb_clk,           //3.3V    
	inout  [7:0]   usb_data,           //3.3V     
	input          usb_nxt,            //3.3V     
	input          usb_dir,            //3.3V     
	output         usb_stp,            //3.3V     
	input          usb_empty,  		  //1.5V
	input          usb_full,    		  //1.5V
	output         usb_oen,    		  //1.5V
	output         usb_rdn,       	  //1.5V
	output         usb_resetn,			  //1.5V
	output         usb_scl,       	  //1.5V
	inout          usb_sda,       	  //1.5V
	output         usb_wrn,				  //1.5V
	

//HPS-Ethernet
	output         enet_hps_gtx_clk,    //3.3V    //Gb Ethernet Clock
	//input		enet_hps_intn,       	//3.3V    //Placed on HPS GPIO
	output         enet_hps_mdc,        //3.3V    //MDIO Clock (TR=0)
	inout          enet_hps_mdio,       //3.3V    //MDIO Data (TR=0)
	input		enet_hps_rx_clk,     		//3.3V    //Receive Data
	input		 enet_hps_rx_dv,      		//3.3V    //Receive Data Valid / Cont
	input	[3:0]	   enet_hps_rxd,        //3.3V    //Receive Data
	output         enet_hps_tx_en,      //3.3V    //Transmit Data Enable / Cont
	output [3:0]   enet_hps_txd,        //3.3V    //Transmit Data
	
//HPS-CAN-BUS
   input          can_0_rx,            //3.3V    //HPS only
   output         can_0_tx,            //3.3V    //HPS only 

//HPS-Trace
	//input          mictor_rstn,       //3.3V    
   output         trace_clk_mic,       //3.3V    
   output [7:0]   trace_data,          //3.3V    

`endif

//HPS-DDR3-400Mx40
`ifdef	ENABLE_DDR3_HPS
   output [14:0]  ddr3_hps_a,          //SSTL15  //Address
   output [2:0]   ddr3_hps_ba,         //SSTL15  //Bank Address
   output         ddr3_hps_casn,       //SSTL15  //Column Address Strobe
   output         ddr3_hps_cke,        //SSTL15  //Clock Enable
   output         ddr3_hps_clk_n,      //SSTL15  //Diff Clock - Neg
   output         ddr3_hps_clk_p,      //SSTL15  //Diff Clock - Pos
   output         ddr3_hps_csn,        //SSTL15  //Chip Select
   output [4:0]   ddr3_hps_dm,         //SSTL15  //Data Write Mask
   inout  [39:0]  ddr3_hps_dq,         //SSTL15  //Data Bus
   inout	 [4:0]   ddr3_hps_dqs_n,      //SSTL15  //Diff Data Strobe - Neg
   inout  [4:0]   ddr3_hps_dqs_p,      //SSTL15  //Diff Data Strobe - Pos
   output         ddr3_hps_odt,        //SSTL15  //On-Die Termination Enable
   output         ddr3_hps_rasn,       //SSTL15  //Row Address Strobe
   output         ddr3_hps_resetn,     //SSTL15  //Reset
   output         ddr3_hps_wen,        //SSTL15  //Write Enable
   input          ddr3_hps_rzq,        //SSTL15
	//input          ddr3_rup,          //OCT_rup
	//input          ddr3_rdn,          //OCT_rdn
`else
   //output         ddr3_hps_csn,        //SSTL15  //Chip Select
`endif

	
//FPGA-GPLL-CLK
`ifdef ENABLE_FPGA_GPLL_CLK
   input          clk_100m_fpga,       //2.5V    //100 MHz (2nd copy to max)
   input          clk_50m_fpga,        //1.5V    //50MHz (2nd copy to max) 
   //input				clk_25m_fpga,			//1.5V
   input          clk_top1,            //2.5V    //156.25 MHz adjustable
   input          clk_bot1,            //1.5V    //100 MHz adjustable
//   input          clk_enet_fpga_p,     //LVDS    //125 MHz fixed
`endif

//FPGA-User-IO
`ifdef ENABLE_FPGA_USER_IO
	input          cpu_resetn,          //2.5V    //NIOS CPU Reset Pushbutton
	input	 [3:0]   user_dipsw_fpga,     //1.5V
	output [3:0]   user_led_fpga,       //1.5V
	input	 [1:0]   user_pb_fpga,        //1.5V
`endif

//FPGA-DDR3-400Mx32
`ifdef	ENABLE_DDR3_FPGA
   output [14:0]  ddr3_fpga_a,         //SSTL15  //Address
   output [2:0]   ddr3_fpga_ba,        //SSTL15  //Bank Address
   output         ddr3_fpga_casn,      //SSTL15  //Column Address Strobe
   output         ddr3_fpga_cke,       //SSTL15  //Clock Enable
   output         ddr3_fpga_clk_n,     //SSTL15  //Diff Clock - Neg
   output         ddr3_fpga_clk_p,     //SSTL15  //Diff Clock - Pos
   output         ddr3_fpga_csn,       //SSTL15  //Chip Select
   output [3:0]   ddr3_fpga_dm,        //SSTL15  //Data Write Mask
   inout  [31:0]  ddr3_fpga_dq,        //SSTL15  //Data Bus
   inout  [3:0]   ddr3_fpga_dqs_n,     //SSTL15  //Diff Data Strobe - Neg
   inout  [3:0]   ddr3_fpga_dqs_p,     //SSTL15  //Diff Data Strobe - Pos
   output         ddr3_fpga_odt,       //SSTL15  //On-Die Termination Enable
   input          ddr3_fpga_rasn,      //SSTL15  //Row Address Strobe
   input          ddr3_fpga_resetn,    //SSTL15  //Reset
   input          ddr3_fpga_wen,       //SSTL15  //Write Enable
   input          ddr3_fpga_rzq,       //OCT_rzqin
`else
   //output         ddr3_fpga_csn,       //SSTL15  //Chip Select
`endif
	

//FPGA-Ethernet
`ifdef ENABLE_FPGA_ETHERNET
	input			   enet1_rx_clk,        //2.5V    //Receive Data Clock
	input	[3:0]	   enet1_rx_d,          //2.5V    //Receive Data
	input			   enet1_rx_dv,         //2.5V    //Receive Data Valid
	input			   enet1_rx_error,      //2.5V    //Receive Data Error
	output         enet1_tx_clk_fb,     //2.5V    //Transmit Clock Feedback
	output [3:0]   enet1_tx_d,          //2.5V    //Transmit Data
	output         enet1_tx_en,         //2.5V    //Transmit Data Enable
	input          enet1_tx_error,      //2.5V    //Transmit Data Error
	output         enet_dual_resetn,    //2.5V    //EtherCat PHY Reset
	input			   enet2_rx_clk,        //2.5V    //Receive Data Clock
	input	[3:0]	   enet2_rx_d,          //2.5V    //Receive Data
	input			   enet2_rx_dv,         //2.5V    //Receive Data Valid
	input			   enet2_rx_error,      //2.5V    //Receive Data Error
	output         enet2_tx_clk_fb,     //2.5V    //Transmit Clock Feedback
	output [3:0]   enet2_tx_d,          //2.5V    //Transmit Data
	output         enet2_tx_en,         //2.5V    //Transmit Data Enable
	input          enet2_tx_error,      //2.5V    //Transmit Data Error
	input				enet_fpga_mdc,			//2.5V	 //Management bus data clock
	input				enet_fpga_mdio,		//2.5V	 //Management bus data
`endif

//SDI-XCVR-Video
`ifdef	ENABLE_SDI_XCVR
   input          clk_148_p,           //LVDS 2.5   //148.5MHz Prog. SDI VCXO 
	input          gxb_rx_l4_p,         //PCML 1.5V    //SDI Receiver (or SMA)
	output         gxb_tx_l4_p,         //PCML 1.5V   //SDI Transmitter (or SMA)
	//148.5M programmable VCXO in refclk section above
	output			sdi_clk148_dn,       //2.5V    //VCXO pump up
	output			sdi_clk148_up,       //2.5V    //VCXO pump down
	input 			sdi_fault,           //2.5V    //SDI Cable Driver Fault
	output			sdi_rsti,            //2.5V    //SDI Cable Driver Reset
	output			sdi_rx_bypass,       //2.5V    //SDI Equalizer Bypass
	output 			sdi_rx_en,           //2.5V    //SDI Equalizer Enable
	output 			sdi_tx_en,           //2.5V    //SDI Cable Driver Enable
	output 			sdi_tx_sd_hdn,       //2.5V    //SDI Cable Driver High-Def 
`endif

`ifdef	ENABLE_I2C_FPGA	
	inout				i2c_sda_fpga, //2.5V
	inout				i2c_scl_fpga, //2.5V
`endif


`ifdef	ENABLE_MAX_FPGA
	output	max_fpga_miso,	//2.5V
	input		max_fpga_mosi,	//2.5V
	inout		max_fpga_sck,  //2.5V
	inout		max_fpga_ssel //2.5V
`endif


//HSMC-Port-A
`ifdef	ENABLE_HSMA_XCVR
	input          refclk_ql2_p,       	//LVDS 2.5V   //HSMA Transceiver Refclk -reqs OCT
   input [3:0]    hsma_rx_p,           //PCML 1.5V   //HSMA Receive Data -reqs OCT
   output [3:0]   hsma_tx_p,           //PCML 1.5V   //HSMA Transmit Data
`endif

 //Enable below for CMOS HSMA
`ifdef ENABLE_HSMA_CMOS       
	inout  [79:0]  hsma_d,            //2.5V    //HSMA CMOS Data Bus
`endif

 //Enable below for LVDS HSMA      
`ifdef 	ENABLE_HSMA_LVDS
   input          hsma_clk_in0,        //2.5V    //Primary single-ended CLKIN
	input				hsma_clk_in_p1,		//2.5V LVCMOS signal
	input				hsma_clk_in_n1,		//2.5V LVCMOS signal
   input          hsma_clk_in_p2,      //2.5V LVDS    //Primary Source-Sync CLKIN
   output         hsma_clk_out0,       //2.5V    //Primary single-ended CLKOUT
	output			hsma_clk_out_p1,		//2.5V LVCMOS signal
	output			hsma_clk_out_n1,		//2.5V LVCMOS signal			
   output         hsma_clk_out_p2,     //2.5V LVDS    //Primary Source-Sync CLKOUT
   inout  [3:0]   hsma_d,              //2.5V    //Dedicated CMOS IO                            
	input  [16:0]  hsma_rx_d_p,         //2.5V LVDS    //LVDS Sounce-Sync Input
	output [16:0]  hsma_tx_d_p,         //2.5V LVDS    //LVDS Sounce-Sync Output
	input          hsma_prsntn,         //2.5V    //HSMC Presence Detect Input
	output         hsma_scl,            //2.5V    //SMBus Clock
	inout          hsma_sda,            //2.5V    //SMBus Data
`endif

//PCI-Express
`ifdef	ENABLE_PCIE_XCVR
   input          pcie_refclk_p,       //1.5V LVDS    //PCIe Refclk -reqs OCT            
   input  [3:0]   pcie_rx_p,           //PCML 1.5V   //PCIe Receive Data-req'sOCT
   output [3:0]   pcie_tx_p,           //PCML 1.5V   //PCIe Transmit Data
   input			pcie_perstn_in,			//2.5V Pin W21 instance 0 
   output			pcie_perstn_out,		//2.5V Pin AG6 instance 1    
   input				pcie_prsnt2_x1,   	//2.5V LVTTL
	input				pcie_prsnt2_x4,   	//2.5V LVTTL
	inout				pcie_smbclk,			//2.5V LVTTL
	inout				pcie_smbdat,			//2.5V LVTTL
	inout				pcie_waken				//2.5V LVTTL
`endif
);

	
// Rev A board Ethernet reset can interrupt device configuration, to fix
// enet_dual_reset tristate as input or drive as output to 1
assign	enet_dual_resetn	=	1'b1;	
// FPGA user dipswitches drive user LEDs
//assign   user_led_fpga		=	~user_dipsw_fpga;
// Disable FPGA DDR3 
assign   ddr3_fpga_csn		=	1'b1;	




endmodule











