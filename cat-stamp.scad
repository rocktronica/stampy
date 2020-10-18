module cat_stamp(
    depth = 2,
    base = 2,
    rim = 1,
    tolerance = .1
) {
    svg_width = 11.951;
    svg_length = 10;

    width = svg_width + rim * 2;
    length = svg_length + rim * 2;

    e = .031;

    module print(bleed = 0) {
        translate([rim, rim, -e]) {
            linear_extrude(depth + e) {
                offset(delta = bleed) {
                    resize([svg_width, svg_length]) {
                        import("cat-stamp.svg");
                    }
                }
            }
        }
    }

    module base() {
        translate([0, 0, depth]) {
            cube([width, length, base]);
        }
    }

    base();
    # print(0);
}

cat_stamp();
