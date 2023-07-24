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
use ieee.math_real.all;

library UNISIM;
use UNISIM.vcomponents.all;


entity time_to_digital_converter_multi_chain is
    generic(TDL_LENGTH: integer;
            N_CHAIN: integer);
    port(sampling_clk: in std_logic;
         point_a: out std_logic; -- the wire between points a and b whose delay is being measured
         point_b: in std_logic;
         tdl_q_raw: out std_logic_vector(TDL_LENGTH * N_CHAIN - 1 downto 0));
end time_to_digital_converter_multi_chain;

architecture Behavioral of time_to_digital_converter_multi_chain is

component tapped_delay_line is
    generic(N: integer);
    port(start: in std_logic;
         stop: in std_logic;
         q: out std_logic_vector(N-1 downto 0));
end component;

signal tdl_start, tdl_stop: std_logic;

type tdl_q_t is array (N_CHAIN - 1 downto 0) of std_logic_vector(TDL_LENGTH - 1 downto 0);
signal tdl_q: tdl_q_t;

signal sampling_clk_net: std_logic;
attribute dont_touch: string;
attribute dont_touch of sampling_clk_net: signal is "true"; -- name referenced by constraints


begin


sampling_clk_net <= sampling_clk;

BUFG_point_a : BUFG
port map (
   I => sampling_clk_net,
   O => point_a
);

BUFG_tdc_stop : BUFG
port map (
   I => sampling_clk_net,
   O => tdl_stop
);

tdl_start <= point_b;

TDL_gen: for i in N_CHAIN - 1 downto 0 generate
    TDL: tapped_delay_line generic map(N => TDL_LENGTH) port map(
        start => tdl_start,
        stop => tdl_stop,
        q => tdl_q(i)
    );
    tdl_q_raw((i+1) * TDL_LENGTH - 1 downto i * TDL_LENGTH) <= tdl_q(i);
end generate;



end Behavioral;

















