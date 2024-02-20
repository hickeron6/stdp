library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Stdp_tb is
end Stdp_tb;

architecture Behavioral of Stdp_tb is
  constant inputneuron : integer := 5;
  constant outputneuron : integer := 5;  
  constant addrbit : integer := 10;      
  constant time_length : integer := 10;  
  constant A_plus : integer := 1;       
  constant Tau_plus : integer := 32;    
  constant A_neg : integer := 1;        
  constant Tau_neg : integer := 32;  
  constant weights_bit_width : integer := 5;   
  
  signal Clock : STD_LOGIC := '0';
  signal Reset : STD_LOGIC := '0';
  signal Input_Channel : STD_LOGIC_VECTOR(inputneuron-1 downto 0) := (others => '0'); 
  signal Input_Valid : STD_LOGIC := '0';
  signal Output_Channel : STD_LOGIC_VECTOR(outputneuron-1 downto 0):= (others => '0');
  signal Output_Valid : STD_LOGIC:= '0';
  signal Weight_Adress_1_pre : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Weight_Adress_2_pre : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Weight_Adress_1_post : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Weight_Adress_2_post : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Weight_Delta_pre : STD_LOGIC_VECTOR(weights_bit_width-1 downto 0);
  signal Weight_Delta_Indicator_pre : STD_LOGIC;
  signal Weight_Delta_post : STD_LOGIC_VECTOR(weights_bit_width-1 downto 0);
  signal Weight_Delta_Indicator_post : STD_LOGIC;
  
begin
  DUT : entity work.Stdp
    generic map (
      inputneuron => inputneuron,
      outputneuron => outputneuron,
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
      Weight_Adress_1_pre => Weight_Adress_1_pre,
      Weight_Adress_2_pre => Weight_Adress_2_pre,
      Weight_Adress_1_post => Weight_Adress_1_post,
      Weight_Adress_2_post => Weight_Adress_2_post,
      Weight_Delta_pre => Weight_Delta_pre,
      Weight_Delta_Indicator_pre => Weight_Delta_Indicator_pre,
      Weight_Delta_post => Weight_Delta_post,
      Weight_Delta_Indicator_post => Weight_Delta_Indicator_post
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
      -- test1
    Reset <= '1';
    wait for 100 ns;
    
    Reset <= '0';
    Input_Channel <= "00100"; 
    Input_Valid <= '1';      
    
    wait for 120 ns;
    Input_Channel <= "00110"; 
    Input_Valid <= '1'; 
    Output_Channel <= "01010"; 
    Output_Valid <= '1'; 
    
    wait for 120 ns;
    Input_Channel <= "01100"; 
    Input_Valid <= '1'; 
    Output_Channel <= "00001"; 
    Output_Valid <= '1';      

    wait for 120 ns;
    Input_Channel <= "00000"; 
    Input_Valid <= '0'; 
    Output_Channel <= "00010"; 
    Output_Valid <= '1';
    
    wait for 20 ns;

    -- ----test2
--    Reset <= '1';
--    wait for 100 ns;
    
--    Reset <= '0';
--    Input_Channel <= "00101"; 
--    Input_Valid <= '1';      
    
--    wait for 120 ns;
--    Input_Channel <= "00000"; 
--    Input_Valid <= '0'; 
--    Output_Channel <= "01110"; 
--    Output_Valid <= '1'; 
    
--    wait for 120 ns;
--    Input_Channel <= "01110"; 
--    Input_Valid <= '1'; 
--    Output_Channel <= "00000"; 
--    Output_Valid <= '0';      

--    wait for 120 ns;
--    Input_Channel <= "00000"; 
--    Input_Valid <= '0'; 
--    Output_Channel <= "00010"; 
--    Output_Valid <= '1';
    
--    wait for 20 ns;
    
    
    wait;
end process;

end Behavioral;
