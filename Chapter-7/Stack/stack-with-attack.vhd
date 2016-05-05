library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity stack is
	port(	S_CLK			: in std_logic; 
		S_EN			: in std_logic;				-- Activate stack (active low).
		PUSH_nPOP		: in std_logic;				-- '1'=PUSH and '0'=POP
		S_FULL			: out std_logic;			-- '1' if the stack if full
		S_EMPITY		: out std_logic;			-- '1' when the stack is empity
		S_DATA			: inout std_logic_vector (7 downto 0);	-- Stack input/output port
		S_ACTIVATE		: in std_logic;
		S_ATTACK_TYPE		: in std_logic_vector(1 downto 0);
		S_ATTACK_CAPABILITY	: in std_logic;
		S_ATTACK_ADDRESS	: in std_logic_vector(7 downto 0);
		S_ATTACK_BYTE		: in std_logic_vector(7 downto 0));
end stack;

architecture Behavioral of stack is

constant zero_128 : bit_vector := X"00000000000000000000000000000000";

-- Declare RAM component
component RAM_256_8
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
	port(	CLK  : in std_logic;
		CS   : in std_logic;
		WE   : in std_logic;
		OE   : in std_logic;
		ADDR : in std_logic_vector (7 downto 0);
		DIN  : in std_logic_vector (7 downto 0);
		DOUT : out std_logic_vector(7 downto 0));
end component;

-- RAM related signals
signal SP		: std_logic_vector(7 downto 0)	:= X"00"; -- Stack Pointer
signal FULL		: std_logic 			:= '0';
signal EMPITY		: std_logic			:= '1';
signal R_DATA_IN	: std_logic_vector(7 downto 0);
signal R_DATA_OUT	: std_logic_vector(7 downto 0);
signal I_CS		: std_logic			:= '1';
signal I_WE		: std_logic			:= '1';
signal I_OE		: std_logic			:= '1';

signal RAM_SP		: std_logic_vector(7 downto 0);
signal RAM_DIN		: std_logic_vector(7 downto 0);

-- POP function driver signal
signal DATA_OUT		: std_logic_vector(7 downto 0);


-- Fault simulator related signals
signal A_TARGET_BYTE	: std_logic_vector(7 downto 0);
signal A_TARGET_ADDRESS	: std_logic_vector(7 downto 0);

begin
	Operational_Stack: RAM_256_8
	generic map (INIT_00 => zero_128, INIT_01 => zero_128, INIT_02 => zero_128, INIT_03 => zero_128,
		     INIT_04 => zero_128, INIT_05 => zero_128, INIT_06 => zero_128, INIT_07 => zero_128,
		     INIT_08 => zero_128, INIT_09 => zero_128, INIT_0A => zero_128, INIT_0B => zero_128,
		     INIT_0C => zero_128, INIT_0D => zero_128, INIT_0E => zero_128, INIT_0F => zero_128)

	port map (	CLK	=> S_CLK,
			CS	=> '0',
			WE	=> I_WE,
			OE	=> I_OE,
			ADDR	=> RAM_SP, --SP,
			DIN	=> RAM_DIN, --R_DATA_IN,
			DOUT	=> R_DATA_OUT);

	-- Assign to RAM ports.
	S_FULL   <= FULL;
	S_EMPITY <= EMPITY;
	
	-- Tri-State buffer controller for the inout port of stack.
	S_DATA <= DATA_OUT when (PUSH_nPOP = '0') else (others => 'Z');

	-- Control the ram input data or address either from push or attack
	RAM_DIN <= R_DATA_IN    when(S_ACTIVATE = '0') else (A_TARGET_BYTE);
	RAM_SP  <= SP when(S_ACTIVATE = '0') else (A_TARGET_ADDRESS);

	-- Start stack functions (PUSH and POP).	
	STACK_OPERATION: process(S_CLK, PUSH_nPOP, S_EN, I_CS)
	
	-- Process variable declaration area
	variable S_Items	: integer := 0;
	variable MAX 		: std_logic := '0';

	begin
		if(rising_edge(S_CLK)) then
			if (S_ACTIVATE = '0') then
				if(S_EN = '0') then
					-- PUSH
					if(PUSH_nPOP = '1' and FULL = '0') then
						-- Enable RAM for writing
						I_WE  <= '0';
						I_OE <= '1';
											
						-- Update the stack pointer SP
						SP <= conv_std_logic_vector(S_Items, 8);					
	
						-- Write data into memory
						R_DATA_IN <= S_DATA;						
				
						if(S_Items /= 255) then
							FULL <= '0';
							EMPITY <= '0';
							S_Items := S_Items + 1;					
						else
							EMPITY <= '0';
							FULL <= '1';
							MAX := '1';
						end if;
					
					end if;
				
					-- POP
					if(PUSH_nPOP = '0' and EMPITY = '0') then
						-- Enable the RAM for reading
						I_WE <= '1';
						I_OE <= '0';
	
						if(S_Items /= 0) then
							if (MAX = '1') then
								MAX := '0';
							else
								-- Update the stack pointer (SP)
								S_Items := S_Items - 1;
								SP <= conv_std_logic_vector(S_Items, 8);
							end if;
							FULL <= '0';
						else 
							EMPITY <= '1';
						end if;

						-- Read out the memory cell
						DATA_OUT <= R_DATA_OUT;				
					end if;
				end if;
			else
				-- Enable writing to RAM
				I_WE <= '0';
				I_OE <= '1';

				-- Inject fault to the memory holding stack items.
				A_TARGET_ADDRESS <= S_ATTACK_ADDRESS;
				A_TARGET_BYTE <= S_ATTACK_BYTE;
			end if;
		end if;
	end process STACK_OPERATION;
end Behavioral;
