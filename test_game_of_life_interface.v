module TestGameOfLifeInterface ();
parameter TEST_ROW = 4;
parameter TEST_COL = 4;
parameter CLK_CHANGE_DELAY = 20;

reg run;
reg write_read_not;
reg serial_in;
reg clk;
wire serial_out;



reg [TEST_ROW*TEST_COL-1:0] game_board;
reg [TEST_ROW*TEST_COL-1:0] game_board2;


GameOfLifeInterface interface(
    .run(run),
    .write_read_not(write_read_not), 
    .serial_in(serial_in), 
    .clk(clk),
    .serial_out(serial_out)
);
defparam interface.ROW = TEST_ROW;
defparam interface.COL = TEST_COL;

always begin
    #CLK_CHANGE_DELAY
    clk = ~clk;
end

reg [TEST_ROW*TEST_COL-1:0] initial_game_board;

integer it;
reg [$clog2(TEST_ROW):0] i;
reg [$clog2(TEST_COL):0] j;
reg [$clog2(TEST_ROW*TEST_COL):0] index;
reg temp;
initial begin
    initial_game_board = 16'b0000_0000_0111_0000;
    clk = 0;
    temp = 0;
    
    $display("insert initializing board.");
    run = 0;
    write_read_not = 1;

    for (it = 0; it < TEST_ROW*TEST_COL; it = it + 1) begin
        serial_in = initial_game_board[it];
        #CLK_CHANGE_DELAY #CLK_CHANGE_DELAY
        temp = ~ temp;
    end

    $display("wait for game to continue one generation.");
    run = 1;
    #CLK_CHANGE_DELAY #CLK_CHANGE_DELAY;
    #CLK_CHANGE_DELAY #CLK_CHANGE_DELAY;
    #CLK_CHANGE_DELAY #CLK_CHANGE_DELAY;

    $display("read all board from serial out.");
    run = 0;
    write_read_not = 0;
    for (it = 0; it < TEST_ROW*TEST_COL; it = it + 1) begin
        #CLK_CHANGE_DELAY #CLK_CHANGE_DELAY;
        game_board[it] = serial_out;
    end

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

    $display("check if the whole board is empty.");
    run = 0;
    write_read_not = 0;
    for (it = 0; it < TEST_ROW*TEST_COL; it = it + 1) begin
        #CLK_CHANGE_DELAY #CLK_CHANGE_DELAY;
        game_board2[it] = serial_out;
    end

    for (i = 0; i < TEST_ROW; i = i + 1) begin
        for (j = 0; j < TEST_COL; j = j + 1) begin
            index = i * TEST_COL + j;
            if (game_board2[index]) begin
                $write("|*");
            end else begin
                $write("| ");
            end
        end
        $display("|");
    end
    $display("");

    $display("insert previous board in.");
    run = 0;
    write_read_not = 1;

    for (it = 0; it < TEST_ROW*TEST_COL; it = it + 1) begin
        serial_in = game_board[it];
        #CLK_CHANGE_DELAY #CLK_CHANGE_DELAY
        temp = ~ temp;
    end

    $display("wait for game to continue one generation.");
    run = 1;
    #CLK_CHANGE_DELAY #CLK_CHANGE_DELAY;
    #CLK_CHANGE_DELAY #CLK_CHANGE_DELAY;
    #CLK_CHANGE_DELAY #CLK_CHANGE_DELAY;

    $display("read all board from serial out.");
    run = 0;
    write_read_not = 0;
    for (it = 0; it < TEST_ROW*TEST_COL; it = it + 1) begin
        #CLK_CHANGE_DELAY #CLK_CHANGE_DELAY;
        game_board[it] = serial_out;
    end
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

    $stop;
end

endmodule