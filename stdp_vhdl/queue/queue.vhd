library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;

entity Queue_Module is
  generic (
    inputneuron : integer := 784;  -- Number of input neurons
    addrbit : integer := 10;      -- Event address bit width
    time_length : integer := 5;    -- Time counter bit width
    A_plus : integer := 1;  -- Using integer
    Tau_plus : integer := 4;  -- As the time window
    A_neg : integer := 1;  -- Using integer
    Tau_neg : integer := 4;  -- As the time window

    ---------------bram
    word_length     : integer := 36;         --time_length + addrbit + 1;
    we_length       : integer := 4;
    rdwr_addr_length    : integer := 10
    );
  port (
    Clock : in STD_LOGIC;                           -- Clock signal
    Reset : in STD_LOGIC;                           -- Reset signal
    Event_Valid : in STD_LOGIC;                   -- Event valid signal
    Event_Valid_Oppo : in STD_LOGIC;                   -- connect to opposite queue
    Event_Address : in STD_LOGIC_VECTOR(addrbit-1 downto 0); -- Event address
    Event_Address_oppo : in STD_LOGIC_VECTOR(addrbit-1 downto 0);                 --add
    time_attach : in STD_LOGIC_VECTOR(time_length-1 downto 0); -- Time attachment
    time_attach_oppo : in STD_LOGIC_VECTOR(time_length-1 downto 0); -- Time attachment
    -- 
    Dequeued_Address : out STD_LOGIC_VECTOR(addrbit-1 downto 0);      --Dequeue address for each oppo input event
    Address_oppo : out STD_LOGIC_VECTOR(addrbit-1 downto 0);                      
    Dequeued_Time : out STD_LOGIC_VECTOR(time_length-1 downto 0);     --Dequeue time for each oppo input event
    Time_oppo : out STD_LOGIC_VECTOR(time_length-1 downto 0);                     --add
    Queue_Valid : out STD_LOGIC
    );
end Queue_Module;

architecture Behavioral of Queue_Module is
  -- Record type to represent each item in the queue
  type Queue_Item is record
    Address : STD_LOGIC_VECTOR(addrbit-1 downto 0);
    Time_Attach : STD_LOGIC_VECTOR(time_length-1 downto 0);
  end record;

  -- Define the queue as an array of Queue_Item records
  type Queue_Type is array (0 to inputneuron ) of Queue_Item;           --need change

  -- Signal to represent the queue
  

  -- Additional signals or ports for enqueue and dequeue operations if needed
  
  ----signal of the input data buffer queue point
  

  type State_Type is (IDLE, OUTPUT_DATA);
  signal State : State_Type := IDLE;

  --signal Queue : Queue_Type;
  --signal Input_Buffer : Queue_Type;
  

  signal Input_Buffer_Tail : integer := 0; 
  signal Input_Buffer_Head : integer := 0;
  signal Input_finish : STD_LOGIC := '1';
  signal Part_finish_d : STD_LOGIC;
  
  signal Queue_Tail : integer := 0;
  signal Queue_Head : integer := 0;
  signal Queue_point : integer := 0;

  ------------------bram
  signal Bram_Queue_addrWR : STD_LOGIC_VECTOR(rdwr_addr_length-1 downto 0) := (others => '0');           --addr of point in bram
  signal Bram_Queue_addrRD : STD_LOGIC_VECTOR(rdwr_addr_length-1 downto 0) := (others => '0');
  signal di_Q : STD_LOGIC_VECTOR(word_length-1 downto 0);
  signal do_Q : STD_LOGIC_VECTOR(word_length-1 downto 0);
  signal wren_Q : STD_LOGIC := '1';
  signal we_Q : STD_LOGIC_VECTOR(we_length-1 downto 0);
  signal rden_Q : STD_LOGIC := '1';

  --signal rd_time : STD_LOGIC_VECTOR(time_length-1 downto 0);

  ------------------
  signal Bram_IB_addrWR : STD_LOGIC_VECTOR(rdwr_addr_length-1 downto 0) := (others => '0');           --addr of point in bram
  signal Bram_IB_addrRD : STD_LOGIC_VECTOR(rdwr_addr_length-1 downto 0) := (others => '0');
  signal di_IB : STD_LOGIC_VECTOR(word_length-1 downto 0);
  signal do_IB : STD_LOGIC_VECTOR(word_length-1 downto 0);
  signal wren_IB : STD_LOGIC := '0';
  signal we_IB : STD_LOGIC_VECTOR(we_length-1 downto 0);
  signal rden_IB : STD_LOGIC := '0';

  --signal rd_time_IB : STD_LOGIC_VECTOR(time_length-1 downto 0);

  -----------------
  signal Queue_Valid_Delay_1, Queue_Valid_Delay_2: std_logic := '0';
  signal Part_finish_Delay_1, Part_finish_Delay_2: std_logic := '0';
  signal Input_finish_Delay_1, Input_finish_Delay_2: std_logic := '1';

  ---------
  signal addr_delay1, addr_delay2 : STD_LOGIC_VECTOR(addrbit-1 downto 0);
  signal time_delay1, time_delay2 : STD_LOGIC_VECTOR(time_length-1 downto 0);


  signal Queue_Valid_sign : STD_LOGIC := '0';


  

  begin

    process(Clock, Reset)
    
    variable eventop_count : integer := 0;

    variable Part_finish : STD_LOGIC := '1';

    variable state_delay : integer := 0;
 
    variable rd_time : STD_LOGIC_VECTOR(time_length-1 downto 0);

    variable rd_addr : STD_LOGIC_VECTOR(addrbit-1 downto 0);

    --variable Queue_Valid_sign : STD_LOGIC := '0';


begin
  if Reset = '1' then
    State <= IDLE;
    Queue_Head <= 0;
    Queue_point <= 0;
    Queue_Tail <= 0;
    Input_Buffer_Tail <= 0;
    Input_Buffer_Head <= 0;
    di_Q <= (others => '0');
    --Part_finish :=  '1';
    --Input_finish <= '1';
    for i in 0 to we_length-1               
            loop
                we_Q(i)   <= '1';
            end loop;
    
    

    elsif rising_edge(Clock) then
      if Event_Valid_Oppo = '1' then
        eventop_count := eventop_count + 1;
      
    end if;

      Queue_Valid_Delay_2 <= Queue_Valid_Delay_1;
      Queue_Valid <= Queue_Valid_Delay_2;

      Part_finish_Delay_2 <= Part_finish_Delay_1;
      Part_finish_d <= Part_finish_Delay_2;

      Queue_Valid_sign <= Queue_Valid_Delay_2;

      --addr_delay2 <= addr_delay1;
      --Dequeued_Address <= addr_delay2;

      --time_delay2 <= time_delay1;
      --Dequeued_Time <= time_delay2;

    case State is
    when IDLE =>

        Queue_Valid <= '0';
        Part_finish_d <= '1';
        Queue_Valid_Delay_1 <= '0';
        --Queue_Head <= 0;

        Queue_Valid_sign <= '0';

        
        --rd_time <= (others => '0');

        --Bram_Queue_addrWR <= (others => '0');
        --Bram_Queue_addrRD <= (others => '0');
        --do_Q <= (others => '0');
        --rden_Q <=

        if eventop_count /= 0 or Event_Valid_Oppo = '1' then             --opposite input control
          
          --# store the first element in buffer and start state
          if Input_Buffer_Tail < inputneuron then
            -----
            di_IB <= (others => '0');
            di_IB (time_length - 1 downto 0) <= time_attach_oppo;               --data in
            di_IB (addrbit + time_length -1 downto time_length) <= Event_Address_oppo;
            Bram_IB_addrWR <= std_logic_vector(to_unsigned(Input_Buffer_Tail, Bram_IB_addrWR'length));     --addr to store
            for i in 0 to we_length-1               
              loop
                  we_IB(i)   <= '1';
              end loop;
            wren_IB <= '1';
            
            --Input_Buffer(Input_Buffer_Tail).Address <= Event_Address_oppo;
            --Input_Buffer(Input_Buffer_Tail).Time_Attach <= time_attach_oppo;
            -----
              Input_Buffer_Tail <= Input_Buffer_Tail + 1;
              --report "eventop_count = " & integer'image(eventop_count) severity note;
              Input_finish <= '0';
              State <= OUTPUT_DATA;

              
            end if;
          end if;

          

          --# initial the input_buffer
          if Input_finish = '1' and eventop_count = 0 then         

            Input_Buffer_Tail <= 0;
            Input_Buffer_Head <= 0;
            -----
            di_IB <= (others => '0');
            --di_IB (time_length - 1 downto 0) <= time_attach_oppo;               --data in
            --di_IB (addrbit + time_length -1 downto time_length) <= Event_Address_oppo;
            Bram_IB_addrWR <= std_logic_vector(to_unsigned( 0 , Bram_IB_addrWR'length));     --addr to store
            for i in 0 to we_length-1               
              loop
                  we_IB(i)   <= '1';
              end loop;
            wren_IB <= '1';
            
            --Input_Buffer(0).Address <= (others => '0');
            --Input_Buffer(0).Time_Attach <= (others => '0');              --initial buffer and point
            -----
            

        end if;



      --# Enqueue step       
      if Event_Valid = '1' then
        --if Queue_Tail < inputneuron * Tau_plus then
          ------
          di_Q (time_length - 1 downto 0) <= time_attach;               --data in
          di_Q (addrbit + time_length -1 downto time_length) <= Event_Address;
          Bram_Queue_addrWR <= std_logic_vector(to_unsigned(Queue_Tail, Bram_Queue_addrWR'length));     --addr to store
          for i in 0 to we_length-1               
            loop
                we_Q(i)   <= '1';
            end loop;
          --wren_Q <= '1';
          --rden_Q <= '0';

          --Queue(Queue_Tail).Address <= Event_Address;
          --Queue(Queue_Tail).Time_Attach <= time_attach;
          ----
          Queue_Head <= Queue_point;
          Queue_Tail <= (Queue_Tail + 1) mod (inputneuron * Tau_plus) ;
        --else
          
        --  Queue_Tail <= (Queue_Tail - inputneuron + 1) mod (inputneuron * Tau_plus); 
        --  ------
        --  di_Q <= (others => '0');
        --  di_Q (time_length - 1 downto 0) <= time_attach;               --data in
        --  di_Q (addrbit + time_length -1 downto time_length) <= Event_Address;
        --  Bram_Queue_addrWR <= std_logic_vector(to_unsigned(Queue_Tail, Bram_Queue_addrWR'length));     --addr to store
        --  for i in 0 to we_length-1               
        --    loop
        --        we_Q(i)   <= '1';
        --    end loop;
        --  wren_Q <= '1';
        --  rden_Q <= '0';

        --  --Queue(Queue_Tail).Address <= Event_Address;
        --  --Queue(Queue_Tail).Time_Attach <= time_attach;
        --  ----
        --  Queue_Head <= Queue_point;
        --  Queue_Tail <= (Queue_Tail + 1) mod (inputneuron * Tau_plus); 
        --  report "loop"; 
        --end if;
        
      end if;



      when OUTPUT_DATA =>
      --
         

          --# input finish for one element
          if eventop_count = 0 then 
            

            state_delay := state_delay + 1;
            
            --report "state_delay = " & integer'image(state_delay) severity note;

            if state_delay = 2 then
              State <= IDLE;
              state_delay := 0;
              Input_finish <= '1';

              --wren_Q <= '0';
              --rden_Q <= '0';


            end if;  
          else 
            Input_finish <= '0'; 
          end if;



      ----# read out all element of the queue in timewindow
        --if Queue(Queue_Head).Time_Attach /= (time_length-1 downto 0 => '0') or Queue(Queue_Head).Address /= (addrbit-1 downto 0 => '0') then
          --if Queue_Head = inputneuron * Tau_plus  then
          --  Queue_Head <= (Queue_point + 1) mod (inputneuron * Tau_plus);
          ----  report "Head to end";
          --end if;
          
          ----
          ----
          
          

        if Queue_Tail /= Queue_Head then
          
          --# when out of the time window
          --if to_integer(unsigned(time_attach_oppo)) - to_integer(unsigned(rd_time)) > Tau_plus then
          --    ------
          --    di_Q <= (others => '0');
          --    Bram_Queue_addrWR <= std_logic_vector(to_unsigned(Queue_Head, Bram_Queue_addrWR'length));     --addr to store
          --    --rden_Q <= '0';
          --    report "Queue_Head = " & integer'image(Queue_Head) severity note;
          --    report "Queue_point = " & integer'image(Queue_point) severity note;
          --    report "rd_time" & integer'image(to_integer(unsigned(rd_time)));

          --  Queue_point <= (Queue_point + 1) mod (inputneuron * Tau_plus);
          --  Queue_Head <= (Queue_Head + 1) mod (inputneuron * Tau_plus);                                               --Delect element whitch beyoned time window
          --  report "out queque";

          --else

          Bram_Queue_addrRD <= std_logic_vector(to_unsigned(Queue_Head, Bram_Queue_addrWR'length));     --addr to store
          --Dequeued_Address(addrbit-1 downto 0) <= do_Q(addrbit + time_length -1 downto time_length) ;
          --Dequeued_Time(time_length-1 downto 0) <= do_Q(time_length-1 downto 0);
          rd_time(time_length-1 downto 0) := do_Q(time_length-1 downto 0);
          rd_addr(addrbit-1 downto 0) := do_Q(addrbit + time_length -1 downto time_length);

          if to_integer(unsigned(time_attach_oppo)) - to_integer(unsigned(rd_time)) > Tau_plus and Queue_Valid_sign = '1' and to_integer(unsigned(rd_time)) /= 0
 then
              di_Q <= (others => '0');
              Bram_Queue_addrWR <= std_logic_vector(to_unsigned(Queue_Head, Bram_Queue_addrWR'length) - 2);     --addr to store
              --rden_Q <= '0';
              --report "Queue_Head = " & integer'image(Queue_Head) severity note;
              --report "Queue_point = " & integer'image(Queue_point) severity note;
              --report "rd_time" & integer'image(to_integer(unsigned(rd_time)));

              Queue_point <= (Queue_point + 1) mod (inputneuron * Tau_plus);
              Queue_Head <= (Queue_Head + 1) mod (inputneuron * Tau_plus);                                               --Delect element whitch beyoned time window
              --report "out queque";

          else

              Dequeued_Address(addrbit-1 downto 0) <= do_Q(addrbit + time_length -1 downto time_length) ;
              Dequeued_Time(time_length-1 downto 0) <= do_Q(time_length-1 downto 0);
          

          end if;


          

          Queue_Head <= (Queue_Head + 1) mod (inputneuron * Tau_plus);
          Queue_Valid_Delay_1 <= '1';
          Part_finish := '0';  

            
            
            ------part finish
            --Bram_Queue_addrRD <= std_logic_vector(to_unsigned(Queue_Head, Bram_Queue_addrWR'length));     --addr to store
            --rden_Q <= '1';
            --Dequeued_Address(addrbit-1 downto 0) <= do_Q(addrbit + time_length -1 downto time_length) ;

      
          ----

         --end if; 
        --end if;
       else
          --* part finish;
          Bram_Queue_addrRD <= std_logic_vector(to_unsigned(Queue_Head, Bram_Queue_addrWR'length));     --addr to store
          Dequeued_Address(addrbit-1 downto 0) <= do_Q(addrbit + time_length -1 downto time_length) ;
          Dequeued_Time(time_length-1 downto 0) <= do_Q(time_length-1 downto 0);



          if eventop_count /= 0 then
            eventop_count := eventop_count - 1;
          end if;

          Part_finish := '1';
          --report"partdone";

          --Dequeued_Address <= (others => '0');
          --Dequeued_Time <= (others => '0');          
          Queue_Head <= Queue_point ;
          Queue_Valid_Delay_1 <= '0';


          


          ---

        end if;
        ----

        ---- input buffer point count and data del
        if Input_finish /= '1' then
          ------
            Bram_IB_addrRD <= std_logic_vector(to_unsigned(Input_Buffer_Head, Bram_IB_addrWR'length));     --addr to store
            rden_IB <= '1';
            Address_oppo(addrbit-1 downto 0) <= do_IB(addrbit + time_length -1 downto time_length) ;
            Time_oppo(time_length-1 downto 0) <= do_IB(time_length-1 downto 0);

            
            --Address_oppo <= Input_Buffer(Input_Buffer_Head).Address;
            --Time_oppo <= Input_Buffer(Input_Buffer_Head).Time_Attach;
          ----
          
          if Part_finish ='1' and Part_finish_Delay_1 ='0'  then
            Input_Buffer_Head <= Input_Buffer_Head + 1;
            
          end if;
        end if;

        
        
        if Input_finish = '1' then
          Input_Buffer_Tail <= 0;
          Input_Buffer_Head <= 0;
        end if;



        if eventop_count /= 0  or Event_Valid_Oppo = '1' then
         -----
            di_IB <= (others => '0');
            di_IB (time_length - 1 downto 0) <= time_attach_oppo;               --data in
            di_IB (addrbit + time_length -1 downto time_length) <= Event_Address_oppo;
            Bram_IB_addrWR <= std_logic_vector(to_unsigned(Input_Buffer_Tail, Bram_IB_addrWR'length));     --addr to store
            for i in 0 to we_length-1               
              loop
                  we_IB(i)   <= '1';
              end loop;
            wren_IB <= '1';

            --Input_Buffer(Input_Buffer_Tail).Address <= Event_Address_oppo;
            --Input_Buffer(Input_Buffer_Tail).Time_Attach <= time_attach_oppo;
         ----- 
         
         --report "eventop_count = " & integer'image(eventop_count) severity note;
         
         if Event_Valid_Oppo = '1' then 

          Input_Buffer_Tail <= Input_Buffer_Tail + 1; 
        end if;                                                 
        
      end if;
      ----
      
    end case;
    Part_finish_Delay_1 <= Part_finish;
    --Part_finish_d <= Part_finish;
  end if;
end process;



        BRAM_QUEUE : BRAM_SDP_MACRO
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
                do  => do_Q,         

                -- Input write data port, width defined by
                -- WRITE_WIDTH parameter
                di  => di_Q,         

                -- Input read address, width defined by read
                -- port depth
                rdaddr  => Bram_Queue_addrRD, 

                -- 1-bit input read clock
                rdclk   => Clock,   

                -- 1-bit input read port enable
                rden    => rden_Q,     

                -- 1-bit input read output register enable
                regce   => '0',   

                -- 1-bit input reset 
                rst     => Reset, 

                -- Input write enable, width defined by write
                -- port depth
                we  => we_Q,         

                -- Input write address, width defined by write
                -- port depth
                wraddr  => Bram_Queue_addrWR,                      --write line

                -- 1-bit input write clock
                wrclk   => Clock,   

                -- 1-bit input write port enable  bramsel
                wren    => wren_Q
                );


        BRAM_Input_buffer : BRAM_SDP_MACRO
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
                do  => do_IB,         

                -- Input write data port, width defined by
                -- WRITE_WIDTH parameter
                di  => di_IB,         

                -- Input read address, width defined by read
                -- port depth
                rdaddr  => Bram_IB_addrRD, 

                -- 1-bit input read clock
                rdclk   => Clock,   

                -- 1-bit input read port enable
                rden    => rden_IB,     

                -- 1-bit input read output register enable
                regce   => '0',   

                -- 1-bit input reset 
                rst     => Reset, 

                -- Input write enable, width defined by write
                -- port depth
                we  => we_IB,         

                -- Input write address, width defined by write
                -- port depth
                wraddr  => Bram_IB_addrWR,                      --write line

                -- 1-bit input write clock
                wrclk   => Clock,   

                -- 1-bit input write port enable  bramsel
                wren    => wren_IB
                );

    

end Behavioral;
