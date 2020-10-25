module donut(
    diameter,
    thickness,
    segments = 24,
    starting_angle = 0,
    coverage = 360
) {
    e = .001;

    segments = max(1, round(segments * (coverage / 360)));

    module segment(angle = 0) {
        rotate([0, 0, -angle]) {
            translate([e / -2, diameter / 2 - thickness / 2, 0]) {
                rotate([0, 90, 0]) {
                    cylinder(d = thickness, h = e);
                }
            }
        }
    }

    for (i = [0 : segments - 1]) {
        hull() {
            segment(starting_angle + i * (coverage / segments));
            segment(starting_angle + (i + 1) * (coverage / segments));
        }
    }
}
