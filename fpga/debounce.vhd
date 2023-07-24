-- MIT License

-- Copyright (c) 2023 Can Aknesil

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;


entity debounce is
    port(clk: in std_logic;
         I: in std_logic;
         O: out std_logic);
end debounce;

architecture Behavioral of debounce is

signal counter: std_logic_vector(19 downto 0);
constant COUNTER_MAX: std_logic_vector(19 downto 0) := "11111111111111111111";

signal state: std_logic := '0'; -- 0: idle, 1: debouncing
signal old_I, O_reg: std_logic;


begin


INPUT_REG: process(clk, I)
begin
    if (rising_edge(clk)) then
        old_I <= I;
    end if;
end process;

FSM: process(clk, old_I, I)
begin
    if (rising_edge(clk)) then
        state <= '0';
        counter <= (others => '0');
        O_reg <= I;
        if (state = '0') then
            if (old_I = I) then
                
            else
                state <= '1';
                O_reg <= O_reg;
            end if;
        else
            if (counter /= COUNTER_MAX) then
                counter <= counter + 1;
                state <= '1';
                O_reg <= O_reg;
            else
                
            end if;
        end if;
    end if;
end process;

O <= O_reg;


end Behavioral;
