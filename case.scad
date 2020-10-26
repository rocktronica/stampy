use <donut.scad>;
use <threads.scad>;

diameter = 75;
height = 15;
fillet = 5;
wall = 4;
floor_ceiling = 1.4;

module case(
    thread_length = 4, // 2 is too short, 6 is good
    thread_pitch = 2, // default 1 too small, 2 bit out w/ thin walls
    tolerance = .1,
    clearance = .1, // .2 too loose for thread_pitch 1
    z_gutter = 0,

    stamp_base_size = 17,
    handle_length = 20,
    handle_diameter = 7,

    debug = false
) {
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
            leadin = cavity ? 0 : 1, // TODO: for non-cavity?
            n_starts = 6
        );
    }

    module bottom() {
        clearance = .2;

        module handle_holder(width = handle_length / 2) {
            x = width / -2;

            for (y = [
                handle_diameter / -2 - wall - clearance,
                handle_diameter / 2 + clearance
            ]) {
                translate([x, y, floor_ceiling - e])
                cube([width, wall, handle_diameter + e]);
            }

            % translate([
                handle_length / -2,
                0,
                floor_ceiling + handle_diameter / 2
            ]) rotate([0, 90, 0]) {
                cylinder(d = handle_diameter, h = handle_length);
            }
        }

        module stamp_base_holder(x = 0, y = 0) {
            overlap = stamp_base_size / 3;

            translate([
                stamp_base_size / -2 - clearance,
                stamp_base_size / -2 - clearance,
                floor_ceiling - e
            ]) {
                a = -wall;
                b = stamp_base_size - overlap + clearance * 2;

                difference() {
                    union() {
                        for (_x = [a, b]) for (_y = [a, b]) {
                            translate([_x + x, _y + y, 0]) {
                                cube([
                                    wall + overlap,
                                    wall + overlap,
                                    handle_diameter + e
                                ]);
                            }
                        }
                    }

                    translate([x, y, -e]) {
                        cube([
                            stamp_base_size + clearance * 2,
                            stamp_base_size + clearance * 2,
                            handle_diameter + e * 3
                        ]);
                    }
                }
            }
        }

        handle_holder();
        stamp_base_holder();

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
        }
    }

    /* translate([0, 0, z_gutter]) top(); */
    bottom();
}

intersection() {
    case(z_gutter = 5);
    /* translate([-diameter, 0, 0]) cube([diameter * 2, diameter, diameter]); */
}
