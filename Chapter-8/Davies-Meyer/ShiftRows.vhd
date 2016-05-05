library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity ShiftRows is
    Port ( STATE_IN  : in std_logic_vector(127 downto 0);
           STATE_OUT : out std_logic_vector(127 downto 0);
           CLK       : in std_logic;
           RESET     : in std_logic);
end ShiftRows;

architecture Behavioral of ShiftRows is

begin
	SHIFTROWS : process(CLK)
	begin
		if (CLK'event and CLK ='1') then
			if RESET = '1' then
				STATE_OUT <= (others => '0');
			else	
				STATE_OUT <= STATE_IN(127 downto 120) &
					     STATE_IN(87 downto 80)   &
					     STATE_IN(47 downto 40)   &
					     STATE_IN(7 downto 0)     &
								
					     STATE_IN(95 downto 88)   &
					     STATE_IN(55 downto 48)   &
					     STATE_IN(15 downto 8)    &
					     STATE_IN(103 downto 96)  &

					     STATE_IN(63 downto 56)   &
					     STATE_IN(23 downto 16)   &
					     STATE_IN(111 downto 104) &
					     STATE_IN(71 downto 64)   &
									
					     STATE_IN(31 downto 24)   &
					     STATE_IN(119 downto 112) &
					     STATE_IN(79 downto 72)   &
					     STATE_IN(39 downto 32);
			end if;							
		end if;
	end process;	

end Behavioral;
