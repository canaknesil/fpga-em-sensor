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


entity pulse_buffer is
    port(I: in std_logic;
         O: out std_logic);
end pulse_buffer;

architecture Behavioral of pulse_buffer is

signal A, B: std_logic;

begin

A <= I;
O <= B;

-- Inspired from Launcher described in 2021 - Time-to-Digital Converter IP-Core for FPGA at State of the Art
process(A, B)
begin
    if B = '1' then
        B <= '0';
    elsif rising_edge(A) then
        B <= '1';
    end if;
end process;

end Behavioral;
