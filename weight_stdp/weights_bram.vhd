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
        WeightStdp_addr : in std_logic_vector(rdwr_addr_length-1 downto 0);          --addr1 input
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

    type addr_matrix is array(784 downto 0) of                     --max num need change
    std_logic_vector(rdwr_addr_length-1
        downto 0);

    type weightD_matrix is array(784 downto 0) of                     --max num need change
    std_logic_vector(weights_bit_width-1 
        downto 0);



    signal data_out : data_matrix;

    signal wren_int : std_logic_vector(2**bram_sel_length-1 downto 0):= (others => '0');
    signal rst  : std_logic;
    ------
    signal wren_stdp : std_logic_vector(2**bram_sel_length-1 downto 0):= (others => '0');
    signal wren_buffer : std_logic_vector(2**bram_sel_length-1 downto 0);--:= (others => '0');  


    
    
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
    type State_Type is (IDLE, Weight_fetch, Weight_stdp_wr, Weight_stdp_rd, Weight_stdp_wr_ff, 
        Weight_stdp_rd_ff, Weight_fetch_ff);
    signal State : State_Type := IDLE;

    ----
    signal stdp_en_count : integer := 0;

    --addr store in stdp
    signal WeightStdp_addr_stor : addr_matrix := (others => (others => '0'));
    signal WeightStdp_addr2_stor : addr_matrix := (others => (others => '0'));
    signal Weight_Delta_stor : weightD_matrix := (others => (others => '0'));
    signal addr_counter : integer := 0;
    signal rden_stor : integer := 0;
    signal weight_stor_count :integer := 0;

    --rd stor
    signal rdaddr_buffer_stor : std_logic_vector(rdwr_addr_length-1 downto 0) := (others => '0');
    --signal rden_buffer : std_logic;
    --signal rd_counter : integer := 3;



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
    process (clk, rst)
    
    variable bram_num : integer := 0;                          --position of bram to stdp
    variable bram_inner_num : integer := 0;                    --position of weight in bram]
    variable weight : std_logic_vector(weights_bit_width-1 downto 0) := (others => '0'); 
    variable weight_line : std_logic_vector(word_length-1 downto 0);
    variable weight_integer : integer;
    --variable data_out : data_matrix;

    variable fetch_sign_count : integer := 0;
    variable data_out_stdp         :  data_matrix;     --

    --
    variable rd_counter : integer := 3;
    --
    --variable rden_buffer : std_logic;





    begin
      if rst = '1' then
        State <= IDLE;

        else
        if rising_edge(clk) then


            if rden = '1' then
                rd_counter := rd_counter + 1;
            end if;



            if WeightStdp_en = '1' then
                WeightStdp_addr_stor(addr_counter) <= WeightStdp_addr;
                WeightStdp_addr2_stor(addr_counter) <= WeightStdp_addr2;
                Weight_Delta_stor(addr_counter) <= Weight_Delta;
                rden_stor <= rden_stor + 1;
                addr_counter <= addr_counter + 1;
                ---
                stdp_en_count <= stdp_en_count + 1;
            end if;    

            
            





            case State is
            ------------------------IDLE
            when IDLE =>
            --
            --en_buffer <= '1';

           

            if wren = '1' then
            for i in 0 to we_length-1               --we_length change to weights_bit_width
            loop
                we_buffer(i)   <= wren;
            end loop;

            
            

            wraddr_buffer   <= wraddr;
            --bram_sel_buffer <= bram_sel;
            di_buffer       <= di;
            wren_buffer     <= wren_int;



            -------------------------
            elsif rden = '1' then


            for i in 0 to we_length-1               --we_length change to weights_bit_width
            loop
                we_buffer(i)   <= '0';
            end loop;
            wren_buffer <= (others => '0');

            en_buffer     <= '1';  

            

            --rden_buffer   <= rden;
            rdaddr_buffer_stor <= rdaddr;
            

            State   <=  Weight_fetch;


            --------------------------
          elsif WeightStdp_en = '1' then                    --weight stdp port
              --
              for i in 0 to we_length-1                     --rd mode
              loop
                we_buffer(i)   <= '1';
            end loop;
              --
              en_buffer     <= '1';
              rdaddr_buffer <= WeightStdp_addr;               --read the 400 weight




              --------

              State   <=  Weight_stdp_wr_ff;
          else
              State   <=  IDLE;
              do      <=  (others => '0');
              we_buffer <= (others => '0');
              di_buffer <= (others => '0');
              wren_buffer <= (others => '0');
              en_buffer <= '1';
              rdaddr_buffer <= (others => '0');


          end if;

      ------------------------------------  
      when Weight_fetch =>
          --data_out      <= data_out_buffer;
          --
          
            for i in 0 to N_bram-1
            loop
              do(
                (i+1)*N_weights_per_word*weights_bit_width-1 
                downto
                i*N_weights_per_word*weights_bit_width
                ) <=
              data_out_buffer(i)(
                N_weights_per_word*weights_bit_width-1
                downto 
                0
                );
          end loop;

          en_buffer <= '1';

          rd_counter := rd_counter - 1;
          report "rd_counter_after = " & integer'image(rd_counter) severity note;

          if rd_counter /= 0 then
              --en_buffer     <= rden_buffer;  
              rdaddr_buffer <= rdaddr_buffer_stor;
              State <= Weight_fetch;





              --rden_buffer <= rden;
              rdaddr_buffer_stor <= rdaddr;
              else
              rd_counter := 3;
              State <= IDLE;
          end if;




      --------------------------------
      when Weight_stdp_wr =>
      
        --
        

            en_buffer     <= '0';
              --

              --data_out_stdp := data_out_buffer; 
              bram_num := to_integer(unsigned(WeightStdp_addr2_stor(addr_counter))) / 7;                --the num of bram   
              bram_inner_num := to_integer(unsigned(WeightStdp_addr2_stor(addr_counter))) mod 7;        --the clonm in the pre select bram

              
              weight_line := data_out_buffer(bram_num);

                


                weight := weight_line((bram_inner_num+1)*weights_bit_width-1 
                  downto bram_inner_num*weights_bit_width);
                
                weight := weight + Weight_Delta_stor(weight_stor_count);
                weight_stor_count <= weight_stor_count + 1;
                weight_line((bram_inner_num+1)*weights_bit_width-1 
                  downto bram_inner_num*weights_bit_width)
                := weight;
                

                ----
                
   
                wren_buffer(bram_num) <= '1';                                      --set the write bram num     
                di_buffer     <= weight_line;
                wraddr_buffer <= WeightStdp_addr_stor(addr_counter - 1);
                ----
                --weight_integer := to_integer(unsigned(WeightStdp_addr_stor(addr_counter - 1)));                             
                --report "write_addr  = " & integer'image(weight_integer) severity note; 
                ----

                ---
                stdp_en_count <= stdp_en_count - 1;
                addr_counter <= addr_counter - 1;

              if stdp_en_count /= 0 then 
                  State <= Weight_stdp_rd_ff;

            else
            State <= IDLE;
            do    <= (others => '0');
            we_buffer <= (others => '0');
            di_buffer <= (others => '0');
            wren_buffer <= (others => '0');
            en_buffer <= '0';
            rdaddr_buffer <= (others => '0');
        end if;



                ----

                --

            --


        -------------------------------
        when Weight_stdp_rd =>
        
            
            for i in 0 to 2**bram_sel_length-1
            loop
                wren_buffer(i) <= '0';
            end loop;

            --

            en_buffer     <= '1';
            rdaddr_buffer <= WeightStdp_addr_stor(addr_counter);

            ---
             --weight_integer := to_integer(unsigned(en_buffer));                             
             --   report "en_buffer = " & integer'image(weight_integer) severity note;
            ---
            ---
            --weight_integer := to_integer(unsigned(rdaddr_buffer));                             
            --report "rdaddr_buffer = " & integer'image(weight_integer) severity note;
            ---
            if stdp_en_count /= 0 then
                State <= Weight_stdp_wr_ff;
                else
                State <= IDLE;

            end if;
            



        ------------------------------------
        when Weight_stdp_rd_ff =>
        
            State <= Weight_stdp_rd;

        -------------------------------------
        when Weight_stdp_wr_ff =>

            State <= Weight_stdp_wr;

        -------------------------------------
        when Weight_fetch_ff =>
            
            State <= Weight_fetch;








        end case;
    end if;
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
                wraddr  => wraddr_buffer,                      --write line

                -- 1-bit input write clock
                wrclk   => clk,   

                -- 1-bit input write port enable  bramsel
                wren    => wren_buffer(i)
                );

    end generate complete_memory;




end architecture behaviour;
