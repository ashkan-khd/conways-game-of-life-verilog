module GameOfLifeInterface (
    run,
    write_read_not, 
    serial_in, 
    clk,
    serial_out
);
parameter ROW = 6;
parameter COL = 6;
input run, write_read_not, serial_in, clk;
output reg serial_out;

reg [ROW*COL-1:0] game_board_initial;
wire [ROW*COL-1:0] game_board;
reg [3:1] read_write_state; // 1:init, 2: write, 3: read
reg game_start;

GameOfLife game(
    .init_board(game_board_initial),
    .start(game_start),
    .clk(clk),
    .game_board(game_board)
);

defparam game.ROW = ROW;
defparam game.COL = COL;


integer write_index;
integer read_index;

reg [ROW*COL-1:0] temp_game_board;

initial begin
    temp_game_board = {ROW*COL{1'b0}};
    write_index = ROW*COL-1;
    read_index = 0;
    read_write_state = 3'b001;
    game_start = 0;
end

always @(posedge clk) begin
    if (~run) begin
        game_start = 0;
        if (read_write_state[1] || (read_write_state[2] && ~write_read_not) || (read_write_state[3] && write_read_not)) begin
            if (read_write_state[1]) begin
                temp_game_board = game_board;
            end
            write_index = ROW*COL-1;
            read_index = 0;
            read_write_state[1] = 0;
            read_write_state[2] = write_read_not;
            read_write_state[3] = ~write_read_not;
        end
        if (read_write_state[2]) begin
            temp_game_board = temp_game_board >> 1;
            temp_game_board[ROW*COL-1] = serial_in;
        end else begin
            serial_out = temp_game_board[0];
            temp_game_board = temp_game_board >> 1;
        end
    end else begin
        game_board_initial = temp_game_board;
        read_write_state = 3'b001;
        game_start = 1;
    end
end


endmodule