# MIT License

# Copyright (c) 2023 Can Aknesil

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set parent RECEIVER_TOP_inst/RECEIVER_inst/TDC_MULTI_CHAIN
set carry_init_cells [get_cells $parent/*/CARRY4_inst_first]
#set carry_init_slices [list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 72 73 74 75 76 77 78 79 80 81]
set carry_init_slices [list 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65]

set i 0
foreach cell $carry_init_cells {
    set x [lindex $carry_init_slices $i]
    set_property BEL CARRY4 $cell
    set_property LOC "SLICE_X${x}Y0" $cell
    incr i
}

#set_property BEL CARRY4 [get_cells {RECEIVER_TOP_inst/RECEIVER_inst/TDC_MULTI_CHAIN/TDL_gen[0].TDL/CARRY4_inst_first}]
#set_property LOC SLICE_X28Y0 [get_cells {RECEIVER_TOP_inst/RECEIVER_inst/TDC_MULTI_CHAIN/TDL_gen[0].TDL/CARRY4_inst_first}]
