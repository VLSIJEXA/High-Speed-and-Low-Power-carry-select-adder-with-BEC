`timescale 1ns / 1ps
////////////////////////////////////////
// Company: 
// Engineer: 
// Create Date:
// Design Name: 
// Module Name:
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Dependencies: 
// Revision:
// Revision :
// Additional Comments:

// Full Adder

module ripple_carry_adder_4bit (
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       cout
);
    wire [2:0] carry;

    assign sum[0] = a[0] ^ b[0] ^ cin;
    assign carry[0] = (a[0] & b[0]) | (cin & (a[0] ^ b[0]));

    assign sum[1] = a[1] ^ b[1] ^ carry[0];
    assign carry[1] = (a[1] & b[1]) | (carry[0] & (a[1] ^ b[1]));

    assign sum[2] = a[2] ^ b[2] ^ carry[1];
    assign carry[2] = (a[2] & b[2]) | (carry[1] & (a[2] ^ b[2]));

    assign sum[3] = a[3] ^ b[3] ^ carry[2];
    assign cout = (a[3] & b[3]) | (carry[2] & (a[3] ^ b[3]));
endmodule

// Carry Select Block using two RCA and MUX
module cs_adder_block (
    input  [3:0] a,
    input  [3:0] b,
    input        cin, // carry input from previous block
    output [3:0] sum,
    output       cout
);
    wire [3:0] sum0, sum1;
    wire cout0, cout1;

    ripple_carry_adder_4bit rca0 (.a(a), .b(b), .cin(1'b0), .sum(sum0), .cout(cout0));
    ripple_carry_adder_4bit rca1 (.a(a), .b(b), .cin(1'b1), .sum(sum1), .cout(cout1));

    assign sum = (cin == 1'b0) ? sum0 : sum1;
    assign cout = (cin == 1'b0) ? cout0 : cout1;
endmodule

// Top-Level 32-bit Carry Select Adder using RCA
module CSA (
    input  [31:0] a,
    input  [31:0] b,
    input         cin,
    output [31:0] sum,
    output        cout
);
    wire [7:0] carry;

    // Block 0: RCA only
    ripple_carry_adder_4bit rca0 (.a(a[3:0]), .b(b[3:0]), .cin(cin), .sum(sum[3:0]), .cout(carry[0]));

    // Blocks 1 to 7: CS Adder Blocks
    cs_adder_block cs1 (.a(a[7:4]), .b(b[7:4]), .cin(carry[0]), .sum(sum[7:4]), .cout(carry[1]));
    cs_adder_block cs2 (.a(a[11:8]), .b(b[11:8]), .cin(carry[1]), .sum(sum[11:8]), .cout(carry[2]));
    cs_adder_block cs3 (.a(a[15:12]), .b(b[15:12]), .cin(carry[2]), .sum(sum[15:12]), .cout(carry[3]));
    cs_adder_block cs4 (.a(a[19:16]), .b(b[19:16]), .cin(carry[3]), .sum(sum[19:16]), .cout(carry[4]));
    cs_adder_block cs5 (.a(a[23:20]), .b(b[23:20]), .cin(carry[4]), .sum(sum[23:20]), .cout(carry[5]));
    cs_adder_block cs6 (.a(a[27:24]), .b(b[27:24]), .cin(carry[5]), .sum(sum[27:24]), .cout(carry[6]));
    cs_adder_block cs7 (.a(a[31:28]), .b(b[31:28]), .cin(carry[6]), .sum(sum[31:28]), .cout(carry[7]));

    assign cout = carry[7];
endmodule
///////////////////////////////////////////
//testbench
module testbench;

    reg [31:0] a, b;
    reg cin;
    wire [31:0] sum;
    wire cout;

    // Instantiate the CSA
    CSA uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        $display("Time\t\tA\t\t\t\tB\t\t\t\tCin\tSum\t\t\t\tCout");
        $monitor("%0dns\t%h\t%h\t%b\t%h\t%b", $time, a, b, cin, sum, cout);

        // Test case 1
        a = 32'h00000000; b = 32'h00000000; cin = 0;
        #10;

        // Test case 2
        a = 32'hFFFFFFFF; b = 32'h00000001; cin = 0;
        #10;

        // Test case 3
        a = 32'h12345678; b = 32'h87654321; cin = 1;
        #10;

        // Test case 4
        a = 32'hAAAAAAAA; b = 32'h55555555; cin = 0;
        #10;

        // Test case 5
        a = 32'hDEADBEEF; b = 32'h12345678; cin = 1;
        #10;

        // Finish simulation
        $finish;
    end

endmodule

