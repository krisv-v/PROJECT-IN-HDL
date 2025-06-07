library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL; 
 
entity qr_trigger_touch is 
port ( 
    clk     : in  std_logic; 
    touch   : in  std_logic; 
    trigger : out std_logic
); 
end entity; 
 
architecture Behavioral of qr_trigger_touch is 
 
    constant COUNT_1MS      : integer := 50_000;  
    signal debounce_counter : integer range 0 to COUNT_1MS := 0; 
 
 
    signal touch_debounced  : std_logic := '0'; 
    signal touch_sync       : std_logic_vector(1 downto 0) := "00"; 
 
    signal trigger_active   : std_logic := '0'; 
    signal pulse_counter    : integer range 0 to COUNT_1MS * 10 := 0;  
 
begin 
    process(clk) 
    begin 
        if rising_edge(clk) then touch_sync <= touch_sync(0) & touch; 
 
            if touch_sync(1) /= touch_sync(0) then 
                debounce_counter <= 0; 
            elsif debounce_counter < COUNT_1MS then 
                debounce_counter <= debounce_counter + 1; 
            else 
                touch_debounced <= touch_sync(1); 
            end if; 
        end if; 
    end process; 
 
    process(clk) 
    begin 
        if rising_edge(clk) then 
            if touch_debounced = '1' and trigger_active = '0' then 
                trigger_active <= '1'; 
                pulse_counter <= 0; 
            elsif trigger_active = '1' then 
                if pulse_counter < COUNT_1MS * 10 then  -- 10 ms pulse 
                    pulse_counter <= pulse_counter + 1; 
                else 
                    trigger_active <= '0'; 
                end if; 
            end if; 
        end if; 
    end process; 
 
    trigger <= trigger_active; 
 
end architecture;