const std = @import("std");

const Cell = enum { empty, x, o };

const Board = struct {
    cells: [9]Cell = .{.empty} ** 9,

    fn display(self: Board) void {
        const sym = [_]u8{ '.', 'X', 'O' };
        std.debug.print("\n", .{});
        for (0..3) |row| {
            for (0..3) |col| {
                const c = sym[@intFromEnum(self.cells[row * 3 + col])];
                if (col < 2) {
                    std.debug.print(" {c} |", .{c});
                } else {
                    std.debug.print(" {c}\n", .{c});
                }
            }
            if (row < 2) std.debug.print("-----------\n", .{});
        }
        std.debug.print("\n", .{});
    }

    fn checkWinner(self: Board) ?Cell {
        const lines = [_][3]u8{
            .{ 0, 1, 2 }, .{ 3, 4, 5 }, .{ 6, 7, 8 },
            .{ 0, 3, 6 }, .{ 1, 4, 7 }, .{ 2, 5, 8 },
            .{ 0, 4, 8 }, .{ 2, 4, 6 },
        };
        for (lines) |l| {
            const a = self.cells[l[0]];
            if (a != .empty and a == self.cells[l[1]] and a == self.cells[l[2]])
                return a;
        }
        return null;
    }

    fn isFull(self: Board) bool {
        for (self.cells) |c| if (c == .empty) return false;
        return true;
    }
};

fn minimax(board: Board, is_maximizing: bool) i32 {
    if (board.checkWinner()) |w| return if (w == .o) 10 else -10;
    if (board.isFull()) return 0;
    var best: i32 = if (is_maximizing) -100 else 100;
    for (0..9) |i| {
        if (board.cells[i] != .empty) continue;
        var b = board;
        b.cells[i] = if (is_maximizing) .o else .x;
        const score = minimax(b, !is_maximizing);
        if (is_maximizing) {
            if (score > best) best = score;
        } else {
            if (score < best) best = score;
        }
    }
    return best;
}

fn bestMove(board: Board) usize {
    var best_score: i32 = -100;
    var best_idx: usize = 0;
    for (0..9) |i| {
        if (board.cells[i] != .empty) continue;
        var b = board;
        b.cells[i] = .o;
        const score = minimax(b, false);
        if (score > best_score) {
            best_score = score;
            best_idx = i;
        }
    }
    return best_idx;
}

// Read a line byte-by-byte using takeByte, return trimmed slice in buf
fn readLine(reader: *std.Io.File.Reader, buf: []u8) ?[]u8 {
    var total: usize = 0;
    while (total < buf.len) {
        const byte = reader.interface.takeByte() catch return null;
        if (byte == '\n') break;
        if (byte != '\r') {
            buf[total] = byte;
            total += 1;
        }
    }
    return buf[0..total];
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const stdin_file = std.Io.File.stdin();
    var reader_buf: [256]u8 = undefined;
    var reader = stdin_file.reader(io, &reader_buf);

    std.debug.print("=== TIC TAC TOE ===\n", .{});
    std.debug.print("You are X, Computer is O\n", .{});
    std.debug.print("\nPositions:\n 1 | 2 | 3\n-----------\n 4 | 5 | 6\n-----------\n 7 | 8 | 9\n\n", .{});

    var board = Board{};
    var line_buf: [64]u8 = undefined;

    while (true) {
        board.display();

        // --- Human turn ---
        const idx = while (true) {
            std.debug.print("Your move (1-9): ", .{});
            const line = readLine(&reader, &line_buf) orelse {
                std.debug.print("Read error.\n", .{});
                return;
            };
            const trimmed = std.mem.trim(u8, line, " \t");
            const num = std.fmt.parseInt(usize, trimmed, 10) catch {
                std.debug.print("Enter a number 1-9.\n", .{});
                continue;
            };
            if (num < 1 or num > 9) {
                std.debug.print("Must be 1-9.\n", .{});
                continue;
            }
            const i = num - 1;
            if (board.cells[i] != .empty) {
                std.debug.print("Cell taken! Choose another.\n", .{});
                continue;
            }
            break i;
        };

        board.cells[idx] = .x;

        if (board.checkWinner()) |_| {
            board.display();
            std.debug.print("You win! Congratulations!\n", .{});
            break;
        }
        if (board.isFull()) {
            board.display();
            std.debug.print("It's a draw!\n", .{});
            break;
        }

        // --- Computer turn ---
        std.debug.print("Computer is thinking...\n", .{});
        const comp = bestMove(board);
        board.cells[comp] = .o;
        std.debug.print("Computer plays position {d}.\n", .{comp + 1});

        if (board.checkWinner()) |_| {
            board.display();
            std.debug.print("Computer wins! Better luck next time.\n", .{});
            break;
        }
        if (board.isFull()) {
            board.display();
            std.debug.print("It's a draw!\n", .{});
            break;
        }
    }
}
