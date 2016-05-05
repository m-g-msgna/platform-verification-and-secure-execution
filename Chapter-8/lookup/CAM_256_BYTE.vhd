library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity CAM_256_BYTE is
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

	port(	CLK      : in std_logic;
		CAM_EN   : in std_logic;
		WR_SR    : in std_logic;
		ADDR_IN  : in std_logic_vector (7 downto 0);
		DATA_IN  : in std_logic_vector (7 downto 0);
		MATCH    : out std_logic;
		ADDR_OUT : out std_logic_vector(7 downto 0));
end CAM_256_BYTE;

architecture Behavioral of CAM_256_BYTE is
	
--Function that converts bit to std_logic
function BS (A : bit) return std_logic is
	begin
		if(A = '1') then return '1';
		else		 return '0';
		end if;
end;

-- Function that converts std_lodic to bit
-- For memory write operation.
function SB (A : std_logic) return bit is
	begin
		if(A = '1') then return '1';
		else		 return '0';
		end if;
end;

signal DATA : bit_vector(2047 downto 0) :=
	INIT_0F & INIT_0E & INIT_0D & INIT_0C &
	INIT_0B & INIT_0A & INIT_09 & INIT_08 & 
	INIT_07 & INIT_06 & INIT_05 & INIT_04 & 
	INIT_03 & INIT_02 & INIT_01 & INIT_00;

begin
	-- RAM read and write process
	RAM_WRITE_SEARCH: process(CLK)

	variable SR_DEPTH :integer := 256;
	variable SR_DATA  :std_logic_vector(7 downto 0);
	variable S_ADDR   :std_logic_vector(7 downto 0);
	variable LSB_ADDR :integer;

	begin
		if(rising_edge(CLK)) then
			-- CAM selected
			if (CAM_EN = '0')  then
				-- If write mode
				if(WR_SR = '0') then
					DATA(conv_integer(ADDR_IN & "111")) <= SB(DATA_IN(7));
					DATA(conv_integer(ADDR_IN & "110")) <= SB(DATA_IN(6));
					DATA(conv_integer(ADDR_IN & "101")) <= SB(DATA_IN(5));
					DATA(conv_integer(ADDR_IN & "100")) <= SB(DATA_IN(4));
					DATA(conv_integer(ADDR_IN & "011")) <= SB(DATA_IN(3));
					DATA(conv_integer(ADDR_IN & "010")) <= SB(DATA_IN(2));
					DATA(conv_integer(ADDR_IN & "001")) <= SB(DATA_IN(1));
					DATA(conv_integer(ADDR_IN & "000")) <= SB(DATA_IN(0));
				end if;
				-- If search mode
				if(WR_SR = '1') then
					MATCH <= '0';
					for L_ADDR in 0 to (SR_DEPTH - 1) loop
						LSB_ADDR := L_ADDR * 8;

						SR_DATA(0) := BS(DATA(LSB_ADDR + 0));
						SR_DATA(1) := BS(DATA(LSB_ADDR + 1));
						SR_DATA(2) := BS(DATA(LSB_ADDR + 2));
						SR_DATA(3) := BS(DATA(LSB_ADDR + 3));
						SR_DATA(4) := BS(DATA(LSB_ADDR + 4));
						SR_DATA(5) := BS(DATA(LSB_ADDR + 5));
						SR_DATA(6) := BS(DATA(LSB_ADDR + 6));
						SR_DATA(7) := BS(DATA(LSB_ADDR + 7));

						if( SR_DATA = DATA_IN ) then
							MATCH <= '1';
							ADDR_OUT <= conv_std_logic_vector(L_ADDR, 8);
							exit;
						else
							MATCH <= '0';
							ADDR_OUT(7 downto 0) <= (others=>'Z');
						end if;
					end loop;
				end if;
			end if;
		end if;
	end process RAM_WRITE_SEARCH;
end Behavioral;
