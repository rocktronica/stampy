use <threads.scad>;
use <utils.scad>;

svg_width = 11.951;
svg_length = 10;

module cat_stamp(
    relief_depth = 2,
    relief_bleed = 0,
    relief_scale = 1,

    base_height = 3,
    base_radius = 2,
    base_rim = 2,

    handle_length = 20,

    tolerance = .2,

    arrange_for_printer = true,

    $fn = 12
) {
    width = svg_width * relief_scale + base_rim * 2;
    length = svg_length * relief_scale + base_rim * 2;

    handle_diameter = base_height + relief_depth;
    handle_cavity_depth = base_height - .6;

    e = .031;

    module threads(
        cavity = true,
        bleed = 0,
        cavity_chamfer = .4
    ) {
        metric_thread(
            diameter = handle_diameter + bleed * 2,
            length = cavity ? handle_cavity_depth + e * 2 : handle_cavity_depth,
            internal = !cavity,
            leadin = cavity ? 0 : 1
        );

        if (cavity) {
            cylinder(
                d1 = handle_diameter + bleed * 2 + cavity_chamfer * 2,
                d2 = handle_diameter + bleed * 2,
                h = cavity_chamfer,
                $fn = 50
            );
        }
    }

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
        difference() {
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

            translate([width / 2, length / 2, -e]) {
                threads(cavity = true, bleed = tolerance);
            }
        }
    }

    module handle(gutter = 2) {
        y = sqrt(pow(length - base_height * 2, 2) / 2)
            + handle_diameter / 2
            + gutter;

        position = arrange_for_printer
            ? [width / 2, y, 0]
            : [width / 2, length / 2, -handle_length];

        translate(position) {
            cylinder(
                d = handle_diameter,
                h = handle_length,
                $fn = 50
            );

            translate([0, 0, handle_length]) {
                threads(cavity = false);
            }
        }
    }

    handle();

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
