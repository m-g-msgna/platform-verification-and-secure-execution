library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MixColumns is
    Port ( CLK       : in std_logic;
	   RESET     : in std_logic;
           STATE_IN  : in std_logic_vector(127 downto 0);
           STATE_OUT : out std_logic_vector(127 downto 0));
end MixColumns;

architecture Behavioral of MixColumns is

COMPONENT Column_Matrix_Mul
	PORT( CM_CLK		: in std_logic;
	      CM_RESET 	        : in std_logic;
              COLUMN_IN 	: in std_logic_vector(31 downto 0);
              COLUMN_OUT 	: out std_logic_vector(31 downto 0));
	END COMPONENT;

begin
	-- First colun
	Column_Matrix_Mul_0: Column_Matrix_Mul
	port map(
		CM_CLK     => CLK,
		CM_RESET   => RESET,
		COLUMN_IN  => STATE_IN(127 downto 96),
		COLUMN_OUT => STATE_OUT(127 downto 96)
	);
	-- Second column
	Column_Matrix_Mul_1 : Column_Matrix_Mul
	port map(
		CM_CLK     => CLK,
		CM_RESET   => RESET,
		COLUMN_IN  => STATE_IN(95 downto 64),
		COLUMN_OUT => STATE_OUT(95 downto 64)
	);
	-- Third column
	Column_Matrix_Mul_2: Column_Matrix_Mul
	port map(
		CM_CLK     => CLK,
		CM_RESET   => RESET,
		COLUMN_IN  => STATE_IN(63 downto 32),
		COLUMN_OUT => STATE_OUT(63 downto 32)
	);
	-- Fourth column
	Column_Matrix_Mul_3: Column_Matrix_Mul
	port map(
		CM_CLK     => CLK,
		CM_RESET   => RESET,
		COLUMN_IN  => STATE_IN(31 downto 0),
		COLUMN_OUT => STATE_OUT(31 downto 0)
	);
end Behavioral;
