use <utils.scad>;

svg_width = 11.951;
svg_length = 10;

module cat_stamp(
    relief_depth = 2,
    relief_bleed = 0,
    relief_scale = 1,

    base_height = 2,
    base_radius = 2,
    base_rim = 2,

    arrange_for_printer = true,

    $fn = 12
) {
    width = svg_width * relief_scale + base_rim * 2;
    length = svg_length * relief_scale + base_rim * 2;

    e = .031;

    module relief(relief_bleed = 0) {
        translate([base_rim, base_rim, base_height - e]) {
            linear_extrude(relief_depth + e) {
                offset(delta = relief_bleed) {
                    resize([
                        svg_width * relief_scale,
                        svg_length * relief_scale
                    ]) {
                        import("cat-stamp.svg");
                    }
                }
            }
        }
    }

    module base() {
        hull() {
            for (x = [
                base_radius + base_height,
                width - base_radius - base_height
            ]) {
                for (y = [
                    base_radius + base_height,
                    length - base_radius - base_height
                ]) {
                    translate([x, y, 0]) {
                        cylinder(
                            r = base_radius,
                            h = e
                        );
                    }
                }
            }

            for (x = [base_radius, width - base_radius]) {
                for (y = [base_radius, length - base_radius]) {
                    translate([x, y, base_height - e]) {
                        cylinder(
                            r = base_radius,
                            h = e
                        );
                    }
                }
            }
        }
    }

    rotate([arrange_for_printer ? 45 : 0, 0, 0]) {
        translate([0, arrange_for_printer ? -base_height : 0, 0]) {
            base();
            # relief(relief_bleed);
        }
    }
}

module output(
    bleeds = [.125, .1, .1],
    scales = [1, 1.25, 1.5]
) {
    gutter = 1;
    base_rim = 2;

    for (i = [0 : len(bleeds) - 1]) {
        x = i > 0
            ? sum(slice(scales, 0, i)) * svg_width
                + base_rim * i * 2
                + gutter * i
            : 0;

        translate([x, 0, 0]) {
            cat_stamp(
                relief_bleed = bleeds[i],
                relief_scale = scales[i],
                base_rim = base_rim,
                arrange_for_printer = true
            );
        }
    }
}

output();
