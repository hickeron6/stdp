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
  constant time_length : integer := 5;  -- Time counter bit width
  constant Tau_plus : integer  := 16;  -- As the time window
  constant  A_neg : integer := 1;  -- Using integer
  constant  Tau_neg : integer  := 16 ; -- As the time window

  -- Signals
  signal Clock : STD_LOGIC := '0';                   -- Clock signal
  signal Reset : STD_LOGIC := '0';                   -- Reset signal
  signal Event_Valid : STD_LOGIC := '0';             -- Event valid signal
  signal Event_Valid_Oppo : STD_LOGIC := '0';        -- Opposite queue event valid signal
  signal Event_Address : STD_LOGIC_VECTOR(addrbit-1 downto 0) := "010"; -- Event address
  signal time_attach : STD_LOGIC_VECTOR(time_length-1 downto 0) := "10001"; -- Time attachment
  signal time_attach_oppo : STD_LOGIC_VECTOR(time_length-1 downto 0) := "10111";
  
  signal Dequeued_Address : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Dequeued_Time : STD_LOGIC_VECTOR(time_length-1 downto 0);
  signal Queue_Valid : STD_LOGIC;

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
    Event_Valid <= '1';
    wait for 10 ns;
    Event_Valid <= '0';
    wait for 10 ns;
    Event_Valid <= '1';
    Event_Address <= "101";
    time_attach <= "10001"; 
    wait for 10 ns;
    Event_Valid <= '1';
    Event_Address <= "011";
    time_attach <= "00001";
    
    wait for 10 ns;  -- Delay before dequeuing data
    Event_Valid <= '0';
    Event_Valid_Oppo <= '1';
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
      time_attach => time_attach,
      time_attach_oppo => time_attach_oppo,
      Dequeued_Address => Dequeued_Address,
      Dequeued_Time => Dequeued_Time,
      Queue_Valid => Queue_Valid
    );

  -- Monitor and display signals if needed

end Behavioral;
