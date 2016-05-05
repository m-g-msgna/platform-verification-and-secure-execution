library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity RAM_256_8 is
	generic(INIT_00 : bit_vector := X"00000000000000000000000000000000";
		INIT_01 : bit_vector := X"00000000000000000000000000000000";
		INIT_02 : bit_vector := X"00000000000000000000000000000000";
		INIT_03 : bit_vector := X"00000000000000000000000000000000";
		INIT_04 : bit_vector := X"00000000000000000000000000000000";
		INIT_05 : bit_vector := X"00000000000000000000000000000000";
		INIT_06 : bit_vector := X"00000000000000000000000000000000";
		INIT_07 : bit_vector := X"00000000000000000000000000000000";
		INIT_08 : bit_vector := X"00000000000000000000000000000000";
		INIT_09 : bit_vector := X"00000000000000000000000000000000";
		INIT_0A : bit_vector := X"00000000000000000000000000000000";
		INIT_0B : bit_vector := X"00000000000000000000000000000000";
		INIT_0C : bit_vector := X"00000000000000000000000000000000";
		INIT_0D : bit_vector := X"00000000000000000000000000000000";
		INIT_0E : bit_vector := X"00000000000000000000000000000000";
		INIT_0F : bit_vector := X"00000000000000000000000000000000");

	port(	CLK  : in std_logic;	-- (CLK, CS, WE, OE from ulogic to logic)
		CS   : in std_logic;	-- CS (Chip Select), active low
		WE   : in std_logic;	-- WE (Write Enable), active low
		OE   : in std_logic;	-- OE (output Enable), active low
		ADDR : in std_logic_vector (7 downto 0);
		DIN  : in std_logic_vector (7 downto 0);
		DOUT : out std_logic_vector(7 downto 0));
end RAM_256_8;

architecture Behavioral of RAM_256_8 is
	
--Function that converts bit to std_logic
function BS (A : bit) return std_logic is
	begin
		if(A = '1') then return '1';
		else		 return '0';
		end if;
end;

--Function that converts std_lodic to bit
function SB (A : std_logic) return bit is
	begin
		if(A = '1') then return '1';
		else		 return '0';
		end if;
end;

signal DATA : bit_vector(2047 downto 0) :=
	INIT_0F & INIT_0E & INIT_0D & INIT_0C & INIT_0B & INIT_0A & INIT_09 & INIT_08 & 
	INIT_07 & INIT_06 & INIT_05 & INIT_04 & INIT_03 & INIT_02 & INIT_01 & INIT_00;

begin
	RAM_WRITE_READ: process(CLK, OE, WE, DIN, CS)
	begin
		if(rising_edge(CLK)) then
			if (CS = '0')  then --chip selected
				if(OE = '1' and WE = '0') then --write mode
					DATA(conv_integer(ADDR & "111")) <= SB(DIN(7));
					DATA(conv_integer(ADDR & "110")) <= SB(DIN(6));
					DATA(conv_integer(ADDR & "101")) <= SB(DIN(5));
					DATA(conv_integer(ADDR & "100")) <= SB(DIN(4));
					DATA(conv_integer(ADDR & "011")) <= SB(DIN(3));
					DATA(conv_integer(ADDR & "010")) <= SB(DIN(2));
					DATA(conv_integer(ADDR & "001")) <= SB(DIN(1));
					DATA(conv_integer(ADDR & "000")) <= SB(DIN(0));
				end if;
				if(OE = '0' and WE = '1') then --read mode
					DOUT(7) <= BS(DATA(conv_integer(ADDR & "111")));
					DOUT(6) <= BS(DATA(conv_integer(ADDR & "110")));
					DOUT(5) <= BS(DATA(conv_integer(ADDR & "101")));
					DOUT(4) <= BS(DATA(conv_integer(ADDR & "100")));
					DOUT(3) <= BS(DATA(conv_integer(ADDR & "011")));
					DOUT(2) <= BS(DATA(conv_integer(ADDR & "010")));
					DOUT(1) <= BS(DATA(conv_integer(ADDR & "001")));
					DOUT(0) <= BS(DATA(conv_integer(ADDR & "000")));
				end if;
			end if;
		end if;
	end process RAM_WRITE_READ;

end Behavioral;
