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
use IEEE.STD_LOGIC_MISC.ALL;

entity loop_antenna is
    generic(N_LOOP: integer); -- number of loops on bobbin
    Port ( pos : in STD_LOGIC;
           neg : out STD_LOGIC);
end loop_antenna;

architecture Behavioral of loop_antenna is

component pulse_buffer is
    port(I: in std_logic;
         O: out std_logic);
end component;

signal edge1, edge2, edge3, edge4: std_logic_vector(1 to N_LOOP);
signal start, stop: std_logic;

attribute dont_touch: string;
attribute dont_touch of edge1, edge2, edge3, edge4, start, stop: signal is "true";

begin

start <= pos;

LOOPS_gen: for i in 1 to N_LOOP generate
    LOOP_START: if i = 1 generate
        --edge1(i) <= start;
        PBUFF: pulse_buffer port map(I => start, O => edge1(i));
    end generate;
    LOOP_START_ELSE: if i /= 1 generate
        --edge1(i) <= edge4(i-1);
        PBUFF: pulse_buffer port map(I => edge4(i-1), O => edge1(i));
    end generate;
    edge2(i) <= edge1(i);
    edge3(i) <= edge2(i);
    edge4(i) <= edge3(i);
end generate;

--stop <= edge4(N_LOOP);
PBUFF_last: pulse_buffer port map(I => edge4(N_LOOP), O => stop);
neg <= stop;


end Behavioral;
