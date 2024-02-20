library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Stdp is
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
end entity Stdp;


architecture behavior of Stdp is
  signal Event_Valid_pre : STD_LOGIC := '0';                   
  signal Event_Address_pre : STD_LOGIC_VECTOR(addrbit-1 downto 0) := (others => '0');
  signal time_attach_pre : STD_LOGIC_VECTOR(time_length-1 downto 0) := (others => '0');
  signal Event_Valid_post : STD_LOGIC := '0';                   
  signal Event_Address_post : STD_LOGIC_VECTOR(addrbit-1 downto 0) := (others => '0');
  signal time_attach_post : STD_LOGIC_VECTOR(time_length-1 downto 0) := (others => '0');
  --
  signal Dequeued_Address_pre : STD_LOGIC_VECTOR(addrbit-1 downto 0) := (others => '0');
  signal Dequeued_Time_pre : STD_LOGIC_VECTOR(time_length-1 downto 0) := (others => '0');
  signal Dequeued_Address_post : STD_LOGIC_VECTOR(addrbit-1 downto 0) := (others => '0');
  signal Dequeued_Time_post : STD_LOGIC_VECTOR(time_length-1 downto 0) := (others => '0');
  signal Queue_Valid_pre : STD_LOGIC;
  signal Queue_Valid_post : STD_LOGIC;
  --
  signal Transis_Addr_pre : STD_LOGIC_VECTOR(addrbit-1 downto 0) := (others => '0');
  signal Transis_Time_pre : STD_LOGIC_VECTOR(time_length-1 downto 0) := (others => '0');
  signal Transis_Addr_post : STD_LOGIC_VECTOR(addrbit-1 downto 0) := (others => '0');
  signal Transis_Time_post : STD_LOGIC_VECTOR(time_length-1 downto 0) := (others => '0');
  --
--  signal Weight_Delta_pre : STD_LOGIC_VECTOR(weights_bit_width-1 downto 0) := (others => '0');
--  signal Weight_Delta_post : STD_LOGIC_VECTOR(weights_bit_width-1 downto 0) := (others => '0');
--  signal Weight_Delta_Indicator_pre : STD_LOGIC := '0';
--  signal Weight_Delta_Indicator_post : STD_LOGIC := '0';
--  signal Weight_Adress_1_pre : STD_LOGIC_VECTOR(addrbit-1 downto 0) := (others => '0');
--  signal Weight_Adress_2_pre : STD_LOGIC_VECTOR(addrbit-1 downto 0) := (others => '0');
--  signal Weight_Adress_1_post : STD_LOGIC_VECTOR(addrbit-1 downto 0) := (others => '0');
--  signal Weight_Adress_2_post : STD_LOGIC_VECTOR(addrbit-1 downto 0) := (others => '0');

component AER_Encoder is
generic (
    inputneuron : integer := 784;  -- Number of input neurons, default is 784
    addrbit : integer := 10;         -- Event address bit width, default is 10 bits
    time_length : integer := 5
    );
Port (
    Clock : in STD_LOGIC;                           -- Clock signal
    Reset : in STD_LOGIC;                           -- Reset signal
    Input_Channel : in STD_LOGIC_VECTOR(inputneuron-1 downto 0); -- Input channels
    Input_Valid : in STD_LOGIC;
    
    Event_Valid : out STD_LOGIC;                   -- Event valid signal
    Event_Address : out STD_LOGIC_VECTOR(addrbit-1 downto 0);-- Event address
    time_attach : out STD_LOGIC_VECTOR(time_length-1 downto 0)
    );
end component AER_Encoder;

component Queue_Module is 
generic (
    inputneuron : integer := 784;  -- Number of input neurons
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
    Event_Address_oppo : in STD_LOGIC_VECTOR(addrbit-1 downto 0);
    time_attach : in STD_LOGIC_VECTOR(time_length-1 downto 0); -- Time attachment
    time_attach_oppo : in STD_LOGIC_VECTOR(time_length-1 downto 0);
    -- 
    Dequeued_Address : out STD_LOGIC_VECTOR(addrbit-1 downto 0);
    Address_oppo : out STD_LOGIC_VECTOR(addrbit-1 downto 0);
    Dequeued_Time : out STD_LOGIC_VECTOR(time_length-1 downto 0);
    Time_oppo : out STD_LOGIC_VECTOR(time_length-1 downto 0);
    Queue_Valid : out STD_LOGIC  
    );
end component Queue_Module;

component Weight_Trans is
generic (
  inputneuron : integer := 784;
  addrbit : integer := 10;
  time_length : integer := 5;
    A_plus : integer := 1;  -- Using integer
    Tau_plus : integer := 32;  -- As the time window
    A_neg : integer := 1;  -- Using integer
    Tau_neg : integer := 32;  -- As the time window
    weights_bit_width : integer := 5
    );
port (
  Clock : in STD_LOGIC;
  Reset : in STD_LOGIC;
  Event_Valid_oppo : in STD_LOGIC;
  Event_Address : in STD_LOGIC_VECTOR(addrbit-1 downto 0);
  time_attach : in STD_LOGIC_VECTOR(time_length-1 downto 0);
  Dequeued_address : in STD_LOGIC_VECTOR(addrbit-1 downto 0);
  Dequeued_Time : in STD_LOGIC_VECTOR(time_length-1 downto 0);

  Weight_Adress_1 : out STD_LOGIC_VECTOR(addrbit-1 downto 0);
  Weight_Adress_2 : out STD_LOGIC_VECTOR(addrbit-1 downto 0);
  Weight_Delta : out STD_LOGIC_VECTOR(weights_bit_width-1 downto 0);
    Weight_Delta_Indicator : out STD_LOGIC  -- Indicator for Weight_Delta
    );
end component Weight_Trans;


begin

  Pre_encoder : AER_Encoder
  generic map(
    inputneuron    =>   inputneuron,
    addrbit        =>   addrbit,
    time_length    =>   time_length
    )
  port map(
    Clock          =>   Clock,
    Reset          =>   Reset,
    Input_Channel  =>   Input_Channel,
    Input_Valid    =>   Input_Valid,
    --
    Event_Valid    =>   Event_Valid_pre,
    Event_Address  =>   Event_Address_pre,
    time_attach    =>   time_attach_pre
    );

  Post_encoder : AER_Encoder
  generic map(
    inputneuron    =>   outputneuron,
    addrbit        =>   addrbit,
    time_length    =>   time_length
    )
  port map(
    Clock          =>   Clock,
    Reset          =>   Reset,
    Input_Channel  =>   Output_Channel,
    Input_Valid    =>   Output_Valid,
    --
    Event_Valid    =>   Event_Valid_post,
    Event_Address  =>   Event_Address_post,
    time_attach    =>   time_attach_post
    );
  

  Pre_queue : Queue_Module
  generic map(
    inputneuron    =>   inputneuron,
    addrbit        =>   addrbit,
    time_length    =>   time_length,
    A_plus          =>   A_plus,
    Tau_plus        =>   Tau_plus,
    A_neg           =>   A_neg,
    Tau_neg         =>   Tau_neg
    )
  port map(
    Clock              =>   Clock,          
    Reset              =>   Reset,
    Event_Valid        =>   Event_Valid_pre,
    Event_Valid_Oppo   =>   Event_Valid_post,
    Event_Address      =>   Event_Address_pre,
      Event_Address_oppo =>   Event_Address_post,    --
      time_attach        =>   time_attach_pre,
      time_attach_oppo   =>   time_attach_post,
    -- 
    Dequeued_Address   =>   Dequeued_Address_pre,
    Address_oppo       =>   Transis_Addr_pre,
    Dequeued_Time      =>   Dequeued_Time_pre,
    Time_oppo          =>   Transis_Time_pre,
    Queue_Valid        =>   Queue_Valid_pre
    );

  Post_queue : Queue_Module
  generic map(
    inputneuron    =>   outputneuron,
    addrbit        =>   addrbit,
    time_length    =>   time_length,
    A_plus          =>   A_plus,
    Tau_plus        =>   Tau_plus,
    A_neg           =>   A_neg,
    Tau_neg         =>   Tau_neg
    )
  port map(
    Clock              =>   Clock,          
    Reset              =>   Reset,
    Event_Valid        =>   Event_Valid_post,
    Event_Valid_Oppo   =>   Event_Valid_pre,
    Event_Address      =>   Event_Address_post,
    Event_Address_oppo =>   Event_Address_pre,
    time_attach        =>   time_attach_post,
    time_attach_oppo   =>   time_attach_pre,
    -- 
    Dequeued_Address   =>   Dequeued_Address_post,
    Address_oppo       =>   Transis_Addr_post,
    Dequeued_Time      =>   Dequeued_Time_post,
    Time_oppo          =>   Transis_Time_post,
    Queue_Valid        =>   Queue_Valid_post
    );



  Pre_weight_trans : Weight_Trans
  generic map(
    inputneuron     =>   inputneuron,
    addrbit         =>   addrbit,
    time_length     =>   time_length,
    A_plus          =>   A_plus,
    Tau_plus        =>   Tau_plus,
    A_neg           =>   A_neg,
    Tau_neg         =>   Tau_neg,
    weights_bit_width => weights_bit_width
    )
  port map(
    Clock              =>   Clock,
    Reset              =>   Reset,
      Event_Address      =>   Transis_Addr_pre,   --may need change
      time_attach        =>   Dequeued_Time_pre,
      Dequeued_address   =>   Dequeued_Address_pre,    --may need change
      Dequeued_Time      =>   Transis_Time_pre, 
      Event_Valid_oppo   =>   Queue_Valid_pre,
    --
    Weight_Adress_1    =>   Weight_Adress_1_pre,
    Weight_Adress_2    =>   Weight_Adress_2_pre,
    Weight_Delta       =>   Weight_Delta_pre,
    Weight_Delta_Indicator   =>   Weight_Delta_Indicator_pre
    );

  Post_weight_trans : Weight_Trans
  generic map(
    inputneuron     =>   outputneuron,
    addrbit         =>   addrbit,
    time_length     =>   time_length,
    A_plus          =>   A_plus,
    Tau_plus        =>   Tau_plus,
    A_neg           =>   A_neg,
    Tau_neg         =>   Tau_neg,
    weights_bit_width => weights_bit_width
    )
  port map(
    Clock              =>   Clock,
    Reset              =>   Reset,
      Event_Address      =>   Transis_Addr_post,   --may need change
      time_attach        =>   Transis_Time_post,
      Dequeued_address   =>   Dequeued_Address_post,    --may need change
      Dequeued_Time      =>   Dequeued_Time_post,
      Event_Valid_oppo   =>   Queue_Valid_post,
    --
    Weight_Adress_1    =>   Weight_Adress_1_post,
    Weight_Adress_2    =>   Weight_Adress_2_post,
    Weight_Delta       =>   Weight_Delta_post,
    Weight_Delta_Indicator   =>   Weight_Delta_Indicator_post
    );


--  process(Clock)
--  begin
--    if Weight_Delta_Indicator_pre = '1' then
--      Weight_Delta <= Weight_Delta_pre;
--      Weight_Delta_Indicator <= Weight_Delta_Indicator_pre;
--      --
--      Weight_Adress_1 <= Weight_Adress_2_pre;                             ----may change 1 to 2
--      Weight_Adress_2 <= Weight_Adress_1_pre;
--    elsif Weight_Delta_Indicator_post = '1' then
--      Weight_Delta <= Weight_Delta_post;
--      Weight_Delta_Indicator <= Weight_Delta_Indicator_post;
--      --
--      Weight_Adress_1 <= Weight_Adress_2_post;
--      Weight_Adress_2 <= Weight_Adress_1_post;
--    else 
--      Weight_Delta <= (others => '0');
--      Weight_Delta_Indicator <= '0';
--      --
--      Weight_Adress_1 <= (others => '0');
--      Weight_Adress_2 <= (others => '0');
--    end if;

--  end process;


end architecture behavior;