library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity SpikeReader is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        spike_data : out STD_LOGIC_VECTOR(9 downto 0)
    );
end SpikeReader;

architecture Behavioral of SpikeReader is
    type SpikeArray is array (0 to 9) of STD_LOGIC;  -- Assuming 10 neurons
    signal spike_line : LINE;
    signal spike_file : TEXT;
    signal spike_buffer : SpikeArray;
    signal state : integer range 0 to 1 := 0;  -- State machine state
    
    procedure ReadSpikeLine (file_handle : in TEXT; buffer : out SpikeArray) is
        variable line_buffer : LINE;
        variable temp_data : LINE;
    begin
        readline(file_handle, line_buffer);
        temp_data := line_buffer.all;
        for i in 0 to 9 loop
            read(temp_data, buffer(i));
        end loop;
    end ReadSpikeLine;

begin
    process (clk, reset)
    begin
        if reset = '1' then
            state <= 0;
        elsif rising_edge(clk) then
            case state is
                when 0 =>
                    if not endfile(spike_file) then
                        ReadSpikeLine(spike_file, spike_buffer);
                        state <= 1;
                    else
                        state <= 0;
                    end if;
                when 1 =>
                    spike_data <= spike_buffer;
                    state <= 0;
                when others =>
                    state <= 0;
            end case;
        end if;
    end process;
    
    file_open(spike_file, "input_spike.txt", READ_MODE);
    
    process
    begin
        wait;
    end process;
    
end Behavioral;
