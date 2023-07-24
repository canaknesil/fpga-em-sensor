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
use ieee.math_real.all;

library UNISIM;
use UNISIM.VComponents.all;

entity tapped_delay_line is
    generic(N: integer);
    port(start: in std_logic;
         stop: in std_logic;
         q: out std_logic_vector(N-1 downto 0));
end tapped_delay_line;

architecture With_CARRY4 of tapped_delay_line is

component CARRY4 is
    port (
        CO: out std_logic_vector(3 downto 0);
        O: out std_logic_vector(3 downto 0);
        CI: in std_logic;
        CYINIT: in std_logic;
        DI: in std_logic_vector(3 downto 0);
        S: in std_logic_vector(3 downto 0));
end component;

attribute dont_touch: string;
attribute dont_touch of CARRY4: component is "yes";

constant inner_N: integer := integer(ceil(real(N) / real(4))) * 4;
signal c: std_logic_vector(inner_N - 1 downto 0);

attribute dont_touch of q: signal is "true";

begin


CARRY4_inst_first : CARRY4
port map (
    CO => c(3 downto 0),         -- 4-bit carry out
    --O => dout,                 -- 4-bit carry chain XOR data out
    CI => '0',                   -- 1-bit carry cascade input
    CYINIT => start,             -- 1-bit carry initialization
    DI => (others => '0'),       -- 4-bit carry-MUX data in
    S => (others => '1')         -- 4-bit carry-MUX select input
);

CARRY4_gen: for i in 1 to inner_N / 4 - 1 generate
begin
    CARRY4_inst: CARRY4 port map (
        CO => c(4*i + 3 downto 4*i),  -- 4-bit carry out
        --O => dout,                  -- 4-bit carry chain XOR data out
        CI => c(4*i - 1),             -- 1-bit carry cascade input
        CYINIT => '0',                -- 1-bit carry initialization
        DI => (others => '0'),        -- 4-bit carry-MUX data in
        S => (others => '1')          -- 4-bit carry-MUX select input
    );
end generate;


FF: process(start, stop)
begin
    if (rising_edge(stop)) then
        q <= c(N-1 downto 0);
    end if;
end process;


end With_CARRY4;
