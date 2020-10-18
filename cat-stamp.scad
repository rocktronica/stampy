svg_width = 11.951;
svg_length = 10;

module cat_stamp(
    depth = 2,
    base = 2,
    rim = 1,
    bleed = 0,
    scale = 1
) {
    width = svg_width * scale + rim * 2;
    length = svg_length * scale + rim * 2;

    e = .031;

    module print(bleed = 0) {
        translate([rim, rim, base - e]) {
            linear_extrude(depth + e) {
                offset(delta = bleed) {
                    resize([svg_width * scale, svg_length * scale]) {
                        import("cat-stamp.svg");
                    }
                }
            }
        }
    }

    module base() {
        cube([width, length, base]);
    }

    base();
    # print(bleed);
}

module test_bleeds(bleeds = [
    /* .1, // details lost here or any lower */
    .125,
    .15,
    .2
]) {
    gutter = 1;

    for (i = [0 : len(bleeds) - 1]) {
        translate([i * (svg_width + gutter), 0, 0]) {
            cat_stamp(bleed = bleeds[i]);
        }
    }
}

test_bleeds();
