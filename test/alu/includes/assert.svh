`ifndef ASSERT__H
`define ASSERT__H


`define ASSERT(CLAUSE, MSG="", arg1=ELIM, arg2=ELIM, arg3=ELIM, arg4=ELIM) \
  if ((i_reset_n === 1'b1) && !(CLAUSE) && (`CLK_TICKING)) begin \
    `DISPLAYERROR(MSG, arg1, arg2, arg3, arg4) \
  end


`endif
