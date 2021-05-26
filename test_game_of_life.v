module TestGameOfLife ();
parameter TEST_ROW = 6;
parameter TEST_COL = 6;
parameter CLK_CHANGE_DELAY = 20;

reg [TEST_ROW*TEST_COL-1:0] init_board;
reg clk, start;
wire [TEST_ROW*TEST_COL-1:0] game_board;
wire game_board_initialized;
GameOfLife game(
    .init_board(init_board),
    .start(start),
    .clk(clk),
    .game_board(game_board),
    .game_board_initialized(game_board_initialized)
);
defparam game.ROW = TEST_ROW;
defparam game.COL = TEST_COL;

always begin
    #CLK_CHANGE_DELAY
    clk = ~clk;
end

integer clk_counter;

reg temp;
integer it;
initial begin
    temp = 0;
    clk_counter = 0;
    clk = 1;
    start = 0;
    // init_board = 64'b00000000__00000000_00000000_00011100_00010000_00001000_00000000_00000000;
    init_board = 64'b000000_000000_001110_001000_000100_000000; // glider pattern
    // init_board = 36'b000000_001000_000100_011100_000000_000000;
    #CLK_CHANGE_DELAY #CLK_CHANGE_DELAY
    start = 1;
    for (it = 0; it < 44; it = it + 1) begin
        #CLK_CHANGE_DELAY #CLK_CHANGE_DELAY
        temp = ~temp;
    end

    $stop;
end

reg [$clog2(TEST_ROW):0] i;
reg [$clog2(TEST_COL):0] j;
reg [$clog2(TEST_ROW*TEST_COL):0] index;

always @(posedge clk) begin
    clk_counter = clk_counter + 1;
end

always @(posedge clk) begin
    $display("clock number: %d", clk_counter);
    for (i = 0; i < TEST_ROW; i = i + 1) begin
        for (j = 0; j < TEST_COL; j = j + 1) begin
            index = i * TEST_COL + j;
            if (game_board[index]) begin
                $write("|*");
            end else begin
                $write("| ");
            end
        end
        $display("|");
    end
    $display("");
end

endmodule
