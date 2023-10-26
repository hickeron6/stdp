library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AER_Encoder_TB is
end AER_Encoder_TB;

architecture Behavioral of AER_Encoder_TB is
  -- Constants
  constant inputneuron : integer := 6;  -- Number of input neurons
  constant addrbit : integer := 3;      -- Event address bit width

  -- Signals
  signal Clock : STD_LOGIC := '0';        -- Clock signal
  signal Reset : STD_LOGIC := '0';        -- Reset signal
  signal Input_Channel : STD_LOGIC_VECTOR(inputneuron-1 downto 0) := "101001";  -- Input channel (6 bits)
  signal Event_Valid : STD_LOGIC;
  signal Event_Address : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Status_nozero : STD_LOGIC;
  signal Input_Valid : STD_LOGIC :='0';

begin
  -- Generate the clock signal
  process
  begin
    wait for 5 ns;  -- Adjust the clock period as needed
    Clock <= not Clock;
  end process;

  -- Generate the reset signal
  process
  begin
    wait for 10 ns;  -- Adjust the reset duration as needed
    Reset <= '1';
    wait for 10 ns;
    Reset <= '0';
    Input_Valid <='1';
    wait for 100 ns;
    Input_Valid <='0';
    wait for 100 ns;
    Input_Valid <='1';
    Input_Channel <="000001";
    wait;
  end process;

  -- Instantiate the AER_Encoder module with the updated parameters
  UUT: entity work.AER_Encoder
    generic map (
      inputneuron => inputneuron,  -- Number of input neurons
      addrbit => addrbit           -- Event address bit width
    )
    port map (
      Clock => Clock,
      Reset => Reset,
      Input_Channel => Input_Channel,
      Input_Valid => Input_Valid,
      Event_Valid => Event_Valid,
      Event_Address => Event_Address,
      Status_nozero => Status_nozero 
    );

  -- Simulation code goes here
  -- You can add code to monitor and display the signals, or perform additional tests.

end architecture Behavioral;
