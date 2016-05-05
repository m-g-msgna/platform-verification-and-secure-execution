library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Integrity_Verifier is
    Port ( CLK		: in std_logic;				-- Clock input
	   RESET     	: in std_logic;				-- Reset signal 
	   INSTRUCTIONS	: in std_logic_vector(7 downto 0);	-- Executed instruction
           HASH_OUT	: out std_logic_vector(127 downto 0);	-- Integrity output 
	   BUSY		: out std_logic;			-- Module busy signal
	   IDLE		: out std_logic);			-- Module idle signal
end Integrity_Verifier;

architecture Behavioral of Integrity_Verifier is

component AES
    Port ( AES_CLK        : in std_logic;
	   RESET      : in std_logic;
	   PLAINTEXT  : in std_logic_vector(127 downto 0);
	   KEY        : in std_logic_vector(127 downto 0);
	   START      : in std_logic;
	   KEY_LOAD   : in std_logic;
	   NEAR_DONE  : out std_logic;
	   DONE       : out std_logic;
	   BUSY       : out std_logic;
 	   CIPHERTEXT : out std_logic_vector(127 downto 0));
end component;

-- AES signal interfaces
signal PLAINTEXT_INPUT	: std_logic_vector(127 downto 0) := (others=>'0');
signal KEY_INPUT	: std_logic_vector(127 downto 0) := (others=>'0');
signal START_INPUT	: std_logic := '0';
signal KEY_LOAD_INPUT	: std_logic := '0';
signal NEAR_DONE_OUTPUT	: std_logic := '0';
signal DONE_OUTPUT	: std_logic := '0';
signal BUSY_OUTPUT	: std_logic := '0';
signal CIPHERTEXT_OUT	: std_logic_vector(127 downto 0) := (others => '0');

-- Instructions buffer
signal Instruction_Buffer : std_logic_vector(127 downto 0) := (others => '0'); 
signal Buffer_Counter 	  : integer range 0 to 15;
-- 
signal Initial_Vector	  : std_logic_vector(127 downto 0) := X"000102030405060708090A0B0C0D0E0F";

begin
	INS_AES: AES
    	Port map (
		AES_CLK    => CLK,
		RESET      => RESET,
		PLAINTEXT  => PLAINTEXT_INPUT,
		KEY        => KEY_INPUT,
		START      => START_INPUT,
		KEY_LOAD   => KEY_LOAD_INPUT,
		NEAR_DONE  => NEAR_DONE_OUTPUT,
		DONE       => DONE_OUTPUT,
		BUSY       => BUSY_OUTPUT,
 		CIPHERTEXT => CIPHERTEXT_OUTPUT);


	START_HASHING: process(CLK)
	begin
		if(CLK'event and CLK = '1') then
			-- Load the key to the davies-meyer scheme.
			if(Buffer_Counter = 16) then
				KEY_INPUT <= Instruction_Buffer;
				KEY_LOAD_INPUT <= '1';
			-- Load the plaintext ..
			elsif (Buffer_Counter = '0') then
				KEY_LOAD_INPUT <= '0';
				
		end if;
	end process;

	-- Operation counter.
	OPERATION_COUNTER: process(CLK)
	begin
		if(CLK'event and CLK = '1') then
			if(Buffer_Counter = 16) then
				Buffer_Counter <= 0;
			else
				Buffer_Counter <= Buffer_Counter + 1;
				-- START_INPUT <= '0';
			end if;
		end if;
	end process;

	-- Buffer executed instructions.
	REGISTER_EXECUTED_INSTRUCTIONS: process(CLK)
	begin
		if(CLK'event and CLK = '1') then
			Instruction_Buffer((((Buffer_Counter + 1)*8)-1) downto (Buffer_Counter * 8)) <= INSTRUCTIONS;
		end if;
	end process;
end Behavioral;
