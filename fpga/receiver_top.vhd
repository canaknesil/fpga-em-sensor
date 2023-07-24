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


entity receiver_top is
    port(CLK100MHZ: in std_logic;
         reset: in std_logic;
         uart_tx: out std_logic;
         receiver_done: out std_logic);
end receiver_top;

architecture Behavioral of receiver_top is

component receiver is
    generic(tdc_N: integer;
            tdc_N_CHAIN: integer;
            N_SAMPLE: integer; -- >= 3
            loop_antenna_N: integer);
            --logic_antenna_N: integer);
    port(reset: in std_logic;
         clk: in std_logic;
         uart_clk: in std_logic; -- must be 100 MHz
         uart_tx: out std_logic;
         done: out std_logic);
end component;

-- generic parameters of receiver
--constant tdc_N: integer := 800;
--constant N_SAMPLE: integer := 4000; -- tuned to maximum
----constant loop_antenna_N: integer := 50;
--constant logic_antenna_N: integer := 200;

constant tdc_N: integer := 800;
constant tdc_N_CHAIN: integer := 8;
constant N_SAMPLE: integer := 500; -- tuned to maximum
constant loop_antenna_N: integer := 6;
--constant logic_antenna_N: integer := 25;

begin

RECEIVER_inst: receiver generic map(
    tdc_N => tdc_N,
    tdc_N_CHAIN => tdc_N_CHAIN,
    N_SAMPLE => N_SAMPLE,
    loop_antenna_N => loop_antenna_N
    --logic_antenna_N => logic_antenna_n
) port map(
    reset => reset,
    clk => CLK100MHZ,
    uart_clk => CLK100MHZ,
    uart_tx => uart_tx,
    done => receiver_done
);

end Behavioral;
