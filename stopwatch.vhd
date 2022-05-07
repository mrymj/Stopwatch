
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity montre is

-------------------------------------------------------------------------------
--                             Port Declarations                             --
-------------------------------------------------------------------------------
port (
	-- Inputs
	CLOCK_50            : in std_logic;
	CLOCK_27            : in std_logic;
	KEY                 : in std_logic_vector (3 downto 0);
	SW                  : in std_logic_vector (9 downto 0);

	--  Communication
	UART_RXD            : in std_logic;

	--  Audio
	AUD_ADCDAT			: in std_logic;

	-- Bidirectionals
	GPIO_0              : inout std_logic_vector (36 downto 0);
	GPIO_1              : inout std_logic_vector (36 downto 0);

	--  Memory (SRAM)
	SRAM_DQ             : inout std_logic_vector (15 downto 0);
	
	--  Memory (SDRAM)
	DRAM_DQ				: inout std_logic_vector (15 downto 0);

	--  PS2 Port
	PS2_CLK				: inout std_logic;
	PS2_DAT				: inout std_logic;
	
	--  Audio
	AUD_BCLK			: inout std_logic;
	AUD_ADCLRCK			: inout std_logic;
	AUD_DACLRCK			: inout std_logic;

	--  AV Config
	I2C_SDAT			: inout std_logic;
	
	-- Outputs
	TD_RESET			: out std_logic;

	--  Simple
	LEDG                : out std_logic_vector (7 downto 0);
	LEDR                : out std_logic_vector (9 downto 0);
	HEX0                : out std_logic_vector (6 downto 0);
	HEX1                : out std_logic_vector (6 downto 0);
	HEX2                : out std_logic_vector (6 downto 0);
	HEX3                : out std_logic_vector (6 downto 0);

	--  Memory (SRAM)
	SRAM_ADDR           : out std_logic_vector (17 downto 0);
	SRAM_CE_N           : out std_logic;
	SRAM_WE_N           : out std_logic;
	SRAM_OE_N           : out std_logic;
	SRAM_UB_N           : out std_logic;
	SRAM_LB_N           : out std_logic;

	--  Communication
	UART_TXD            : out std_logic;
	
	-- Memory (SDRAM)
	DRAM_ADDR			: out std_logic_vector (11 downto 0);
	DRAM_BA_1			: buffer std_logic;
	DRAM_BA_0			: buffer std_logic;
	DRAM_CAS_N			: out std_logic;
	DRAM_RAS_N			: out std_logic;
	DRAM_CLK			: out std_logic;
	DRAM_CKE			: out std_logic;
	DRAM_CS_N			: out std_logic;
	DRAM_WE_N			: out std_logic;
	DRAM_UDQM			: buffer std_logic;
	DRAM_LDQM			: buffer std_logic;

	--  Audio
	AUD_XCK				: out std_logic;
	AUD_DACDAT			: out std_logic;
	
	--  VGA
	VGA_CLK				: out std_logic;
	VGA_HS				: out std_logic;
	VGA_VS				: out std_logic;
	VGA_R				: out std_logic_vector (3 downto 0);
	VGA_G				: out std_logic_vector (3 downto 0);
	VGA_B				: out std_logic_vector (3 downto 0);
	
	--  AV Config
	I2C_SCLK			: out std_logic
	);
end montre;


architecture sys of montre is

-------------------------------------------------------------------------------
--                           Subentity Declarations                          --
-------------------------------------------------------------------------------
    component sys_montre is
        port (
            clk_clk                : in    std_logic                     := 'X';             -- clk
            reset_reset_n          : in    std_logic                     := 'X';             -- reset_n
            pll_sdram_clk_clk      : out   std_logic;                                        -- clk
            sdram_controller_addr  : out   std_logic_vector(11 downto 0);                    -- addr
            sdram_controller_ba    : out   std_logic_vector(1 downto 0);                     -- ba
            sdram_controller_cas_n : out   std_logic;                                        -- cas_n
            sdram_controller_cke   : out   std_logic;                                        -- cke
            sdram_controller_cs_n  : out   std_logic;                                        -- cs_n
            sdram_controller_dq    : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
            sdram_controller_dqm   : out   std_logic_vector(1 downto 0);                     -- dqm
            sdram_controller_ras_n : out   std_logic;                                        -- ras_n
            sdram_controller_we_n  : out   std_logic;                                        -- we_n
            key_export             : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
            ledg_export            : out   std_logic_vector(7 downto 0);                      -- export
            sw_export              : in    std_logic_vector(9 downto 0)  := (others => 'X'); -- export
            ledr_export            : out   std_logic_vector(9 downto 0);                     -- export
            hex_HEX0               : out   std_logic_vector(6 downto 0);                     -- HEX0
            hex_HEX1               : out   std_logic_vector(6 downto 0);                     -- HEX1
            hex_HEX2               : out   std_logic_vector(6 downto 0);                     -- HEX2
            hex_HEX3               : out   std_logic_vector(6 downto 0)                      -- HEX3
        );
    end component sys_montre;
signal BA : std_logic_vector(1 downto 0);
signal DQM : std_logic_vector(1 downto 0);
begin
    DRAM_BA_0 <= BA(0);
	 DRAM_BA_1 <= BA(1); 
	 
	 DRAM_LDQM <= DQM(0);
	 DRAM_UDQM <= DQM(1);
    u0 : component sys_montre
        port map (
            clk_clk                => CLOCK_50,                --              clk.clk
            reset_reset_n          => KEY(0),          --            reset.reset_n
            pll_sdram_clk_clk      => DRAM_CLK,      --    pll_sdram_clk.clk
            sdram_controller_addr  => DRAM_ADDR,  -- sdram_controller.addr
            sdram_controller_ba    => BA,    --                 .ba
            sdram_controller_cas_n => DRAM_CAS_N, --                 .cas_n
            sdram_controller_cke   => DRAM_CKE,   --                 .cke
            sdram_controller_cs_n  => DRAM_CS_N,  --                 .cs_n
            sdram_controller_dq    => DRAM_DQ,    --                 .dq
            sdram_controller_dqm   => DQM,   --                 .dqm
            sdram_controller_ras_n => DRAM_RAS_N, --                 .ras_n
            sdram_controller_we_n  => DRAM_WE_N,  --                 .we_n
            key_export             => KEY(3 downto 1)&'1',             --              key.export
            ledg_export            => LEDG,           --             ledg.export
				sw_export              => SW,              --               sw.export
            ledr_export            => LEDR,            --             ledr.export
            hex_HEX0               => HEX0,               --              hex.HEX0
            hex_HEX1               => HEX1,               --                 .HEX1
            hex_HEX2               => HEX2,               --                 .HEX2
            hex_HEX3               => HEX3                --                 .HEX3
        );
end sys;

