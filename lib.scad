$fn = $preview ? 32 : 64;

tiny = 0.01;

module rotate_around(point, angle) {
  translate(point) rotate(angle) translate(-point) children();
}

module smooth_cylinder(h, r, fillet, r1, r2) {
  r1 = is_undef(r1) ? r : r1;
  r2 = is_undef(r2) ? r : r2;

  rotate_extrude() hull() {
    polygon([ [ 0, 0 ], [ r1 - fillet, 0 ], [ r2 - fillet, h ], [ 0, h ] ]);
    translate([ r1 - fillet, fillet ]) circle(fillet);
    translate([ r2 - fillet, h - fillet ]) circle(fillet);
  }
}

module offset_cylinder(h, r, r1, r2, offset) {
  r1 = is_undef(r1) ? r : r1;
  r2 = is_undef(r2) ? r : r2;

  if (h != 0 && r != 0)
    translate([ 0, 0, -offset ]) smooth_cylinder(h = h + offset * 2, r1 = r1 + offset,
                                                 r2 = r2 + offset, fillet = offset);
}

module smooth_cube(size, fillet) {
  r = fillet;
  d = r * 2;

  hull() {
    translate([ 0, r, r ]) cube(size - [ 0, d, d ]);
    translate([ r, 0, r ]) cube(size - [ d, 0, d ]);
    translate([ r, r, 0 ]) cube(size - [ d, d, 0 ]);
    translate([ r, r, r ]) sphere(fillet);
    translate([ size.x - r, r, r ]) sphere(fillet);
    translate([ r, size.y - r, r ]) sphere(fillet);
    translate([ size.x - r, size.y - r, r ]) sphere(fillet);
    translate([ r, r, size.z - r ]) sphere(fillet);
    translate([ size.x - r, r, size.z - r ]) sphere(fillet);
    translate([ r, size.y - r, size.z - r ]) sphere(fillet);
    translate([ size.x - r, size.y - r, size.z - r ]) sphere(fillet);
  }
}

module offset_cube(size, offset) {
  if (size.x != 0 && size.y != 0 && size.z != 0)
    translate(-[ offset, offset, offset ])
      smooth_cube(size + [ offset, offset, offset ] * 2, fillet = offset);
}

module lever_button_slot(size, radius, reach) {
  hull() {
    linear_extrude(is_undef(reach) ? size.z : reach) circle(radius);
    linear_extrude(size.z)
      polygon([ [ -size.x / 2, size.y ], [ size.x / 2, size.y ], [ 0, 0 ] ]);
  }
}

module lever_button(size, radius, reach) {
  z_reach = max(is_undef(reach) ? size.z : reach, size.z);

  difference() {
    hull() {
      lever_button_slot(size, radius, z_reach);
      translate([ 0, 0, -size.z / 2 ]) cylinder(h = size.z / 2, r = radius);
    }
    translate([ -size.x / 2, size.y, z_reach ])
      resize([ size.x, size.y * 2 - radius * 2, z_reach * 2 - size.z ])
        rotate([ 0, 90, 0 ]) cylinder(h = size.x, r = 0.1);
  }
}

// Extracts a grid of repeated child modules from 'points' polygon.
// points - [[x1, y1], ..., [xn, yn]] grid area;
// step =[0, 0] - grid cell offset;
// shell =0 - grid border thickness, negative go towards center, positive go away;
// rounding =0 - grid cell rounding;
// angle =0 - grid rotation around z-axis;
// round_grid_border =false - should intersections between grid and shell be rounded.
module grid(points, step = [ 0, 0 ], shell = 0, rounding = 0, angle = 0,
            round_grid_border = false) {
  assert(len(points) >= 3);

  min_x = min([for (p = points) p.x]);
  min_y = min([for (p = points) p.y]);
  max_x = max([for (p = points) p.x]);
  max_y = max([for (p = points) p.y]);
  center = [ min_x + max_x, min_y + max_y ] / 2;
  radius = sqrt(pow(center.x - min_x, 2) + pow(center.y - min_y, 2));
  start = angle == 0 ? [ min_x, min_y ] : (center - [ radius, radius ]);
  end = angle == 0 ? [ max_x, max_y ] : (center + [ radius, radius ]);

  difference() {
    offset(delta = max(shell, 0)) polygon(points);
    offset(delta = min(shell, 0)) polygon(points);
  }

  intersection() {
    offset(delta = shell) polygon(points);

    offset(round_grid_border ? -rounding : 0) offset(round_grid_border ? rounding : 0)
      difference() {
      offset(delta = shell + rounding) polygon(points);

      intersection() {
        offset(delta = min(0, shell)) offset(round_grid_border ? 0 : rounding * 2)
          polygon(points);

        rotate_around(center, angle) {
          for (x = [start.x:step.x:end.x])
            for (y = [start.y:step.y:end.y]) {
              translate([ x, y ]) children();
            }
        }
      }
    }
  }
}

// Converts grid cells inside 'points' polygon into solids.
// points - [[x1, y1], ..., [xn, yn]] grid area;
// step =[0, 0] - grid cell offset;
// shell =0 - grid border thickness, negative go towards center, positive go away;
// rounding =0 - grid cell rounding;
// angle =0 - grid rotation around z-axis;
// round_grid_border =false - should intersections between grid and shell be rounded.
module grid_slot(points, step = [ 0, 0 ], shell = 0, rounding = 0, angle = 0,
                 round_grid_border = false) {
  difference() {
    polygon(points);

    grid(points = points, step = step, shell = shell, rounding = rounding,
         angle = angle, round_grid_border = round_grid_border) children();
  }
}

module fillet_cylinder(h, r, bottom_fillet = 0, top_fillet = 0) {
  rotate_extrude() {
    square([ r, h ]);

    difference() {
      translate([ r, 0 ]) square(bottom_fillet);
      translate([ r + bottom_fillet, bottom_fillet ]) circle(bottom_fillet);
    }

    difference() {
      translate([ r, h - top_fillet ]) square(top_fillet);
      translate([ r + top_fillet, h - top_fillet ]) circle(top_fillet);
    }
  }
}

module mirror_copy(m) {
  children();
  mirror(m) children();
}

module difference_last() {
  difference() {
    for (idx = [0:$children - 2])
      children(idx);

    children($children - 1);
  }
}

// https://gist.github.com/boredzo/fde487c724a40a26fa9c?permalink_comment_id=4258747#gistcomment-4258747
// Skews the child geometry.
// xy: Angle towards X along Y axis.
// xz: Angle towards X along Z axis.
// yx: Angle towards Y along X axis.
// yz: Angle towards Y along Z axis.
// zx: Angle towards Z along X axis.
// zy: Angle towards Z along Y axis.
module skew(xy = 0, xz = 0, yx = 0, yz = 0, zx = 0, zy = 0) {
  matrix = [
    [ 1, tan(xy), tan(xz), 0 ], [ tan(yx), 1, tan(yz), 0 ], [ tan(zx), tan(zy), 1, 0 ],
    [ 0, 0, 0, 1 ]
  ];
  multmatrix(matrix) children();
}

module support(size, steps, thickness) {
  points =
    [for (x = 0, y = 0, i = 0; x <= size.x && y <= size.y;
          x = x + steps[i].x, y = y + steps[i].y, i = (i + 1) % len(steps))[x, y]];

  for (i = [0:len(points) - 2])
    linear_extrude(size.z) hull() {
      translate(points[i]) circle(thickness / 2);
      translate(points[i + 1]) circle(thickness / 2);
    }
}
