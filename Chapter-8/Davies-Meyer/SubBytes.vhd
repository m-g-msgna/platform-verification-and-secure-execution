library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use work.AES_CONSTANTS.all;

entity SubBytes is
    Port ( STATE_IN  : in std_logic_vector (127 downto 0);
           STATE_OUT : out std_logic_vector (127 downto 0);
           CLK       : in std_logic;
           RESET     : in std_logic);
end SubBytes;

architecture Behavioral of SubBytes is

signal SUB_BYTE_BUFFER : std_logic_vector (127 downto 0) := (others => '0');

begin

	SUBSTITUTE_BYTE : process(CLK)
	begin
		if (CLK'event and CLK ='1') then
			if RESET = '1' then
				STATE_OUT <= (others => '0');
			else	
				STATE_OUT <= SUB_BYTE_BUFFER; 
			end if;	
		end if;
	end process;	

	SUB_ARRAY : for i in 0 to 15 generate
	begin
		SUB_BYTE_BUFFER((((i+1)*8)-1) downto(i*8)) <= SBOX(conv_integer(STATE_IN((((i+1)*8)-1) downto(i*8)))); 
	end generate;

end Behavioral;
