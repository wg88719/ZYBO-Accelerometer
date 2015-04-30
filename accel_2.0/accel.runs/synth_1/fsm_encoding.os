
 add_fsm_encoding \
       {SPImaster.STATE} \
       { }  \
       {{000 000} {001 001} {010 010} {011 100} {100 011} {101 101} {110 110} }

 add_fsm_encoding \
       {axi_data_fifo_v2_1_axic_reg_srl_fifo.state} \
       { }  \
       {{00 010} {01 011} {10 000} {11 001} }
