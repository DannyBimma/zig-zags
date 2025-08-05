const std = @import("std");
const m = std.math;

const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,
    // Calcs the distance between two Vec3 objects
    pub fn distance(self: Vec3, other: Vec3) f64 {
        const xd = m.pow(f64, self.x - other.x, 2.0);
        const yd = m.pow(f64, self.y - other.y, 2.0);
        const zd = m.pow(f64, self.z - other.z, 2.0);
        return m.sqrt(xd + yd + zd);
    }
};
/// P.s. The self argument corresponds to the Vec3 object from
/// which this distance() method is being called from.
/// While the other is a separate Vec3 object that is given
/// as input to this method.
/// In the example below, the self argument corresponds to
/// the object v1, because the distance() method is being
/// called from the v1 object, while the other argument
/// corresponds to the object v2.
const v1 = Vec3{ .x = 4.2, .y = 2.4, .z = 0.9 };

const v2 = Vec3{ .x = 5.1, .y = 5.6, .z = 1.6 };

pub fn main() void {
    std.debug.print("Distance: {d}\n", .{v1.distance(v2)});
}
