library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Stdp_tb is
end Stdp_tb;

architecture Behavioral of Stdp_tb is
  constant inputneuron : integer := 5; 
  constant outputneuron : integer := 2; 
  constant addrbit : integer := 10;      
  constant time_length : integer := 10;  
  constant A_plus : integer := 1;       
  constant Tau_plus : integer := 4;    
  constant A_neg : integer := -1;        
  constant Tau_neg : integer := 4;  
  constant weights_bit_width : integer := 5; 

  constant input_spikes_file : string  := "C:\Users\62390\Desktop\ARE\stdp_vhdl\stdp\input_spike.txt";  
  constant output_spikes_file : string  := "C:\Users\62390\Desktop\ARE\stdp_vhdl\stdp\output_spike.txt";
  constant weight_delta_file : string := "C:\Users\62390\Desktop\ARE\stdp_vhdl\stdp\weight_delta_vhdl.txt";

  
  signal Clock : STD_LOGIC := '0';
  signal Reset : STD_LOGIC := '1'; 
  signal ResetDone : BOOLEAN := FALSE; 
  signal Input_Channel : STD_LOGIC_VECTOR(inputneuron-1 downto 0) := (others => '0'); 
  signal Input_Valid : STD_LOGIC := '0';
  signal Output_Channel : STD_LOGIC_VECTOR(outputneuron-1 downto 0) := (others => '0');
  signal Output_Valid : STD_LOGIC := '0';
  signal Weight_Adress_1_pre : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Weight_Adress_2_pre : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Weight_Delta_pre : STD_LOGIC_VECTOR(weights_bit_width-1 downto 0);
  signal Weight_Delta_Indicator_pre : STD_LOGIC;
  signal Weight_Adress_1_post : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal Weight_Adress_2_post : STD_LOGIC_VECTOR(addrbit-1 downto 0);
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
      Weight_Delta_pre => Weight_Delta_pre,
      Weight_Delta_Indicator_pre => Weight_Delta_Indicator_pre,
      Weight_Adress_1_post => Weight_Adress_1_post,
      Weight_Adress_2_post => Weight_Adress_2_post,
      Weight_Delta_post => Weight_Delta_post,
      Weight_Delta_Indicator_post => Weight_Delta_Indicator_post
    );
    
  -- Clock process
  process
    file weightD_file : text open write_mode is weight_delta_file;
    
    variable Weight_Delta_Indi_pre : STD_LOGIC;
    variable Weight_Del_pre : STD_LOGIC_VECTOR(weights_bit_width-1 downto 0);
    variable Weight_Del_line_pre : line;
    
    variable Weight_Delta_Indi_post : STD_LOGIC;
    variable Weight_Del_post : STD_LOGIC_VECTOR(weights_bit_width-1 downto 0);
    variable Weight_Del_line_post : line;

    variable int_value : integer; -- Variable to hold the integer value
  begin
      Clock <= '0';
      wait for 2.5 ns;
      Clock <= '1';
      wait for 2.5 ns;

        -- Write in weight 
    Weight_Delta_Indi_pre := Weight_Delta_Indicator_pre;
    Weight_Del_pre := Weight_Delta_pre;

     if Weight_Delta_Indi_pre = '1' then
    -- Convert binary to integer
    int_value := to_integer(signed(Weight_Del_pre));
    -- Write the integer value to the line variable
    write(Weight_Del_line_pre, int_value);
    --
    int_value := to_integer(unsigned(Weight_Adress_2_pre));
    write(Weight_Del_line_pre, ','); -- Adding a space
    write(Weight_Del_line_pre, int_value);
    int_value := to_integer(unsigned(Weight_Adress_1_pre));       --addr2 for row and addr1 for clumn
    write(Weight_Del_line_pre, ','); -- Adding a space
    write(Weight_Del_line_pre, int_value);
    
    -- Write the line to the file
    writeline(weightD_file, Weight_Del_line_pre);
  end if;
  ---
  Weight_Delta_Indi_post := Weight_Delta_Indicator_post;
  Weight_Del_post := Weight_Delta_post;
  
  if Weight_Delta_Indi_post = '1' then
    -- Convert binary to integer
    int_value := to_integer(signed(Weight_Del_post));
    -- Write the integer value to the line variable
    write(Weight_Del_line_post, int_value);
    --
    int_value := to_integer(unsigned(Weight_Adress_1_post));
    write(Weight_Del_line_post, ','); -- Adding a space
    write(Weight_Del_line_post, int_value);
    int_value := to_integer(unsigned(Weight_Adress_2_post));
    write(Weight_Del_line_post, ','); -- Adding a space
    write(Weight_Del_line_post, int_value);
    -- Write the line to the file
    writeline(weightD_file, Weight_Del_line_post);
  end if; 
  end process;

  -- Simulation 

  read_inputs : process
    file inputs_file : text open read_mode is input_spikes_file;
    file outputs_file : text open read_mode is output_spikes_file;
 
    variable input_read_line : line;
    variable inputs_var : std_logic_vector(inputneuron-1 downto 0);
    variable output_read_line : line;
    variable outputs_var : std_logic_vector(outputneuron-1 downto 0);


  begin
    if not ResetDone then
      
      Reset <= '1';
      ResetDone <= TRUE; 
    end if;

    
    wait for 10 ns;
    -- Read line from file
    if endfile(inputs_file) then
    Input_Valid <= '0';
    Output_Valid <= '0';
    else
    
    --
    readline(inputs_file, input_read_line);
    read(input_read_line, inputs_var);
    readline(outputs_file, output_read_line);
    read(output_read_line, outputs_var);
    
    Reset <= '0';
    Input_Channel <= inputs_var; 
    Input_Valid <= '1';
    Output_Valid <= '0'; 
    wait for 150 ns;
    Output_Channel <= outputs_var; 
    Output_Valid <= '1';
    Input_Valid <= '0';
    
    wait for 150 ns;
    

    end if;



    --
   -- wait for 110 ns;
  end process;

end Behavioral;
