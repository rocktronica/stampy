# stampy

OpenSCAD code for 3D-printed stamps, made especially for pottery.

## Images

Images are SVG files, flattened to work with OpenSCAD.

At small scales, keep the design simple and line widths consistent so no details get lost.

## Printing

Make sure `arrange_for_printer` in `stampy.scad` is `true`; this angles the stamps at 45 degrees, a Cool Trick to get higher resolution w/o additional suppots. Then slice at .1mm per layer.

It's helpful to print the stamps separately from their handles or anything else to prevent layer noise.

## License

MIT license.

Included `threads.scad` by [Dan Kirshner](https://dkprojects.net/openscad-threads/), GNU GPL license.

If you're using this for anything commercial, please switch the SVGs out -- I didn't design them.
