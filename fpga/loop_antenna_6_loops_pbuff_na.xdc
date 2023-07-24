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

create_pblock pblock_1
add_cells_to_pblock [get_pblocks pblock_1] [get_cells -quiet [list RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA]]
resize_pblock [get_pblocks pblock_1] -add {SLICE_X0Y1:SLICE_X5Y7}
set_property BEL AFF [get_cells {RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/LOOPS_gen[1].LOOP_START.PBUFF/B_reg}]
set_property LOC SLICE_X3Y6 [get_cells {RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/LOOPS_gen[1].LOOP_START.PBUFF/B_reg}]
set_property BEL AFF [get_cells {RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/LOOPS_gen[4].LOOP_START_ELSE.PBUFF/B_reg}]
set_property LOC SLICE_X4Y7 [get_cells {RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/LOOPS_gen[4].LOOP_START_ELSE.PBUFF/B_reg}]
set_property BEL AFF [get_cells {RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/LOOPS_gen[5].LOOP_START_ELSE.PBUFF/B_reg}]
set_property LOC SLICE_X5Y7 [get_cells {RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/LOOPS_gen[5].LOOP_START_ELSE.PBUFF/B_reg}]
set_property BEL AFF [get_cells {RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/LOOPS_gen[3].LOOP_START_ELSE.PBUFF/B_reg}]
set_property LOC SLICE_X4Y5 [get_cells {RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/LOOPS_gen[3].LOOP_START_ELSE.PBUFF/B_reg}]
set_property BEL AFF [get_cells {RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/LOOPS_gen[6].LOOP_START_ELSE.PBUFF/B_reg}]
set_property LOC SLICE_X4Y6 [get_cells {RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/LOOPS_gen[6].LOOP_START_ELSE.PBUFF/B_reg}]
set_property BEL AFF [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/PBUFF_last/B_reg]
set_property LOC SLICE_X5Y5 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/PBUFF_last/B_reg]
set_property BEL AFF [get_cells {RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/LOOPS_gen[2].LOOP_START_ELSE.PBUFF/B_reg}]
set_property LOC SLICE_X5Y6 [get_cells {RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/LOOPS_gen[2].LOOP_START_ELSE.PBUFF/B_reg}]
set_property BEL A6LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge1_inst]
set_property LOC SLICE_X79Y7 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge1_inst]
set_property BEL B6LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge1_inst__0]
set_property LOC SLICE_X79Y7 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge1_inst__0]
set_property BEL C6LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge1_inst__1]
set_property LOC SLICE_X79Y7 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge1_inst__1]
set_property BEL D6LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge1_inst__2]
set_property LOC SLICE_X79Y7 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge1_inst__2]
set_property BEL D6LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge1_inst__3]
set_property LOC SLICE_X80Y7 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge1_inst__3]
set_property BEL A5LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge1_inst__4]
set_property LOC SLICE_X79Y7 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge1_inst__4]
set_property BEL B5LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge2_inst]
set_property LOC SLICE_X79Y192 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge2_inst]
set_property BEL C5LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge2_inst__0]
set_property LOC SLICE_X79Y192 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge2_inst__0]
set_property BEL D6LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge2_inst__1]
set_property LOC SLICE_X80Y192 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge2_inst__1]
set_property BEL C6LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge2_inst__2]
set_property LOC SLICE_X80Y192 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge2_inst__2]
set_property BEL B6LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge2_inst__3]
set_property LOC SLICE_X80Y192 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge2_inst__3]
set_property BEL D6LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge2_inst__4]
set_property LOC SLICE_X80Y191 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge2_inst__4]
set_property BEL A5LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge3_inst]
set_property LOC SLICE_X80Y4 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge3_inst]

set_property BEL D5LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge3_inst__0]
set_property LOC SLICE_X79Y4 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge3_inst__0]
set_property BEL D5LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge3_inst__1]
set_property LOC SLICE_X80Y4 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge3_inst__1]
set_property BEL C5LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge3_inst__2]
set_property LOC SLICE_X80Y4 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge3_inst__2]
set_property BEL B5LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge3_inst__3]
set_property LOC SLICE_X80Y4 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge3_inst__3]
set_property BEL D6LUT [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge3_inst__4]
set_property LOC SLICE_X80Y3 [get_cells RECEIVER_TOP_inst/RECEIVER_inst/ANTENNA/edge3_inst__4]
