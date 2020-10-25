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

    translate([0, 0, z_gutter]) top();
    bottom();
}

intersection() {
    case(z_gutter = 5);
    /* translate([-diameter, 0, 0]) cube([diameter * 2, diameter, diameter]); */
}
