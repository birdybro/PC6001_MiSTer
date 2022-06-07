-- megafunction wizard: %ROM: 1-PORT%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: altsyncram 

-- ============================================================
-- File Name: MATRIXROM.vhd
-- Megafunction Name(s):
-- 			altsyncram
--
-- Simulation Library Files(s):
-- 			altera_mf
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 11.0 Build 208 07/03/2011 SP 1 SJ Web Edition
-- ************************************************************


--Copyright (C) 1991-2011 Altera Corporation
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, Altera MegaCore Function License 
--Agreement, or other applicable license agreement, including, 
--without limitation, that your use is for the sole purpose of 
--programming logic devices manufactured by Altera and sold by 
--Altera or its authorized distributors.  Please refer to the 
--applicable agreement for further details.


LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY MATRIXROM IS
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		address		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
END MATRIXROM;


ARCHITECTURE SYN OF matrixrom IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (8 DOWNTO 0);



	COMPONENT altsyncram
	GENERIC (
		address_aclr_a		: STRING;
		clock_enable_input_a		: STRING;
		clock_enable_output_a		: STRING;
		init_file		: STRING;
		intended_device_family		: STRING;
		lpm_type		: STRING;
		numwords_a		: NATURAL;
		operation_mode		: STRING;
		outdata_aclr_a		: STRING;
		outdata_reg_a		: STRING;
		widthad_a		: NATURAL;
		width_a		: NATURAL;
		width_byteena_a		: NATURAL
	);
	PORT (
			aclr0	: IN STD_LOGIC ;
			address_a	: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
			clock0	: IN STD_LOGIC ;
			q_a	: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	q    <= sub_wire0(8 DOWNTO 0);

	altsyncram_component : altsyncram
	GENERIC MAP (
		address_aclr_a => "CLEAR0",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "rtl/matrixrom.mif",
		intended_device_family => "Cyclone III",
		lpm_type => "altsyncram",
		numwords_a => 2048,
		operation_mode => "ROM",
		outdata_aclr_a => "CLEAR0",
		outdata_reg_a => "CLOCK0",
		widthad_a => 11,
		width_a => 9,
		width_byteena_a => 1
	)
	PORT MAP (
		aclr0 => aclr,
		address_a => address,
		clock0 => clock,
		q_a => sub_wire0
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: ADDRESSSTALL_A NUMERIC "0"
-- Retrieval info: PRIVATE: AclrAddr NUMERIC "1"
-- Retrieval info: PRIVATE: AclrByte NUMERIC "0"
-- Retrieval info: PRIVATE: AclrOutput NUMERIC "1"
-- Retrieval info: PRIVATE: BYTE_ENABLE NUMERIC "0"
-- Retrieval info: PRIVATE: BYTE_SIZE NUMERIC "9"
-- Retrieval info: PRIVATE: BlankMemory NUMERIC "0"
-- Retrieval info: PRIVATE: CLOCK_ENABLE_INPUT_A NUMERIC "0"
-- Retrieval info: PRIVATE: CLOCK_ENABLE_OUTPUT_A NUMERIC "0"
-- Retrieval info: PRIVATE: Clken NUMERIC "0"
-- Retrieval info: PRIVATE: IMPLEMENT_IN_LES NUMERIC "0"
-- Retrieval info: PRIVATE: INIT_FILE_LAYOUT STRING "PORT_A"
-- Retrieval info: PRIVATE: INIT_TO_SIM_X NUMERIC "0"
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone III"
-- Retrieval info: PRIVATE: JTAG_ENABLED NUMERIC "0"
-- Retrieval info: PRIVATE: JTAG_ID STRING "NONE"
-- Retrieval info: PRIVATE: MAXIMUM_DEPTH NUMERIC "0"
-- Retrieval info: PRIVATE: MIFfilename STRING "../src/matrixrom.mif"
-- Retrieval info: PRIVATE: NUMWORDS_A NUMERIC "2048"
-- Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "0"
-- Retrieval info: PRIVATE: RegAddr NUMERIC "1"
-- Retrieval info: PRIVATE: RegOutput NUMERIC "1"
-- Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
-- Retrieval info: PRIVATE: SingleClock NUMERIC "1"
-- Retrieval info: PRIVATE: UseDQRAM NUMERIC "0"
-- Retrieval info: PRIVATE: WidthAddr NUMERIC "11"
-- Retrieval info: PRIVATE: WidthData NUMERIC "9"
-- Retrieval info: PRIVATE: rden NUMERIC "0"
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
-- Retrieval info: CONSTANT: ADDRESS_ACLR_A STRING "CLEAR0"
-- Retrieval info: CONSTANT: CLOCK_ENABLE_INPUT_A STRING "BYPASS"
-- Retrieval info: CONSTANT: CLOCK_ENABLE_OUTPUT_A STRING "BYPASS"
-- Retrieval info: CONSTANT: INIT_FILE STRING "../src/matrixrom.mif"
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Cyclone III"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "altsyncram"
-- Retrieval info: CONSTANT: NUMWORDS_A NUMERIC "2048"
-- Retrieval info: CONSTANT: OPERATION_MODE STRING "ROM"
-- Retrieval info: CONSTANT: OUTDATA_ACLR_A STRING "CLEAR0"
-- Retrieval info: CONSTANT: OUTDATA_REG_A STRING "CLOCK0"
-- Retrieval info: CONSTANT: WIDTHAD_A NUMERIC "11"
-- Retrieval info: CONSTANT: WIDTH_A NUMERIC "9"
-- Retrieval info: CONSTANT: WIDTH_BYTEENA_A NUMERIC "1"
-- Retrieval info: USED_PORT: aclr 0 0 0 0 INPUT GND "aclr"
-- Retrieval info: USED_PORT: address 0 0 11 0 INPUT NODEFVAL "address[10..0]"
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT VCC "clock"
-- Retrieval info: USED_PORT: q 0 0 9 0 OUTPUT NODEFVAL "q[8..0]"
-- Retrieval info: CONNECT: @aclr0 0 0 0 0 aclr 0 0 0 0
-- Retrieval info: CONNECT: @address_a 0 0 11 0 address 0 0 11 0
-- Retrieval info: CONNECT: @clock0 0 0 0 0 clock 0 0 0 0
-- Retrieval info: CONNECT: q 0 0 9 0 @q_a 0 0 9 0
-- Retrieval info: GEN_FILE: TYPE_NORMAL MATRIXROM.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL MATRIXROM.inc FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL MATRIXROM.cmp FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL MATRIXROM.bsf FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL MATRIXROM_inst.vhd FALSE
-- Retrieval info: LIB_FILE: altera_mf
