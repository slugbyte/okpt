const std = @import("std");
const RGBColor = @import("./color.zig").RGBColor;

const PNGDecodeError = error{
    EBitdepthNotValid,
    ECompressionTypeNotValid,
    EFilterTypeNotValid,
};

const ColorType = enum(u32) {
    Greyscale = 0,
    Truecolor = 2,
    IndexedColor = 3,
    GreyscaleAlpha = 4,
    TruecolorAlpha = 6,

    pub fn isBitDepthValid(self: ColorType, bit_depth: u8) bool {
        return switch (self) {
            .Greyscale => bit_depth == 1 or bit_depth == 2 or bit_depth == 4 or bit_depth == 8 or bit_depth == 16,
            .IndexedColor => bit_depth == 1 or bit_depth == 2 or bit_depth == 4 or bit_depth == 8,
            .Truecolor, .TruecolorAlpha, .GreyscaleAlpha => bit_depth == 8 or bit_depth == 16,
        };
    }
};

const ChunkIHDR = struct {
    width: u32,
    height: u32,
    bit_depth: u8,
    color_type: ColorType,
    is_interlaced: bool,
};

const ChunkPLTE = struct {
    len: usize,
    data: *const RGBColor,
};

const ChunkIDAT = struct {
    pub fn filterNone(self: *ChunkIDAT) void {
        _ = self;
    }

    pub fn filterSub(self: *ChunkIDAT) void {
        _ = self;
    }

    pub fn filterUp(self: *ChunkIDAT) void {
        _ = self;
    }

    pub fn filterAverage(self: *ChunkIDAT) void {
        _ = self;
    }

    pub fn filterPaeth(self: *ChunkIDAT) void {
        _ = self;
    }
};

const ChunkIEND = struct {};

const Chunk = union(enum) {
    IHDR: ChunkIHDR,
    IDAT: ChunkIDAT,
    IEND: ChunkIEND,
};

const PNGDecoder = struct {
    header: ChunkIHDR,
    pallet: ChunkPLTE,
    len: usize,
    data: *const RGBColor,
};
