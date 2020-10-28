use <donut.scad>;
use <threads.scad>;

module cat_stamp(
    svg_filename = "bee-edit.svg",
    svg_width = 12.62,
    svg_length = 12.647,

    relief_depth = 6,
    relief_bleed = -.1,
    relief_scale = 1,
    relief_rotation = 0,

    base_width = undef,
    base_length = undef,
    base_height = 3,
    base_radius = 2,
    base_rim = 2,
    base_platform = 3,

    handle_diameter = undef,
    handle_height = 60,

    tolerance = .2,

    include_handle = true,
    arrange_for_printer = true,

    $fn = 12
) {
    base_width = base_width != undef
        ? base_width
        : svg_width * relief_scale + base_rim * 2;
    base_length = base_length != undef
        ? base_length
        : svg_length * relief_scale + base_rim * 2;

    handle_diameter = handle_diameter != undef
        ? handle_diameter
        : base_height + relief_depth;
    handle_cavity_depth = base_height + base_platform - .6;

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
        translate([
            base_width / 2,
            base_length / 2,
            base_height + base_platform - e
        ]) {
            mirror([1, 0, 0]) {
                rotate([0, 0, relief_rotation]) {
                    translate([
                        (svg_width * relief_scale) / -2,
                        (svg_length * relief_scale) / -2,
                        0
                    ]) {
                        linear_extrude(relief_depth + e) {
                            offset(delta = relief_bleed) {
                                resize([
                                    svg_width * relief_scale,
                                    svg_length * relief_scale
                                ]) {
                                    import(svg_filename);
                                }
                            }
                        }
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
                    base_width - base_radius - base_height
                ]) {
                    for (y = [
                        base_radius + base_height,
                        base_length - base_radius - base_height
                    ]) {
                        translate([x, y, 0]) {
                            cylinder(
                                r = base_radius,
                                h = e
                            );
                        }
                    }
                }

                for (x = [base_radius, base_width - base_radius]) {
                    for (y = [base_radius, base_length - base_radius]) {
                        for (z = [base_height, base_height + base_platform]) {
                            translate([x, y, z - e]) {
                                cylinder(
                                    r = base_radius,
                                    h = e
                                );
                            }
                        }
                    }
                }
            }

            translate([base_width / 2, base_length / 2, -e]) {
                threads(cavity = true, bleed = tolerance);
            }
        }
    }

    module handle(
        gutter = 2,
        fillet = 2,
        $fn = 24
    ) {
        y = sqrt(pow(base_length - base_height * 2, 2) / 2)
            + handle_diameter / 2
            + gutter;

        position = arrange_for_printer
            ? [base_width / 2, y, 0]
            : [base_width / 2, base_length / 2, -handle_height];

        translate(position) {
            hull() {
                donut(handle_diameter, fillet * 2, segments = $fn);

                translate([0, 0, handle_height - e]) {
                    cylinder(d = handle_diameter, h = e);
                }
            }

            translate([0, 0, handle_height]) {
                threads(cavity = false);
            }
        }
    }

    if (include_handle) {
        handle();
    }

    rotate([arrange_for_printer ? 45 : 0, 0, 0]) {
        translate([0, arrange_for_printer ? -base_height : 0, 0]) {
            base();
            # relief(relief_bleed);
        }
    }
}

module output(
    svgs = [
        // svg_filename, svg_width, svg_length
        ["bee-edit.svg", 12.62, 12.647],
        ["cat-smaller-mouth-edit.svg", 12.142, 10.028],
    ],
    rotations = [0, 90],
    plot = 22
) {
    for (i = [0 : len(svgs) - 1]) {
        svg = svgs[i];

        for (ii = [0 : len(rotations) - 1]) {
            translate([plot * i * 2 + plot * ii, 0, 0]) {
                cat_stamp(
                    svg_filename = svg[0],
                    svg_width = svg[1],
                    svg_length = svg[2],

                    relief_rotation = rotations[ii],

                    base_width = 20,
                    base_length = 20,

                    handle_diameter = 9,

                    include_handle = true,
                    arrange_for_printer = true
                );
            }
        }
    }
}

output();
