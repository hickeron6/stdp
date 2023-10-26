library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Weight_Trans is
  generic (
    inputneuron : integer := 784;
    addrbit : integer := 10;
    time_length : integer := 5;
    A_plus : integer := 1;  -- Using integer
    Tau_plus : integer := 32;  -- As the time window
    A_neg : integer := 1;  -- Using integer
    Tau_neg : integer := 32  -- As the time window
  );
  port (
    Clock : in STD_LOGIC;
    Reset : in STD_LOGIC;
    Event_Valid_oppo : in STD_LOGIC;
    Event_Address : in STD_LOGIC_VECTOR(addrbit-1 downto 0);
    time_attach : in STD_LOGIC_VECTOR(time_length-1 downto 0);
    Dequeued_address : in STD_LOGIC_VECTOR(addrbit-1 downto 0);
    Dequeued_Time : in STD_LOGIC_VECTOR(time_length-1 downto 0);

    Weight_Adress_1 : out STD_LOGIC_VECTOR(addrbit-1 downto 0);
    Weight_Adress_2 : out STD_LOGIC_VECTOR(addrbit-1 downto 0);
    Weight_Delta : out STD_LOGIC_VECTOR(time_length-1 downto 0);
    Weight_Delta_Indicator : out STD_LOGIC  -- Indicator for Weight_Delta
  );
end Weight_Trans;

architecture Behavior of Weight_Trans is
  signal Time_Delta : integer := 0;  -- Using integer
  signal Weight_Delta_Approx : integer := 0;  -- Using integer
  signal signed_t1, signed_t2 : INTEGER := 0;

begin

  signed_t1 <= TO_INTEGER(UNSIGNED(time_attach));
  signed_t2 <= TO_INTEGER(UNSIGNED(Dequeued_Time));
  Time_Delta <= signed_t1 - signed_t2;
      
  process(Clock)
  begin
    if rising_edge(Clock) then
      -- Approximate weight delta calculation
      if Event_Valid_oppo = '1' then
       if signed_t2 /= 0 or signed_t2 /= 0 then
        if Time_Delta > 0 and Time_Delta < Tau_neg then
          Weight_Delta_Approx <= -A_neg * (Tau_neg-Time_Delta) ;
          Weight_Delta_Indicator <= '1';  -- Indicator signal set to '1'
        elsif Time_Delta < 0 and Time_Delta > -Tau_plus then                --formula positive have changed to fit result
          Weight_Delta_Approx <= A_plus * (Tau_plus+Time_Delta) ; 
          Weight_Delta_Indicator <= '1';  -- Indicator signal set to '1'
        else
          Weight_Delta_Approx <= 0;
          Weight_Delta_Indicator <= '0';  -- Indicator signal set to '0'
        end if;
       else
          Weight_Delta_Approx <= 0;
          Weight_Delta_Indicator <= '0';  -- Indicator signal set to '0'
       end if;
      end if;
    end if;
 end process;
    -- Convert the approximate weight delta back to STD_LOGIC_VECTOR
    Weight_Delta <= std_logic_vector(to_unsigned(Weight_Delta_Approx, time_length));  -- Convert back to STD_LOGIC_VECTOR
    Weight_Adress_1 <= Event_Address;
    Weight_Adress_2 <= Dequeued_address;
    
 
  
end Behavior;
