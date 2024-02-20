library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Testbench Entity
entity tb_stdp_weight_bram_test is
-- Testbench doesn't have ports.
end entity tb_stdp_weight_bram_test;

-- Testbench Architecture
architecture behavior of tb_stdp_weight_bram_test is

    -- Constants for the length of vectors, adjust as necessary
    constant word_length     : integer := 36;
    constant N_weights_per_word  : integer := 7;
    constant rdwr_addr_length    : integer := 10;
    constant  we_length       : integer := 4;
    constant N_neurons       : integer := 400;
    constant weights_bit_width   : integer := 5;
    constant N_bram          : integer := 58;
    constant bram_sel_length     : integer := 6;
        -- Additional generics
        constant inputneuron : integer := 5;         -- 784
        constant outputneuron : integer := 5;
        constant addrbit : integer := 10;             -- 10
        constant time_length : integer := 10;         -- 5
        constant A_plus : integer := 1;              -- Using integer
        constant Tau_plus : integer := 32;           -- As the time window
        constant A_neg : integer := 1;               -- Using integer
        constant Tau_neg : integer := 32;             -- As the time window

    -- Local signals for interfacing with the DUT
    signal tb_clk         : std_logic := '0';
    signal tb_di          : std_logic_vector(word_length-1 downto 0) := (others => '0');
    signal tb_rst_n       : std_logic := '0';
    signal tb_rdaddr      : std_logic_vector(rdwr_addr_length-1 downto 0) := (others => '0');
    signal tb_rden        : std_logic := '0';
    signal tb_wren        : std_logic := '0';
    signal tb_wraddr      : std_logic_vector(rdwr_addr_length-1 downto 0) := (others => '0');
    signal tb_bram_sel    : std_logic_vector(bram_sel_length-1 downto 0) := (others => '0');
    signal tb_do          : std_logic_vector(N_bram*N_weights_per_word*weights_bit_width-1 downto 0);
    signal tb_Input_Channel : std_logic_vector(inputneuron-1 downto 0) := (others => '0');
    signal tb_Input_Valid : std_logic := '0';
    signal tb_Output_Channel : std_logic_vector(outputneuron-1 downto 0);
    signal tb_Output_Valid : std_logic;
    
    begin
    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.stdp_weight_bram_test
    generic map(
        word_length => word_length,
        N_weights_per_word => N_weights_per_word,
        rdwr_addr_length => rdwr_addr_length,
            we_length => 4, -- Adjust as necessary
            N_neurons => 400, -- Adjust as necessary
            weights_bit_width => weights_bit_width,
            N_bram => N_bram,
            bram_sel_length => bram_sel_length,
            inputneuron => inputneuron,
            outputneuron => outputneuron,
            addrbit => addrbit, -- Adjust as necessary
            time_length => time_length, -- Adjust as necessary
            A_plus => 1, -- Adjust as necessary
            Tau_plus => 32, -- Adjust as necessary
            A_neg => 1, -- Adjust as necessary
            Tau_neg => 32 -- Adjust as necessary
            )
    port map(
        clk => tb_clk,
        di => tb_di,
        rst_n => tb_rst_n,
        rdaddr => tb_rdaddr,
        rden => tb_rden,
        wren => tb_wren,
        wraddr => tb_wraddr,
        bram_sel => tb_bram_sel,
        do => tb_do,
        Input_Channel => tb_Input_Channel,
        Input_Valid => tb_Input_Valid,
        Output_Channel => tb_Output_Channel,
        Output_Valid => tb_Output_Valid
        );

    -- Clock generation process
    clock_process: process
    begin
        tb_clk <= '0';
        wait for 5 ns; -- 100 MHz Clock
        tb_clk <= '1';
        wait for 5 ns;
    end process;



    -- Test stimulus process
    stimulus_process: process
    begin
        -- Initial reset
        tb_rst_n <= '1';
        wait for 10 ns;
        
        tb_rst_n <= '0';
    ----test for simple stdp
--        tb_Input_Channel <= "10101"; 
--        tb_Input_Valid <= '1';      

--        wait for 120 ns;
--        tb_Input_Channel <= "00000"; 
--        tb_Input_Valid <= '0'; 
--        tb_Output_Channel <= "01000"; 
--        tb_Output_Valid <= '1'; 

--        wait for 200 ns;
--        tb_bram_sel <= "000000";
--        tb_rdaddr <= "0000000011";  -- Read from the same address
--        tb_rden <= '1';

--        wait for 30 ns;
--        tb_rden <= '0';


--        wait for 120 ns;
--        tb_Input_Channel <= "01000"; 
--        tb_Input_Valid <= '1'; 
--        tb_Output_Channel <= "00000"; 
--        tb_Output_Valid <= '0';      

   ---------------------------------
   wait for 10 ns;
   tb_di <= "000000000000000000000000000000000101";
        tb_wraddr <= "0010101010";  -- Write to a specific address
        tb_wren <= '1';
        tb_bram_sel <= "000000";
        --
        wait for 10 ns;
        tb_di <= "000000000000000000000000000000000001";
        tb_wraddr <= "0000000011";  -- Write to a specific address
        tb_wren <= '1';
        tb_bram_sel <= "000000";
        --bram_sel <= std_logic_vector(to_unsigned(1, 6) + to_unsigned(to_integer(unsigned(bram_sel)), 6));
        --end loop;
        

        wait for 10 ns;
        tb_di <= (others => '0');
        tb_wren <= '0';
        wait for 10 ns;
        
        -- Example: Read data from BRAM
        tb_rdaddr <= "0010101010";  -- Read from the same address
        tb_rden <= '1';
        wait for 10 ns;
--        rden <= '0';
--        wait for 10 ns;
        -----
        tb_rdaddr <= "0000000011";  -- Read from the same address
        tb_rden <= '1';
        wait for 10 ns;
--        rden <= '0';
--        wait for 10 ns;
        -- Example: Read data from BRAM
        
        tb_rdaddr <= "0010101010";  -- Read from the same address
        tb_rden <= '1';
        wait for 20 ns;
        
        ---------for the stdp input step
        -----------------------------------
        tb_rdaddr <= (others => '0');
        tb_rden <= '0';
        tb_Input_Channel <= "00101"; 
        tb_Input_Valid <= '1';      
        
        wait for 50 ns;
        tb_Input_Channel <= "00000"; 
        tb_Input_Valid <= '0'; 
        tb_Output_Channel <= "01000"; 
        tb_Output_Valid <= '1'; 
        
--        wait for 120 ns;
----        tb_Input_Channel <= "01000"; 
----        tb_Input_Valid <= '1'; 
----        tb_Output_Channel <= "00000"; 
--        tb_Output_Valid <= '0'; 

wait for 250 ns;
        --------
        --tb_WeightStdp_en   <= '0';
        -----
--        tb_rdaddr <= "0010101010";  -- Read from the same address
        tb_rdaddr <= "0000000011";
        tb_rden <= '1';
        wait for 10 ns;
        ---
        tb_rdaddr <= "0010101010";  -- Read from the same address
--        tb_rdaddr <= "0000000011";  -- Read from the same address
        tb_rden <= '1';
        wait for 10 ns;
        
       -- rden <= '0';
       
        
        
--        wait for 10 ns;
        -- Example: Read data from BRAM
        tb_rdaddr <= "0000000110";  -- Read from the same address
        tb_rden <= '1';
        wait for 10 ns;
        tb_rden <= '0';

        wait;
    end process;

end architecture behavior;
