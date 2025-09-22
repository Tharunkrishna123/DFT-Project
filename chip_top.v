module DFT1(refclk,clk2,data_in,reset,data_out);
  input refclk,clk2;
  input [4:0]data_in;
  input reset;
  output  [4:0]data_out;
  
wire [19:0] deco1,pipo1;
wire [9:0] enco1,blackbox_out,pipo2;
wire [9:0] x;
  
  
  
  decoder5x20 D1(data_in,deco1);
  pll PLL(refclk,clk1);
  pipo20 P1(clk1,reset,deco1,pipo1);
  encoder20x10 E1(pipo1,enco1);
  pipo10 P2(clk2,reset_out,x,pipo2);
  encoder10x5 E2(pipo2,data_out);
   blackbox BB(
    .reset_out(reset_out),
    .data_out(blackbox_out)
  );

  xor (x[0],blackbox_out[0],enco1[0]);
  xor (x[1],blackbox_out[1],enco1[1]);
  xor (x[2],blackbox_out[2],enco1[2]);
  xor (x[3],blackbox_out[3],enco1[3]);
  xor (x[4],blackbox_out[4],enco1[4]);
  xor (x[5],blackbox_out[5],enco1[5]);
  xor (x[6],blackbox_out[6],enco1[6]);
  xor (x[7],blackbox_out[7],enco1[7]);
  xor (x[8],blackbox_out[8],enco1[8]);
  xor (x[9],blackbox_out[9],enco1[9]);
endmodule

module pll(
  input refclk,
  output clk
);
  //assign clk=refclk;  
endmodule
module blackbox(
  output reset_out,
  output [9:0]data_out
);
  //assign reset_out = 1'b0;      
  //assign data_out = 10'd0;   
endmodule

module decoder5x20 (
    input [4:0] in,
    output [19:0] out
);

    wire A, B, C, D, E; 
    wire nA, nB, nC, nD, nE;

    assign A = in[4];
    assign B = in[3];
    assign C = in[2];
    assign D = in[1];
    assign E = in[0];

    not g0(nA, A);
    not g1(nB, B);
    not g2(nC, C);
    not g3(nD, D);
    not g4(nE, E);

    // out[0] = ~A & ~B & ~C & ~D & ~E
    and g5(out[0], nA, nB, nC, nD, nE);
    
    // out[1] = ~A & ~B & ~C & ~D &  E
    and g6(out[1], nA, nB, nC, nD, E);

    // out[2] = ~A & ~B & ~C &  D & ~E
    and g7(out[2], nA, nB, nC, D, nE);

    // out[3] = ~A & ~B & ~C &  D &  E
    and g8(out[3], nA, nB, nC, D, E);

    // out[4] = ~A & ~B &  C & ~D & ~E
    and g9(out[4], nA, nB, C, nD, nE);

    // out[5] = ~A & ~B &  C & ~D &  E
    and g10(out[5], nA, nB, C, nD, E);

    // out[6] = ~A & ~B &  C &  D & ~E
    and g11(out[6], nA, nB, C, D, nE);

    // out[7] = ~A & ~B &  C &  D &  E
    and g12(out[7], nA, nB, C, D, E);

    // out[8] = ~A &  B & ~C & ~D & ~E
    and g13(out[8], nA, B, nC, nD, nE);

    // out[9] = ~A &  B & ~C & ~D &  E
    and g14(out[9], nA, B, nC, nD, E);

    // out[10] = ~A &  B & ~C &  D & ~E
    and g15(out[10], nA, B, nC, D, nE);

    // out[11] = ~A &  B & ~C &  D &  E
    and g16(out[11], nA, B, nC, D, E);

    // out[12] = ~A &  B &  C & ~D & ~E
    and g17(out[12], nA, B, C, nD, nE);

    // out[13] = ~A &  B &  C & ~D &  E
    and g18(out[13], nA, B, C, nD, E);

    // out[14] = ~A &  B &  C &  D & ~E
    and g19(out[14], nA, B, C, D, nE);

    // out[15] = ~A &  B &  C &  D &  E
    and g20(out[15], nA, B, C, D, E);

    // out[16] =  A & ~B & ~C & ~D & ~E
    and g21(out[16], A, nB, nC, nD, nE);

    // out[17] =  A & ~B & ~C & ~D &  E
    and g22(out[17], A, nB, nC, nD, E);

    // out[18] =  A & ~B & ~C &  D & ~E
    and g23(out[18], A, nB, nC, D, nE);

    // out[19] =  A & ~B & ~C &  D &  E
    and g24(out[19], A, nB, nC, D, E);

endmodule


// D latch gate-level
module d_latch (
    input wire d,
    input wire en,
    output wire q
);
    wire dbar, s, r, qbar;

    not u1(dbar, d);
    and u2(s, d, en);
    and u3(r, dbar, en);
    nor u4(q, r, qbar);
    nor u5(qbar, s, q);
endmodule

// Master-Slave D flip-flop
module dff_gate (
    input wire clk,
    input wire d,
    input wire reset,
    output wire q
);
    wire nclk,nreset;
    wire qm,d_mux;
    not u1(nclk, clk);
    not u2(nreset, reset);
    and(d_mux,d,nreset);
    d_latch master (
        .d(d_mux),
        .en(nclk),
        .q(qm)
    );

    d_latch slave (
        .d(qm),
        .en(clk),
        .q(q)
    );
endmodule

// 20-bit PIPO register
module pipo20 (
    input wire clk,
    input wire reset,
    input wire [19:0] d_in,
    output wire [19:0] q_out
);
    genvar i;
    generate
        for (i = 0; i < 20; i = i + 1) begin : dff_array
            dff_gate dff_inst (
                .clk(clk),
                .reset(reset),
                .d(d_in[i]),
                .q(q_out[i])
                
            );
        end
    endgenerate
endmodule
module encoder20x10 (in,out);
  input  [19:0] in;
  output  [9:0] out;


  assign out[9:5] = 5'b0;
  or(out[0],  in[1] , in[3] , in[5] , in[7] , in[9] , in[11] , in[13] , in[15] , in[17] , in[19]);
  or(out[1] , in[2] , in[3] , in[6] , in[7] , in[10] , in[11] , in[14] , in[15] , in[18] , in[19]);
  or(out[2] , in[4] , in[5] , in[6] , in[7] , in[12] , in[13] , in[14] , in[15] , in[19]);
  or(out[3] , in[8] , in[9] , in[10] , in[11] , in[12] , in[13] , in[14] , in[15]);
  or(out[4] , in[16] , in[17] , in[18] , in[19]);
endmodule


module pipo10 (
    input wire clk,
    input wire reset,
    input wire [9:0] d_in,
    output wire [9:0] q_out
);
    genvar i;
    generate
        for (i = 0; i < 10; i = i + 1) begin : dff_array
            dff_gate dff_inst (
                .clk(clk),
                .reset(reset),
                .d(d_in[i]),
                .q(q_out[i])
            );
        end
    endgenerate
endmodule


module encoder10x5(in, out);
    input [9:0] in;
    output [4:0] out;

    wire P0, P1, P2, P3, P4, P5, P6, P7, P8, P9;

    // Intermediate wires for inverted inputs to simplify logic
    wire not_in_0, not_in_1, not_in_2, not_in_3, not_in_4, not_in_5, not_in_6, not_in_7, not_in_8, not_in_9;

    not (not_in_0, in[0]);
    not (not_in_1, in[1]);
    not (not_in_2, in[2]);
    not (not_in_3, in[3]);
    not (not_in_4, in[4]);
    not (not_in_5, in[5]);
    not (not_in_6, in[6]);
    not (not_in_7, in[7]);
    not (not_in_8, in[8]);
    not (not_in_9, in[9]);

    // Priority terms (P_N)
    assign P9 = in[9];
    and (P8, in[8], not_in_9);
    and (P7, in[7], not_in_8, not_in_9);
    and (P6, in[6], not_in_7, not_in_8, not_in_9);
    and (P5, in[5], not_in_6, not_in_7, not_in_8, not_in_9);
    and (P4, in[4], not_in_5, not_in_6, not_in_7, not_in_8, not_in_9);
    and (P3, in[3], not_in_4, not_in_5, not_in_6, not_in_7, not_in_8, not_in_9);
    and (P2, in[2], not_in_3, not_in_4, not_in_5, not_in_6, not_in_7, not_in_8, not_in_9);
    and (P1, in[1], not_in_2, not_in_3, not_in_4, not_in_5, not_in_6, not_in_7, not_in_8, not_in_9);
    and (P0, in[0], not_in_1, not_in_2, not_in_3, not_in_4, not_in_5, not_in_6, not_in_7, not_in_8, not_in_9);

    // Output bit 0 (LSB)
    or (out[0], P1, P3, P5, P7, P9);

    // Output bit 1
    or (out[1], P2, P3, P6, P7);

    // Output bit 2
    or (out[2], P4, P5, P6, P7);

    // So out[3] is 1 for P8 or P9
    or (out[3], P8, P9);
    
    assign out[4] = 1'b0;

endmodule
