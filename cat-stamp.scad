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

test_bleeds();
