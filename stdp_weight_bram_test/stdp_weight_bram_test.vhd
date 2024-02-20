library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity stdp_weight_bram_test is
    generic(
        word_length     : integer := 36;
        N_weights_per_word  : integer := 7;
        rdwr_addr_length    : integer := 10;
        we_length       : integer := 4;
        N_neurons       : integer := 400;
        weights_bit_width   : integer := 5;
        N_bram          : integer := 58;
        bram_sel_length     : integer := 6;
        -----Additional generics
        inputneuron : integer := 784;         -- 784
        outputneuron : integer := 400;
        addrbit : integer := 10;             -- 10
        time_length : integer := 10;         -- 5
        A_plus : integer := 1;              -- Using integer
        Tau_plus : integer := 32;           -- As the time window
        A_neg : integer := 1;               -- Using integer
        Tau_neg : integer := 32             -- As the time window
    );

    port(
        -- input
        clk     : in std_logic;
        di      : in std_logic_vector(word_length-1 downto 0);
        rst_n       : in std_logic;
        rdaddr      : in std_logic_vector(rdwr_addr_length-1 downto 0);
        rden        : in std_logic;
        wren        : in std_logic;
        wraddr      : in std_logic_vector(rdwr_addr_length-1 downto 0);
        bram_sel    : in std_logic_vector(bram_sel_length-1 downto 0);

        -- output
        do      : out std_logic_vector(N_bram*
                    N_weights_per_word*
                    weights_bit_width-1 downto 0);

        -- Additional ports for stdp logic
        Input_Channel : in STD_LOGIC_VECTOR(inputneuron-1 downto 0); -- Input channels
        Input_Valid : in STD_LOGIC;
        Output_Channel : in STD_LOGIC_VECTOR(inputneuron-1 downto 0); -- Output channels
        Output_Valid : in STD_LOGIC

        -- The following ports are commented out because they are not connected in the architecture
        -- Weight_Adress_1 : out STD_LOGIC_VECTOR(addrbit-1 downto 0);
        -- Weight_Adress_2 : out STD_LOGIC_VECTOR(addrbit-1 downto 0);
        -- Weight_Delta : out STD_LOGIC_VECTOR(time_length-1 downto 0);
        -- Weight_Delta_Indicator : out STD_LOGIC  -- Indicator for Weight_Delta               
    );
end entity stdp_weight_bram_test;

architecture behavior of stdp_weight_bram_test is
        
    signal WeightStdp_en   : std_logic;
    signal WeightStdp_addr : std_logic_vector(10-1 downto 0);                  -----???
    signal WeightStdp_addr2 : std_logic_vector(10-1 downto 0);
    signal Weight_Delta : std_logic_vector(weights_bit_width-1 downto 0);

    signal rst_inverted : std_logic;
    -----
    signal Weight_Adress_1_pre : STD_LOGIC_VECTOR(addrbit-1 downto 0);
    signal Weight_Adress_2_pre : STD_LOGIC_VECTOR(addrbit-1 downto 0);
    signal Weight_Adress_1_post : STD_LOGIC_VECTOR(addrbit-1 downto 0);
    signal Weight_Adress_2_post : STD_LOGIC_VECTOR(addrbit-1 downto 0);
    signal Weight_Delta_pre : STD_LOGIC_VECTOR(weights_bit_width-1 downto 0);
    signal Weight_Delta_Indicator_pre : STD_LOGIC;  -- Indicator for Weight_Delta
    signal Weight_Delta_post : STD_LOGIC_VECTOR(weights_bit_width-1 downto 0);
    signal Weight_Delta_Indicator_post : STD_LOGIC ; -- Indicator for Weight_Delta  



    component stdp is
        generic (
        inputneuron : integer := 784;         --784
        outputneuron : integer := 400;
        addrbit : integer := 10;             --10
        time_length : integer := 10;           --5
        A_plus : integer := 1;  -- Using integer
        Tau_plus : integer := 32;  -- As the time window
        A_neg : integer := 1;  -- Using integer
        Tau_neg : integer := 32;  -- As the time window
        weights_bit_width : integer := 5
  );
  port (
        Clock : in STD_LOGIC;                           -- Clock signal
        Reset : in STD_LOGIC;                           -- Reset signal
        Input_Channel : in STD_LOGIC_VECTOR(inputneuron-1 downto 0); -- Input channels
        Input_Valid : in STD_LOGIC;
        Output_Channel : in STD_LOGIC_VECTOR(outputneuron-1 downto 0); -- Input channels
        Output_Valid : in STD_LOGIC;

        Weight_Adress_1_pre : out STD_LOGIC_VECTOR(addrbit-1 downto 0);
        Weight_Adress_2_pre : out STD_LOGIC_VECTOR(addrbit-1 downto 0);
        Weight_Adress_1_post : out STD_LOGIC_VECTOR(addrbit-1 downto 0);
        Weight_Adress_2_post : out STD_LOGIC_VECTOR(addrbit-1 downto 0);
        Weight_Delta_pre : out STD_LOGIC_VECTOR(weights_bit_width-1 downto 0);
        Weight_Delta_Indicator_pre : out STD_LOGIC;  -- Indicator for Weight_Delta
        Weight_Delta_post : out STD_LOGIC_VECTOR(weights_bit_width-1 downto 0);
        Weight_Delta_Indicator_post : out STD_LOGIC  -- Indicator for Weight_Delta
  );  
    end component stdp;

    component weights_bram is
        generic(
            word_length     : integer := 36;
            N_weights_per_word  : integer := 7;
            rdwr_addr_length    : integer := 10;
            we_length       : integer := 4;
            N_neurons       : integer := 400;
            weights_bit_width   : integer := 10;
            N_bram          : integer := 58;
            bram_sel_length     : integer := 6
        );
        port(
            clk     : in std_logic;
            di      : in std_logic_vector(word_length-1 downto 0);
            rst_n       : in std_logic;
            rdaddr      : in std_logic_vector(rdwr_addr_length-1 downto 0);
            rden        : in std_logic;
            wren        : in std_logic;
            wraddr      : in std_logic_vector(rdwr_addr_length-1 downto 0);
            bram_sel    : in std_logic_vector(bram_sel_length-1 downto 0);
            -- weight stdp port
            WeightStdp_en   : in std_logic;
            WeightStdp_addr : in std_logic_vector(rdwr_addr_length-1 downto 0);
            WeightStdp_addr2 : in std_logic_vector(rdwr_addr_length-1 downto 0);
            Weight_Delta : in std_logic_vector(weights_bit_width-1 downto 0);
            -- output
            do      : out std_logic_vector(N_bram*
                        N_weights_per_word*
                        weights_bit_width-1 downto 0)
        );
    end component weights_bram;

begin  

    rst_inverted <= not rst_n;


    COM_STDP : stdp
        generic map(
            inputneuron => inputneuron,
            outputneuron=> outputneuron,
            addrbit     => rdwr_addr_length,
            time_length => time_length,
            A_plus      => A_plus,
            Tau_plus    => Tau_plus,
            A_neg       => A_neg,
            Tau_neg     => Tau_neg,
            weights_bit_width => weights_bit_width
        )
        port map(
            Clock               => clk,
            Reset               => rst_n,
            Input_Channel       => Input_Channel,
            Input_Valid         => Input_Valid,
            Output_Channel      => Output_Channel,
            Output_Valid        => Output_Valid,
            Weight_Adress_1_pre => Weight_Adress_1_pre,
            Weight_Adress_2_pre => Weight_Adress_2_pre,
            Weight_Adress_1_post=> Weight_Adress_1_post,
            Weight_Adress_2_post=> Weight_Adress_2_post,
            Weight_Delta_pre    => Weight_Delta_pre,
            Weight_Delta_post   => Weight_Delta_post,
            Weight_Delta_Indicator_pre => Weight_Delta_Indicator_pre,
            Weight_Delta_Indicator_post => Weight_Delta_Indicator_post
        );

    COM_WEIGHT_BRAM : weights_bram
        generic map(
            word_length         => word_length,
            N_weights_per_word  => N_weights_per_word,
            rdwr_addr_length    => rdwr_addr_length,
            we_length           => we_length,
            N_neurons           => N_neurons,
            weights_bit_width   => weights_bit_width,
            N_bram              => N_bram,
            bram_sel_length     => bram_sel_length
        )
        port map(
            clk                 => clk,
            di                  => di,
            rst_n               => rst_inverted,
            rdaddr              => rdaddr,
            rden                => rden,
            wren                => wren,
            wraddr              => wraddr,
            bram_sel            => bram_sel,
            WeightStdp_en       => WeightStdp_en,
            WeightStdp_addr     => WeightStdp_addr,
            WeightStdp_addr2    => WeightStdp_addr2,
            Weight_Delta        => Weight_Delta,
            do                  => do
        );


      process(clk)
      begin
        if Weight_Delta_Indicator_pre /= '0' then
            WeightStdp_en <= Weight_Delta_Indicator_pre;
            WeightStdp_addr <= Weight_Adress_1_pre;
            WeightStdp_addr2 <= Weight_Adress_2_pre;
            Weight_Delta <= Weight_Delta_pre;
        elsif Weight_Delta_Indicator_post /= '0' then
            WeightStdp_en <= Weight_Delta_Indicator_post;
            WeightStdp_addr <= Weight_Adress_1_post;
            WeightStdp_addr2 <= Weight_Adress_2_post;
            Weight_Delta <= Weight_Delta_post;
        else
            Weight_Delta <= (others => '0');
            WeightStdp_en <= '0';
            WeightStdp_addr <= (others => '0');
            WeightStdp_addr2 <= (others => '0');
        end if;

      end process;




end architecture behavior;
