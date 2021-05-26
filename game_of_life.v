module GameOfLife (
    init_board,
    start,
    clk,
    game_board,
    game_board_initialized
);
parameter ROW = 4;
parameter COL = 6;

input [ROW*COL-1:0] init_board;
input clk, start;
output reg [ROW*COL-1:0] game_board;
output reg game_board_initialized;

initial begin
    game_board_initialized = 0;
    game_board = {ROW*COL{1'b0}};
end

reg [ROW*COL-1:0] middleware_board;

integer i, j, index;
reg [3:0] alive_neighbours_count;
reg basis_of_living, cons_of_being_alive;

always @(posedge clk) begin
    if (start) begin
        if (~game_board_initialized) begin
            middleware_board = init_board;
            game_board = init_board;
            game_board_initialized = 1;
        end else begin
            for (i = 0; i < ROW*COL; i = i + 1) begin
                alive_neighbours_count = alive_neighbors(index2row(i), index2col(i));
                basis_of_living = alive_neighbours_count == 3;
                cons_of_being_alive = game_board[i] && alive_neighbours_count == 2;
                middleware_board[i] = basis_of_living || cons_of_being_alive;
            end
            game_board = middleware_board;
        end
    end else begin
        game_board_initialized = 0;
    end
end


function [3:0] alive_neighbors;
    input [$clog2(ROW)-1:0] row;
    input [$clog2(COL)-1:0] col;
    reg [$clog2(ROW)-1:0] row_back;
    reg [$clog2(ROW)-1:0] row_forward;
    reg [$clog2(COL)-1:0] col_back;
    reg [$clog2(COL)-1:0] col_forward; begin
        row_back = row == 0 ? ROW - 1 : row - 1;
        row_forward = row == ROW-1 ? 0 : row + 1;
        col_back = col == 0 ? COL-1 : col - 1;
        col_forward = col == COL-1 ? 0 : col + 1;

        alive_neighbors = 0;
        alive_neighbors = alive_neighbors + game_board[point2index(row_back, col_back)];
        alive_neighbors = alive_neighbors + game_board[point2index(row_back, col)];
        alive_neighbors = alive_neighbors + game_board[point2index(row_back, col_forward)];
        alive_neighbors = alive_neighbors + game_board[point2index(row, col_back)];
        alive_neighbors = alive_neighbors + game_board[point2index(row, col_forward)];
        alive_neighbors = alive_neighbors + game_board[point2index(row_forward, col_back)];
        alive_neighbors = alive_neighbors + game_board[point2index(row_forward, col)];
        alive_neighbors = alive_neighbors + game_board[point2index(row_forward, col_forward)];
    end   
endfunction

function [$clog2(ROW)-1:0] index2row;
    input [$clog2(COL*ROW)-1:0] index; begin
        index2row = index / COL;
    end
endfunction

function [$clog2(COL)-1:0] index2col;
    input [$clog2(COL*ROW)-1:0] index; begin
        index2col = index % COL;
    end
endfunction

function [$clog2(COL*ROW)-1:0] point2index;
    input [$clog2(ROW)-1:0] row;
    input [$clog2(COL)-1:0] col; begin
        point2index = (row*COL + col);
    end
endfunction

endmodule