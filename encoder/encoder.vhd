library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AER_Encoder is
  generic (
    inputneuron : integer := 784;  -- Number of input neurons, default is 784
    addrbit : integer := 10;         -- Event address bit width, default is 10 bits
    time_length : integer := 5
  );
  Port (
    Clock : in STD_LOGIC;                           -- Clock signal
    Reset : in STD_LOGIC;                           -- Reset signal
    Input_Channel : in STD_LOGIC_VECTOR(inputneuron-1 downto 0); -- Input channels
    Input_Valid : in STD_LOGIC;

    Event_Valid : out STD_LOGIC;                   -- Event valid signal
    Event_Address : out STD_LOGIC_VECTOR(addrbit-1 downto 0);-- Event address
    time_attach : out STD_LOGIC_VECTOR(time_length-1 downto 0)
  );
end AER_Encoder;

architecture Behavioral of AER_Encoder is
  signal Event_Count : integer := 0;  -- Event counter for generating event address
  signal Event_Found : STD_LOGIC := '0';  -- Flag to indicate if an event has been found
  signal Valid_buffer : integer := 0;   -- For recognizing the no zero sign
  signal time_buffer : STD_LOGIC_VECTOR(time_length-1 downto 0) := (others => '0');
  

begin
  process(Clock, Reset, Input_Channel)
  variable Event_Count_pre : integer := 0;  -- Event counter for sign status
  --variable Event_Found_buffer : integer := 0;
  begin
  
  if Input_Channel'event then --and Input_Channel = "1" then
      Event_Count <= 0;
  end if;

  if Reset = '1' then
    Event_Count <= 0;        -- Clear event counter on reset
  elsif rising_edge(Clock) then
    if Event_Count < inputneuron then
      if Input_Channel(Event_Count) = '1' then
        Event_Valid <= '1';  -- Set event valid signal
        Valid_buffer <= Valid_buffer + 1;
        Event_Address <= conv_std_logic_vector(Event_Count, addrbit);
        if Valid_buffer = 0 then
          time_attach <= time_buffer;
        end if;
      else
        Event_Valid <= '0';  -- Make event invalid if no event in the current channel
      end if;
      Event_Count <= Event_Count + 1;  -- Increment event counter
    else
      Event_Valid <= '0';  -- Make event invalid if event counter reaches the maximum value
      Valid_buffer <= 0;
    end if;
  end if;

  end process;

  

  process(Clock)
  begin
    time_buffer <= time_buffer + 1;
  end process;


end Behavioral;
