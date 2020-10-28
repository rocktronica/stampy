use <threads.scad>;

module cat_stamp(
    svg_filename = "bee-edit.svg",
    svg_width = 12.62,
    svg_length = 12.647,

    relief_depth = 4,
    relief_bleed = -.1,
    relief_scale = 1,

    base_width = undef,
    base_length = undef,
    base_height = 3,
    base_radius = 2,
    base_rim = 2,

    handle_diameter = undef,
    handle_height = 20,

    tolerance = .2,

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
        mirror([1, 0, 0]) {
            translate([
                (base_width + svg_width * relief_scale) / -2,
                svg_length * relief_scale / -2 + base_length / 2,
                base_height - e
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
                        translate([x, y, base_height - e]) {
                            cylinder(
                                r = base_radius,
                                h = e
                            );
                        }
                    }
                }
            }

            translate([base_width / 2, base_length / 2, -e]) {
                threads(cavity = true, bleed = tolerance);
            }
        }
    }

    module handle(gutter = 2) {
        y = sqrt(pow(base_length - base_height * 2, 2) / 2)
            + handle_diameter / 2
            + gutter;

        position = arrange_for_printer
            ? [base_width / 2, y, 0]
            : [base_width / 2, base_length / 2, -handle_height];

        translate(position) {
            cylinder(
                d = handle_diameter,
                h = handle_height,
                $fn = 50
            );

            translate([0, 0, handle_height]) {
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
    svgs = [
        // svg_filename, svg_width, svg_length
        ["bee-edit.svg", 12.62, 12.647],
        ["cat-smaller-mouth-edit.svg", 12.142, 10.028],
    ],
    plot = 18
) {
    for (i = [0 : len(svgs) - 1]) {
        svg = svgs[i];

        translate([plot * i, 0, 0]) {
            cat_stamp(
                svg_filename = svg[0],
                svg_width = svg[1],
                svg_length = svg[2],

                base_width = 15,
                base_length = 15,
                arrange_for_printer = true
            );
        }
    }
}

output();
