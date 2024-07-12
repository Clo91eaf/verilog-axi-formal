// Language: Verilog 2005

/*
 * Formal properties of priority_encoder
 */
module f_priority_encoder #
(
  parameter WIDTH = 4,
  // LSB priority: "LOW", "HIGH"
  parameter LSB_PRIORITY = "LOW"
)
(
  input  wire [WIDTH-1:0]     input_unencoded,
  output wire           output_valid,
  output wire [$clog2(WIDTH)-1:0] output_encoded,
  output wire [WIDTH-1:0]     output_unencoded
);

parameter LEVELS = WIDTH > 2 ? $clog2(WIDTH) : 1;
parameter W = 2**LEVELS;

  priority_encoder #(/*AUTOINSTPARAM*/
             // Parameters
             .WIDTH       (WIDTH),
             .LSB_PRIORITY  (LSB_PRIORITY),
             .LEVELS      (LEVELS),
             .W         (W))
    dut(/*AUTOINST*/
      // Outputs
      .output_valid         (output_valid),
      .output_encoded       (output_encoded[$clog2(WIDTH)-1:0]),
      .output_unencoded       (output_unencoded[WIDTH-1:0]),
      // Inputs
      .input_unencoded      (input_unencoded[WIDTH-1:0]));

  // Assume properties

  // Proof properties
  // output need to sync between encoded and unencoded
  always @(*) begin
    if(input_unencoded)
      prf_sync: assert property(
        (1<<output_encoded) == output_unencoded
      );
  end

  always @(*) begin
    if(input_unencoded && (LSB_PRIORITY== "LOW"))
      prf_input_low: assert property(
        (input_unencoded >> output_encoded) == WIDTH'b1
      );
    else if(input_unencoded && (LSB_PRIORITY== "HIGH"))
      prf_input_high: assert property(
        input_unencoded << ((WIDTH-1)-output_encoded) == {1'b1,{WIDTH-1{1'b0}}}
      );
  end


  // Cover properties
  // output need to sync between encoded and unencoded
  cvr_onehot: cover property(
    (1<<output_encoded) == output_unencoded
  );

  // Valid signal
  always @(*) begin
    if(input_unencoded)
      cvr_vld: cover property(
        (output_valid == 1'b1)
      );
    else
      cvr_invld: cover property(
        (output_valid == 1'b0)
      );
  end

endmodule

// Local Variables:
// verilog-library-files:("../verilog-axi/rtl/priority_encoder.v")
// End:

