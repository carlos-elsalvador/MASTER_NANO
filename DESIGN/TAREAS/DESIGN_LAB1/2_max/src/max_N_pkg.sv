package max_N_pkg;

  parameter int N = 8;  // Number of inputs
  parameter int DATA_WIDTH = 8;  // Data word length
  parameter int STAGES_NUM = $clog2(N);  // Number of stages
  parameter bit [0:STAGES_NUM-1] VPIPE_ON = 3'b001;  // ON OFF registered outputs vector
  parameter int CHAN_WIDTH = $clog2(N);  // Channel width

endpackage
