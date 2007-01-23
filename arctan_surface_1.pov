// ===== 1 ======= 2 ======= 3 ======= 4 ======= 5 ======= 6 ======= 7 ======= 8 ======= 9 ======= 10

#version 3.5;

#include "colors.inc"
#include "rad_def.inc"

global_settings {
  assumed_gamma 1
  max_trace_level 12
  ambient_light color White
  radiosity {
    Rad_Settings(Radiosity_Normal, off, off)
    //Rad_Settings(Radiosity_Final, off, off)
  }
//  photons {
//    spacing 0.02
//    max_trace_level 5
//  }
}

// ===== 1 ======= 2 ======= 3 ======= 4 ======= 5 ======= 6 ======= 7 ======= 8 ======= 9 ======= 10

#declare M_Glass =
  material {
    texture {
      //pigment { color rgbf <1.0, 0.6, 0.0, 1.2> }
      //pigment { brick brick_size <5,5,1> }
      pigment { brick rgbf <1.0, 0.6, 0.0, 1.2> Clear brick_size <2,2,100>*.2 mortar .1 }
      finish {
        ambient 0.0
        diffuse 0.05
        //specular 0.6
        roughness 0.001
        reflection {
          //0.1, 0.9
          0.1
          fresnel on
        }
        conserve_energy
      }
    }
    interior {
      ior 1.5
      fade_power 1001
      fade_distance 0.9
      fade_color <0.5,0.8,0.6>
    }
  }

// ===== 1 ======= 2 ======= 3 ======= 4 ======= 5 ======= 6 ======= 7 ======= 8 ======= 9 ======= 10

// the Riemann surface - intersection between isosurfaces and a cylinder

intersection {
  union {
    isosurface {
      function { pow((z-(atan2(y,x)+pi/2)),2) - .01 }
      max_gradient 300
      contained_by { box { <0,-200,-100>, <200,200,100> } }
      rotate <0, 0, 90>
    }
    isosurface {
      function { pow((z-(atan2(y,x)-pi/2)),2) - .01 }
      max_gradient 300
      contained_by { box { <0,-200,-100>, <200,200,50> } }
      rotate <0, 0, -90>
    }
  }
  cylinder { <0,0,-100>, <0,0,100>, 50 }

  material { M_Glass }
  hollow
}

#declare func1 = function(x) {
  pow(x,3) - 3*x
}

#declare curve = function(x,y,z,fx,fy,fz) {
  (pow(x-fx,2) + pow(y-fy,2) + pow(z-fz,2)) - 1
}

//isosurface {
//  //function { curve(x,y,z,func1(sqrt(y+2)),y,0) }
//  //function { curve(x,y,z,y,y,0) }
//  //function { -(pow(x-y,2) + pow(z,2) - 1) }
//  //function { -((x-y)*(x-y) + z*z - 10) }
//  function { -(x*x + y*y + z*z - 25) }
//  //function { x*x - 100 }
//  //function { -(z*z - 100) }
//  //contained_by { box{<-100,-100,-100>, <100,100,100>} }
//  contained_by { box{-5,5} }
//  //max_gradient 2
//  open
//  all_intersections
//  pigment { color Black }
//}

// x-axis
cylinder {
  <-100, 0, 0>,     // Center of one end
  <100, 0, 0>,     // Center of other end
  0.1            // Radius
  open           // Remove end caps
  pigment { color Black }
}

// y-axis
cylinder {
  <0, -100, 0>,     // Center of one end
  <0, 100, 0>,     // Center of other end
  0.1            // Radius
  open           // Remove end caps
  pigment { color Black }
}

// z-axis
cylinder {
  <0, 0, 0>,     // Center of one end
  <0, 0, 100>,     // Center of other end
  0.1            // Radius
  open           // Remove end caps
  pigment { color Black }
}

// ===== 1 ======= 2 ======= 3 ======= 4 ======= 5 ======= 6 ======= 7 ======= 8 ======= 9 ======= 10

sphere {
  <0, 0, 0>, 1
  hollow
  texture {
    pigment {
      gradient y
      color_map {
        [ 0.5 color rgb <0.5, 0.5, 0.5> ]
        [ 1.0 color rgb <1.0, 1.0, 1.0>*0.7 ]
      }
    }
    finish {
      ambient color White*0.7
      diffuse 0.6
      specular 0.3
    }
    scale <1, 2, 1>
    translate  <0, -1, 0>
  }
  scale <1, 1, 1>*1000
}

light_source {
  <-4, -2, 3>*100
  color rgb <1.0, 0.95, 0.90>*1.5
//  photons {
//    refraction on
//    reflection on
//  }
}

camera {
  orthographic
  right -4/3*x
  up y
  angle
  direction <-1,0,0>
// view 1
//  location <-4, 4, 5>*20
//  look_at <-10, 1, 0>
// view 2
//  location <1, 1, 5>*20
//  look_at <-1, 1, 0>
// view 3
//  location <1, 1, 5>*10
//  look_at <-1, 1, 0>
// view 4
  location <1, -1, 5>*2
  look_at <-1, 1, 0>*.5
}

// ===== 1 ======= 2 ======= 3 ======= 4 ======= 5 ======= 6 ======= 7 ======= 8 ======= 9 ======= 10
