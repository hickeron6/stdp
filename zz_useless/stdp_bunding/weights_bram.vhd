library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;


entity weights_bram is

    generic(
        word_length     : integer := 36;
        N_weights_per_word  : integer := 7;
        rdwr_addr_length    : integer := 10;
        we_length       : integer := 4;
        N_neurons       : integer := 400;
        weights_bit_width   : integer := 5;
        N_bram          : integer := 58;
        bram_sel_length     : integer := 6
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

end entity weights_bram;



architecture behaviour of weights_bram is


    type data_matrix is array(N_bram-1 downto 0) of
        std_logic_vector(word_length-1
        downto 0);

    --signal data_out : data_matrix;

    signal wren_int : std_logic_vector(2**bram_sel_length-1 downto 0):= (others => '0');
    signal rst  : std_logic;
    ------
    signal wren_stdp : std_logic_vector(2**bram_sel_length-1 downto 0):= (others => '0');
    signal wren_buffer : std_logic_vector(2**bram_sel_length-1 downto 0):= (others => '0');  


    
    
    ---Read port buffer for compete
    signal en_buffer             : std_logic := '0';
    signal rdaddr_buffer         : std_logic_vector(rdwr_addr_length-1 downto 0) := (others => '0');

    --type state_type is (idle, weight_fetch, weight_stdp);
    ----
    --signal weight_fetch_sign   : std_logic := '0';
    signal weight_stdp_sign      : std_logic := '0';

    ----Write port buffer for compete
    signal we_buffer             : std_logic_vector(we_length-1 downto 0);
    signal wraddr_buffer         : std_logic_vector(rdwr_addr_length-1 downto 0) := (others => '0');
    signal bram_sel_buffer       : std_logic_vector(bram_sel_length-1 downto 0) := (others => '0');
    signal di_buffer             : std_logic_vector(word_length-1 downto 0) := (others => '0');

    ----Output port
    signal data_out_buffer       :  data_matrix;
    --signal data_out_stdp         :  data_matrix;

    ----
    type State_Type is (IDLE, Weight_fetch, Weight_stdp);
    signal State : State_Type := IDLE;



    component decoder is

        generic(
            N   : integer := 8      
        );

        port(
            -- input
            encoded_in  : in std_logic_vector(N-1 downto 0);

            -- output
            decoded_out : out  std_logic_vector(2**N -1 downto 0)
        );

    end component decoder;


begin

    rst <= not rst_n;

    ------state machine--------
    process (clk, rst, data_out_buffer, di)
    
    variable bram_num : integer := 0;                          --position of bram to stdp
    variable bram_inner_num : integer := 0;                    --position of weight in bram]
    variable weight : std_logic_vector(weights_bit_width-1 downto 0) := (others => '0'); 
    variable data_out : data_matrix;

    variable fetch_sign_count : integer := 0;
    variable data_out_stdp         :  data_matrix;     --


    begin
      if rst = '1' then
        State <= IDLE;

      else
        case State is
          when IDLE =>
            if wren = '1' then
            for i in 0 to we_length-1               --we_length change to weights_bit_width
                loop
                we_buffer(i)   <= wren;
            end loop;

            wraddr_buffer   <= wraddr;
            bram_sel_buffer <= bram_sel;
            di_buffer       <= di;
            wren_buffer     <= wren_int;
            elsif rden = '1' then                                --weight fetch port
              en_buffer     <= rden;
              rdaddr_buffer <= rdaddr;
              
              State   <=  Weight_fetch;
            elsif WeightStdp_en = '1' then                    --weight stdp port
              en_buffer     <= WeightStdp_en;
              rdaddr_buffer <= WeightStdp_addr;               --read the 400 weight
                         
              State   <=  Weight_stdp;
            else
              State   <=  IDLE;
            end if;



          when Weight_fetch =>
          data_out      := data_out_buffer;
            if fetch_sign_count = 1 then
            for i in 0 to N_bram-1
            loop
              do(
                (i+1)*N_weights_per_word*weights_bit_width-1 
                downto
                i*N_weights_per_word*weights_bit_width
              ) <=
              data_out(i)(
                N_weights_per_word*weights_bit_width-1
                downto 
                0
            );
            end loop;
            end if;
            fetch_sign_count := fetch_sign_count + 1;
            if fetch_sign_count = 2 then
              State <= IDLE;
              fetch_sign_count := 0;
            end if;

          when Weight_stdp =>
            data_out_stdp := data_out_buffer; 
            bram_num := to_integer(unsigned(WeightStdp_addr2)) / 7;                 
            bram_inner_num := to_integer(unsigned(WeightStdp_addr2)) mod 7;

            if bram_num /= 0 or bram_inner_num /= 0 then
            weight := data_out_stdp(bram_num)(bram_inner_num*weights_bit_width-1 
                                              downto (bram_inner_num-1)*weights_bit_width);
            weight := weight + Weight_Delta;
            --
            wren_stdp <= (others => '0'); 
            wren_stdp(bram_num) <= '1';                                      --set the write bram num
            wren_buffer     <= wren_stdp;
            di_buffer <= (others => '0');
            di_buffer(bram_inner_num*weights_bit_width-1 
                      downto (bram_inner_num-1)*weights_bit_width) 
                    <= weight;
            wraddr_buffer <= WeightStdp_addr;
            end if;
            
            if WeightStdp_en = '1' then
              State <= Weight_stdp;
            elsif rden = '1' then                                --weight fetch port
              en_buffer     <= rden;
              rdaddr_buffer <= rdaddr;
              
              State   <=  Weight_fetch; 
            else
              State <= IDLE;
            end if;
          end case;
        end if;
      end process;

             

               



    ------state machine--------


    bram_decoder    : decoder
        generic map(
            N       => bram_sel_length
        )

        port map(
            -- input
            encoded_in  => bram_sel,

            -- output
            decoded_out => wren_int
        );

    complete_memory : for i in 0 to N_bram-1
    generate


        BRAM_SDP_MACRO_inst : BRAM_SDP_MACRO
            generic map (

                -- Target BRAM, "18Kb" or "36Kb" 
                BRAM_SIZE       => "36Kb", 

                -- Target device: "VIRTEX5", "VIRTEX6", "7SERIES",
                -- "SPARTAN6" 
                DEVICE          => "7SERIES", 

                -- Valid values are 1-72 (37-72 only valid when
                -- BRAM_SIZE="36Kb")
                WRITE_WIDTH         => word_length,

                -- Valid values are 1-72 (37-72 only valid when
                -- BRAM_SIZE="36Kb")
                READ_WIDTH      => word_length,     

                -- Optional output register (0 or 1)
                DO_REG          => 0, 
                INIT_FILE       => "NONE",

                -- Collision check enable "ALL", "WARNING_ONLY",
                -- "GENERATE_X_ONLY" or "NONE" 
                SIM_COLLISION_CHECK     => "ALL", 
                
                --  Set/Reset value for port output
                SRVAL           => X"000000000", 

                -- Specify "READ_FIRST" for same clock or
                -- synchronous
                -- clocks. Specify "WRITE_FIRST for asynchrononous
                -- clocks on ports
                WRITE_MODE      => "READ_FIRST", 
                               
                --  Initial values on output port
                INIT            => X"000000000" 
            )


            port map (
                
                -- Output read data port, width defined by
                -- READ_WIDTH parameter
                do  => data_out_buffer(i),         

                -- Input write data port, width defined by
                -- WRITE_WIDTH parameter
                di  => di_buffer,         

                -- Input read address, width defined by read
                -- port depth
                rdaddr  => rdaddr_buffer, 

                -- 1-bit input read clock
                rdclk   => clk,   

                -- 1-bit input read port enable
                rden    => en_buffer,     

                -- 1-bit input read output register enable
                regce   => '0',   

                -- 1-bit input reset 
                rst     => rst, 

                -- Input write enable, width defined by write
                -- port depth
                we  => we_buffer,         

                -- Input write address, width defined by write
                -- port depth
                wraddr  => wraddr_buffer, 

                -- 1-bit input write clock
                wrclk   => clk,   

                -- 1-bit input write port enable
                wren    => wren_buffer(i)
            );

    end generate complete_memory;




end architecture behaviour;
