const std = @import("std");

// ─── Reflection table ────────────────────────────────────────────────────────
// When Eliza echoes back words from the user's input, she reflects pronouns.
const reflections = [_][2][]const u8{
    .{ "i am",   "you are" },
    .{ "i was",  "you were" },
    .{ "i",      "you" },
    .{ "i'd",    "you would" },
    .{ "i've",   "you have" },
    .{ "i'll",   "you will" },
    .{ "my",     "your" },
    .{ "me",     "you" },
    .{ "myself", "yourself" },
    .{ "you are","i am" },
    .{ "you were","i was" },
    .{ "you've", "i have" },
    .{ "you'll", "i will" },
    .{ "your",   "my" },
    .{ "yours",  "mine" },
    .{ "you",    "i" },
    .{ "am",     "are" },
};

// ─── Pattern/response table ───────────────────────────────────────────────────
// Each entry: keyword to look for, and a list of possible responses.
// "*" in a response means: insert the reflected remainder of the user's input.
const Pattern = struct {
    keyword: []const u8,
    responses: []const []const u8,
};

const patterns = [_]Pattern{
    .{
        .keyword = "hello",
        .responses = &.{
            "Hello. How are you feeling today?",
            "Hi there. What brings you here?",
        },
    },
    .{
        .keyword = "i need",
        .responses = &.{
            "Why do you need *?",
            "Would it really help you to get *?",
            "Are you sure you need *?",
        },
    },
    .{
        .keyword = "i want",
        .responses = &.{
            "Why do you want *?",
            "What would it mean to you if you got *?",
            "Suppose you got *. What then?",
        },
    },
    .{
        .keyword = "i am",
        .responses = &.{
            "How long have you been *?",
            "Do you believe it is normal to be *?",
            "How do you feel about being *?",
        },
    },
    .{
        .keyword = "i'm",
        .responses = &.{
            "How long have you been *?",
            "Do you enjoy being *?",
            "Why do you tell me you're *?",
        },
    },
    .{
        .keyword = "i feel",
        .responses = &.{
            "Tell me more about feeling *.",
            "Do you often feel *?",
            "When do you usually feel *?",
            "What makes you feel *?",
        },
    },
    .{
        .keyword = "i have",
        .responses = &.{
            "Why do you tell me that you have *?",
            "Have you always had *?",
            "How does having * make you feel?",
        },
    },
    .{
        .keyword = "i can't",
        .responses = &.{
            "How do you know you can't *?",
            "Have you tried to *?",
            "Perhaps you could * if you tried.",
        },
    },
    .{
        .keyword = "i don't",
        .responses = &.{
            "Why don't you *?",
            "Do you wish you did *?",
            "Does it bother you that you don't *?",
        },
    },
    .{
        .keyword = "why don't you",
        .responses = &.{
            "Do you really think I don't *?",
            "Perhaps eventually I will *.",
            "Do you really want me to *?",
        },
    },
    .{
        .keyword = "why can't i",
        .responses = &.{
            "Do you think you should be able to *?",
            "Why do you want to *?",
            "Have you tried to *?",
        },
    },
    .{
        .keyword = "are you",
        .responses = &.{
            "Why does it matter whether I am *?",
            "Would you prefer it if I were not *?",
            "Perhaps you believe I am *.",
            "I may be *. What do you think?",
        },
    },
    .{
        .keyword = "you are",
        .responses = &.{
            "Why do you think I am *?",
            "Does it please you to think that I am *?",
            "Perhaps you would like me to be *.",
        },
    },
    .{
        .keyword = "you're",
        .responses = &.{
            "Why do you say I'm *?",
            "Does it please you to think I'm *?",
        },
    },
    .{
        .keyword = "because",
        .responses = &.{
            "Is that the real reason?",
            "Are there other reasons?",
            "Does that reason explain anything else?",
            "What other reasons might there be?",
        },
    },
    .{
        .keyword = "sorry",
        .responses = &.{
            "Please don't apologize.",
            "Apologies are not necessary.",
            "What feelings do you have when you apologize?",
        },
    },
    .{
        .keyword = "dream",
        .responses = &.{
            "What does that dream suggest to you?",
            "Do you dream often?",
            "What people appear in your dreams?",
            "Do you think dreams have meaning?",
        },
    },
    .{
        .keyword = "mother",
        .responses = &.{
            "Tell me more about your mother.",
            "How did your mother make you feel?",
            "What was your relationship with your mother like?",
        },
    },
    .{
        .keyword = "father",
        .responses = &.{
            "Tell me more about your father.",
            "How did your father make you feel?",
            "What was your relationship with your father like?",
        },
    },
    .{
        .keyword = "family",
        .responses = &.{
            "Tell me more about your family.",
            "Who in your family are you closest to?",
            "How does your family make you feel?",
        },
    },
    .{
        .keyword = "friend",
        .responses = &.{
            "Tell me more about your friends.",
            "What do your friends mean to you?",
            "Do you think your friends understand you?",
        },
    },
    .{
        .keyword = "yes",
        .responses = &.{
            "You seem quite certain.",
            "I see. Can you elaborate?",
            "Why do you say yes?",
        },
    },
    .{
        .keyword = "no",
        .responses = &.{
            "Why not?",
            "Are you saying no just to be negative?",
            "Why are you being so negative?",
        },
    },
    .{
        .keyword = "maybe",
        .responses = &.{
            "You don't seem very certain.",
            "Why the uncertainty?",
            "Can't you be more definitive?",
        },
    },
    .{
        .keyword = "always",
        .responses = &.{
            "Can you think of a specific example?",
            "Really, always?",
            "When specifically?",
        },
    },
    .{
        .keyword = "never",
        .responses = &.{
            "Never?",
            "Can you think of a time when you did?",
            "That seems extreme — never?",
        },
    },
    .{
        .keyword = "computer",
        .responses = &.{
            "Are you really talking about me?",
            "Does it concern you to talk to a computer?",
            "What do you think machines have to do with your problems?",
            "Do you feel threatened by computers?",
        },
    },
    .{
        .keyword = "think",
        .responses = &.{
            "Do you really think so?",
            "Why do you think that?",
            "But you're not sure?",
        },
    },
    .{
        .keyword = "feel",
        .responses = &.{
            "Tell me more about those feelings.",
            "Do you often feel that way?",
            "What brings on that feeling?",
        },
    },
    .{
        .keyword = "love",
        .responses = &.{
            "Tell me more about your feelings of love.",
            "Have you told them you love them?",
            "What does love mean to you?",
        },
    },
    .{
        .keyword = "hate",
        .responses = &.{
            "That's a strong word. Why do you hate *?",
            "What makes you hate *?",
            "Does hating * affect your life?",
        },
    },
    .{
        .keyword = "sad",
        .responses = &.{
            "I'm sorry to hear you're sad. Can you tell me more?",
            "How long have you been feeling sad?",
            "What do you think causes your sadness?",
        },
    },
    .{
        .keyword = "happy",
        .responses = &.{
            "That's good to hear! What makes you happy?",
            "How long have you felt happy?",
            "What contributes to your happiness?",
        },
    },
    .{
        .keyword = "angry",
        .responses = &.{
            "What makes you angry?",
            "Do you often feel angry?",
            "Why do you think you feel angry?",
        },
    },
    .{
        .keyword = "anxious",
        .responses = &.{
            "What are you anxious about?",
            "Do you often feel anxious?",
            "What helps when you feel anxious?",
        },
    },
    .{
        .keyword = "afraid",
        .responses = &.{
            "What are you afraid of?",
            "Does fear affect your daily life?",
            "Have you always been afraid of that?",
        },
    },
    .{
        .keyword = "sick",
        .responses = &.{
            "I'm sorry to hear that. How long have you felt sick?",
            "Have you seen a doctor?",
            "What kind of sickness are you experiencing?",
        },
    },
    .{
        .keyword = "lonely",
        .responses = &.{
            "I'm sorry you feel lonely. Do you often feel this way?",
            "What do you think causes your loneliness?",
            "What would make you feel less lonely?",
        },
    },
    .{
        .keyword = "work",
        .responses = &.{
            "Tell me more about your work.",
            "Do you enjoy your work?",
            "What aspects of work bother you?",
        },
    },
    .{
        .keyword = "problem",
        .responses = &.{
            "Tell me more about this problem.",
            "How long has this been a problem?",
            "How does this problem affect your life?",
        },
    },
    .{
        .keyword = "help",
        .responses = &.{
            "What kind of help are you looking for?",
            "How do you think I can help?",
            "What would be most helpful to you right now?",
        },
    },
    .{
        .keyword = "what",
        .responses = &.{
            "Why do you ask?",
            "What do you think?",
            "Does that question concern you?",
        },
    },
    .{
        .keyword = "how",
        .responses = &.{
            "What is it you're really asking?",
            "How do you suppose?",
            "Why is that important to you?",
        },
    },
    .{
        .keyword = "who",
        .responses = &.{
            "Who do you have in mind?",
            "Why do you ask about who?",
        },
    },
    .{
        .keyword = "when",
        .responses = &.{
            "Why is timing so important to you?",
            "When do you think?",
        },
    },
    .{
        .keyword = "where",
        .responses = &.{
            "Where do you think?",
            "Why is place important to you?",
        },
    },
};

// Fallback responses used when no keyword matches
const fallbacks = [_][]const u8{
    "Please tell me more.",
    "Can you elaborate on that?",
    "How does that make you feel?",
    "I see. Go on.",
    "Very interesting. Please continue.",
    "Can you give me an example?",
    "I'm not sure I understand. Can you say more?",
    "What do you mean by that?",
    "How long have you felt this way?",
    "Why do you bring that up?",
};

// ─── Helpers ─────────────────────────────────────────────────────────────────

fn toLower(buf: []u8, input: []const u8) []u8 {
    const n = @min(buf.len - 1, input.len);
    for (0..n) |i| {
        buf[i] = std.ascii.toLower(input[i]);
    }
    buf[n] = 0;
    return buf[0..n];
}

// Reflect the user's words (pronoun swap) into out_buf.
// Returns a slice of out_buf.
fn reflect(input: []const u8, out_buf: []u8) []u8 {
    var lower_buf: [512]u8 = undefined;
    const lower = toLower(&lower_buf, input);

    var out_len: usize = 0;
    var i: usize = 0;

    outer: while (i < lower.len) {
        // Try each reflection pair
        for (reflections) |pair| {
            const from = pair[0];
            if (i + from.len <= lower.len and
                std.mem.eql(u8, lower[i .. i + from.len], from))
            {
                // Check word boundary after match
                const after = i + from.len;
                if (after < lower.len and std.ascii.isAlphanumeric(lower[after])) {
                    // not a word boundary, skip
                } else {
                    const to = pair[1];
                    if (out_len + to.len < out_buf.len) {
                        @memcpy(out_buf[out_len .. out_len + to.len], to);
                        out_len += to.len;
                        i += from.len;
                        // skip space after match if present
                        if (i < lower.len and lower[i] == ' ') {
                            if (out_len < out_buf.len) {
                                out_buf[out_len] = ' ';
                                out_len += 1;
                            }
                            i += 1;
                        }
                        continue :outer;
                    }
                }
            }
        }
        // No reflection matched — copy character as-is
        if (out_len < out_buf.len) {
            out_buf[out_len] = lower[i];
            out_len += 1;
        }
        i += 1;
    }
    return out_buf[0..out_len];
}

// Find the keyword match and return (pattern index, position after keyword).
fn findPattern(lower: []const u8) ?struct { pat: usize, after: usize } {
    for (patterns, 0..) |pat, pi| {
        const kw = pat.keyword;
        // Search for keyword anywhere in the string
        var si: usize = 0;
        while (si + kw.len <= lower.len) : (si += 1) {
            if (std.mem.eql(u8, lower[si .. si + kw.len], kw)) {
                // Check it starts on a word boundary
                if (si > 0 and std.ascii.isAlphanumeric(lower[si - 1])) continue;
                // Check it ends on a word boundary
                const after = si + kw.len;
                if (after < lower.len and std.ascii.isAlphanumeric(lower[after])) continue;
                return .{ .pat = pi, .after = after };
            }
        }
    }
    return null;
}

// ─── Main ─────────────────────────────────────────────────────────────────────

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const stdin_file = std.Io.File.stdin();
    var reader_buf: [256]u8 = undefined;
    var reader = stdin_file.readerStreaming(io, &reader_buf);

    std.debug.print("ELIZA - Computer Psychotherapist\n", .{});
    std.debug.print("================================\n", .{});
    std.debug.print("Hello. I am ELIZA. How are you feeling today?\n", .{});
    std.debug.print("(Type 'quit' or 'bye' to exit)\n\n", .{});

    var input_buf: [512]u8 = undefined;
    var lower_buf: [512]u8 = undefined;
    var reflect_buf: [512]u8 = undefined;
    var response_buf: [1024]u8 = undefined;
    var turn: usize = 0;

    while (true) {
        std.debug.print("> ", .{});

        // Read input byte by byte
        var input_len: usize = 0;
        while (input_len < input_buf.len - 1) {
            const byte = reader.interface.takeByte() catch break;
            if (byte == '\n') break;
            if (byte != '\r') {
                input_buf[input_len] = byte;
                input_len += 1;
            }
        }
        const input = std.mem.trim(u8, input_buf[0..input_len], " \t");

        if (input.len == 0) continue;

        // Check for exit
        const lower_input = toLower(&lower_buf, input);
        if (std.mem.eql(u8, lower_input, "quit") or
            std.mem.eql(u8, lower_input, "bye") or
            std.mem.eql(u8, lower_input, "exit") or
            std.mem.eql(u8, lower_input, "goodbye"))
        {
            std.debug.print("Goodbye. It was good talking with you.\n", .{});
            break;
        }

        // Find a matching pattern
        const response = if (findPattern(lower_input)) |match| blk: {
            const pat = patterns[match.pat];
            // Pick response round-robin
            const resp = pat.responses[turn % pat.responses.len];

            // Does the response contain "*"? If so, substitute reflected remainder.
            if (std.mem.indexOf(u8, resp, "*")) |star| {
                // Get the text after the keyword in the user's input
                const remainder = std.mem.trim(u8, lower_input[match.after..], " \t");
                const reflected = reflect(remainder, &reflect_buf);

                // Build: resp[0..star] ++ reflected ++ resp[star+1..]
                var out_len: usize = 0;
                const prefix = resp[0..star];
                const suffix = resp[star + 1 ..];

                @memcpy(response_buf[out_len .. out_len + prefix.len], prefix);
                out_len += prefix.len;
                if (reflected.len > 0) {
                    @memcpy(response_buf[out_len .. out_len + reflected.len], reflected);
                    out_len += reflected.len;
                } else {
                    const filler = "that";
                    @memcpy(response_buf[out_len .. out_len + filler.len], filler);
                    out_len += filler.len;
                }
                @memcpy(response_buf[out_len .. out_len + suffix.len], suffix);
                out_len += suffix.len;
                break :blk response_buf[0..out_len];
            } else {
                break :blk resp;
            }
        } else blk: {
            // No keyword matched — use a fallback
            break :blk fallbacks[turn % fallbacks.len];
        };

        std.debug.print("{s}\n\n", .{response});
        turn += 1;
    }
}
