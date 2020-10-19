svg_width = 11.951;
svg_length = 10;

module cat_stamp(
    depth = 2,
    base = 2,
    rim = 1,
    bleed = 0,
    scale = 1,
    radius = 2,
    arrange_for_printer = true,
    $fn = 12
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
        hull() {
            for (x = [radius + base, width - radius - base]) {
                for (y = [radius + base, length - radius - base]) {
                    translate([x, y, 0]) {
                        cylinder(
                            r = radius,
                            h = e
                        );
                    }
                }
            }

            for (x = [radius, width - radius]) {
                for (y = [radius, length - radius]) {
                    translate([x, y, base - e]) {
                        cylinder(
                            r = radius,
                            h = e
                        );
                    }
                }
            }
        }
    }

    rotate([arrange_for_printer ? 45 : 0, 0, 0]) {
        translate([0, arrange_for_printer ? -base : 0, 0]) {
            base();
            # print(bleed);
        }
    }
}

module test_bleeds(
    bleeds = [
        /* 0, // details lost here at all scales */
        .1, // details lost here and lower at scale 1
        /* .125, */
        /* .15, */
        /* .2 */
    ],
    scales = [
        /* 1, */
        1.25,
        1.5
    ]
) {
    gutter = 1;

    plot = max(svg_width, svg_length) * max(scales);

    for (i = [0 : len(bleeds) - 1]) {
        for (ii = [0 : len(scales) - 1]) {
            translate([
                i * (svg_width * scales[ii] + gutter),
                ii * (svg_length * scales[0] + gutter),
                0
            ]) {
                cat_stamp(
                    bleed = bleeds[i],
                    scale = scales[ii],
                    rim = gutter
                );
            }
        }
    }
}

cat_stamp(
    scale = 2,
    arrange_for_printer = false
);
