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


-- Adapted from rams_sp_nc.vhd in ug901-vivado-synthesis-examples.zip

-- Single-Port Block RAM No-Change Mode
-- File: rams_sp_nc.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rams_sp_nc is
 generic(
  SIZE: integer := 1024;
  ADDR_WIDTH: integer := 10;
  DATA_WIDTH: integer := 8
 );
 port(
  clk  : in  std_logic;
  we   : in  std_logic;
  en   : in  std_logic;
  addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
  di   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  do   : out std_logic_vector(DATA_WIDTH-1 downto 0)
 );
end rams_sp_nc;

architecture syn of rams_sp_nc is
 type ram_type is array (SIZE-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
 signal RAM : ram_type;
begin
 process(clk)
 begin
  if clk'event and clk = '1' then
   if en = '1' then
    if we = '1' then
     RAM(to_integer(unsigned(addr))) <= di;
    else
     do <= RAM(to_integer(unsigned(addr)));
    end if;
   end if;
  end if;
 end process;

end syn;
