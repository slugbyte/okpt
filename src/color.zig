const std = @import("std");

pub const RGBColor = struct {
    red: f32,
    green: f32,
    blue: f32,
    alpha: f32 = 1.0,

    pub fn toSRGBColor(self: RGBColor, gamma: f32) SRGBColor {
        return SRGBColor.fromRGBColor(self, gamma);
    }

    pub fn toHSLColor(self: RGBColor) HSLColor {
        return HSLColor.fromRGBColor(self);
    }

    pub fn format(value: RGBColor, comptime _: []const u8, _: std.fmt.FormatOptions, stream: anytype) !void {
        try stream.print("RGB(r{d:.2}, g{d:.2} b{d:.2})", .{ value.red, value.green, value.blue });
    }
};

pub const SRGBColor = struct {
    sR: f32,
    sG: f32,
    sB: f32,
    sAlpha: f32 = 1.0,

    /// gamma must not be 0;
    pub fn gammaEncode(channel: f32, gamma: f32) f32 {
        if (channel <= 0.0031308) {
            return 12.92 * channel;
        } else {
            return 1.055 * std.math.pow(f32, channel, 1 / gamma) - 0.055;
        }
    }

    /// gamma must not be 0;
    pub fn gammaDecode(channel: f32, gamma: f32) f32 {
        if (channel <= 0.04045) {
            return channel / 12.92;
        } else {
            return std.math.pow(f32, (channel + 0.055) / (1.055), gamma);
        }
    }

    /// gamma must not be 0;
    pub fn toRGBColor(self: SRGBColor, gamma: f32) RGBColor {
        return .{
            .r = SRGBColor.gammaDecode(self.sR, gamma),
            .g = SRGBColor.gammaDecode(self.sG, gamma),
            .b = SRGBColor.gammaDecode(self.sB, gamma),
        };
    }

    pub fn fromRGBColor(self: RGBColor, gamma: f32) SRGBColor {
        return .{
            .sR = SRGBColor.gammaEncode(self.sR, gamma),
            .sG = SRGBColor.gammaEncode(self.sG, gamma),
            .sB = SRGBColor.gammaEncode(self.sB, gamma),
        };
    }

    pub fn format(value: HSLColor, comptime _: []const u8, _: std.fmt.FormatOptions, stream: anytype) !void {
        try stream.print("SRGB(s{r:.2}, g{d:.2}, b{d:.2})", .{ value.sR, value.sG, value.sB });
    }
};

pub const HSLColor = struct {
    hue: f32,
    saturation: f32,
    light: f32,
    alpha: f32 = 1.0,

    pub fn format(value: HSLColor, comptime _: []const u8, _: std.fmt.FormatOptions, stream: anytype) !void {
        try stream.print("HSL(h{d:.2}, s{d:.2}, l{d:.2})", .{ value.hue, value.saturation, value.light });
    }

    fn hueToRGBValue(q: f32, hue: f32, sat: f32, light: f32) f32 {
        var k: f32 = @rem(q + (hue / 30.0), 12.0);
        var a: f32 = sat * std.math.min(light, 1 - light);
        return light - (a * std.math.max(-1.0, std.math.min(k - 3.0, std.math.min(9.0 - k, 1))));
    }

    pub fn toRGBColor(self: HSLColor) RGBColor {
        var hue: f32 = self.hue * 360.0;

        return RGBColor{
            .red = HSLColor.hueToRGBValue(0, hue, self.saturation, self.light),
            .green = HSLColor.hueToRGBValue(8, hue, self.saturation, self.light),
            .blue = HSLColor.hueToRGBValue(4, hue, self.saturation, self.light),
        };
    }

    pub fn fromRGBColor(rgb_color: RGBColor) HSLColor {
        var result = HSLColor{
            .hue = 0.0,
            .saturation = 0.0,
            .light = 0.0,
        };
        const vmax: f32 = std.math.max(rgb_color.red, std.math.max(rgb_color.green, rgb_color.blue));
        const vmin: f32 = std.math.min(rgb_color.red, std.math.min(rgb_color.green, rgb_color.blue));
        const delta: f32 = vmax - vmin;

        result.light = (vmax + vmin) / 2.0;

        if (delta == 0.0) {
            return result;
        }

        result.saturation = blk: {
            if (result.light > 0.5) {
                break :blk delta / (2.0 - vmax - vmin);
            } else {
                break :blk delta / (vmax + vmin);
            }
        };

        if (vmax == rgb_color.red) result.hue = ((rgb_color.green - rgb_color.blue) / 6.0) / delta;
        if (vmax == rgb_color.green) result.hue = (1.0 / 3.0) + ((rgb_color.blue - rgb_color.red) / 6.0) / delta;
        if (vmax == rgb_color.blue) result.hue = (2.0 / 3.0) + ((rgb_color.red - rgb_color.green) / 6.0) / delta;
        if (result.hue < 0.0) result.hue += 1.0;
        if (result.hue > 1.0) result.hue -= 1.0;

        return result;
    }
};
