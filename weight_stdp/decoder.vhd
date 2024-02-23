library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity AER_Decoder is
  generic (
    inputneuron : integer := 784;
    addrbit : integer := 10;
    N_bram      : integer := 58;
    N_weights_per_word  : integer := 7;
    weights_bit_width : integer := 5
 );
 Port(
   Clock : in STD_LOGIC;                           -- Clock signal
   Reset : in STD_LOGIC;                           -- Reset signal
   Event_Valid : in STD_LOGIC;                   -- Event valid signal
   Event_Address : in STD_LOGIC_VECTOR(addrbit-1 downto 0); -- Event address
   Status_nozero : in STD_LOGIC
   Weight_outp : STD_LOGIC_VECTOR(N_bram*N_weights_per_word*weights_bit_width-1 downto 0) := (others => '0');
 );
end AER_Decoder;

architecture Behavior of AER_Decoder is
  signal Address_buffer : STD_LOGIC_VECTOR := '0';
  signal do :  STD_LOGIC_VECTOR(N_bram*N_weights_per_word*weights_bit_width-1 downto 0) := (others => '0');
  signal do_buffer :  STD_LOGIC_VECTOR(N_bram*N_weights_per_word*weights_bit_width-1 downto 0) := (others => '0');

begin
  process(Event_Address)
  begin
  Address_buffer <= Event_Address;          -- Address_buffer port map to weight_bram_read addr
  do_buffer <= do;                          -- Fetch the w of the input addr
  
  if Status_nozero = 0 then
    Weight_outp <= do_buffer;
  else
    wait;
  end if;
  end process;


