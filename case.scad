use <donut.scad>;
use <threads.scad>;

module case(
    diameter = 90,
    floor_ceiling = 2,
    fillet = 5,
    wall = 4,

    thread_length = 4,
    thread_pitch = 2,
    tolerance = .1,
    clearance = .1,

    vertical_clearance = 2,

    engraving_depth = 1,

    base_platform = 3,
    base_height = 6,
    base_size = 20,
    handle_height = 60,
    handle_diameter = 9,

    inner_wall = 2,

    z_gutter = 0,
    debug = true,
    bisect = true
) {
    height = 2 * (base_platform + base_height)
        + floor_ceiling * 2
        + vertical_clearance;

    e = .031;
    donut_fn = $preview ? 24 : 120;

    module outer() {
        if (debug) {
            cylinder(d = diameter, h = height);
        } else {
            hull() {
                for (z = [fillet, height - fillet]) {
                    translate([0, 0, z]) {
                        donut(diameter, fillet * 2, segments = donut_fn);
                    }
                }
            }
        }
    }

    module inner() {
        fillet = max(e, fillet - max(floor_ceiling, wall));

        if (debug) {
            translate([0, 0, floor_ceiling]) {
                cylinder(
                    d = diameter - wall * 2,
                    h = height - floor_ceiling * 2
                );
            }
        } else {
            hull() {
                for (z = [
                    floor_ceiling + fillet / 2,
                    height - fillet / 2 - floor_ceiling + e
                ]) {
                    translate([0, 0, z]) {
                        donut(
                            diameter - wall * 2,
                            fillet,
                            segments = donut_fn
                        );
                    }
                }
            }
        }
    }

    module threads(cavity = true) {
        bleed = tolerance + clearance;

        metric_thread(
            pitch = thread_pitch,
            diameter = diameter - wall * .8 + (cavity ? bleed * 3 : bleed * -2),
            length = thread_length,
            internal = !cavity,
            leadin = cavity ? 0 : 1,
            n_starts = 6
        );
    }

    module holders() {
        clearance = .1;

        module handle_holder(width = wall * 3, end_gutter = wall) {
            for (x = [
                handle_height / -2 + end_gutter,
                handle_height / 2 - width - end_gutter
            ]) {
                for (y = [
                    handle_diameter / -2 - inner_wall - clearance,
                    handle_diameter / 2 + clearance
                ]) {
                    translate([x, y, 0]) {
                        cube([width, inner_wall, handle_diameter]);
                    }
                }
            }

            % translate([
                handle_height / -2,
                0,
                handle_diameter / 2
            ]) rotate([0, 90, 0]) {
                cylinder(d = handle_diameter, h = handle_height);
            }
        }

        module base_holder() {
            overlap = base_size / 3;

            translate([
                base_size / -2 - clearance,
                base_size / -2 - clearance,
                0
            ]) {
                a = -inner_wall;
                b = base_size - overlap + clearance * 2;

                difference() {
                    union() {
                        for (p = [[a,a], [b,b]]) {
                            translate([p.x, p.y, 0]) {
                                cube([
                                    inner_wall + overlap,
                                    inner_wall + overlap,
                                    base_height
                                ]);
                            }
                        }
                    }

                    translate([0, 0, -e]) {
                        cube([
                            base_size + clearance * 2,
                            base_size + clearance * 2,
                            base_height + e * 2
                        ]);
                    }
                }

                % translate([clearance, clearance, 0]) {
                    cube([
                        base_size,
                        base_size,
                        handle_diameter
                    ]);
                }
            }
        }

        gutter = 4;
        y_plot = base_size / 2 + clearance + inner_wall
            + handle_diameter / 2 + inner_wall
            + gutter;

        for (y = [-y_plot, y_plot]) {
            translate([0, y, 0]) {
                base_holder();
            }
        }

        handle_holder();
    }

    module engraving(
        svg_filename = "bee-edit.svg",
        svg_width = 12.62,
        svg_length = 12.647,
        z = 0
    ) {
        scale = (diameter / 2) / max(svg_width, svg_length);

        translate([svg_width * scale / -2, svg_length * scale / -2, z]) {
            linear_extrude(engraving_depth + e) {
                offset(delta = tolerance) {
                    resize([
                        svg_width * scale,
                        svg_length * scale
                    ]) {
                        import(svg_filename);
                    }
                }
            }
        }
    }

    module bottom() {
        difference() {
            union() {
                intersection() {
                    outer();
                    cylinder(d = diameter + e * 2, h = height / 2, $fn = donut_fn);
                }
                translate([0, 0, height / 2 -e]) {
                    threads(cavity = false);
                }
            }

            inner();

            engraving(
                "bee-edit.svg", 12.62, 12.647,
                z = -e
            );
        }

        translate([0, 0, floor_ceiling - e]) {
            # holders();
        }
    }

    module top() {
        difference() {
            intersection() {
                outer();
                translate([0, 0, height / 2]) {
                    cylinder(d = diameter + e * 2, h = height / 2, $fn = donut_fn);
                }
            }

            inner();

            translate([0, 0, height / 2 -e]) {
                threads(cavity = true);
            }

            engraving(
                "cat-smaller-mouth-edit.svg", 12.142, 10.028,
                z = height - engraving_depth
            );
        }

        translate([0, 0, height - floor_ceiling + e]) {
            mirror([0, 0, 1]) {
                # holders();
            }
        }
    }

    intersection() {
        union() {
            translate([0, 0, z_gutter]) top();
            bottom();
        }

        if (bisect) {
            translate([-diameter, 0, 0]) cube([diameter * 2, diameter, diameter]);
        }
    }
}

case(z_gutter = 5);
