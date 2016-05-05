library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AES is
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
end AES;

architecture Behavioral of AES is

----Sub Components Definitions
component Key_Schedule
	port(   CLK       : in std_logic;
           	RESET     : in std_logic;
	   	KEY_IN    : in std_logic_vector(127 downto 0);
	   	KEY_PARA  : out std_logic_vector(127 downto 0);
	   	LOAD_KEY  : in std_logic;
	   	KEY_EXP   : in std_logic);
end component;

component SubBytes
	port(	STATE_IN  : in std_logic_vector(127 downto 0);
           	STATE_OUT : out std_logic_vector(127 downto 0);
           	CLK       : in std_logic;
           	RESET     : in std_logic);
end component;

component ShiftRows
	port(	STATE_IN  : in std_logic_vector(127 downto 0);
           	STATE_OUT : out std_logic_vector(127 downto 0);
           	CLK       : in std_logic;
           	RESET     : in std_logic);
end component;

component MixColumns
	port(	CLK       : in std_logic;
	   	RESET     : in std_logic;
           	STATE_IN  : in std_logic_vector(127 downto 0);
           	STATE_OUT : out std_logic_vector(127 downto 0));
end component;

component AddRoundKey
	port(	STATE_IN  : in std_logic_vector(127 downto 0);
           	KEY_IN    : in std_logic_vector(127 downto 0);
           	STATE_OUT : out std_logic_vector(127 downto 0);
           	CLK       : in std_logic;
           	RESET     : in std_logic);
end component;
----End Sub Components Definitions

type state is (RESET_1,RESET_2,IDLE,PROCESSING);  
signal pr_state,nx_state : state ;

SIGNAL RST_BUF : STD_LOGIC := '0';
SIGNAL BUSY_BUF : STD_LOGIC := '0';
SIGNAL PLAINTEXT_BUFFER : STD_LOGIC_VECTOR(127 downto 0) := (OTHERS => '0');

SIGNAL OPN_COUNT : STD_LOGIC_VECTOR(1 downto 0) := "00";
SIGNAL RND_COUNT : STD_LOGIC_VECTOR(3 downto 0) := "0000";
SIGNAL RND_MUX_CNTRL  : STD_LOGIC_VECTOR(1 downto 0) := "00";
 
SIGNAL KEY_BUF : STD_LOGIC_VECTOR(127 downto 0) := (OTHERS => '0');
SIGNAL SubBytes_IN_BUF : STD_LOGIC_VECTOR(127 downto 0) := (OTHERS => '0');
SIGNAL SubBytes_OUT_BUF : STD_LOGIC_VECTOR(127 downto 0) := (OTHERS => '0');
SIGNAL ShiftRows_IN_BUF : STD_LOGIC_VECTOR(127 downto 0) := (OTHERS => '0');
SIGNAL ShiftRows_OUT_BUF : STD_LOGIC_VECTOR(127 downto 0) := (OTHERS => '0');
SIGNAL MixColumns_IN_BUF : STD_LOGIC_VECTOR(127 downto 0) := (OTHERS => '0');
SIGNAL MixColumns_OUT_BUF : STD_LOGIC_VECTOR(127 downto 0) := (OTHERS => '0');
SIGNAL AddRoundKey_IN_BUF : STD_LOGIC_VECTOR(127 downto 0) := (OTHERS => '0');
SIGNAL AddRoundKey_OUT_BUF : STD_LOGIC_VECTOR(127 downto 0) := (OTHERS => '0');

begin

--Instantiate Sub-Components
INST_Key_Schedule: Key_Schedule
	port map(
		CLK      => AES_CLK,
		RESET    => RST_BUF,
		KEY_IN   => KEY,
		KEY_PARA => KEY_BUF,
		LOAD_KEY => KEY_LOAD,
		KEY_EXP  => BUSY_BUF
	);
	
INST_SubBytes: SubBytes PORT MAP(
		STATE_IN => SubBytes_IN_BUF,
		STATE_OUT => SubBytes_OUT_BUF,
		CLK => AES_CLK,
		RESET => RST_BUF
	);

INST_ShiftRows: ShiftRows PORT MAP(
		STATE_IN => ShiftRows_IN_BUF,
		STATE_OUT => ShiftRows_OUT_BUF,
		CLK => AES_CLK,
		RESET => RST_BUF
	);	

INST_MixColumns: MixColumns PORT MAP(
		CLK => AES_CLK,
		RESET => RST_BUF,
		STATE_IN => MixColumns_IN_BUF,
		STATE_OUT => MixColumns_OUT_BUF 
	);

INST_AddRoundKey: AddRoundKey PORT MAP(
		STATE_IN => AddRoundKey_IN_BUF,
		KEY_IN => KEY_BUF,
		STATE_OUT => AddRoundKey_OUT_BUF,
		CLK => AES_CLK,
		RESET => RST_BUF
	);
-----END Component Instatiation

STATE_MACHINE_HEAD : PROCESS (AES_CLK, RESET) ----State Machine Master Control
begin
	IF (AES_CLK'event and AES_CLK='1') then
		IF (RESET = '1') then
			pr_state <= RESET_1;
		ELSE
			pr_state <= nx_state;
		END IF;
	END IF;
END PROCESS;

-- State Machine State Definitions
STATE_MACHINE_BODY : PROCESS (AES_CLK, RESET, PR_STATE, START, KEY_LOAD, OPN_COUNT, RND_COUNT)
begin
	CASE pr_state is
		
		WHEN RESET_1 =>  --Master Reset State
			RST_BUF <= '1';
			BUSY_BUF  <= '0';
			nx_state <= RESET_2;

		WHEN RESET_2 =>  --Extra Reset State to prevent reset glitching
			RST_BUF <= '1';
			BUSY_BUF  <= '0';
			nx_state <= IDLE;

		WHEN IDLE =>   --Waiting for Key Load or Data/Start assertion
			RST_BUF <= '0';
			BUSY_BUF  <= '0';
			IF (START = '1') then
				nx_state <= PROCESSING;
			ELSE
				nx_state <= IDLE;
			END IF;	
				
		WHEN PROCESSING =>   --Enable step/round counters
			RST_BUF <= '0';
			BUSY_BUF  <= '1';
			IF (OPN_COUNT = "11" AND  RND_COUNT = X"A") then
				nx_state <= IDLE;
			ELSE
				nx_state <= PROCESSING;
			END IF;
	END CASE;
END PROCESS;	
				
-- Counts through each step and each round of cipher sequence, affects data path mux and state machine
OPERATIONS_COUNTER : PROCESS (AES_CLK, PR_STATE)
begin	
	IF (AES_CLK'event and AES_CLK='1') then
		IF (PR_STATE = RESET_1 OR PR_STATE = RESET_2 OR PR_STATE = IDLE) then
			OPN_COUNT <= "11";   --Step Counter Starts on 3 to correspond to AddRoundKey step at very start of cipher
			RND_COUNT <= "0000";
		ELSE
			OPN_COUNT <= OPN_COUNT + 1;   ---Always increment when processing
			IF OPN_COUNT = "11" then     ---Increment at the last step of a round
				RND_COUNT <= RND_COUNT + 1;
			END IF;
		END IF;
	END IF;
END PROCESS;


-- Output Latch for ciphertext
CIPHER_TEXT_OUTPUT_REGISTER : PROCESS(AES_CLK, PR_STATE)
begin
	IF (AES_CLK'event and AES_CLK='1') then
		IF (PR_STATE = RESET_1 OR PR_STATE = RESET_2) then
			CIPHERTEXT <= (OTHERS => '0');
		ELSIF (OPN_COUNT = "11" AND  RND_COUNT = X"A") then
			CIPHERTEXT <= AddRoundKey_OUT_BUF;
		END IF;
	END IF;
END PROCESS;

-- Single Pulse Signal when cipher is complete and output data is valid
ENCRYPT_DONE_SIGNAL_LATCH : PROCESS(AES_CLK) 
begin
	IF (AES_CLK'event and AES_CLK='1') then
		IF (OPN_COUNT = "11" AND  RND_COUNT = X"A") then
			DONE <= '1';
		ELSE
			DONE <= '0';
		END IF;
	END IF;
END PROCESS;


NEARLY_DONE_SIGNAL_LATCH : PROCESS(AES_CLK)   -----Single Pule Signal when cipher is one clock cycle from completion: possiible trigger for continous loading
begin
	IF (AES_CLK'event and AES_CLK='1') then
		IF (OPN_COUNT = "10" AND  RND_COUNT = X"A") then
			NEAR_DONE <= '1';
		ELSE
			NEAR_DONE <= '0';
		END IF;
	END IF;
END PROCESS;


DATA_PATH_MUX_CONTROL : PROCESS(AES_CLK)    
begin
	IF (AES_CLK'event and AES_CLK='1') then
		IF (PR_STATE = RESET_1 OR PR_STATE = RESET_2 OR PR_STATE = IDLE) then
			RND_MUX_CNTRL <= "00";
		ELSIF (OPN_COUNT = "00" AND  RND_COUNT = X"1") then
			RND_MUX_CNTRL <= "01";
		ELSIF (OPN_COUNT = "11" AND  RND_COUNT = X"9") then
			RND_MUX_CNTRL <= "11";
		END IF;
	END IF;
END PROCESS;

-- Read plaintext interface port.
PLAINTEXT_INPUT_REGISTER : PROCESS(AES_CLK)
begin
	IF (AES_CLK'event and AES_CLK='1') then
		IF (RESET = '1') then
			PLAINTEXT_BUFFER <= (OTHERS => '0');
		ELSIF (START = '1' AND PR_STATE = IDLE) then
			PLAINTEXT_BUFFER <= PLAINTEXT;
		END IF;
	END IF;
END PROCESS;	
			
			
		

			
-----Async Signals-------------------			
			
DATA_PATH_MUTIPLEXER : PROCESS (RND_MUX_CNTRL,ShiftRows_OUT_BUF,MixColumns_OUT_BUF,PLAINTEXT_BUFFER)  ---Changes input to AddRoundKEy based on state of cipher
begin				
	CASE RND_MUX_CNTRL IS
		WHEN "00" =>
			AddRoundKey_IN_BUF 	<=PLAINTEXT_BUFFER;
		WHEN "01" =>
			AddRoundKey_IN_BUF 	<= MixColumns_OUT_BUF;
		WHEN "11" =>
			AddRoundKey_IN_BUF 	<= ShiftRows_OUT_BUF;	
		when others =>
			AddRoundKey_IN_BUF 	<= MixColumns_OUT_BUF;

	END CASE;
END PROCESS;	
			
-----Set Core to Look BUSY during reset without actually asserting BUSY_BUF
BUSY_OUTPUT_MUX : PROCESS (BUSY_BUF, pr_state)
begin
	IF (PR_STATE = RESET_1 OR PR_STATE = RESET_2) then
		BUSY <= '1';
	ELSE	
		BUSY <= BUSY_BUF;
	END IF;
END PROCESS;

---Fixed Pipeline Connections
SubBytes_IN_BUF 	<= AddRoundKey_OUT_BUF; 
ShiftRows_IN_BUF 	<= SubBytes_OUT_BUF;
MixColumns_IN_BUF 	<= ShiftRows_OUT_BUF;
			
end Behavioral;
