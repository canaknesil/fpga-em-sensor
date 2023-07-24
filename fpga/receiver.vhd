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
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity receiver is
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
end receiver;


architecture Behavioral of receiver is


--component time_to_digital_converter is
--    generic(TDL_LENGTH: integer);
--    port(sampling_clk: in std_logic;
--         point_a: out std_logic; -- the wire between points a and b whose delay is being measured
--         point_b: in std_logic;
--         tdl_q: out std_logic_vector(TDL_LENGTH - 1 downto 0));
--end component;

component time_to_digital_converter_multi_chain is
    generic(TDL_LENGTH: integer;
            N_CHAIN: integer);
    port(sampling_clk: in std_logic;
         point_a: out std_logic; -- the wire between points a and b whose delay is being measured
         point_b: in std_logic;
         tdl_q_raw: out std_logic_vector(TDL_LENGTH * N_CHAIN - 1 downto 0));
end component;

component loop_antenna is
    generic(n_loop: integer);
    Port ( pos : in STD_LOGIC;
           neg : out STD_LOGIC);
end component;

--component logic_antenna is
--    generic(N: integer); -- Should be an even number
--    Port ( pos : in STD_LOGIC;
--           neg : out STD_LOGIC);
--end component;

component rams_sp_nc is
    generic(SIZE: integer;
            ADDR_WIDTH: integer;
            DATA_WIDTH: integer
);
    port(clk  : in  std_logic;
         we   : in  std_logic;
         en   : in  std_logic;
         addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
         di   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
         do   : out std_logic_vector(DATA_WIDTH-1 downto 0)
);
end component;

component UART_TX_CTRL is
    Port ( SEND : in  STD_LOGIC;
           DATA : in  STD_LOGIC_VECTOR (7 downto 0);
           CLK : in  STD_LOGIC;
           READY : out  STD_LOGIC;
           UART_TX : out  STD_LOGIC);
end component;


function get_addr_width(n: integer) return integer is
begin
    return integer(ceil(log2(real(n))));
end function;


signal tdc_sampling_clk, tdc_point_a, tdc_point_b: std_logic;
signal tdc_tdl_q: std_logic_vector(tdc_N * tdc_N_CHAIN - 1 downto 0);
signal sampling_en, sampling_en_reg: std_logic;

constant MEM_SIZE: integer := N_SAMPLE;
constant MEM_ADDR_WIDTH: integer := get_addr_width(MEM_SIZE);
constant MEM_DATA_WIDTH: integer := tdc_tdl_q'length;
signal mem_we, mem_en: std_logic;
signal mem_addr: std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
signal mem_di, mem_do: std_logic_vector(MEM_DATA_WIDTH - 1 downto 0);

signal uart_send, uart_ready: std_logic;
signal uart_data: std_logic_vector(7 downto 0);
type uart_data_sel_t is (NONE, SYNCCHAR, FROM_MEM);
signal uart_data_sel: uart_data_sel_t;


-- FSM
type receiver_state_t is (
    INIT, CAPTURE_FIRST, CAPTURE_SECOND, CAPTURE, CAPTURE_LAST, 
    SEND_SYNCWORD_WAIT_READY, SEND_SYNCWORD, SEND_DATA_CHECK_ADDR, SEND_DATA_READ,
    SEND_DATA_CHECK_IDX, SEND_DATA_WAIT_READY, SEND_DATA, SEND_DATA_INCR_IDX, SEND_DATA_INCR_ADDR, 
    HALT_WAIT_READY, HALT
);
signal state : receiver_state_t;

constant MEM_DO_BYTE_IDX_MAX: integer := MEM_DATA_WIDTH;
signal mem_do_byte_idx: std_logic_vector(get_addr_width(MEM_DO_BYTE_IDX_MAX) downto 0); -- incremented by 8, one extra bit for overflow
signal mem_addr_fsm: std_logic_vector(MEM_ADDR_WIDTH downto 0); -- mem_addr with one extra bit for overflow


function sel(cond: boolean; 
             st1, st2: receiver_state_t) return receiver_state_t is
begin
    if (cond) then
        return st1;
    else
        return st2;
    end if;
end function;


begin


-- CLOCK GATING
-- recommended at https://www.intel.com/content/www/us/en/docs/programmable/683082/22-1/recommended-clock-gating-methods.html
GATING_FF: process(sampling_en, clk)
begin
    if (falling_edge(clk)) then
        sampling_en_reg <= sampling_en;
    end if;
end process;

tdc_sampling_clk <= clk and sampling_en_reg;


-- TDC AND THE ANTENNA
--TDC: time_to_digital_converter generic map(TDL_LENGTH => tdc_N) port map(
--    sampling_clk => tdc_sampling_clk,
--    point_a => tdc_point_a,
--    point_b => tdc_point_b,
--    tdl_q => tdc_tdl_q
--);

TDC_MULTI_CHAIN: time_to_digital_converter_multi_chain generic map(
    TDL_LENGTH => tdc_N,
    N_CHAIN => tdc_N_CHAIN
) port map(
    sampling_clk => tdc_sampling_clk,
    point_a => tdc_point_a,
    point_b => tdc_point_b,
    tdl_q_raw => tdc_tdl_q
);


--tdc_point_b <= tdc_point_a; -- no antenna

ANTENNA: loop_antenna generic map(n_loop => loop_antenna_N) port map(
    pos => tdc_point_a,
    neg => tdc_point_b
);

--ANTENNA: logic_antenna generic map(N => logic_antenna_N) port map(
--    pos => tdc_point_a,
--    neg => tdc_point_b
--);


-- MEMORY
mem_di <= tdc_tdl_q;
mem_addr <= mem_addr_fsm(MEM_ADDR_WIDTH - 1 downto 0);

MEM: rams_sp_nc generic map(
    SIZE => MEM_SIZE,
    ADDR_WIDTH => MEM_ADDR_WIDTH,
    DATA_WIDTH => MEM_DATA_WIDTH
) port map(
    clk => clk,
    we => mem_we,
    en => mem_en,
    addr => mem_addr,
    di => mem_di,
    do => mem_do
);


-- UART
with uart_data_sel select
uart_data <= X"53" when SYNCCHAR, -- S
             mem_do(to_integer(unsigned(mem_do_byte_idx)) + 7 downto to_integer(unsigned(mem_do_byte_idx))) when FROM_MEM,
             (others => '0') when others;

UART: UART_TX_CTRL port map(
    SEND => uart_send,
    DATA => uart_data,
    CLK => uart_clk,
    READY => uart_ready,
    UART_TX => uart_tx
);


-- FSM

-- FSM output signals:
-- sampling_en
-- mem_we
-- mem_en
-- mem_addr_fsm
-- mem_do_byte_idx
-- uart_send
-- uart_data_sel

-- FSM input signals
-- uart_ready

FSM: process(clk, reset, uart_ready)
begin
    if (reset = '1') then
        sampling_en <= '0';
        mem_we <= '0';
        mem_en <= '0';
        mem_addr_fsm <= (others => '0');
        mem_do_byte_idx <= (others => '0');
        uart_send <= '0';
        uart_data_sel <= NONE;
        state <= INIT;
        
    elsif (rising_edge(clk)) then
        sampling_en <= '0';
        mem_we <= '0';
        mem_en <= '0';
        mem_addr_fsm <= (others => '0');
        mem_do_byte_idx <= (others => '0');
        uart_send <= '0';
        uart_data_sel <= NONE;
        
        case state is
        
        when INIT =>
            state <= CAPTURE_FIRST;
            
        when CAPTURE_FIRST =>
            sampling_en <= '1'; -- First sampling clock edge comes 1 cycle after sampling_en is set.
            state <= CAPTURE_SECOND;
            
        when CAPTURE_SECOND =>
            sampling_en <= '1';
            mem_we <= '1';
            mem_en <= '1';
            state <= CAPTURE;
            
        when CAPTURE =>
            sampling_en <= '1';
            mem_we <= '1';
            mem_en <= '1';
            mem_addr_fsm <= mem_addr_fsm + 1;
            state <= sel(mem_addr_fsm + 1 = N_SAMPLE - 2, CAPTURE_LAST, CAPTURE);
            
        when CAPTURE_LAST =>
            mem_we <= '1';
            mem_en <= '1';
            mem_addr_fsm <= mem_addr_fsm + 1;
            state <= SEND_SYNCWORD_WAIT_READY;
            
        when SEND_SYNCWORD_WAIT_READY =>
            state <= sel(uart_ready = '1', SEND_SYNCWORD, SEND_SYNCWORD_WAIT_READY);
            
        when SEND_SYNCWORD =>
            uart_send <= '1';
            uart_data_sel <= SYNCCHAR;
            state <= SEND_DATA_CHECK_ADDR;
            
        -- OUTER FOR LOOP
        when SEND_DATA_CHECK_ADDR =>
            if (mem_addr_fsm = N_SAMPLE) then
                state <= HALT_WAIT_READY;
            else
                mem_addr_fsm <= mem_addr_fsm;
                state <= SEND_DATA_READ;
            end if;
            
        when SEND_DATA_READ =>
            mem_en <= '1'; -- Reading from memory is latched.
            mem_addr_fsm <= mem_addr_fsm;
            state <= SEND_DATA_CHECK_IDX;
            
        -- INNER FOR LOOP
        when SEND_DATA_CHECK_IDX =>
            mem_addr_fsm <= mem_addr_fsm;
            if (mem_do_byte_idx = MEM_DO_BYTE_IDX_MAX) then
                mem_do_byte_idx <= (others => '0');
                state <= SEND_DATA_INCR_ADDR;
            else
                mem_do_byte_idx <= mem_do_byte_idx;
                state <= SEND_DATA_WAIT_READY;
            end if;
            
        when SEND_DATA_WAIT_READY =>
            mem_addr_fsm <= mem_addr_fsm;
            mem_do_byte_idx <= mem_do_byte_idx;
            state <= sel(uart_ready = '1', SEND_DATA, SEND_DATA_WAIT_READY);
            
        when SEND_DATA =>
            uart_send <= '1';
            uart_data_sel <= FROM_MEM;
            mem_addr_fsm <= mem_addr_fsm;
            mem_do_byte_idx <= mem_do_byte_idx;
            state <= SEND_DATA_INCR_IDX;
            
        when SEND_DATA_INCR_IDX =>
            mem_addr_fsm <= mem_addr_fsm;
            mem_do_byte_idx <= mem_do_byte_idx + 8;
            state <= SEND_DATA_CHECK_IDX;
            
        -- INNER FOR LOOP END
        when SEND_DATA_INCR_ADDR =>
            mem_addr_fsm <= mem_addr_fsm + 1;
            state <= SEND_DATA_CHECK_ADDR;
            
        -- OUTER FOR LOOP END
        when HALT_WAIT_READY =>
            state <= sel(uart_ready = '1', HALT, HALT_WAIT_READY);
            
        when HALT => 
            state <= HALT;
            
        when others => -- should never be reached
            state <= INIT;
            
        end case;
    end if;
end process;


with state select done <= '1' when HALT,
                          '0' when others;



end Behavioral;















