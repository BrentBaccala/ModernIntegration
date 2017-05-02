
// A regular tetrahedral die with each vertex lettered, for use as
// a "lifeline" in the game question at the start of Chapter 1.

// see http://mathworld.wolfram.com/RegularPyramid.html

H = 30;                       // height of pyramid
R = H/sqrt(2);                // circumradius
a = 2*R*sqrt(3)/2;            // side length
r = a/2/sqrt(3);              // inradius

// see https://en.wikipedia.org/wiki/Tetrahedron

dihedral_angle = acos(1/3);   // angle of the pyramid's edges

// a single letter, centered and translated to just below the
// pyramid's vertex, and extending +/- 0.5 units above and below
// the xy-plane, to be used to indent into the pyramid
//
// the 'flip' flag is used to flip the letters on the bottom
// so they don't appear backwards when viewed

module letter(t, ang, flip=false) {
  rotate([0,0,ang]) translate([R-7,0,-0.5]) linear_extrude(height=1) {
     rotate([0,flip ? 180 : 0,-90]) text(t, halign="center", valign="top", size=8);
  };
}

module pyramid() {
  difference() {

    // a cylinder approximated by three points on its base forms a tetrahedron
    cylinder(H,R,00,$fn=3);

    rotate([0,0,0]) translate([-r,0,0]) rotate([0,-dihedral_angle,0]) translate([r,0,0]) {
      letter("A", 0);
      letter("B", 120);
      letter("C", 240);
    }
    rotate([0,0,120]) translate([-r,0,0]) rotate([0,-dihedral_angle,0]) translate([r,0,0]) {
      letter("A", 0);
      letter("C", 120);
      letter("D", 240);
    }
    rotate([0,0,240]) translate([-r,0,0]) rotate([0,-dihedral_angle,0]) translate([r,0,0]) {
      letter("A", 0);
      letter("D", 120);
      letter("B", 240);
    }
    {
      letter("D", 0, true);
      letter("B", 120, true);
      letter("C", 240, true);
    }
  }
}

pyramid();
