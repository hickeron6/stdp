library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Queue_Module is
  generic (
    inputneuron : integer := 4;  -- Number of input neurons
    addrbit : integer := 10;      -- Event address bit width
    time_length : integer := 5;    -- Time counter bit width
    A_plus : integer := 1;  -- Using integer
    Tau_plus : integer := 32;  -- As the time window
    A_neg : integer := 1;  -- Using integer
    Tau_neg : integer := 32  -- As the time window
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
    Dequeued_Address : out STD_LOGIC_VECTOR(addrbit-1 downto 0);
    Address_oppo : out STD_LOGIC_VECTOR(addrbit-1 downto 0);                      --add
    Dequeued_Time : out STD_LOGIC_VECTOR(time_length-1 downto 0);
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
  type Queue_Type is array (0 to inputneuron * Tau_plus - 1) of Queue_Item;           --need change

  -- Signal to represent the queue
  signal Queue : Queue_Type;
  --signal Input_Buffer : Queue_Type;

  -- Additional signals or ports for enqueue and dequeue operations if needed
  
  ----signal of the input data buffer queue point
  

  type State_Type is (IDLE, OUTPUT_DATA);
  signal State : State_Type := IDLE;

  signal Input_Buffer : Queue_Type;
  signal Input_Buffer_Tail : integer := 0; 
  signal Input_Buffer_Head : integer := 0;
  signal Input_finish : STD_LOGIC;
  signal Part_finish_d : STD_LOGIC;
  
  signal Queue_Tail : integer := 0;
  signal Queue_Head : integer := 0;
  signal Queue_point : integer := 0;



  

  begin

    process(Clock, Reset)
    
    variable eventop_count : integer := 0;

    variable Part_finish : STD_LOGIC;



begin
  if Reset = '1' then
    State <= IDLE;
    Queue_Head <= 0;
    Queue_point <= 0;
    Queue_Tail <= 0;
    Input_Buffer_Tail <= 0;
    Input_Buffer_Head <= 0;
    Part_finish :=  '1';
    Input_finish <= '1';
    for i in Queue'range loop
      Queue(i).Address <= (others => '0');
      Queue(i).Time_Attach <= (others => '0');
    end loop;
    for i in Input_Buffer'range loop
      Input_Buffer(i).Address <= (others => '0');
      Input_Buffer(i).Time_Attach <= (others => '0');
    end loop;

    elsif rising_edge(Clock) then
      if Event_Valid_Oppo = '1' then
        eventop_count := eventop_count + 1;
      --report "eventop_count_pre = " & integer'image(eventop_count) severity note;
    end if;

    case State is
    when IDLE =>
        if eventop_count /= 0 or Event_Valid_Oppo = '1' then --or Input_Buffer_Tail /= Input_Buffer_Head then            --opposite input control
          if Input_Buffer_Tail < inputneuron then
            
            Input_Buffer(Input_Buffer_Tail).Address <= Event_Address_oppo;
            Input_Buffer(Input_Buffer_Tail).Time_Attach <= time_attach_oppo;

              Input_Buffer_Tail <= Input_Buffer_Tail + 1;
              --report "eventop_count = " & integer'image(eventop_count) severity note;
              Input_finish <= '0';
              State <= OUTPUT_DATA;

              
            end if;
          end if;

          


          if Input_finish = '1' and eventop_count = 0 then 

            Input_Buffer_Tail <= 0;
            Input_Buffer_Head <= 0;

            Input_Buffer(0).Address <= (others => '0');
          Input_Buffer(0).Time_Attach <= (others => '0');              --initial buffer and point

        end if;



      --Inqueue       
      if Event_Valid = '1' then
        if Queue_Tail < inputneuron * Tau_plus then
         
          Queue(Queue_Tail).Address <= Event_Address;
          Queue(Queue_Tail).Time_Attach <= time_attach;
          Queue_Head <= Queue_point;
          Queue_Tail <= (Queue_Tail + 1) mod (inputneuron * Tau_plus) ;
          else
          
          Queue_Tail <= (Queue_Tail - inputneuron + 1) mod (inputneuron * Tau_plus); 
          Queue(Queue_Tail).Address <= Event_Address;
          Queue(Queue_Tail).Time_Attach <= time_attach;
          Queue_Head <= Queue_point;
          Queue_Tail <= (Queue_Tail + 1) mod (inputneuron * Tau_plus); 
          report "loop"; 
        end if;
        
      end if;



      when OUTPUT_DATA =>
      --

      
      

      ----Dequeue all element
        --if Queue(Queue_Head).Time_Attach /= (time_length-1 downto 0 => '0') or Queue(Queue_Head).Address /= (addrbit-1 downto 0 => '0') then
          if Queue_Head = inputneuron * Tau_plus  then
            Queue_Head <= (Queue_point + 1) mod (inputneuron * Tau_plus);
            report "Head to end";
          end if;
          
        if Queue_Tail /= Queue_Head then--or Queue(Queue_Head).Time_Attach /= (time_length-1 downto 0 => '0') or Queue(Queue_Head).Address /= (addrbit-1 downto 0 => '0') then
          if to_integer(unsigned(time_attach_oppo)) - to_integer(unsigned(Queue(Queue_Head).Time_Attach)) > Tau_plus then
            Queue(Queue_Head).Address <= (others => '0');
            Queue(Queue_Head).Time_Attach <= (others => '0');
            Queue_point <= (Queue_point + 1) mod (inputneuron * Tau_plus);
            Queue_Head <= (Queue_Head + 1) mod (inputneuron * Tau_plus);                                               --Delect element whitch beyoned time window
            report "out queque";
            else
            Dequeued_Address <= Queue(Queue_Head).Address;
            Dequeued_Time <= Queue(Queue_Head).Time_Attach;
--            report "The value of Queue_point is " & integer'image(Queue_point) severity note;
--            report "The value of Queue_Head is " & integer'image(Queue_Head) severity note;
--            report "The value of Queue_Tail is " & integer'image(Queue_Tail) severity note;
		Queue_Head <= (Queue_Head + 1) mod (inputneuron * Tau_plus);
		Queue_Valid <= '1';
		Part_finish := '0';

	   end if;
	else

	  eventop_count := eventop_count - 1;
	  Part_finish := '1';
          --report"partdone";
          Dequeued_Address <= (others => '0');
          Dequeued_Time <= (others => '0');          
          Queue_Head <= Queue_point;
          Queue_Valid <= '0';

          if eventop_count = 0 then 
            Input_finish <= '1';

            State <= IDLE;  
            else
            Input_finish <= '0'; 
          end if;


          ---

        end if;
        ----

        ----buffer point count
        if Input_finish /= '1' then
          Address_oppo <= Input_Buffer(Input_Buffer_Head).Address;
          Time_oppo <= Input_Buffer(Input_Buffer_Head).Time_Attach;
          if Part_finish ='1' and Part_finish_d ='0'  then
            Input_Buffer_Head <= Input_Buffer_Head + 1;
            
          end if;
        end if;

        
        
        if Input_finish = '1' then
          Input_Buffer_Tail <= 0;
          Input_Buffer_Head <= 0;
        end if;


        if eventop_count /= 0  or Event_Valid_Oppo = '1' then
         Input_Buffer(Input_Buffer_Tail).Address <= Event_Address_oppo;
         Input_Buffer(Input_Buffer_Tail).Time_Attach <= time_attach_oppo;
         --report "eventop_count = " & integer'image(eventop_count) severity note;
         
         if Event_Valid_Oppo = '1' then 

          Input_Buffer_Tail <= Input_Buffer_Tail + 1; 
        end if;                                                 
        
      end if;
      ----
      
    end case;
    Part_finish_d <= Part_finish;
  end if;
end process;


end Behavioral;