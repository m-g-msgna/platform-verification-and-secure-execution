library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Column_Matrix_Mul is
    Port ( CM_CLK	: in std_logic;
	   CM_RESET 	: in std_logic;
           COLUMN_IN 	: in std_logic_vector(31 downto 0);
           COLUMN_OUT 	: out std_logic_vector(31 downto 0));
end Column_Matrix_Mul;

architecture Behavioral of Column_Matrix_Mul is

signal a0 	: std_logic_vector(7 downto 0) := (others => '0');
signal a0x2 	: std_logic_vector(7 downto 0) := (others => '0');
signal a0x3 	: std_logic_vector(7 downto 0) := (others => '0');

signal a1	: std_logic_vector(7 downto 0) := (others => '0');
signal a1x2	: std_logic_vector(7 downto 0) := (others => '0');
signal a1x3	: std_logic_vector(7 downto 0) := (others => '0');

signal a2	: std_logic_vector(7 downto 0) := (others => '0');
signal a2x2	: std_logic_vector(7 downto 0) := (others => '0');
signal a2x3	: std_logic_vector(7 downto 0) := (others => '0');

signal a3	: std_logic_vector(7 downto 0) := (others => '0');
signal a3x2	: std_logic_vector(7 downto 0) := (others => '0');	
signal a3x3	: std_logic_vector(7 downto 0) := (others => '0');

signal r0	: std_logic_vector(7 downto 0) := (others => '0');
signal r1	: std_logic_vector(7 downto 0) := (others => '0');
signal r2	: std_logic_vector(7 downto 0) := (others => '0');
signal r3	: std_logic_vector(7 downto 0) := (others => '0');

begin
	-- byte breakdown of the input column
	a0 <= COLUMN_IN(31 downto 24);
	a1 <= COLUMN_IN(23 downto 16);
	a2 <= COLUMN_IN(15 downto 8);
	a3 <= COLUMN_IN(7 downto 0);

	-- Galois Field Multiplications
	-- Multiply by 2 is done with a left shift and a conditional XOR with X"1B" if the MSB is 1
	GaloisXTwo : process (a0,a1,a2,a3) 
	begin
		if (a0(7) = '1') then
			a0x2 <=(a0(6 downto 0) & '0') xor X"1B";
		else
			a0x2 <= a0(6 downto 0) & '0';
		end if;
		
		if (a1(7) = '1') then
			a1x2 <=(a1(6 downto 0) & '0') xor X"1B";
		else
			a1x2 <= a1(6 downto 0) & '0';
		end if;
		
		if (a2(7) = '1') then
			a2x2 <=(a2(6 downto 0) & '0') xor X"1B";
		else
			a2x2 <= a2(6 downto 0) & '0';
		end if;
	
		if (a3(7) = '1') then
			a3x2 <=(a3(6 downto 0) & '0') xor X"1B";
		else
			a3x2 <= a3(6 downto 0) & '0';
		end if;
	end process;	
		
	-- Multiply by 3: Multiply by 2 and then XOR with (equivalent to adding) the original value
	a0x3 <= a0x2 XOR a0;
	a1x3 <= a1x2 XOR a1;
	a2x3 <= a2x2 XOR a2;
	a3x3 <= a3x2 XOR a3;


	-- The MixColumn Function
	MixColumns : process (CM_CLK)
	begin
		if (CM_CLK'event and CM_CLK = '1') then
			if CM_RESET = '1' then 
				r0 <= X"00";
				r1 <= X"00";
				r2 <= X"00";
				r3 <= X"00";
			else	
				r0 <= a0x2 xor a1x3 xor a2 xor a3; ---- Final Sum of products for the matix operation
				r1 <= a1x2 xor a2x3 xor a3 xor a0;
				r2 <= a2x2 xor a3x3 xor a0 xor a1;
				r3 <= a3x2 xor a0x3 xor a1 xor a2;
			end if;	
		end if;
	end process;	

----Assemble Output Column
COLUMN_OUT <= r0 & r1 & r2 & r3;

end Behavioral;
