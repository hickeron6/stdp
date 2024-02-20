LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_weights_bram IS
END tb_weights_bram;

ARCHITECTURE behavior OF tb_weights_bram IS 

    CONSTANT word_length : INTEGER := 36;
    CONSTANT N_weights_per_word :INTEGER :=7;
    CONSTANT rdwr_addr_length : INTEGER := 10;
    CONSTANT we_length : INTEGER := 4;
    CONSTANT N_neurons : INTEGER := 400;
    CONSTANT weights_bit_width : INTEGER := 5;
    CONSTANT N_bram : INTEGER := 58;
    CONSTANT bram_sel_length : INTEGER := 6;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL di : STD_LOGIC_VECTOR(word_length-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rst_n : STD_LOGIC := '0';
    SIGNAL rdaddr : STD_LOGIC_VECTOR(rdwr_addr_length-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rden : STD_LOGIC := '0';
    SIGNAL wren : STD_LOGIC := '0';
    SIGNAL wraddr : STD_LOGIC_VECTOR(rdwr_addr_length-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL bram_sel : STD_LOGIC_VECTOR(bram_sel_length-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL do : STD_LOGIC_VECTOR(N_bram * N_weights_per_word*weights_bit_width-1 DOWNTO 0) ;
    --
    signal WeightStdp_en   :  std_logic := '0';
    signal WeightStdp_addr :  std_logic_vector(rdwr_addr_length-1 downto 0):= (OTHERS => '0');
    signal WeightStdp_addr2 :  std_logic_vector(rdwr_addr_length-1 downto 0):= (OTHERS => '0');
    signal Weight_Delta :  std_logic_vector(weights_bit_width-1 downto 0):= (OTHERS => '0');


    --

    COMPONENT weights_bram
        GENERIC(
            word_length : INTEGER;
            N_weights_per_word : INTEGER;
            rdwr_addr_length : INTEGER;
            we_length : INTEGER;
            N_neurons : INTEGER;
            weights_bit_width : INTEGER;
            N_bram : INTEGER;
            bram_sel_length : INTEGER
        );
        port(
        -- input
        clk     : in std_logic;
        di      : in std_logic_vector(word_length-1 downto 0);
        rst_n       : in std_logic;
        rdaddr      : in std_logic_vector(rdwr_addr_length-1 
                    downto 0);
        rden        : in std_logic;
        wren        : in std_logic;
        wraddr      : in std_logic_vector(rdwr_addr_length-1
                    downto 0);
        bram_sel    : in std_logic_vector(bram_sel_length-1 
                    downto 0);

        

        -- weight stdp port

        WeightStdp_en   : in std_logic;
        WeightStdp_addr : in std_logic_vector(rdwr_addr_length-1 downto 0);
        WeightStdp_addr2 : in std_logic_vector(rdwr_addr_length-1 downto 0);
        Weight_Delta : in std_logic_vector(weights_bit_width-1 downto 0);            --time length need define,may be 5

        -- output
        do      : out std_logic_vector(N_bram*
                    N_weights_per_word*
                    weights_bit_width-1 
                    downto 0)    
    );
    END COMPONENT;

    BEGIN
        uut: COMPONENT weights_bram
            GENERIC MAP (
                word_length => word_length,
                N_weights_per_word => 7,
                rdwr_addr_length => rdwr_addr_length,
                we_length => we_length,
                N_neurons => N_neurons,
                weights_bit_width => weights_bit_width,
                N_bram => N_bram,
                bram_sel_length => bram_sel_length
            )
            PORT MAP (
                clk => clk,
                di => di,
                rst_n => rst_n,
                rdaddr => rdaddr,
                rden => rden,
                wren => wren,
                wraddr => wraddr,
                bram_sel => bram_sel,
                do => do,
                --
                WeightStdp_en => WeightStdp_en,
                WeightStdp_addr => WeightStdp_addr,
                WeightStdp_addr2 => WeightStdp_addr2,
                Weight_Delta => Weight_Delta
            );

    clk_process : PROCESS
    BEGIN
        -- Initialize your testbench signals and apply stimulus here
        rst_n <= '0';  -- Assert reset
        wait for 10 ns;
        rst_n <= '1';  -- Deassert reset
        
        
        -- Example: Write data to BRAM
       --for i in 0 to 57 
        --loop
        wait for 10 ns;
        di <= "000000000000000000000000000000001101";
        wraddr <= "0010101010";  -- Write to a specific address
        wren <= '1';
        bram_sel <= "000000";
        --bram_sel <= std_logic_vector(to_unsigned(1, 6) + to_unsigned(to_integer(unsigned(bram_sel)), 6));
        --end loop;


        wait for 10 ns;
        wren <= '0';
        wait for 10 ns;
        
        -- Example: Read data from BRAM
        rdaddr <= "0010101010";  -- Read from the same address
        rden <= '1';
        wait for 10 ns;
--        rden <= '0';
--        wait for 10 ns;
        -----
        rdaddr <= "0000101011";  -- Read from the same address
        rden <= '1';
        wait for 10 ns;
--        rden <= '0';
--        wait for 10 ns;
        -- Example: Read data from BRAM
        rdaddr <= "0010101010";  -- Read from the same address
        rden <= '1';
        wait for 5 ns;
        ---------
        rden <= '0';
        rdaddr <= (others => '0');
        WeightStdp_en   <= '1';
        WeightStdp_addr <= "0000101011";
        WeightStdp_addr2  <= "0000000001";
        Weight_Delta  <= "00010";
        --
--        wait for 20 ns;
--        WeightStdp_en   <= '1';
--        WeightStdp_addr <= "0000101011";
--        WeightStdp_addr2  <= "0000000010";
--        Weight_Delta  <= "00010";

        wait for 100 ns;
        --------
        WeightStdp_en   <= '0';
        rdaddr <= "0000101011";  -- Read from the same address
        rden <= '1';
        wait for 10 ns;
--        rden <= '0';
--        wait for 10 ns;
        -- Example: Read data from BRAM
        rdaddr <= "0010101010";  -- Read from the same address
        rden <= '1';
        wait for 10 ns;
        rden <= '0';
        
        -- Continue with your test scenarios

        -- End simulation
        wait;
    END PROCESS;

    process
  begin
      clk <= '0';
      wait for 5 ns;
      clk <= '1';
      wait for 5 ns;
  end process;
END;
