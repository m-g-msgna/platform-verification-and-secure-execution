library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.NUMERIC_STD.ALL;

entity testbench is
end testbench;
 
architecture Behavioral of testbench is

constant zero_128 : bit_vector := X"00000000000000000000000000000000";

component CAM_256_BYTE
	generic(INIT_00 : bit_vector := zero_128;
		INIT_01 : bit_vector := zero_128;
		INIT_02 : bit_vector := zero_128;
		INIT_03 : bit_vector := zero_128;
		INIT_04 : bit_vector := zero_128;
		INIT_05 : bit_vector := zero_128;
		INIT_06 : bit_vector := zero_128;
		INIT_07 : bit_vector := zero_128;
		INIT_08 : bit_vector := zero_128;
		INIT_09 : bit_vector := zero_128;
		INIT_0A : bit_vector := zero_128;
		INIT_0B : bit_vector := zero_128;
		INIT_0C : bit_vector := zero_128;
		INIT_0D : bit_vector := zero_128;
		INIT_0E : bit_vector := zero_128;
		INIT_0F : bit_vector := zero_128);

	port(	CLK      : in std_logic;
		CAM_EN   : in std_logic;
		WR_SR    : in std_logic;
		ADDR_IN  : in std_logic_vector (7 downto 0);
		DATA_IN  : in std_logic_vector (7 downto 0);
		MATCH    : out std_logic;
		ADDR_OUT : out std_logic_vector(7 downto 0));
end component;

signal IN_CLK		: std_logic;
signal IN_CAM_EN	: std_logic;
signal IN_WR_SR		: std_logic;
signal IN_ADDRESS 	: std_logic_vector(7 downto 0);
signal IN_DATA		: std_logic_vector(7 downto 0);

signal OUT_MATCH	: std_logic;
signal OUT_ADDRESS	: std_logic_vector(7 downto 0);

constant CLK_Period	: time := 10 ns;

-- 00 - FF permituated data apart from 0x16 which is missing intentionally.
type data_array is array (0 to 255) of std_logic_vector(7 downto 0);
constant  write_data  : data_array := (
	x"63", x"7C", x"77", x"7B", x"F2", x"6B", x"6F", x"C5",
	x"30", x"01", x"67", x"2B", x"FE", x"D7", x"AB", x"76",
	x"CA", x"82", x"C9", x"7D", x"FA", x"59", x"47", x"F0", 
	x"AD", x"D4", x"A2", x"AF", x"9C", x"A4", x"72", x"C0",
	x"B7", x"FD", x"93", x"26", x"36", x"3F", x"F7", x"CC", 
	x"34", x"A5", x"E5", x"F1", x"71", x"D8", x"31", x"15",
	x"04", x"C7", x"23", x"C3", x"18", x"96", x"05", x"9A", 
	x"07", x"12", x"80", x"E2", x"EB", x"27", x"B2", x"75",
	x"09", x"83", x"2C", x"1A", x"1B", x"6E", x"5A", x"A0", 
	x"52", x"3B", x"D6", x"B3", x"29", x"E3", x"2F", x"84",
	x"53", x"D1", x"00", x"ED", x"20", x"FC", x"B1", x"5B", 
	x"6A", x"CB", x"BE", x"39", x"4A", x"4C", x"58", x"CF",
	x"D0", x"EF", x"AA", x"FB", x"43", x"4D", x"33", x"85", 
	x"45", x"F9", x"02", x"7F", x"50", x"3C", x"9F", x"A8",
	x"51", x"A3", x"40", x"8F", x"92", x"9D", x"38", x"F5", 
	x"BC", x"B6", x"DA", x"21", x"10", x"FF", x"F3", x"D2",
	x"CD", x"0C", x"13", x"EC", x"5F", x"97", x"44", x"17", 
	x"C4", x"A7", x"7E", x"3D", x"64", x"5D", x"19", x"73",
	x"60", x"81", x"4F", x"DC", x"22", x"2A", x"90", x"88", 
	x"46", x"EE", x"B8", x"14", x"DE", x"5E", x"0B", x"DB",
	x"E0", x"32", x"3A", x"0A", x"49", x"06", x"24", x"5C", 
	x"C2", x"D3", x"AC", x"62", x"91", x"95", x"E4", x"79",
	x"E7", x"C8", x"37", x"6D", x"8D", x"D5", x"4E", x"A9", 
	x"6C", x"56", x"F4", x"EA", x"65", x"7A", x"AE", x"08",
	x"BA", x"78", x"25", x"2E", x"1C", x"A6", x"B4", x"C6", 
	x"E8", x"DD", x"74", x"1F", x"4B", x"BD", x"8B", x"8A",
	x"70", x"3E", x"B5", x"66", x"48", x"03", x"F6", x"0E", 
	x"61", x"35", x"57", x"B9", x"86", x"C1", x"1D", x"9E",
	x"E1", x"F8", x"98", x"11", x"69", x"D9", x"8E", x"94", 
	x"9B", x"1E", x"87", x"E9", x"CE", x"55", x"28", x"DF",
	x"8C", x"A1", x"89", x"0D", x"BF", x"E6", x"42", x"68", 
	x"41", x"99", x"2D", x"0F", x"B0", x"54", x"BB", x"00");

begin
	CAM: CAM_256_BYTE
	generic map ( INIT_00 => zero_128,
		      INIT_01 => zero_128,
		      INIT_02 => zero_128,
		      INIT_03 => zero_128,
		      INIT_04 => zero_128,
		      INIT_05 => zero_128,
		      INIT_06 => zero_128,
		      INIT_07 => zero_128,
		      INIT_08 => zero_128,
		      INIT_09 => zero_128,
		      INIT_0A => zero_128,
		      INIT_0B => zero_128,
		      INIT_0C => zero_128,
		      INIT_0D => zero_128,
		      INIT_0E => zero_128,
		      INIT_0F => zero_128)

	port map(	CLK	  => IN_CLK,
			CAM_EN	  => IN_CAM_EN,
			WR_SR	  => IN_WR_SR,
			ADDR_IN	  => IN_ADDRESS,
			DATA_IN   => IN_DATA,
			MATCH     => OUT_MATCH,
			ADDR_OUT  => OUT_ADDRESS);

	-- Clock process for T_CLK (clock period is 10ns)
	process
	begin
		clock_loop : loop
			IN_CLK <= transport '0';
			wait for CLK_Period/2;

			IN_CLK <= transport '1';
			wait for CLK_Period/2;
		end loop clock_loop;
	end process;

	-- Stimulus process
	proc_cam: process

	begin

		-- Write data into the memory first
		wait for CLK_Period * 3;
		IN_CAM_EN <= '0';    -- Enable the CAM.
		IN_WR_SR <= '0';     -- Write memory enable
		
		-- Write memory until it is full
		write_loop : for write_add in 0 to 255 loop
			IN_ADDRESS <= conv_std_logic_vector(write_add, 8);
			IN_DATA <= write_data(write_add);
			wait for CLK_Period;
		end loop write_loop; -- Finish writting to the memory.

		-- Search mode.
		IN_WR_SR <= '1'; 

		IN_DATA <= X"BF";
		wait for CLK_Period;
		IN_DATA <= X"68";
		wait for CLK_Period;
		IN_DATA <= X"2D";
		wait for CLK_Period;
		IN_DATA <= X"B0";
		wait for CLK_Period;
		IN_DATA <= X"16";
		wait for CLK_Period;
	end process;
end Behavioral;
