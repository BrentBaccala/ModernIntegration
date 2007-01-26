// Persistence Of Vision raytracer version 3.5 sample file.
// Demo showing several torii ... Dieter Bayer, June 1994
//
// -w320 -h240
// -w800 -h600 +a0.3
//


#include "colors.inc"
#include "textures.inc"
#include "glass.inc"
#include "rad_def.inc"


global_settings { 
  assumed_gamma 2.2 
  max_trace_level 5
  ambient_light color White
  //ambient_light 4
  radiosity {
    Rad_Settings(Radiosity_Fast, off, off)
    //Rad_Settings(Radiosity_Final, off, off)
  }
}


camera {
  location <20, -180, 200>
//  right <4/3, 0, 0>
//  up <0, 1, 0>
//  sky <0, 1, 0>
//  direction <0, 0, 1.8>
  direction <1.8, 0, 0>
  look_at <0, 15, 0>
}

//light_source { <50, 200, 100> colour Gray70 }
//light_source { <-20, 40, 20> colour Gray70 }
//light_source { <50, -80, 200> colour Gray70 }
//light_source { <50, 80, 200> colour Gray70 }
//light_source { <100, 80, 200> colour Gray70 }
//light_source { <100, -280, 200> colour Gray70 }
//light_source { <-100, 80, 200> colour Gray70 }
//light_source { <-100, -280, 200> colour Gray70 }

//light_source { <50, 80, -20> colour Gray70 }

//light_source { <0, 80, 0> colour Gray70 }

sphere {
  <0, 0, 0>, 1
  hollow
  texture {
    pigment {
      gradient y
      color_map {
        [ 0.5 color rgb <0.0, 0.0, 0.5> ]
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
  <4,-10,20> * 100
  color rgb <1.0, 0.95, 0.90>*1.5
  photons {
    refraction on
    reflection on
  }
}

background { color MidnightBlue }

// x-axis
  cylinder {
    <-100, 0, 0>,     // Center of one end
    <100, 0, 0>,     // Center of other end
    0.5            // Radius
    open           // Remove end caps
    //texture { T_Stone25 scale 4 }
    pigment { color Green }
  }

// y-axis
  cylinder {
    <0, -100, 0>,     // Center of one end
    <0, 100, 0>,     // Center of other end
    0.5            // Radius
    open           // Remove end caps
    //texture { T_Stone25 scale 4 }
    pigment { color Red }
  }

// z-axis
  cylinder {
    <0, 0, 0>,     // Center of one end
    <0, 0, 100>,     // Center of other end
    0.5            // Radius
    open           // Remove end caps
    //texture { T_Stone25 scale 4 }
    pigment { color Blue }
  }

// M_Glass is from Villarceau_Circles

#declare M_Glass =
  material {
    texture {
      pigment { color rgbf <1.0, 0.6, 0.0, 1.2> }
      finish {
        ambient 0.0
        diffuse 0.05
        specular 0.6
        roughness 0.001
        reflection {
          0.1, 0.9
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

#declare F_GlassMy6 =
  finish {
    specular 0.6
    roughness 0.002
    //ambient 0.6
    ambient 0.1
    diffuse 0.1
    brilliance 5
    reflection {
      0.1, 1.0
      fresnel on
    }
    conserve_energy
  }

intersection {
  union {
  isosurface {
    function { pow(z/10-atan2(y,x),2) - .01 }
    contained_by { box { <0,-200,-50>, <200,200,50> } }
    //open
  }
  isosurface {
    function { pow((z/10-(atan2(y,x)-pi)),2) - .01 }
    contained_by { box { <0,-200,-100>, <200,200,50> } }
    //open
    rotate <0, 0, 180>
  }
  isosurface {
    function { pow((z/10-(atan2(y,x)-2*pi)),2) - .01 }
    contained_by { box { <0,-200,-100>, <200,200,50> } }
    //open
  }
  }
  cylinder { <0,0,-100>, <0,0,100>, 50 }

//    pigment { color Orange }
////    pigment { color rgbft<1,1,0,0.9,0.9> }
//   finish { F_GlassMy6 }
//    interior { I_Glass1 }
  material { M_Glass }
  }

