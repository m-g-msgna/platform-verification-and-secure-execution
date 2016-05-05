library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AddRoundKey is
    Port ( STATE_IN  : in std_logic_vector(127 downto 0);
           KEY_IN    : in std_logic_vector(127 downto 0);
           STATE_OUT : out std_logic_vector(127 downto 0);
           CLK       : in std_logic;
           RESET     : in std_logic);
end AddRoundKey;

architecture Behavioral of AddRoundKey is

begin

	STATE_IN_XOR_STATE_OUT : process(CLK)
	begin
		if (CLK'event and CLK ='1') then
			if RESET = '1' then
				STATE_OUT <= (others => '0');
			else	
				STATE_OUT <= STATE_IN xor KEY_IN;
			end if;	
		end if;
	end process;	

end Behavioral;
