library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Weight_Trans_tb is
end Weight_Trans_tb;

architecture Behavioral of Weight_Trans_tb is
  -- Constants for generic parameters
  constant inputneuron : integer := 5;
  constant addrbit : integer := 3;
  constant time_length : integer := 5;
  constant A_plus : integer := 1;
  constant Tau_plus : integer := 16;
  constant A_neg : integer := 1;
  constant Tau_neg : integer := 16;

  -- Signals for testbench
  signal Clock : STD_LOGIC := '0';
  signal Reset : STD_LOGIC := '0';
  signal Event_Address : STD_LOGIC_VECTOR(addrbit-1 downto 0) := (others => '0');
  signal time_attach : STD_LOGIC_VECTOR(time_length-1 downto 0) := (others => '0');
  signal Dequeued_address : STD_LOGIC_VECTOR(addrbit-1 downto 0) := (others => '0');
  signal Dequeued_Time : STD_LOGIC_VECTOR(time_length-1 downto 0) := (others => '0');
  signal Weight_Adress_1 : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Weight_Adress_2 : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Weight_Delta : STD_LOGIC_VECTOR(time_length-1 downto 0);
  signal Weight_Delta_Indicator :  STD_LOGIC;
  signal Event_Valid_oppo : STD_LOGIC;

begin
  -- Instantiate the Weight_Trans module
  DUT : entity work.Weight_Trans
    generic map (
      inputneuron => inputneuron,
      addrbit => addrbit,
      time_length => time_length,
      A_plus => A_plus,
      Tau_plus => Tau_plus,
      A_neg => A_neg,
      Tau_neg => Tau_neg
    )
    port map (
      Clock => Clock,
      Reset => Reset,
      Event_Address => Event_Address,
      time_attach => time_attach,
      Dequeued_address => Dequeued_address,
      Dequeued_Time => Dequeued_Time,
      Weight_Adress_1 => Weight_Adress_1,
      Weight_Adress_2 => Weight_Adress_2,
      Weight_Delta => Weight_Delta,
      Weight_Delta_Indicator => Weight_Delta_Indicator,
      Event_Valid_oppo => Event_Valid_oppo
    );
    
  process
  begin
    wait for 5 ns;  -- Adjust the clock period as needed
    Clock <= not Clock;
  end process;


  -- Clock process
  process
  begin
    wait for 5 ns;  -- Adjust the reset duration as needed
    Reset <= '1';
    wait for 9 ns;
    Reset <= '0';
    Event_Valid_oppo <= '1';
    Event_Address <= "001";
    Dequeued_address <= "010";
    time_attach <= "00100";
    Dequeued_Time <="00001";
    wait for 5 ns;
    Event_Valid_oppo <= '0';
    wait for 5 ns;
    Event_Valid_oppo<= '1';
    Event_Address <= "100";
    Dequeued_address <= "011";
    time_attach <= "01001";
    Dequeued_Time <="00011";
    wait for 5 ns;
    Event_Valid_oppo <= '0';
    wait for 5 ns;
    Event_Valid_oppo<= '1';
    Event_Address <= "100";
    Dequeued_address <= "011";
    time_attach <= "01001";
    Dequeued_Time <="00011";
    wait for 5 ns;
    Event_Valid_oppo <= '0';

    wait;
  end process;
end Behavioral;
