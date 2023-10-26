library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AER_Encoder is
  generic (
    inputneuron : integer := 784;  -- Number of input neurons, default is 784
    addrbit : integer := 10         -- Event address bit width, default is 10 bits
  );
  Port (
    Clock : in STD_LOGIC;                           -- Clock signal
    Reset : in STD_LOGIC;                           -- Reset signal
    Input_Channel : in STD_LOGIC_VECTOR(inputneuron-1 downto 0); -- Input channels
    Input_Valid : in STD_LOGIC;
    Event_Valid : out STD_LOGIC;                   -- Event valid signal
    Event_Address : out STD_LOGIC_VECTOR(addrbit-1 downto 0); -- Event address
    Status_nozero :out STD_LOGIC
  );
end AER_Encoder;

architecture Behavioral of AER_Encoder is
  signal Event_Count : integer := 0;  -- Event counter for generating event address
  signal Event_Found : STD_LOGIC := '0';  -- Flag to indicate if an event has been found
  signal Valid_buffer : integer := 0;   --for recg the no zero sign

begin
  process(Reset, Input_Valid)
  begin
      

  if Reset = '1' then
    Event_Count <= 0;        -- Clear event counter on reset
    Event_Found <= '0';    -- Reset event found flag
  elsif rising_edge(Input_Valid) then
    Event_Count <= 0;
    if rising_edge(Clock) then
    if Event_Count < inputneuron then
      if Input_Channel(Event_Count) = '1' then
        Event_Valid <= '1';  -- Set event valid signal
        Valid_buffer <= Valid_buffer + 1;
        Event_Found <= not Event_Found;  -- Set event found flag, for not to set the sign
      else
        Event_Valid <= '0';  -- Make event invalid if no event in the current channel
      end if;
      Event_Count <= Event_Count + 1;  -- Increment event counter
    else
      Event_Valid <= '0';  -- Make event invalid if event counter reaches the maximum value
      Valid_buffer <= 0;
      --Event_Found <= false; -- Reset event found flag
    end if;
    end if;
  end if;
end process;




  process(Event_Found)
  begin
    Event_Address <= conv_std_logic_vector(Event_Count, addrbit);
    if Valid_buffer > 1 then
      Status_nozero <= '1';                   
    else
      Status_nozero <= '0';
    end if;
  end process;

end Behavioral;
