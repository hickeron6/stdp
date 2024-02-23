library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Queue_Module_TB is
end Queue_Module_TB;

architecture Behavioral of Queue_Module_TB is
  -- Constants
  constant inputneuron : integer := 5;  -- Number of input neurons
  constant addrbit : integer := 3;      -- Event address bit width
  constant time_length : integer := 10;  -- Time counter bit width
  constant Tau_plus : integer  := 16;  -- As the time window
  constant  A_neg : integer := 1;  -- Using integer
  constant  Tau_neg : integer  := 16 ; -- As the time window
  constant Queue_length : integer := 10;

  -- Signals
  signal Clock : STD_LOGIC := '0';                   -- Clock signal
  signal Reset : STD_LOGIC := '0';                   -- Reset signal
  signal Event_Valid : STD_LOGIC := '0';             -- Event valid signal
  signal Event_Valid_Oppo : STD_LOGIC := '0';        -- Opposite queue event valid signal
  signal Event_Address : STD_LOGIC_VECTOR(addrbit-1 downto 0) := "000"; -- Event address
  signal Event_Address_oppo : STD_LOGIC_VECTOR(addrbit-1 downto 0) := "000";
  signal time_attach : STD_LOGIC_VECTOR(time_length-1 downto 0) := "0000000000"; -- Time attachment
  signal time_attach_oppo : STD_LOGIC_VECTOR(time_length-1 downto 0) := "0000000000";
  
  signal Dequeued_Address : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Dequeued_Time : STD_LOGIC_VECTOR(time_length-1 downto 0);
  signal Queue_Valid : STD_LOGIC;
  --
  signal Address_oppo : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Time_oppo : STD_LOGIC_VECTOR(time_length-1 downto 0);
  

begin
  -- Generate the clock signal
  process
  begin
    wait for 5 ns;  -- Adjust the clock period as needed
    Clock <= not Clock;
  end process;

  -- Reset the Queue Module
  process
  begin
    wait for 10 ns;
    Reset <= '1';
    wait for 10 ns;
    Reset <= '0';
    wait;
  end process;

  -- Stimulus process to test enqueue and dequeue operations
  process
  begin
    wait for 25 ns;  -- Delay before enqueuing data
--    Event_Valid <= '1';
--    Event_Address <= "100";
--    time_attach <= "0000100000";
--    wait for 10 ns;
--    Event_Valid <= '0';
--    wait for 10 ns;
--    Event_Valid <= '1';
--    Event_Address <= "101";
--    time_attach <= "1000100000"; 
    wait for 10 ns;
    Event_Valid <= '1';
    Event_Address <= "011";
    time_attach <= "0000000001";
    wait for 10 ns;
    Event_Valid <= '1';
    Event_Address <= "111";
    time_attach <= "0000000010";
    wait for 10 ns;
    Event_Valid <= '1';
    Event_Address <= "110";
    time_attach <= "0000000011";
    
    wait for 10 ns;  -- Delay before dequeuing data
    Event_Valid <= '0';
    Event_Valid_Oppo <= '1';
    Event_Address_oppo <= "011";
    time_attach_oppo <= "0000000110";
    wait for 10 ns;
    Event_Address_oppo <= "001";
    time_attach_oppo <= "0000000111";
    wait for 10 ns;
    Event_Address_oppo <= "010";
    time_attach_oppo <= "0000001000";
    wait for 10 ns;
    Event_Valid_Oppo <= '0';
    
    ----
    wait for 150 ns;
    Event_Valid <= '1';
    Event_Address <= "010";
    --time_attach <= "0000010011";                  --to test time window
    time_attach <= "0000000011";
    wait for 10 ns;
    Event_Valid <= '0';
    Event_Valid_Oppo <= '1';
    Event_Address_oppo <= "001";
    time_attach_oppo <= "0000010011";
    wait for 10 ns;
    Event_Address_oppo <= "111";
    time_attach_oppo <= "0000010011";
    wait for 10 ns;
    Event_Address_oppo <= "110";
    time_attach_oppo <= "0000010011";
    wait for 10 ns;
    Event_Valid_Oppo <= '0';
    
    --
    wait for 150 ns;
    Event_Valid <= '1';
    Event_Valid_Oppo <= '0';
    Event_Address <= "011";
    time_attach <= "0000000101";
    wait for 10 ns;
    Event_Valid <= '1';
    Event_Valid_Oppo <= '0';
    Event_Address <= "010";
    time_attach <= "0000001011";
    wait for 10 ns;
    Event_Valid <= '0';
    Event_Valid_Oppo <= '1';
    Event_Address_oppo <= "001";
    time_attach_oppo <= "0000010011";
    wait for 10 ns;
    Event_Valid <= '0';
    Event_Valid_Oppo <= '1';
    Event_Address_oppo <= "011";
    time_attach_oppo <= "0000010100";
    wait for 10 ns;
    Event_Valid_Oppo <= '0';
    
    ----
     wait for 100 ns;
    Event_Valid <= '1';
    Event_Valid_Oppo <= '0';
    Event_Address <= "011";
    time_attach <= "0000001011";
    wait for 10 ns;
    Event_Valid <= '0';
    Event_Valid_Oppo <= '1';
    Event_Address_oppo <= "001";
    time_attach_oppo <= "0000010011";
    wait for 10 ns;
    Event_Valid <= '0';
    Event_Valid_Oppo <= '1';
    Event_Address_oppo <= "011";
    time_attach_oppo <= "0000010101";
    wait for 10 ns;
    Event_Valid_Oppo <= '0';

    wait;
  end process;

  -- Instantiate the Queue_Module
  UUT: entity work.Queue_Module
    generic map (
      inputneuron => inputneuron,
      addrbit => addrbit,
      time_length => time_length,
      Tau_plus => Tau_plus,
      A_neg => A_neg,
      Tau_neg => Tau_neg
    )
    port map (
      Clock => Clock,
      Reset => Reset,
      Event_Valid => Event_Valid,
      Event_Valid_Oppo => Event_Valid_Oppo,
      Event_Address => Event_Address,
      Event_Address_oppo => Event_Address_oppo,
      time_attach => time_attach,
      time_attach_oppo => time_attach_oppo,
      Dequeued_Address => Dequeued_Address,
      Dequeued_Time => Dequeued_Time,
      Queue_Valid => Queue_Valid,
      --
      Address_oppo => Address_oppo,
      Time_oppo => Time_oppo
    );

  -- Monitor and display signals if needed

end Behavioral;
