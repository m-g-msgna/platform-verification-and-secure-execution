library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.AES_CONSTANTS.all;

entity Key_Schedule is
    Port ( CLK       : in std_logic;				-- System clock
           RESET     : in std_logic;				-- Reset the circuit
	   KEY_IN    : in std_logic_vector(127 downto 0);	-- Main 128 bit key
	   KEY_PARA  : out std_logic_vector(127 downto 0);	-- Round key output
	   LOAD_KEY  : in std_logic;				-- Load original key
	   KEY_EXP   : in std_logic);				-- Expand key
end Key_Schedule;

architecture Behavioral of Key_Schedule is

signal MASTER_KEY : ARRAY4x32 := (X"00000000",X"00000000",X"00000000",X"00000000");
signal ACTIVE_KEY : ARRAY4x32 := (X"00000000",X"00000000",X"00000000",X"00000000");
signal KEY_INTRVL : integer range 0 to 15;
signal ROTWRDSUB  : std_logic_vector(31 downto 0) := (OTHERS => '0');
signal STEP_COUNT : integer range 0 to 3;
signal KEY_COL_0  : std_logic_vector(31 downto 0) := (OTHERS => '0');
signal KEY_COL_1  : std_logic_vector(31 downto 0) := (OTHERS => '0');
signal KEY_COL_2  : std_logic_vector(31 downto 0) := (OTHERS => '0');
signal KEY_COL_3  : std_logic_vector(31 downto 0) := (OTHERS => '0');
signal ACT_RCON   : std_logic_vector(7 downto 0)  := (OTHERS => '0');

begin

	ROUND_STEP_COUNTER : process (CLK, RESET, KEY_EXP)
	begin
		if (CLK'event and CLK = '1') then
			IF (RESET = '1' or KEY_EXP = '0') then
				STEP_COUNT <= 3;
			elsif STEP_COUNT = 3 then
				STEP_COUNT <= 0;
			else
				STEP_COUNT <= STEP_COUNT + 1;
			end if;
		end if;
	end process;

	-- Read the original key bytes
	MASTER_KEY_REGISTER : process (CLK, RESET, KEY_EXP)
	begin
		if (CLK'event and CLK = '1') then
			if (RESET = '1') then
				-- Reset the master key to all 0s
				MASTER_KEY <= (X"00000000", X"00000000", X"00000000", X"00000000");
			elsif (LOAD_KEY = '1' and KEY_EXP = '0') then
				-- Load the master key with the value in the KEY_IN interface
				MASTER_KEY <= (KEY_IN(127 downto 96), KEY_IN(95 downto 64), KEY_IN(63 downto 32), KEY_IN(31 downto 0));
			end if;
		end if;
	end process;


	KEY_PROCESSING_REGISTERS : process (CLK, RESET, KEY_EXP)
	begin
		if (CLK'event and CLK = '1') then
			if RESET = '1'then
				ACTIVE_KEY <= (X"00000000",X"00000000",X"00000000",X"00000000");
				ROTWRDSUB  <= X"00000000";
				KEY_INTRVL <= 0;
				ACT_RCON   <= X"00";			
			elsif KEY_EXP = '0' then
				ACTIVE_KEY <= MASTER_KEY;
				ROTWRDSUB  <= X"00000000";
				KEY_INTRVL <= 0;
				ACT_RCON   <= X"00";
				if (LOAD_KEY = '1') then
					ACTIVE_KEY <= (KEY_IN(127 downto 96),KEY_IN(95 downto 64),KEY_IN(63 downto 32),KEY_IN(31 downto 0));
				end if;	
			elsif STEP_COUNT = 3 then
				ACTIVE_KEY <= ACTIVE_KEY;
				ROTWRDSUB  <= SBOX(conv_integer(ACTIVE_KEY(3)(23 downto 16))) &
					      SBOX(conv_integer(ACTIVE_KEY(3)(15 downto 8))) &
					      SBOX(conv_integer(ACTIVE_KEY(3)(7 downto 0))) &
					      SBOX(conv_integer(ACTIVE_KEY(3)(31 downto 24)))	;
								
								
				KEY_INTRVL <= KEY_INTRVL;
				ACT_RCON   <= RCON(KEY_INTRVL);	
			elsif STEP_COUNT = 0 then
				ACTIVE_KEY <= 	(KEY_COL_0,KEY_COL_1,KEY_COL_2,KEY_COL_3);
				ROTWRDSUB  <= ROTWRDSUB;
				KEY_INTRVL <= KEY_INTRVL + 1;
				ACT_RCON <= ACT_RCON;
			end if;
		end if;
	end process;	

	KEY_COL_0 <= ACTIVE_KEY(0) XOR ROTWRDSUB XOR (ACT_RCON & X"000000");
	KEY_COL_1 <= ACTIVE_KEY(1) XOR KEY_COL_0;
	KEY_COL_2 <= ACTIVE_KEY(2) XOR KEY_COL_1;
	KEY_COL_3 <= ACTIVE_KEY(3) XOR KEY_COL_2;
	KEY_PARA  <= ACTIVE_KEY(0) & ACTIVE_KEY(1) & ACTIVE_KEY(2) & ACTIVE_KEY(3);

end Behavioral;
