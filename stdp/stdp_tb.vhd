library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Stdp_tb is
end Stdp_tb;

architecture Behavioral of Stdp_tb is
  constant inputneuron : integer := 5;  
  constant addrbit : integer := 3;      
  constant time_length : integer := 7;  
  constant A_plus : integer := 1;       
  constant Tau_plus : integer := 32;    
  constant A_neg : integer := 1;        
  constant Tau_neg : integer := 32;     
  
  signal Clock : STD_LOGIC := '0';
  signal Reset : STD_LOGIC := '0';
  signal Input_Channel : STD_LOGIC_VECTOR(inputneuron-1 downto 0) := (others => '0'); 
  signal Input_Valid : STD_LOGIC := '0';
  signal Output_Channel : STD_LOGIC_VECTOR(inputneuron-1 downto 0):= (others => '0');
  signal Output_Valid : STD_LOGIC:= '0';
  signal Weight_Adress_1 : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Weight_Adress_2 : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Weight_Delta : STD_LOGIC_VECTOR(time_length-1 downto 0);
  signal Weight_Delta_Indicator : STD_LOGIC;
  
begin
  DUT : entity work.Stdp
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
      Input_Channel => Input_Channel,
      Input_Valid => Input_Valid,
      Output_Channel => Output_Channel,
      Output_Valid => Output_Valid,
      Weight_Adress_1 => Weight_Adress_1,
      Weight_Adress_2 => Weight_Adress_2,
      Weight_Delta => Weight_Delta,
      Weight_Delta_Indicator => Weight_Delta_Indicator
    );
    
  -- Clock process
  process
  begin
      Clock <= '0';
      wait for 5 ns;
      Clock <= '1';
      wait for 5 ns;
  end process;

  -- Simulation stopper

process
begin
    Reset <= '1';
    wait for 10 ns;
    
    Reset <= '0';
    Input_Channel <= "10101"; 
    Input_Valid <= '1';      
    
    wait for 120 ns;
    Input_Channel <= "00000"; 
    Input_Valid <= '0'; 
    Output_Channel <= "01000"; 
    Output_Valid <= '1'; 
    
    wait for 120 ns;
    Input_Channel <= "01000"; 
    Input_Valid <= '1'; 
    Output_Channel <= "00000"; 
    Output_Valid <= '0';      

    wait for 20 ns;

    -- ... 可以继续更新输入信号的值和等待更多时间 ...
    
    wait;
end process;

end Behavioral;
