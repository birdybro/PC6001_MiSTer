--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity SDREADIF is
	port (
		SD_DAT0		: in  std_logic;						-- from SD card
		SD_WP		: in  std_logic;						-- from SD card
		ADD			: in  std_logic_vector(9 downto 0);		-- from CPU
		DATAI		: in  std_logic_vector(7 downto 0);		-- from CPU
		WRN			: in  std_logic;						-- from CPU
		RDN			: in  std_logic;						-- from CPU
		CMTRDOPEN	: in  std_logic;						-- from 8049
		CMTRDREQ	: in  std_logic;						-- from 8049
		CMTRDACC	: in  std_logic;						-- from 8049
		CMTRDACCMD	: in  std_logic;
		CMTWROPEN	: in  std_logic;						-- from 8049
		CMTWRREQ	: in  std_logic;						-- from 8049
		CMTWRDT		: in  std_logic_vector(7 downto 0);		-- from 8049
		DETBLK		: in  std_logic;
		FDEXTSEL	: in  std_logic;
		DMADIR		: in  std_logic;
		DMAONN		: in  std_logic;
		DMASIZE		: in  std_logic_vector(3 downto 0);
		FDINT_EXT	: in  std_logic;						-- from EXT_FDC
		COMEND		: in  std_logic;						-- from FDC
		COMMAND		: in  std_logic_vector(4 downto 0);		-- from FDC
		MT			: in  std_logic;						-- from FDC
		MF			: in  std_logic;						-- from FDC
		SK			: in  std_logic;						-- from FDC
		DNUM		: in  std_logic_vector(1 downto 0);		-- from FDC
		HNUM		: in  std_logic;						-- from FDC
		IDRC		: in  std_logic_vector(7 downto 0);		-- from FDC
		IDRH		: in  std_logic_vector(7 downto 0);		-- from FDC
		IDRR		: in  std_logic_vector(7 downto 0);		-- from FDC
		IDRN		: in  std_logic_vector(7 downto 0);		-- from FDC
		EOT			: in  std_logic_vector(7 downto 0);		-- from FDC
		GPL			: in  std_logic_vector(7 downto 0);		-- from FDC
		DTL			: in  std_logic_vector(7 downto 0);		-- from FDC
		EXT_COMEND	: in  std_logic;						-- from EXT_FDC
		EXT_COMMAND	: in  std_logic_vector(4 downto 0);		-- from EXT_FDC
		EXT_MT		: in  std_logic;						-- from EXT_FDC
		EXT_MF		: in  std_logic;						-- from EXT_FDC
		EXT_SK		: in  std_logic;						-- from EXT_FDC
		EXT_DNUM	: in  std_logic_vector(1 downto 0);		-- from EXT_FDC
		EXT_HNUM	: in  std_logic;						-- from EXT_FDC
		EXT_IDRC	: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
		EXT_IDRH	: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
		EXT_IDRR	: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
		EXT_IDRN	: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
		EXT_EOT		: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
		EXT_GPL		: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
		EXT_DTL		: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
		CNUM0		: in  std_logic_vector(7 downto 0);		-- from FDC
		CNUM1		: in  std_logic_vector(7 downto 0);		-- from FDC
		CNUM2		: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
		CNUM3		: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
		FDCACT		: in  std_logic;						-- from FDC
		FDCCNUM		: in  std_logic_vector(7 downto 0);		-- from FDC
		FDCSNUM		: in  std_logic_vector(7 downto 0);		-- from FDC
		FDCEXTACT	: in  std_logic;						-- from EXT_FDC
		FDCEXTCNUM	: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
		FDCEXTSNUM	: in  std_logic_vector(7 downto 0);		-- from EXT_FDC
		CLK50M		: in  std_logic;
		RSTN		: in  std_logic;
		DATAO		: out std_logic_vector(7 downto 0);		-- to CPU
		SD_RDAD		: out std_logic_vector(18 downto 0);	-- to SDRAM/CGROM
		SD_RDDT		: out std_logic_vector(7 downto 0);		-- to SDRAM/CGROM
		SD_SDENB	: out std_logic;						-- to SDRAM
		SD_SDWRN	: out std_logic;						-- to SDRAM
		SD_RDDONE	: out std_logic;
		SD_ERR		: out std_logic;
		SD_OUTENB	: out std_logic;
		CMTRDRDY	: out std_logic;						-- to 8049
		CMTWRRDY	: out std_logic;						-- to 8049
		CMTRDDT		: out std_logic_vector(7 downto 0);		-- to 8049
		CMTCNT		: out std_logic_vector(15 downto 0);
		ACCCNT		: out std_logic_vector(31 downto 0);
		SD_CMD		: out std_logic;						-- to SD card
		SD_DAT		: out std_logic_vector(3 downto 1);		-- to SD card
		SD_CLK		: out std_logic;						-- to SD card
		EXT_DMADIR	: out std_logic;						-- to EXT_FDC
		EXT_DMAONN	: out std_logic;						-- to EXT_FDC
		EXT_DMASIZE	: out std_logic_vector(7 downto 0);		-- to EXT_FDC
		FDD0		: out std_logic_vector(2 downto 0);		-- to FDC
		FDD1		: out std_logic_vector(2 downto 0);		-- to FDC
		FDD2		: out std_logic_vector(2 downto 0);		-- to EXT_FDC
		FDD3		: out std_logic_vector(2 downto 0);		-- to EXT_FDC
		FLOPPY0		: out std_logic_vector(3 downto 0);		-- to FDC
		FLOPPY1		: out std_logic_vector(3 downto 0);		-- to FDC
		FLOPPY2		: out std_logic_vector(3 downto 0);		-- to EXT_FDC
		FLOPPY3		: out std_logic_vector(3 downto 0);		-- to EXT_FDC
		ST0			: out std_logic_vector(7 downto 0);		-- to FDC
		ST1			: out std_logic_vector(7 downto 0);		-- to FDC
		ST2			: out std_logic_vector(7 downto 0);		-- to FDC
		RST_C		: out std_logic_vector(7 downto 0);		-- to FDC
		RST_H		: out std_logic_vector(7 downto 0);		-- to FDC
		RST_R		: out std_logic_vector(7 downto 0);		-- to FDC
		RST_N		: out std_logic_vector(7 downto 0);		-- to FDC
		ENDTRG		: out std_logic;						-- to FDC
		EXT_ST0		: out std_logic_vector(7 downto 0);		-- to EXT_FDC
		EXT_ST1		: out std_logic_vector(7 downto 0);		-- to EXT_FDC
		EXT_ST2		: out std_logic_vector(7 downto 0);		-- to EXT_FDC
		EXT_RST_C	: out std_logic_vector(7 downto 0);		-- to EXT_FDC
		EXT_RST_H	: out std_logic_vector(7 downto 0);		-- to EXT_FDC
		EXT_RST_R	: out std_logic_vector(7 downto 0);		-- to EXT_FDC
		EXT_RST_N	: out std_logic_vector(7 downto 0);		-- to EXT_FDC
		EXT_ENDTRG	: out std_logic;						-- to EXT_FDC
		MONOUT		: out std_logic_vector(28 downto 0)
	);
end SDREADIF;

architecture RTL of SDREADIF is

	component SDREAD_CMDCNT is
		port (
			SD_DAT0		: in  std_logic;
			SD_WP		: in  std_logic;
			CMD_START	: in  std_logic;
			CMD_NO		: in  std_logic_vector(5 downto 0);
			SDADD		: in  std_logic_vector(31 downto 0);
			SDCNTENB	: in  std_logic;
			OUTDT		: in  std_logic_vector(7 downto 0);
			CLK			: in  std_logic;
			RSTN		: in  std_logic;
			STATEOUT	: out std_logic_vector(7 downto 0);
			INDT		: out std_logic_vector(7 downto 0);
			INDTENB		: out std_logic;
			OUTDTENB	: out std_logic;
			INDTLT		: out std_logic;
			INDTLT2		: out std_logic;
			CMD_END		: out std_logic;
			IDLEDET		: out std_logic;
			ERRDET		: out std_logic;
			SD_CMD		: out std_logic;
			SD_DAT		: out std_logic_vector(3 downto 1);
			SD_CLK		: out std_logic
		);
	end component;

	component SPRAM_1024W8B is
		port (
			address	: in  std_logic_vector(9 downto 0);
			data	: in  std_logic_vector(7 downto 0);
			wren	: in  std_logic;
			clock	: in  std_logic;
			aclr	: in  std_logic;
			q		: out std_logic_vector(7 downto 0)
		);
	end component;

	component SPRAM_2048W8B is
		port (
			address	: in  std_logic_vector(10 downto 0);
			data	: in  std_logic_vector(7 downto 0);
			wren	: in  std_logic;
			clock	: in  std_logic;
			aclr	: in  std_logic;
			q		: out std_logic_vector(7 downto 0)
		);
	end component;

	signal indt_i		: std_logic_vector(7 downto 0);
	signal indtenb_i	: std_logic;
	signal outdtenb_i	: std_logic;
	signal indtlt2_i	: std_logic;
	signal cmd_end_i	: std_logic;
	signal idledet_i	: std_logic;
	signal errdet_i		: std_logic;
	signal cmd_end_f1	: std_logic;
	signal cmd_end_f2	: std_logic;
	signal sdrdenb		: std_logic;
	signal sdwrenb		: std_logic;

	signal sd_rdcnt		: std_logic_vector(8 downto 0);
	signal sd_wrcnt		: std_logic_vector(8 downto 0);

	signal fifo_sdramtmg	: std_logic_vector(4 downto 0);
	signal fifo_cmtrdadd	: std_logic_vector(31 downto 0);
	signal fifo_cmtwradd	: std_logic_vector(31 downto 0);

	signal cmtrdycnt	: std_logic_vector(23 downto 0);
	signal cmtrdrdy_i	: std_logic;
	signal cmtrddt_i	: std_logic_vector(7 downto 0);

	signal cmtwrrdy_i	: std_logic;

	signal aclr		: std_logic;
	signal buf_add	: std_logic_vector(8 downto 0);
	signal buf_dat	: std_logic_vector(7 downto 0);
	signal buf_wr	: std_logic;
	signal buf_q	: std_logic_vector(7 downto 0);

	signal bufc_add	: std_logic_vector(9 downto 0);
	signal bufc_dat	: std_logic_vector(7 downto 0);
	signal bufc_wr	: std_logic;
	signal bufc_q	: std_logic_vector(7 downto 0);
	signal buff_add	: std_logic_vector(10 downto 0);
	signal buff_dat	: std_logic_vector(7 downto 0);
	signal buff_wr	: std_logic;
	signal buff_q	: std_logic_vector(7 downto 0);

	signal reg_start		: std_logic;						-- 0x8200(0)
	signal reg_startend		: std_logic;						-- 0x8200(0)
	signal reg_idledet		: std_logic;						-- 0x8200(1)
	signal reg_errdet		: std_logic;						-- 0x8200(2)
	signal reg_inuse		: std_logic;						-- 0x8201(0)
	signal reg_sderr		: std_logic;						-- 0x8201(1)
	signal reg_sdrddone		: std_logic;						-- 0x8202(0)
	signal reg_rominit		: std_logic;						-- 0x8203(0)
	signal reg_rominitend	: std_logic;						-- 0x8203(0)
	signal reg_cmdno		: std_logic_vector(5 downto 0);		-- 0x8205(5:0)
	signal reg_sdadd		: std_logic_vector(31 downto 0);	-- 0x8206-0x8209
	signal reg_bufad		: std_logic_vector(2 downto 0);		-- 0x8210(2:0)
	signal reg_bufsel		: std_logic_vector(3 downto 0);		-- 0x8211(3:0)
	signal reg_sdrdinit		: std_logic;						-- 0x8213(0)
	signal reg_sdrdfull		: std_logic;						-- 0x8213(4)
	signal reg_sdwrinit		: std_logic;						-- 0x8214(0)
	signal reg_sdwrfull		: std_logic;						-- 0x8214(4)

	signal reg_cmtlen_0		: std_logic_vector(31 downto 0);	-- 0x8220-0x8223
	signal reg_cmtptr_0		: std_logic_vector(31 downto 0);	-- 0x8224-0x8227
	signal reg_cl_0			: std_logic_vector(15 downto 0);	-- 0x8228-0x8229
	signal reg_sec_0		: std_logic_vector( 7 downto 0);	-- 0x822A
	signal reg_stcl_0		: std_logic_vector(15 downto 0);	-- 0x822B-0x822C
	signal reg_befcl_0		: std_logic_vector(15 downto 0);	-- 0x822D-0x822E
	signal reg_dircl_0		: std_logic_vector(15 downto 0);	-- 0x822F-0x8230
	signal reg_dirpos_0		: std_logic_vector(15 downto 0);	-- 0x8231-0x8232
	signal reg_fatnew_0		: std_logic_vector( 7 downto 0);	-- 0x8233
	signal reg_cmtrdst		: std_logic;						-- 0x8234(0)
	signal reg_cmtrdinit	: std_logic;						-- 0x8234(1)
	signal reg_cmtrdld		: std_logic;						-- 0x8234(2)
	signal reg_cmtrdfull	: std_logic;						-- 0x8234(4)
	signal reg_cmtrdend		: std_logic;						-- 0x8234(5)

	signal reg_cmtlen_1		: std_logic_vector(31 downto 0);	-- 0x8240-0x8243
	signal reg_cmtptr_1		: std_logic_vector(31 downto 0);	-- 0x8244-0x8247
	signal reg_cl_1			: std_logic_vector(15 downto 0);	-- 0x8248-0x8249
	signal reg_sec_1		: std_logic_vector( 7 downto 0);	-- 0x824A
	signal reg_stcl_1		: std_logic_vector(15 downto 0);	-- 0x824B-0x824C
	signal reg_befcl_1		: std_logic_vector(15 downto 0);	-- 0x824D-0x824E
	signal reg_dircl_1		: std_logic_vector(15 downto 0);	-- 0x824F-0x8250
	signal reg_dirpos_1		: std_logic_vector(15 downto 0);	-- 0x8251-0x8252
	signal reg_fatnew_1		: std_logic_vector( 7 downto 0);	-- 0x8253
	signal reg_cmtwrst		: std_logic;						-- 0x8254(0)
	signal reg_cmtwrld		: std_logic;						-- 0x8254(1)
	signal reg_cmtwrok		: std_logic;						-- 0x8254(2)
	signal reg_cmtwrfull	: std_logic;						-- 0x8254(4)

	signal reg_cmtlen_2		: std_logic_vector(31 downto 0);	-- 0x8260-0x8263
	signal reg_cmtptr_2		: std_logic_vector(31 downto 0);	-- 0x8264-0x8267
	signal reg_cl_2			: std_logic_vector(15 downto 0);	-- 0x8268-0x8269
	signal reg_sec_2		: std_logic_vector( 7 downto 0);	-- 0x826A
	signal reg_stcl_2		: std_logic_vector(15 downto 0);	-- 0x826B-0x826C
	signal reg_befcl_2		: std_logic_vector(15 downto 0);	-- 0x826D-0x826E
	signal reg_dircl_2		: std_logic_vector(15 downto 0);	-- 0x826F-0x8270
	signal reg_dirpos_2		: std_logic_vector(15 downto 0);	-- 0x8271-0x8272
	signal reg_fatnew_2		: std_logic_vector( 7 downto 0);	-- 0x8273
	signal reg_floppy_2		: std_logic_vector( 3 downto 0);	-- 0x8274
	signal reg_fdd_2		: std_logic_vector( 2 downto 0);	-- 0x827F

	signal reg_cmtlen_3		: std_logic_vector(31 downto 0);	-- 0x8280-0x8283
	signal reg_cmtptr_3		: std_logic_vector(31 downto 0);	-- 0x8284-0x8287
	signal reg_cl_3			: std_logic_vector(15 downto 0);	-- 0x8288-0x8289
	signal reg_sec_3		: std_logic_vector( 7 downto 0);	-- 0x828A
	signal reg_stcl_3		: std_logic_vector(15 downto 0);	-- 0x828B-0x828C
	signal reg_befcl_3		: std_logic_vector(15 downto 0);	-- 0x828D-0x828E
	signal reg_dircl_3		: std_logic_vector(15 downto 0);	-- 0x828F-0x8290
	signal reg_dirpos_3		: std_logic_vector(15 downto 0);	-- 0x8291-0x8292
	signal reg_fatnew_3		: std_logic_vector( 7 downto 0);	-- 0x8293
	signal reg_floppy_3		: std_logic_vector( 3 downto 0);	-- 0x8294
	signal reg_fdd_3		: std_logic_vector( 2 downto 0);	-- 0x829F

	signal reg_cmtlen_4		: std_logic_vector(31 downto 0);	-- 0x82A0-0x82A3
	signal reg_cmtptr_4		: std_logic_vector(31 downto 0);	-- 0x82A4-0x82A7
	signal reg_cl_4			: std_logic_vector(15 downto 0);	-- 0x82A8-0x82A9
	signal reg_sec_4		: std_logic_vector( 7 downto 0);	-- 0x82AA
	signal reg_stcl_4		: std_logic_vector(15 downto 0);	-- 0x82AB-0x82AC
	signal reg_befcl_4		: std_logic_vector(15 downto 0);	-- 0x82AD-0x82AE
	signal reg_dircl_4		: std_logic_vector(15 downto 0);	-- 0x82AF-0x82B0
	signal reg_dirpos_4		: std_logic_vector(15 downto 0);	-- 0x82B1-0x82B2
	signal reg_fatnew_4		: std_logic_vector( 7 downto 0);	-- 0x82B3
	signal reg_floppy_4		: std_logic_vector( 3 downto 0);	-- 0x82B4
	signal reg_fdd_4		: std_logic_vector( 2 downto 0);	-- 0x82BF

	signal reg_cmtlen_5		: std_logic_vector(31 downto 0);	-- 0x82C0-0x82C3
	signal reg_cmtptr_5		: std_logic_vector(31 downto 0);	-- 0x82C4-0x82C7
	signal reg_cl_5			: std_logic_vector(15 downto 0);	-- 0x82C8-0x82C9
	signal reg_sec_5		: std_logic_vector( 7 downto 0);	-- 0x82CA
	signal reg_stcl_5		: std_logic_vector(15 downto 0);	-- 0x82CB-0x82CC
	signal reg_befcl_5		: std_logic_vector(15 downto 0);	-- 0x82CD-0x82CE
	signal reg_dircl_5		: std_logic_vector(15 downto 0);	-- 0x82CF-0x82D0
	signal reg_dirpos_5		: std_logic_vector(15 downto 0);	-- 0x82D1-0x82D2
	signal reg_fatnew_5		: std_logic_vector( 7 downto 0);	-- 0x82D3
	signal reg_floppy_5		: std_logic_vector( 3 downto 0);	-- 0x82D4
	signal reg_fdd_5		: std_logic_vector( 2 downto 0);	-- 0x82DF

	signal reg_cmtwnom		: std_logic_vector(31 downto 0);	-- 0x8300-0x8303
	signal reg_cmtwacc		: std_logic_vector(31 downto 0);	-- 0x8304-0x8307
	signal reg_cmtwst		: std_logic_vector(31 downto 0);	-- 0x8308-0x830B
	signal reg_acccnt		: std_logic_vector(31 downto 0);	-- 0x830C-0x830F

	signal reg_st0			: std_logic_vector(7 downto 0);		-- 0x8320
	signal reg_st1			: std_logic_vector(7 downto 0);		-- 0x8321
	signal reg_st2			: std_logic_vector(7 downto 0);		-- 0x8322
	signal reg_rst_c		: std_logic_vector(7 downto 0);		-- 0x8323
	signal reg_rst_h		: std_logic_vector(7 downto 0);		-- 0x8324
	signal reg_rst_r		: std_logic_vector(7 downto 0);		-- 0x8325
	signal reg_rst_n		: std_logic_vector(7 downto 0);		-- 0x8326
	signal reg_endtrg		: std_logic;						-- 0x8327

	signal reg_ext_dmadir	: std_logic;						-- 0x8340
	signal reg_ext_dmaonn	: std_logic;						-- 0x8340
	signal reg_ext_dmasize	: std_logic_vector(7 downto 0);		-- 0x8341
	signal reg_ext_st0		: std_logic_vector(7 downto 0);		-- 0x8350
	signal reg_ext_st1		: std_logic_vector(7 downto 0);		-- 0x8351
	signal reg_ext_st2		: std_logic_vector(7 downto 0);		-- 0x8352
	signal reg_ext_rst_c	: std_logic_vector(7 downto 0);		-- 0x8353
	signal reg_ext_rst_h	: std_logic_vector(7 downto 0);		-- 0x8354
	signal reg_ext_rst_r	: std_logic_vector(7 downto 0);		-- 0x8355
	signal reg_ext_rst_n	: std_logic_vector(7 downto 0);		-- 0x8356
	signal reg_ext_endtrg	: std_logic;						-- 0x8357

	signal reg_start_f1	: std_logic;
	signal reg_start_f2	: std_logic;
	signal reg_start_f3	: std_logic;
	signal reg_start_r	: std_logic;

	signal reg_startlt1	: std_logic;
	signal reg_startlt2	: std_logic;

	signal reg_rominit_f1	: std_logic;
	signal reg_rominit_f2	: std_logic;
	signal reg_rominit_f3	: std_logic;
	signal reg_rominit_r	: std_logic;
	signal rominitcnt		: std_logic_vector(17 downto 0);

	signal cmtrdopen_f1	: std_logic;
	signal cmtrdopen_f2	: std_logic;
	signal cmtrdreq_f1	: std_logic;
	signal cmtrdreq_f2	: std_logic;
	signal cmtrdreq_f3	: std_logic;
	signal cmtwropen_f1	: std_logic;
	signal cmtwropen_f2	: std_logic;
	signal cmtwrreq_f1	: std_logic;
	signal cmtwrreq_f2	: std_logic;
	signal cmtwrreq_f3	: std_logic;
	signal cmtwrreq_r	: std_logic;
	signal detblk_f1	: std_logic;
	signal detblk_f2	: std_logic;

	signal cmtwr_lt	: std_logic;

	signal cmtwrdt_f1	: std_logic_vector(7 downto 0);
	signal cmtwrdt_f2	: std_logic_vector(7 downto 0);
	signal cmtwrdt_f3	: std_logic_vector(7 downto 0);

	signal reg_cmtwrst_f1	: std_logic;
	signal reg_cmtwrst_f2	: std_logic;
	signal reg_cmtwrst_f3	: std_logic;

	signal fddwrdt_f3	: std_logic_vector(7 downto 0);
	signal fddwrreq_r	: std_logic;

	signal datao_i		: std_logic_vector(7 downto 0);
	signal sd_rdad_i	: std_logic_vector(18 downto 0);
	signal sd_rddt_i	: std_logic_vector(7 downto 0);
	signal sd_sdenb_i	: std_logic;
	signal sd_sdwrn_i	: std_logic;
	signal sd_cgenb_i	: std_logic;
	signal sd_cgwrn_i	: std_logic;
	signal sdadd_i		: std_logic_vector(31 downto 0);

	signal rdn_f1	: std_logic;
	signal rdn_f2	: std_logic;
	signal rdn_f3	: std_logic;
	signal wrn_f1	: std_logic;
	signal wrn_f2	: std_logic;
	signal wrn_f3	: std_logic;
	signal add_f1	: std_logic_vector(9 downto 0);
	signal add_f2	: std_logic_vector(9 downto 0);
	signal datai_f1	: std_logic_vector(7 downto 0);
	signal datai_f2	: std_logic_vector(7 downto 0);
	signal rdp		: std_logic;
	signal wrp		: std_logic;
	signal add_exp	: std_logic_vector(15 downto 0);

	signal statecnt	: std_logic_vector(7 downto 0);


begin

	U_SDREAD_CMDCNT : SDREAD_CMDCNT
	port map (
		SD_DAT0		=> SD_DAT0,
		SD_WP		=> SD_WP,
		CMD_START	=> reg_startlt2,
		CMD_NO		=> reg_cmdno,
		SDADD		=> sdadd_i,
		SDCNTENB	=> reg_inuse,
		OUTDT		=> buf_q,
		CLK			=> CLK50M,
		RSTN		=> RSTN,
		STATEOUT	=> statecnt,
		INDT		=> indt_i,
		INDTENB		=> indtenb_i,
		OUTDTENB	=> outdtenb_i,
		INDTLT2		=> indtlt2_i,
		CMD_END		=> cmd_end_i,
		IDLEDET		=> idledet_i,
		ERRDET		=> errdet_i,
		SD_CMD		=> SD_CMD,
		SD_DAT		=> SD_DAT,
		SD_CLK		=> SD_CLK
	);

	sdadd_i <= reg_sdadd(22 downto 0) & "000000000";

	U_SPRAM_1024W8B : SPRAM_1024W8B
	port map (
		address	=> bufc_add,
		data	=> bufc_dat,
		wren	=> bufc_wr,
		clock	=> CLK50M,
		aclr	=> aclr,
		q		=> bufc_q
	);

	U_SPRAM_2048W8B : SPRAM_2048W8B
	port map (
		address	=> buff_add,
		data	=> buff_dat,
		wren	=> buff_wr,
		clock	=> CLK50M,
		aclr	=> aclr,
		q		=> buff_q
	);

	aclr     <= not RSTN;

	buf_add  <=	sd_wrcnt                  when (reg_bufsel = "0000") else
				add_f2(8 downto 0)        when (reg_bufsel = "0001") else
				fifo_cmtrdadd(8 downto 0) when (reg_bufsel = "0100") else
				fifo_cmtrdadd(8 downto 0) when (reg_bufsel = "0101") else
				sd_rdcnt                  when (reg_bufsel = "1000") else
				add_f2(8 downto 0)        when (reg_bufsel = "1001") else
				fifo_cmtwradd(8 downto 0) when (reg_bufsel = "1100") else
				(others => '0');

	bufc_add <= reg_bufad(0 downto 0) & buf_add;
	buff_add <= reg_bufad(1 downto 0) & buf_add;

	buf_dat  <=	indt_i     when (reg_bufsel = "1000") else
				datai_f2   when (reg_bufsel = "1001") else
				cmtwrdt_f3 when (reg_bufsel = "1100") else
				fddwrdt_f3 when (reg_bufsel = "1110") else
				X"00";

	bufc_dat <= buf_dat;
	buff_dat <= buf_dat;

	buf_wr   <=	sdrdenb    when (reg_bufsel = "1000") else
				wrp        when (reg_bufsel = "1001" and add_f2(9) = '0') else
				cmtwrreq_r when (reg_bufsel = "1100") else
				fddwrreq_r when (reg_bufsel = "1110") else
				'0';

	bufc_wr  <= buf_wr when (reg_bufad(2) = '0') else '0';
	buff_wr  <= buf_wr when (reg_bufad(2) = '1') else '0';

	buf_q    <= bufc_q when (reg_bufad(2) = '0') else buff_q;


	MONOUT(28)           <= '0';
	MONOUT(27)           <= reg_cmtwrok;
	MONOUT(26)           <= reg_cmtwrld;
	MONOUT(25)           <= reg_cmtwrst;
	MONOUT(24)           <= cmtwrreq_r;
--	MONOUT(23 downto 16) <= cmtwrdt_f3;
--	MONOUT(15)           <= reg_cmtwrfull;
--	MONOUT(14)           <= sdrdenb;
--	MONOUT(13)           <= wrp;
--	MONOUT(12 downto  9) <= reg_bufsel;

	MONOUT(23 downto 22) <= "00";
	MONOUT(21 downto 16) <= reg_cmdno;
	MONOUT(15 downto  8) <= indt_i;
	MONOUT( 7 downto  0) <= statecnt;

	fddwrdt_f3    <= X"00";
	fddwrreq_r    <= '0';


-- CPU I/F
-- data latch
	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			rdn_f1   <= '1';
			rdn_f2   <= '1';
			rdn_f3   <= '1';
			wrn_f1   <= '1';
			wrn_f2   <= '1';
			wrn_f3   <= '1';
			add_f1   <= (others => '0');
			add_f2   <= (others => '0');
			datai_f1 <= (others => '0');
			datai_f2 <= (others => '0');
		elsif (CLK50M'event and CLK50M = '1') then
			rdn_f1   <= RDN;
			rdn_f2   <= rdn_f1;
			rdn_f3   <= rdn_f2;
			wrn_f1   <= WRN;
			wrn_f2   <= wrn_f1;
			wrn_f3   <= wrn_f2;
			add_f1   <= ADD;
			add_f2   <= add_f1;
			datai_f1 <= DATAI;
			datai_f2 <= datai_f1;
		end if;
	end process;

	rdp <= '1' when (rdn_f2 = '0' and rdn_f3 = '1') else '0';
	wrp <= '1' when (wrn_f2 = '0' and wrn_f3 = '1') else '0';

	add_exp <= "100000" & add_f2;

-- register
	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			reg_start    <= '0';
			reg_inuse    <= '0';
			reg_sderr    <= '0';
			reg_sdrddone <= '0';
			reg_rominit  <= '0';
			reg_cmdno    <= (others => '0');
			reg_sdadd    <= (others => '0');
			reg_bufad    <= (others => '0');
			reg_bufsel   <= (others => '0');
			reg_sdrdinit <= '0';
			reg_sdwrinit <= '0';
			reg_cmtlen_0 <= (others => '0');
			reg_cmtptr_0 <= (others => '0');
			reg_cl_0     <= (others => '0');
			reg_sec_0    <= (others => '0');
			reg_stcl_0   <= (others => '0');
			reg_befcl_0  <= (others => '0');
			reg_dircl_0  <= (others => '0');
			reg_dirpos_0 <= (others => '0');
			reg_fatnew_0 <= (others => '0');
			reg_cmtrdst  <= '0';
			reg_cmtrdinit<= '0';
			reg_cmtrdld  <= '0';
			reg_cmtlen_1 <= (others => '0');
			reg_cmtptr_1 <= (others => '0');
			reg_cl_1     <= (others => '0');
			reg_sec_1    <= (others => '0');
			reg_stcl_1   <= (others => '0');
			reg_befcl_1  <= (others => '0');
			reg_dircl_1  <= (others => '0');
			reg_dirpos_1 <= (others => '0');
			reg_fatnew_1 <= (others => '0');
			reg_cmtwrst  <= '0';
			reg_cmtwrld  <= '0';
			reg_cmtwrok  <= '0';
			reg_cmtlen_2 <= (others => '0');
			reg_cmtptr_2 <= (others => '0');
			reg_cl_2     <= (others => '0');
			reg_sec_2    <= (others => '0');
			reg_stcl_2   <= (others => '0');
			reg_befcl_2  <= (others => '0');
			reg_dircl_2  <= (others => '0');
			reg_dirpos_2 <= (others => '0');
			reg_fatnew_2 <= (others => '0');
			reg_floppy_2 <= (others => '0');
			reg_fdd_2    <= (others => '0');
			reg_cmtlen_3 <= (others => '0');
			reg_cmtptr_3 <= (others => '0');
			reg_cl_3     <= (others => '0');
			reg_sec_3    <= (others => '0');
			reg_stcl_3   <= (others => '0');
			reg_befcl_3  <= (others => '0');
			reg_dircl_3  <= (others => '0');
			reg_dirpos_3 <= (others => '0');
			reg_fatnew_3 <= (others => '0');
			reg_floppy_3 <= (others => '0');
			reg_fdd_3    <= (others => '0');
			reg_cmtlen_4 <= (others => '0');
			reg_cmtptr_4 <= (others => '0');
			reg_cl_4     <= (others => '0');
			reg_sec_4    <= (others => '0');
			reg_stcl_4   <= (others => '0');
			reg_befcl_4  <= (others => '0');
			reg_dircl_4  <= (others => '0');
			reg_dirpos_4 <= (others => '0');
			reg_fatnew_4 <= (others => '0');
			reg_floppy_4 <= (others => '0');
			reg_fdd_4    <= (others => '0');
			reg_cmtlen_5 <= (others => '0');
			reg_cmtptr_5 <= (others => '0');
			reg_cl_5     <= (others => '0');
			reg_sec_5    <= (others => '0');
			reg_stcl_5   <= (others => '0');
			reg_befcl_5  <= (others => '0');
			reg_dircl_5  <= (others => '0');
			reg_dirpos_5 <= (others => '0');
			reg_fatnew_5 <= (others => '0');
			reg_floppy_5 <= (others => '0');
			reg_fdd_5    <= (others => '0');
			reg_st0      <= (others => '0');
			reg_st1      <= (others => '0');
			reg_st2      <= (others => '0');
			reg_rst_c    <= (others => '0');
			reg_rst_h    <= (others => '0');
			reg_rst_r    <= (others => '0');
			reg_rst_n    <= (others => '0');
			reg_endtrg   <= '0';
			reg_ext_dmadir	<= '1';
			reg_ext_dmaonn	<= '1';
			reg_ext_dmasize <= (others => '0');
			reg_ext_st0     <= (others => '0');
			reg_ext_st1     <= (others => '0');
			reg_ext_st2     <= (others => '0');
			reg_ext_rst_c   <= (others => '0');
			reg_ext_rst_h   <= (others => '0');
			reg_ext_rst_r   <= (others => '0');
			reg_ext_rst_n   <= (others => '0');
			reg_ext_endtrg  <= '0';

		elsif (CLK50M'event and CLK50M = '1') then
			if (wrp = '1') then
				case add_exp is
					when X"8200" => reg_start                  <= datai_f2(0);
					when X"8201" =>	reg_inuse                  <= datai_f2(0);
									reg_sderr                  <= datai_f2(1);
					when X"8202" => reg_sdrddone               <= datai_f2(0);
					when X"8203" => reg_rominit                <= datai_f2(0);
					when X"8205" => reg_cmdno                  <= datai_f2(5 downto 0);
					when X"8206" => reg_sdadd( 7 downto  0)    <= datai_f2;
					when X"8207" => reg_sdadd(15 downto  8)    <= datai_f2;
					when X"8208" => reg_sdadd(23 downto 16)    <= datai_f2;
					when X"8209" => reg_sdadd(31 downto 24)    <= datai_f2;
					when X"8210" => reg_bufad                  <= datai_f2(2 downto 0);
					when X"8211" => reg_bufsel                 <= datai_f2(3 downto 0);
					when X"8213" => reg_sdrdinit               <= datai_f2(0);
					when X"8214" => reg_sdwrinit               <= datai_f2(0);
					when X"8220" => reg_cmtlen_0( 7 downto  0) <= datai_f2;
					when X"8221" => reg_cmtlen_0(15 downto  8) <= datai_f2;
					when X"8222" => reg_cmtlen_0(23 downto 16) <= datai_f2;
					when X"8223" => reg_cmtlen_0(31 downto 24) <= datai_f2;
					when X"8224" => reg_cmtptr_0( 7 downto  0) <= datai_f2;
					when X"8225" => reg_cmtptr_0(15 downto  8) <= datai_f2;
					when X"8226" => reg_cmtptr_0(23 downto 16) <= datai_f2;
					when X"8227" => reg_cmtptr_0(31 downto 24) <= datai_f2;
					when X"8228" => reg_cl_0( 7 downto  0)     <= datai_f2;
					when X"8229" => reg_cl_0(15 downto  8)     <= datai_f2;
					when X"822A" => reg_sec_0                  <= datai_f2;
					when X"822B" => reg_stcl_0( 7 downto  0)   <= datai_f2;
					when X"822C" => reg_stcl_0(15 downto  8)   <= datai_f2;
					when X"822D" => reg_befcl_0( 7 downto  0)  <= datai_f2;
					when X"822E" => reg_befcl_0(15 downto  8)  <= datai_f2;
					when X"822F" => reg_dircl_0( 7 downto  0)  <= datai_f2;
					when X"8230" => reg_dircl_0(15 downto  8)  <= datai_f2;
					when X"8231" => reg_dirpos_0( 7 downto  0) <= datai_f2;
					when X"8232" => reg_dirpos_0(15 downto  8) <= datai_f2;
					when X"8233" => reg_fatnew_0               <= datai_f2;
					when X"8234" => reg_cmtrdst                <= datai_f2(0);
									reg_cmtrdinit              <= datai_f2(1);
									reg_cmtrdld                <= datai_f2(2);
					when X"8240" => reg_cmtlen_1( 7 downto  0) <= datai_f2;
					when X"8241" => reg_cmtlen_1(15 downto  8) <= datai_f2;
					when X"8242" => reg_cmtlen_1(23 downto 16) <= datai_f2;
					when X"8243" => reg_cmtlen_1(31 downto 24) <= datai_f2;
					when X"8244" => reg_cmtptr_1( 7 downto  0) <= datai_f2;
					when X"8245" => reg_cmtptr_1(15 downto  8) <= datai_f2;
					when X"8246" => reg_cmtptr_1(23 downto 16) <= datai_f2;
					when X"8247" => reg_cmtptr_1(31 downto 24) <= datai_f2;
					when X"8248" => reg_cl_1( 7 downto  0)     <= datai_f2;
					when X"8249" => reg_cl_1(15 downto  8)     <= datai_f2;
					when X"824A" => reg_sec_1                  <= datai_f2;
					when X"824B" => reg_stcl_1( 7 downto  0)   <= datai_f2;
					when X"824C" => reg_stcl_1(15 downto  8)   <= datai_f2;
					when X"824D" => reg_befcl_1( 7 downto  0)  <= datai_f2;
					when X"824E" => reg_befcl_1(15 downto  8)  <= datai_f2;
					when X"824F" => reg_dircl_1( 7 downto  0)  <= datai_f2;
					when X"8250" => reg_dircl_1(15 downto  8)  <= datai_f2;
					when X"8251" => reg_dirpos_1( 7 downto 0)  <= datai_f2;
					when X"8252" => reg_dirpos_1(15 downto 8)  <= datai_f2;
					when X"8253" => reg_fatnew_1               <= datai_f2;
					when X"8254" => reg_cmtwrst                <= datai_f2(0);
									reg_cmtwrld                <= datai_f2(1);
									reg_cmtwrok                <= datai_f2(2);
					when X"8260" => reg_cmtlen_2( 7 downto  0) <= datai_f2;
					when X"8261" => reg_cmtlen_2(15 downto  8) <= datai_f2;
					when X"8262" => reg_cmtlen_2(23 downto 16) <= datai_f2;
					when X"8263" => reg_cmtlen_2(31 downto 24) <= datai_f2;
					when X"8264" => reg_cmtptr_2( 7 downto  0) <= datai_f2;
					when X"8265" => reg_cmtptr_2(15 downto  8) <= datai_f2;
					when X"8266" => reg_cmtptr_2(23 downto 16) <= datai_f2;
					when X"8267" => reg_cmtptr_2(31 downto 24) <= datai_f2;
					when X"8268" => reg_cl_2( 7 downto  0)     <= datai_f2;
					when X"8269" => reg_cl_2(15 downto  8)     <= datai_f2;
					when X"826A" => reg_sec_2                  <= datai_f2;
					when X"826B" => reg_stcl_2( 7 downto  0)   <= datai_f2;
					when X"826C" => reg_stcl_2(15 downto  8)   <= datai_f2;
					when X"826D" => reg_befcl_2( 7 downto  0)  <= datai_f2;
					when X"826E" => reg_befcl_2(15 downto  8)  <= datai_f2;
					when X"826F" => reg_dircl_2( 7 downto  0)  <= datai_f2;
					when X"8270" => reg_dircl_2(15 downto  8)  <= datai_f2;
					when X"8271" => reg_dirpos_2( 7 downto  0) <= datai_f2;
					when X"8272" => reg_dirpos_2(15 downto  8) <= datai_f2;
					when X"8273" => reg_fatnew_2               <= datai_f2;
					when X"8274" => reg_floppy_2( 3 downto  0) <= datai_f2(3 downto 0);
					when X"827F" => reg_fdd_2( 2 downto  0)    <= datai_f2(2 downto 0);
					when X"8280" => reg_cmtlen_3( 7 downto  0) <= datai_f2;
					when X"8281" => reg_cmtlen_3(15 downto  8) <= datai_f2;
					when X"8282" => reg_cmtlen_3(23 downto 16) <= datai_f2;
					when X"8283" => reg_cmtlen_3(31 downto 24) <= datai_f2;
					when X"8284" => reg_cmtptr_3( 7 downto  0) <= datai_f2;
					when X"8285" => reg_cmtptr_3(15 downto  8) <= datai_f2;
					when X"8286" => reg_cmtptr_3(23 downto 16) <= datai_f2;
					when X"8287" => reg_cmtptr_3(31 downto 24) <= datai_f2;
					when X"8288" => reg_cl_3( 7 downto  0)     <= datai_f2;
					when X"8289" => reg_cl_3(15 downto  8)     <= datai_f2;
					when X"828A" => reg_sec_3                  <= datai_f2;
					when X"828B" => reg_stcl_3( 7 downto  0)   <= datai_f2;
					when X"828C" => reg_stcl_3(15 downto  8)   <= datai_f2;
					when X"828D" => reg_befcl_3( 7 downto  0)  <= datai_f2;
					when X"828E" => reg_befcl_3(15 downto  8)  <= datai_f2;
					when X"828F" => reg_dircl_3( 7 downto  0)  <= datai_f2;
					when X"8290" => reg_dircl_3(15 downto  8)  <= datai_f2;
					when X"8291" => reg_dirpos_3( 7 downto  0) <= datai_f2;
					when X"8292" => reg_dirpos_3(15 downto  8) <= datai_f2;
					when X"8293" => reg_fatnew_3               <= datai_f2;
					when X"8294" => reg_floppy_3( 3 downto  0) <= datai_f2(3 downto 0);
					when X"829F" => reg_fdd_3( 2 downto  0)    <= datai_f2(2 downto 0);
					when X"82A0" => reg_cmtlen_4( 7 downto  0) <= datai_f2;
					when X"82A1" => reg_cmtlen_4(15 downto  8) <= datai_f2;
					when X"82A2" => reg_cmtlen_4(23 downto 16) <= datai_f2;
					when X"82A3" => reg_cmtlen_4(31 downto 24) <= datai_f2;
					when X"82A4" => reg_cmtptr_4( 7 downto  0) <= datai_f2;
					when X"82A5" => reg_cmtptr_4(15 downto  8) <= datai_f2;
					when X"82A6" => reg_cmtptr_4(23 downto 16) <= datai_f2;
					when X"82A7" => reg_cmtptr_4(31 downto 24) <= datai_f2;
					when X"82A8" => reg_cl_4( 7 downto  0)     <= datai_f2;
					when X"82A9" => reg_cl_4(15 downto  8)     <= datai_f2;
					when X"82AA" => reg_sec_4                  <= datai_f2;
					when X"82AB" => reg_stcl_4( 7 downto  0)   <= datai_f2;
					when X"82AC" => reg_stcl_4(15 downto  8)   <= datai_f2;
					when X"82AD" => reg_befcl_4( 7 downto  0)  <= datai_f2;
					when X"82AE" => reg_befcl_4(15 downto  8)  <= datai_f2;
					when X"82AF" => reg_dircl_4( 7 downto  0)  <= datai_f2;
					when X"82B0" => reg_dircl_4(15 downto  8)  <= datai_f2;
					when X"82B1" => reg_dirpos_4( 7 downto  0) <= datai_f2;
					when X"82B2" => reg_dirpos_4(15 downto  8) <= datai_f2;
					when X"82B3" => reg_fatnew_4               <= datai_f2;
					when X"82B4" => reg_floppy_4( 3 downto  0) <= datai_f2(3 downto 0);
					when X"82BF" => reg_fdd_4( 2 downto  0)    <= datai_f2(2 downto 0);
					when X"82C0" => reg_cmtlen_5( 7 downto  0) <= datai_f2;
					when X"82C1" => reg_cmtlen_5(15 downto  8) <= datai_f2;
					when X"82C2" => reg_cmtlen_5(23 downto 16) <= datai_f2;
					when X"82C3" => reg_cmtlen_5(31 downto 24) <= datai_f2;
					when X"82C4" => reg_cmtptr_5( 7 downto  0) <= datai_f2;
					when X"82C5" => reg_cmtptr_5(15 downto  8) <= datai_f2;
					when X"82C6" => reg_cmtptr_5(23 downto 16) <= datai_f2;
					when X"82C7" => reg_cmtptr_5(31 downto 24) <= datai_f2;
					when X"82C8" => reg_cl_5( 7 downto  0)     <= datai_f2;
					when X"82C9" => reg_cl_5(15 downto  8)     <= datai_f2;
					when X"82CA" => reg_sec_5                  <= datai_f2;
					when X"82CB" => reg_stcl_5( 7 downto  0)   <= datai_f2;
					when X"82CC" => reg_stcl_5(15 downto  8)   <= datai_f2;
					when X"82CD" => reg_befcl_5( 7 downto  0)  <= datai_f2;
					when X"82CE" => reg_befcl_5(15 downto  8)  <= datai_f2;
					when X"82CF" => reg_dircl_5( 7 downto  0)  <= datai_f2;
					when X"82D0" => reg_dircl_5(15 downto  8)  <= datai_f2;
					when X"82D1" => reg_dirpos_5( 7 downto  0) <= datai_f2;
					when X"82D2" => reg_dirpos_5(15 downto  8) <= datai_f2;
					when X"82D3" => reg_fatnew_5               <= datai_f2;
					when X"82D4" => reg_floppy_5( 3 downto  0) <= datai_f2(3 downto 0);
					when X"82DF" => reg_fdd_5( 2 downto  0)    <= datai_f2(2 downto 0);
					when X"8320" => reg_st0                    <= datai_f2;
					when X"8321" => reg_st1                    <= datai_f2;
					when X"8322" => reg_st2                    <= datai_f2;
					when X"8323" => reg_rst_c                  <= datai_f2;
					when X"8324" => reg_rst_h                  <= datai_f2;
					when X"8325" => reg_rst_r                  <= datai_f2;
					when X"8326" => reg_rst_n                  <= datai_f2;
					when X"8327" => reg_endtrg                 <= datai_f2(0);
					when X"8340" => reg_ext_dmadir             <= datai_f2(1);
									reg_ext_dmaonn             <= datai_f2(0);
					when X"8341" => reg_ext_dmasize            <= datai_f2;
					when X"8350" => reg_ext_st0                <= datai_f2;
					when X"8351" => reg_ext_st1                <= datai_f2;
					when X"8352" => reg_ext_st2                <= datai_f2;
					when X"8353" => reg_ext_rst_c              <= datai_f2;
					when X"8354" => reg_ext_rst_h              <= datai_f2;
					when X"8355" => reg_ext_rst_r              <= datai_f2;
					when X"8356" => reg_ext_rst_n              <= datai_f2;
					when X"8357" => reg_ext_endtrg             <= datai_f2(0);
					when others  => null;
				end case;
			end if;
		end if;
	end process;

	reg_cmtwnom  <= X"0007EEEE";
	reg_cmtwacc  <= X"00011000";
	reg_cmtwst   <= X"00120000";
	reg_acccnt   <= X"03000000";

-- start_end register
	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			cmd_end_f1 <= '0';
			cmd_end_f2 <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			cmd_end_f1 <= cmd_end_i;
			cmd_end_f2 <= cmd_end_f1;
		end if;
	end process;

	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			reg_start_f1 <= '0';
			reg_start_f2 <= '0';
			reg_start_f3 <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			reg_start_f1 <= reg_start;
			reg_start_f2 <= reg_start_f1;
			reg_start_f3 <= reg_start_f2;
		end if;
	end process;

	reg_start_r <= '1' when (reg_start_f2 = '1' and reg_start_f3 = '0') else '0';

	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			reg_startlt1 <= '0';
			reg_startlt2 <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			if (reg_start_r = '1') then
				reg_startlt1 <= '1';
			elsif (indtlt2_i = '1') then
				reg_startlt1 <= '0';
			end if;

			if (indtlt2_i = '1') then
				reg_startlt2 <= reg_startlt1;
			end if;
		end if;
	end process;

	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			reg_startend <= '0';
			reg_idledet  <= '0';
			reg_errdet   <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			if (cmd_end_f1 = '1' and cmd_end_f2 = '0') then
				reg_startend <= '0';
			elsif (reg_start_r = '1') then
				reg_startend <= '1';
			end if;
			if (cmd_end_f1 = '1' and cmd_end_f2 = '0') then
				reg_idledet  <= idledet_i;
				reg_errdet   <= errdet_i;
			end if;
		end if;
	end process;

-- register read
	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			datao_i <= (others => '0');
		elsif (CLK50M'event and CLK50M = '1') then
			if (rdp = '1') then
				case add_exp is
					when X"8200" => datao_i <= "00000" & reg_errdet & reg_idledet & reg_startend;
					when X"8201" =>	datao_i <= "000000" & reg_sderr & reg_inuse;
					when X"8202" =>	datao_i <= "0000000" & reg_sdrddone;
					when X"8203" =>	datao_i <= "0000000" & reg_rominitend;
					when X"8204" => datao_i <= "0000000" & SD_WP;
					when X"8205" => datao_i <= "00" & reg_cmdno;
					when X"8206" => datao_i <= reg_sdadd( 7 downto  0);
					when X"8207" => datao_i <= reg_sdadd(15 downto  8);
					when X"8208" => datao_i <= reg_sdadd(23 downto 16);
					when X"8209" => datao_i <= reg_sdadd(31 downto 24);
					when X"8210" => datao_i <= "00000" & reg_bufad;
					when X"8211" => datao_i <= "0000" & reg_bufsel;
					when X"8212" => datao_i <= "000000" & cmtwropen_f2 & cmtrdopen_f2;
					when X"8213" => datao_i <= "000" & reg_sdrdfull & "000" & reg_sdrdinit;
					when X"8214" => datao_i <= "000" & reg_sdwrfull & "000" & reg_sdwrinit;
					when X"8220" => datao_i <= reg_cmtlen_0( 7 downto  0);
					when X"8221" => datao_i <= reg_cmtlen_0(15 downto  8);
					when X"8222" => datao_i <= reg_cmtlen_0(23 downto 16);
					when X"8223" => datao_i <= reg_cmtlen_0(31 downto 24);
					when X"8224" => datao_i <= reg_cmtptr_0( 7 downto  0);
					when X"8225" => datao_i <= reg_cmtptr_0(15 downto  8);
					when X"8226" => datao_i <= reg_cmtptr_0(23 downto 16);
					when X"8227" => datao_i <= reg_cmtptr_0(31 downto 24);
					when X"8228" => datao_i <= reg_cl_0( 7 downto  0);
					when X"8229" => datao_i <= reg_cl_0(15 downto  8);
					when X"822A" => datao_i <= reg_sec_0;
					when X"822B" => datao_i <= reg_stcl_0( 7 downto  0);
					when X"822C" => datao_i <= reg_stcl_0(15 downto  8);
					when X"822D" => datao_i <= reg_befcl_0( 7 downto  0);
					when X"822E" => datao_i <= reg_befcl_0(15 downto  8);
					when X"822F" => datao_i <= reg_dircl_0( 7 downto  0);
					when X"8230" => datao_i <= reg_dircl_0(15 downto  8);
					when X"8231" => datao_i <= reg_dirpos_0( 7 downto  0);
					when X"8232" => datao_i <= reg_dirpos_0(15 downto  8);
					when X"8233" => datao_i <= reg_fatnew_0;
					when X"8234" => datao_i <=	"00" & reg_cmtrdend & reg_cmtrdfull &
												"0" & reg_cmtrdld & reg_cmtrdinit & reg_cmtrdst;
					when X"8240" => datao_i <= reg_cmtlen_1( 7 downto  0);
					when X"8241" => datao_i <= reg_cmtlen_1(15 downto  8);
					when X"8242" => datao_i <= reg_cmtlen_1(23 downto 16);
					when X"8243" => datao_i <= reg_cmtlen_1(31 downto 24);
					when X"8244" => datao_i <= reg_cmtptr_1( 7 downto  0);
					when X"8245" => datao_i <= reg_cmtptr_1(15 downto  8);
					when X"8246" => datao_i <= reg_cmtptr_1(23 downto 16);
					when X"8247" => datao_i <= reg_cmtptr_1(31 downto 24);
					when X"8248" => datao_i <= reg_cl_1( 7 downto  0);
					when X"8249" => datao_i <= reg_cl_1(15 downto  8);
					when X"824A" => datao_i <= reg_sec_1;
					when X"824B" => datao_i <= reg_stcl_1( 7 downto  0);
					when X"824C" => datao_i <= reg_stcl_1(15 downto  8);
					when X"824D" => datao_i <= reg_befcl_1( 7 downto  0);
					when X"824E" => datao_i <= reg_befcl_1(15 downto  8);
					when X"824F" => datao_i <= reg_dircl_1( 7 downto  0);
					when X"8250" => datao_i <= reg_dircl_1(15 downto  8);
					when X"8251" => datao_i <= reg_dirpos_1( 7 downto  0);
					when X"8252" => datao_i <= reg_dirpos_1(15 downto  8);
					when X"8253" => datao_i <= reg_fatnew_1;
					when X"8254" => datao_i <=	"000" & reg_cmtwrfull &
												"0" & reg_cmtwrok & reg_cmtwrld & reg_cmtwrst;
					when X"8255" => datao_i <= fifo_cmtwradd( 7 downto  0);
					when X"8256" => datao_i <= fifo_cmtwradd(15 downto  8);
					when X"8257" => datao_i <= fifo_cmtwradd(23 downto 16);
					when X"8258" => datao_i <= fifo_cmtwradd(31 downto 24);
					when X"8260" => datao_i <= reg_cmtlen_2( 7 downto  0);
					when X"8261" => datao_i <= reg_cmtlen_2(15 downto  8);
					when X"8262" => datao_i <= reg_cmtlen_2(23 downto 16);
					when X"8263" => datao_i <= reg_cmtlen_2(31 downto 24);
					when X"8264" => datao_i <= reg_cmtptr_2( 7 downto  0);
					when X"8265" => datao_i <= reg_cmtptr_2(15 downto  8);
					when X"8266" => datao_i <= reg_cmtptr_2(23 downto 16);
					when X"8267" => datao_i <= reg_cmtptr_2(31 downto 24);
					when X"8268" => datao_i <= reg_cl_2( 7 downto  0);
					when X"8269" => datao_i <= reg_cl_2(15 downto  8);
					when X"826A" => datao_i <= reg_sec_2;
					when X"826B" => datao_i <= reg_stcl_2( 7 downto  0);
					when X"826C" => datao_i <= reg_stcl_2(15 downto  8);
					when X"826D" => datao_i <= reg_befcl_2( 7 downto  0);
					when X"826E" => datao_i <= reg_befcl_2(15 downto  8);
					when X"826F" => datao_i <= reg_dircl_2( 7 downto  0);
					when X"8270" => datao_i <= reg_dircl_2(15 downto  8);
					when X"8271" => datao_i <= reg_dirpos_2( 7 downto  0);
					when X"8272" => datao_i <= reg_dirpos_2(15 downto  8);
					when X"8273" => datao_i <= reg_fatnew_2;
					when X"8274" => datao_i <= "0000" & reg_floppy_2;
					when X"8275" => datao_i <= CNUM0;
					when X"827F" => datao_i <= "00000" & reg_fdd_2;
					when X"8280" => datao_i <= reg_cmtlen_3( 7 downto  0);
					when X"8281" => datao_i <= reg_cmtlen_3(15 downto  8);
					when X"8282" => datao_i <= reg_cmtlen_3(23 downto 16);
					when X"8283" => datao_i <= reg_cmtlen_3(31 downto 24);
					when X"8284" => datao_i <= reg_cmtptr_3( 7 downto  0);
					when X"8285" => datao_i <= reg_cmtptr_3(15 downto  8);
					when X"8286" => datao_i <= reg_cmtptr_3(23 downto 16);
					when X"8287" => datao_i <= reg_cmtptr_3(31 downto 24);
					when X"8288" => datao_i <= reg_cl_3( 7 downto  0);
					when X"8289" => datao_i <= reg_cl_3(15 downto  8);
					when X"828A" => datao_i <= reg_sec_3;
					when X"828B" => datao_i <= reg_stcl_3( 7 downto  0);
					when X"828C" => datao_i <= reg_stcl_3(15 downto  8);
					when X"828D" => datao_i <= reg_befcl_3( 7 downto  0);
					when X"828E" => datao_i <= reg_befcl_3(15 downto  8);
					when X"828F" => datao_i <= reg_dircl_3( 7 downto  0);
					when X"8290" => datao_i <= reg_dircl_3(15 downto  8);
					when X"8291" => datao_i <= reg_dirpos_3( 7 downto  0);
					when X"8292" => datao_i <= reg_dirpos_3(15 downto  8);
					when X"8293" => datao_i <= reg_fatnew_3;
					when X"8294" => datao_i <= "0000" & reg_floppy_3;
					when X"8295" => datao_i <= CNUM1;
					when X"829F" => datao_i <= "00000" & reg_fdd_3;
					when X"82A0" => datao_i <= reg_cmtlen_4( 7 downto  0);
					when X"82A1" => datao_i <= reg_cmtlen_4(15 downto  8);
					when X"82A2" => datao_i <= reg_cmtlen_4(23 downto 16);
					when X"82A3" => datao_i <= reg_cmtlen_4(31 downto 24);
					when X"82A4" => datao_i <= reg_cmtptr_4( 7 downto  0);
					when X"82A5" => datao_i <= reg_cmtptr_4(15 downto  8);
					when X"82A6" => datao_i <= reg_cmtptr_4(23 downto 16);
					when X"82A7" => datao_i <= reg_cmtptr_4(31 downto 24);
					when X"82A8" => datao_i <= reg_cl_4( 7 downto  0);
					when X"82A9" => datao_i <= reg_cl_4(15 downto  8);
					when X"82AA" => datao_i <= reg_sec_4;
					when X"82AB" => datao_i <= reg_stcl_4( 7 downto  0);
					when X"82AC" => datao_i <= reg_stcl_4(15 downto  8);
					when X"82AD" => datao_i <= reg_befcl_4( 7 downto  0);
					when X"82AE" => datao_i <= reg_befcl_4(15 downto  8);
					when X"82AF" => datao_i <= reg_dircl_4( 7 downto  0);
					when X"82B0" => datao_i <= reg_dircl_4(15 downto  8);
					when X"82B1" => datao_i <= reg_dirpos_4( 7 downto  0);
					when X"82B2" => datao_i <= reg_dirpos_4(15 downto  8);
					when X"82B3" => datao_i <= reg_fatnew_4;
					when X"82B4" => datao_i <= "0000" & reg_floppy_4;
					when X"82B5" => datao_i <= CNUM2;
					when X"82BF" => datao_i <= "00000" & reg_fdd_4;
					when X"82C0" => datao_i <= reg_cmtlen_5( 7 downto  0);
					when X"82C1" => datao_i <= reg_cmtlen_5(15 downto  8);
					when X"82C2" => datao_i <= reg_cmtlen_5(23 downto 16);
					when X"82C3" => datao_i <= reg_cmtlen_5(31 downto 24);
					when X"82C4" => datao_i <= reg_cmtptr_5( 7 downto  0);
					when X"82C5" => datao_i <= reg_cmtptr_5(15 downto  8);
					when X"82C6" => datao_i <= reg_cmtptr_5(23 downto 16);
					when X"82C7" => datao_i <= reg_cmtptr_5(31 downto 24);
					when X"82C8" => datao_i <= reg_cl_5( 7 downto  0);
					when X"82C9" => datao_i <= reg_cl_5(15 downto  8);
					when X"82CA" => datao_i <= reg_sec_5;
					when X"82CB" => datao_i <= reg_stcl_5( 7 downto  0);
					when X"82CC" => datao_i <= reg_stcl_5(15 downto  8);
					when X"82CD" => datao_i <= reg_befcl_5( 7 downto  0);
					when X"82CE" => datao_i <= reg_befcl_5(15 downto  8);
					when X"82CF" => datao_i <= reg_dircl_5( 7 downto  0);
					when X"82D0" => datao_i <= reg_dircl_5(15 downto  8);
					when X"82D1" => datao_i <= reg_dirpos_5( 7 downto  0);
					when X"82D2" => datao_i <= reg_dirpos_5(15 downto  8);
					when X"82D3" => datao_i <= reg_fatnew_5;
					when X"82D4" => datao_i <= "0000" & reg_floppy_5;
					when X"82D5" => datao_i <= CNUM3;
					when X"82DF" => datao_i <= "00000" & reg_fdd_5;
					when X"8310" => datao_i <= "00000" & FDEXTSEL & DMADIR & DMAONN;
					when X"8311" => datao_i <= "0000" & DMASIZE;
					when X"8320" => datao_i <= reg_st0;
					when X"8321" => datao_i <= reg_st1;
					when X"8322" => datao_i <= reg_st2;
					when X"8323" => datao_i <= reg_rst_c;
					when X"8324" => datao_i <= reg_rst_h;
					when X"8325" => datao_i <= reg_rst_r;
					when X"8326" => datao_i <= reg_rst_n;
					when X"8327" => datao_i <= "0000000" & reg_endtrg;
					when X"8330" => datao_i <= "0000000" & COMEND;
					when X"8331" => datao_i <= "000" & COMMAND;
					when X"8332" => datao_i <= "00000" & MT & MF & SK;
					when X"8333" => datao_i <= "000000" & DNUM;
					when X"8334" => datao_i <= "0000000" & HNUM;
					when X"8335" => datao_i <= IDRC;
					when X"8336" => datao_i <= IDRH;
					when X"8337" => datao_i <= IDRR;
					when X"8338" => datao_i <= IDRN;
					when X"8339" => datao_i <= EOT;
					when X"833A" => datao_i <= GPL;
					when X"833B" => datao_i <= DTL;
					when X"8340" => datao_i <= "000000" & reg_ext_dmadir & reg_ext_dmaonn;
					when X"8341" => datao_i <= reg_ext_dmasize;
					when X"8350" => datao_i <= reg_ext_st0;
					when X"8351" => datao_i <= reg_ext_st1;
					when X"8352" => datao_i <= reg_ext_st2;
					when X"8353" => datao_i <= reg_ext_rst_c;
					when X"8354" => datao_i <= reg_ext_rst_h;
					when X"8355" => datao_i <= reg_ext_rst_r;
					when X"8356" => datao_i <= reg_ext_rst_n;
					when X"8357" => datao_i <= "0000000" & reg_ext_endtrg;
					when X"8360" => datao_i <= "0000000" & EXT_COMEND;
					when X"8361" => datao_i <= "000" & EXT_COMMAND;
					when X"8362" => datao_i <= "00000" & EXT_MT & EXT_MF & EXT_SK;
					when X"8363" => datao_i <= "000000" & EXT_DNUM;
					when X"8364" => datao_i <= "0000000" & EXT_HNUM;
					when X"8365" => datao_i <= EXT_IDRC;
					when X"8366" => datao_i <= EXT_IDRH;
					when X"8367" => datao_i <= EXT_IDRR;
					when X"8368" => datao_i <= EXT_IDRN;
					when X"8369" => datao_i <= EXT_EOT;
					when X"836A" => datao_i <= EXT_GPL;
					when X"836B" => datao_i <= EXT_DTL;
					when X"8370" => datao_i <= "0000000" & FDINT_EXT;

					when others  =>
						if (add_f2(9) = '0') then
							datao_i <= buf_q;
						else
							datao_i <= X"FF";
						end if;
				end case;
			end if;
		end if;
	end process;


-- SD read data
	sdrdenb <= '1' when (indtenb_i = '1' and indtlt2_i = '1') else '0';

	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			sd_rdcnt <= (others => '1');
			reg_sdrdfull <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			if (reg_sdrdinit = '1') then
				sd_rdcnt <= (others => '0');
				reg_sdrdfull <= '0';
			elsif (sdrdenb = '1') then
				if (sd_rdcnt = "111111111") then
					reg_sdrdfull <= '1';
				else
					sd_rdcnt <= sd_rdcnt + 1;
				end if;
			end if;
		end if;
	end process;

-- SD write data
	sdwrenb <= '1' when (outdtenb_i = '1' and indtlt2_i = '1') else '0';

	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			sd_wrcnt <= (others => '1');
			reg_sdwrfull <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			if (reg_sdwrinit = '1') then
				sd_wrcnt <= (others => '0');
				reg_sdwrfull <= '0';
			elsif (sdwrenb = '1') then
				if (sd_wrcnt = "111111111") then
					reg_sdwrfull <= '1';
				else
					sd_wrcnt <= sd_wrcnt + 1;
				end if;
			end if;
		end if;
	end process;


-- fifo address for CMT read
	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			fifo_sdramtmg <= (others => '0');
			fifo_cmtrdadd <= (others => '0');
			reg_cmtrdend  <= '0';
			reg_cmtrdfull <= '0';
			cmtrdycnt     <= (others => '0');
			cmtrdrdy_i    <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			if (reg_cmtrdinit = '1') then
				fifo_sdramtmg <= (others => '0');
				fifo_cmtrdadd <= (others => '0');
				reg_cmtrdend  <= '0';
				reg_cmtrdfull <= '0';
				cmtrdycnt     <= (others => '0');
				cmtrdrdy_i    <= '0';
			elsif (reg_cmtrdld = '1') then
				fifo_cmtrdadd <= reg_cmtptr_0;
			elsif (reg_cmtrdst = '1') then
				if (fifo_cmtrdadd = reg_cmtlen_0) then
					reg_cmtrdend  <= '1';
					reg_cmtrdfull <= '0';
				elsif (reg_cmtrdend = '0' and reg_cmtrdfull = '0') then

					if (reg_bufsel = "0101") then

						if (fifo_sdramtmg = "11111") then
							fifo_sdramtmg <= (others => '0');
							fifo_cmtrdadd <= fifo_cmtrdadd + 1;
							if (fifo_cmtrdadd(8 downto 0) = "111111111") then
								reg_cmtrdfull <= '1';
							end if;
						else
							fifo_sdramtmg <= fifo_sdramtmg + 1;
						end if;

					elsif (reg_bufsel = "0100") then

						if (cmtrdreq_f2 = '1' and cmtrdreq_f3 = '0') then
							cmtrdycnt     <= (others => '0');
							cmtrdrdy_i    <= '0';
							fifo_cmtrdadd <= fifo_cmtrdadd + 1;
							if (fifo_cmtrdadd(8 downto 0) = "111111111") then
								reg_cmtrdfull <= '1';
							end if;
						elsif (CMTRDACC = '0' and cmtrdycnt >= reg_cmtwst(23 downto 0) ) then
							cmtrdrdy_i    <= '1';
						elsif (CMTRDACC = '1' and CMTRDACCMD = '0' and cmtrdycnt >= reg_cmtwnom(23 downto 0) ) then
							cmtrdrdy_i    <= '1';
						elsif (CMTRDACC = '1' and CMTRDACCMD = '1' and cmtrdycnt >= reg_cmtwacc(23 downto 0) ) then
							cmtrdrdy_i    <= '1';
						else
							if (cmtrdopen_f2 = '0') then
								cmtrdycnt     <= (others => '0');
							elsif (detblk_f2 = '0') then
								cmtrdycnt     <= cmtrdycnt + 1;
							end if;
							cmtrdrdy_i    <= '0';
						end if;

					end if;

				end if;
			else
				reg_cmtrdfull <= '0';
			end if;
		end if;
	end process;


-- SDRAM write data generate
	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			reg_rominit_f1 <= '0';
			reg_rominit_f2 <= '0';
			reg_rominit_f3 <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			reg_rominit_f1 <= reg_rominit;
			reg_rominit_f2 <= reg_rominit_f1;
			reg_rominit_f3 <= reg_rominit_f2;
		end if;
	end process;

	reg_rominit_r <= '1' when (reg_rominit_f2 = '1' and reg_rominit_f3 = '0') else '0';

	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			rominitcnt <= (others => '0');
			reg_rominitend <= '0';
		elsif (CLK50M'event and CLK50M = '1') then

			if (reg_rominit_r = '1') then
				reg_rominitend <= '1';
			elsif (rominitcnt = "11" & X"FFFF") then
				reg_rominitend <= '0';
			end if;

			if (reg_rominitend = '1') then
				rominitcnt <= rominitcnt + 1;
			else
				rominitcnt <= (others => '0');
			end if;

		end if;
	end process;


	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			sd_rdad_i  <= (others => '0');
			sd_rddt_i  <= (others => '0');
			sd_sdenb_i <= '0';
			sd_sdwrn_i <= '1';
		elsif (CLK50M'event and CLK50M = '1') then
			if (reg_rominitend = '1') then

				sd_rdad_i  <= "010" & "11" & rominitcnt(17 downto 4);
				sd_rddt_i  <= X"FF";
				sd_sdenb_i <= '1';

				if (rominitcnt(3 downto 2) = "10") then
					sd_sdwrn_i <= '0';
				else
					sd_sdwrn_i <= '1';
				end if;

			else

				sd_rdad_i <= fifo_cmtrdadd(18 downto 0) + reg_cmtptr_0(18 downto 0);
				sd_rddt_i <= buf_q;

				if (reg_cmtrdst = '1' and reg_bufsel = "0101") then
					sd_sdenb_i <= '1';
					if (fifo_sdramtmg(4 downto 3) = "10") then
						sd_sdwrn_i <= '0';
					else
						sd_sdwrn_i <= '1';
					end if;
				else
					sd_sdenb_i <= '0';
					sd_sdwrn_i <= '1';
				end if;

			end if;
		end if;
	end process;


-- CMT read data
	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			cmtrddt_i <= (others => '0');
		elsif (CLK50M'event and CLK50M = '1') then
			cmtrddt_i <= buf_q;
		end if;
	end process;


-- from 8049 data latch
	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			cmtrdopen_f1 <= '0';
			cmtrdopen_f2 <= '0';
			cmtrdreq_f1  <= '0';
			cmtrdreq_f2  <= '0';
			cmtrdreq_f3  <= '0';
			cmtwropen_f1 <= '0';
			cmtwropen_f2 <= '0';
			cmtwrreq_f1  <= '0';
			cmtwrreq_f2  <= '0';
			cmtwrreq_f3  <= '0';
			cmtwrdt_f1   <= (others => '0');
			cmtwrdt_f2   <= (others => '0');
			cmtwrdt_f3   <= (others => '0');
			detblk_f1    <= '0';
			detblk_f2    <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			cmtrdopen_f1 <= CMTRDOPEN;
			cmtrdopen_f2 <= cmtrdopen_f1;
			cmtrdreq_f1  <= CMTRDREQ;
			cmtrdreq_f2  <= cmtrdreq_f1;
			cmtrdreq_f3  <= cmtrdreq_f2;
			cmtwropen_f1 <= CMTWROPEN;
			cmtwropen_f2 <= cmtwropen_f1;
			cmtwrreq_f1  <= CMTWRREQ;
			cmtwrreq_f2  <= cmtwrreq_f1;
			cmtwrreq_f3  <= cmtwrreq_f2;
			cmtwrdt_f1   <= CMTWRDT;
			cmtwrdt_f2   <= cmtwrdt_f1;
			cmtwrdt_f3   <= cmtwrdt_f2;
			detblk_f1    <= DETBLK;
			detblk_f2    <= detblk_f1;
		end if;
	end process;

-- CMT write data receive permission
	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			reg_cmtwrst_f1 <= '0';
			reg_cmtwrst_f2 <= '0';
			reg_cmtwrst_f3 <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			reg_cmtwrst_f1 <= reg_cmtwrst;
			reg_cmtwrst_f2 <= reg_cmtwrst_f1;
			reg_cmtwrst_f3 <= reg_cmtwrst_f2;
		end if;
	end process;

	cmtwrreq_r <= '1' when (cmtwrreq_f2 = '1' and cmtwrreq_f3 = '0') else '0';

	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			cmtwrrdy_i    <= '0';
			reg_cmtwrfull <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			if (reg_cmtwrok = '0') then
				cmtwrrdy_i    <= '1';
				reg_cmtwrfull <= '0';
			elsif (cmtwropen_f2 = '0') then
				cmtwrrdy_i    <= '0';
				reg_cmtwrfull <= '0';
			elsif (cmtwrreq_r = '1') then
				if (fifo_cmtwradd(8 downto 0) = "111111111") then
					cmtwrrdy_i    <= '0';
					reg_cmtwrfull <= '1';
				else
					cmtwrrdy_i    <= '1';
					reg_cmtwrfull <= '0';
				end if;
			elsif (reg_cmtwrst_f2 = '1' and reg_cmtwrst_f3 = '0') then
				cmtwrrdy_i    <= '1';
				reg_cmtwrfull <= '0';
			end if;
		end if;
	end process;

	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			fifo_cmtwradd <= (others => '0');
		elsif (CLK50M'event and CLK50M = '1') then
			if (reg_cmtwrok = '0') then
				fifo_cmtwradd <= (others => '0');
			elsif (reg_cmtwrld = '1') then
				fifo_cmtwradd <= reg_cmtlen_1;
			elsif (cmtwrreq_r = '1') then
				fifo_cmtwradd <= fifo_cmtwradd + 1;
			end if;
		end if;
	end process;


	process (CLK50M,RSTN)
	begin
		if (RSTN = '0') then
			cmtwr_lt <= '0';
		elsif (CLK50M'event and CLK50M = '1') then
			if (reg_inuse = '1') then
				if (cmtwropen_f2 = '1') then
					cmtwr_lt <= '1';
				end if;
			else
				cmtwr_lt <= '0';
			end if;
		end if;
	end process;


	DATAO     <= datao_i;

	FDD0      <= reg_fdd_2;
	FDD1      <= reg_fdd_3;
	FDD2      <= reg_fdd_4;
	FDD3      <= reg_fdd_5;

	FLOPPY0   <= reg_floppy_2;
	FLOPPY1   <= reg_floppy_3;
	FLOPPY2   <= reg_floppy_4;
	FLOPPY3   <= reg_floppy_5;

	ST0       <= reg_st0;
	ST1       <= reg_st1;
	ST2       <= reg_st2;
	RST_C     <= reg_rst_c;
	RST_H     <= reg_rst_h;
	RST_R     <= reg_rst_r;
	RST_N     <= reg_rst_n;
	ENDTRG    <= reg_endtrg;

	EXT_ST0     <= reg_ext_st0;
	EXT_ST1     <= reg_ext_st1;
	EXT_ST2     <= reg_ext_st2;
	EXT_RST_C   <= reg_ext_rst_c;
	EXT_RST_H   <= reg_ext_rst_h;
	EXT_RST_R   <= reg_ext_rst_r;
	EXT_RST_N   <= reg_ext_rst_n;
	EXT_ENDTRG  <= reg_ext_endtrg;

	EXT_DMADIR  <= reg_ext_dmadir;
	EXT_DMAONN  <= reg_ext_dmaonn;
	EXT_DMASIZE <= reg_ext_dmasize;

	SD_RDAD   <= sd_rdad_i;
	SD_RDDT   <= sd_rddt_i;
	SD_SDENB  <= sd_sdenb_i;
	SD_SDWRN  <= sd_sdwrn_i;

	SD_RDDONE <= reg_sdrddone;
	CMTRDRDY  <= cmtrdrdy_i;
	CMTWRRDY  <= cmtwrrdy_i;
	CMTRDDT   <= cmtrddt_i;

	SD_ERR    <= reg_sderr;
	SD_OUTENB <= reg_inuse;

	ACCCNT    <= reg_acccnt;

	CMTCNT <=
				(FDCCNUM    & FDCSNUM)     when (FDCACT = '1') else
				(FDCEXTCNUM & FDCEXTSNUM)  when (FDCEXTACT = '1') else
				fifo_cmtwradd(15 downto 0) when (cmtwropen_f2 = '1' or cmtwr_lt = '1') else
				fifo_cmtrdadd(15 downto 0);


end RTL;
