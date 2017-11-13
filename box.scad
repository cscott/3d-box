/*//////////////////////////////////////////////////////////////////
              -    FB Aka Heartman/Hearty 2016     -
              -   http://heartygfx.blogspot.com    -
              -       OpenScad Parametric Box      -
              -         CC BY-NC 3.0 License       -
////////////////////////////////////////////////////////////////////
12/02/2016 - Fixed minor bug
28/02/2016 - Added holes ventilation option
09/03/2016 - Added PCB feet support, fixed the shell artefact on export mode.

*/////////////////////////// - Info - //////////////////////////////

// All coordinates are starting as integrated circuit pins.
// From the top view :

//   CoordD           <---       CoordC
//                                 ^
//                                 ^
//                                 ^
//   CoordA           --->       CoordB


////////////////////////////////////////////////////////////////////


////////// - Paramètres de la boite - Box parameters - /////////////

/* [Box dimensions] */
// - Longueur - Length
  Length        = 73; // (pcb=59) + 6*(wall=2) + 2*(m=1)
// - Largeur - Width
  Width         = 41; // (pcb=37) + 2*(wall=2)
// - Hauteur - Height
  Height        = 40.5; // 36 + 2*(wall=2) + 0.5 (extra foot height)
// - Epaisseur - Wall thickness
  Thick         = 2;

/* [Box options] */
// - Diamètre Coin arrondi - Filet diameter
  Filet         = 2.1;//[0.1:12]
// - lissage de l'arrondi - Filet smoothness
  Resolution    = 50;//[1:100]
// - Tolérance - Tolerance (Panel/rails gap)
  m             = 1;
// - Decorations to ventilation holes
  Vent          = 1;// [0:No, 1:Yes]
// - Decoration-Holes width (in mm)
  Vent_width    = 1.5;



/* [PCB_Feet] */
//All dimensions are from the center foot axis

// - Coin bas gauche - Low left corner X position
PCBPosX         = -1; // -(3*Thick+2) + (3*Thick+m)
// - Coin bas gauche - Low left corner Y position
PCBPosY         = -3; // -(Thick+5) + Thick + 2 (to adjust feet to 7mm in)
// - Longueur PCB - PCB Length
PCBLength       = 49; // (pcb=59) - 10
// - Largeur PCB - PCB Width
PCBWidth        = 23; // (pcb=37) - 10 - 2*2 (to adjust feed to 7mm in)
// - Heuteur pied - Feet height
FootHeight      = 9.5; // foot height = 9, plus .5 for extra clearance
// - Diamètre pied - Foot diameter
FootDia         = 4.5;
// - Diamètre trou - Hole diameter
FootHole        = 1;


/* [STL element to export] */
part = "all"; // [tshell,bshell,fpanl,bpanl]
/* [Hidden] */

box_orig(part=part);


/////////// - Boitier générique bord arrondis - Generic rounded box - //////////

module RoundBox($a=Length, $b=Width, $c=Height,
                Length=Length, Filet=Filet, Resolution=Resolution) {
  $fn=Resolution;
  translate([0,Filet,Filet]) {
    minkowski() {
      cube ([$a-(Length/2),$b-(2*Filet),$c-(2*Filet)], center = false);
      rotate([0,90,0]) {
        cylinder(r=Filet,h=Length/2, center = false);
      }
    }
  }
} // End of RoundBox Module


//////////////////////////// - Module Coque/Shell - /////////////////////////

module Coque(Length=Length, Width=Width, Height=Height, Thick=Thick*2, Filet=Filet, m=m, Resolution=Resolution, Dec_Thick=undef, Dec_size=undef, Vent_width=Vent_width) {//Coque - Shell
    difference(){
        difference(){//sides decoration
            union(){
                     difference() {//soustraction de la forme centrale - Substraction Fileted box

                        difference(){//soustraction cube median - Median cube slicer
                            union() {//union
                            difference(){//Coque
                                RoundBox($a=Length, $b=Width, $c=Height,
                                         Length=Length, Filet=Filet, Resolution=Resolution);
                                translate([Thick/2,Thick/2,Thick/2]){
                                        RoundBox($a=Length-Thick, $b=Width-Thick, $c=Height-Thick, Length=Length, Filet=Filet, Resolution=Resolution);
                                        }
                                        }//Fin diff Coque
                                difference(){//largeur Rails
                                     translate([Thick+m,Thick/2,Thick/2]){// Rails
                                          RoundBox($a=Length-((2*Thick)+(2*m)), $b=Width-Thick, $c=Height-(Thick*2), Length=Length, Filet=Filet, Resolution=Resolution);
                                                          }//fin Rails
                                     translate([((Thick+m/2)*1.55),Thick/2,Thick/2+0.1]){ // +0.1 added to avoid the artefact
                                          RoundBox($a=Length-((Thick*3)+2*m), $b=Width-Thick, $c=Height-Thick, Length=Length, Filet=Filet, Resolution=Resolution);
                                                    }
                                                }//Fin largeur Rails
                                    }//Fin union
                               translate([-Thick,-Thick,Height/2]){// Cube à soustraire
                                    cube ([Length+100, Width+100, Height], center=false);
                                            }
                                      }//fin soustraction cube median - End Median cube slicer
                               translate([-Thick/2,Thick,Thick]){// Forme de soustraction centrale
                                    RoundBox($a=Length+Thick, $b=Width-Thick*2, $c=Height-Thick, Length=Length, Filet=Filet, Resolution=Resolution);
                                    }
                                }


                difference(){// wall fixation box legs
                    union(){
                        translate([3*Thick +5,Thick,Height/2]){
                            rotate([90,0,0]){
                                    $fn=6;
                                    cylinder(d=16,Thick/2);
                                    }
                            }

                       translate([Length-((3*Thick)+5),Thick,Height/2]){
                            rotate([90,0,0]){
                                    $fn=6;
                                    cylinder(d=16,Thick/2);
                                    }
                            }

                        }
                            translate([4,Thick+Filet,Height/2-57]){
                             rotate([45,0,0]){
                                   cube([Length,40,40]);
                                  }
                           }
                           translate([0,-(Thick*1.46),Height/2]){
                                cube([Length,Thick*2,10]);
                           }
                    } //Fin fixation box legs
            }

        union(){// outbox sides decorations

            for(i=[0:Thick:Length/4]){

                // Ventilation holes part code submitted by Ettie - Thanks ;)
                    translate([10+i,-Dec_Thick+Dec_size,1]){
                    cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([(Length-10) - i,-Dec_Thick+Dec_size,1]){
                    cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([(Length-10) - i,Width-Dec_size,1]){
                    cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([10+i,Width-Dec_size,1]){
                    cube([Vent_width,Dec_Thick,Height/4]);
                    }


                    }// fin de for
               // }
                }//fin union decoration
            }//fin difference decoration


            union(){ //sides holes
                $fn=50;
                translate([3*Thick+5,20,Height/2+4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
                translate([Length-((3*Thick)+5),20,Height/2+4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
                translate([3*Thick+5,Width+5,Height/2-4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
                translate([Length-((3*Thick)+5),Width+5,Height/2-4]){
                    rotate([90,0,0]){
                    cylinder(d=2,20);
                    }
                }
            }//fin de sides holes

        }//fin de difference holes
}// fin coque

////////////////////////////// - Experiment - ///////////////////////////////////////////





/////////////////////// - Foot with base filet - /////////////////////////////
module foot(FootDia,FootHole,FootHeight,Thick=Thick,Filet=Filet,FootDia=FootDia,FootHeight=FootHeight,Couleur1="black"){
    Filet=2;
    color(Couleur1)
    translate([0,0,Filet-1.5])
    difference(){

    difference(){
            //translate ([0,0,-Thick]){
                cylinder(d=FootDia+Filet,FootHeight-Thick, $fn=100);
                        //}
                    rotate_extrude($fn=100){
                            translate([(FootDia+Filet*2)/2,Filet,0]){
                                    minkowski(){
                                            square(10);
                                            circle(Filet, $fn=100);
                                        }
                                 }
                           }
                   }
            cylinder(d=FootHole,FootHeight+1, $fn=100);
               }
}// Fin module foot

module Feet(Thick=Thick,Filet=Filet,FootDia=FootDia,FootHole=FootHole,FootHeight=FootHeight,PCBLength=PCBLength,PCBWidth=PCBWidth,Couleur1="gray"){
//////////////////// - PCB only visible in the preview mode - /////////////////////
    translate([3*Thick+2,Thick+5,FootHeight+(Thick/2)-0.5]){

    %square ([PCBLength+10,PCBWidth+10]);
       translate([PCBLength/2,PCBWidth/2,0.5]){
        color("Olive")
        %text("PCB", halign="center", valign="center", font="Arial black");
       }
    } // Fin PCB


////////////////////////////// - 4 Feet - //////////////////////////////////////////
    translate([3*Thick+7,Thick+10,Thick/2]){
        foot(FootDia,FootHole,FootHeight,Thick=Thick,Filet=Filet,FootDia=FootDia,FootHeight=FootHeight,Couleur1=Couleur1);
    }
    translate([(3*Thick)+PCBLength+7,Thick+10,Thick/2]){
        foot(FootDia,FootHole,FootHeight,Thick=Thick,Filet=Filet,FootDia=FootDia,FootHeight=FootHeight,Couleur1=Couleur1);
        }
    translate([(3*Thick)+PCBLength+7,(Thick)+PCBWidth+10,Thick/2]){
        foot(FootDia,FootHole,FootHeight,Thick=Thick,Filet=Filet,FootDia=FootDia,FootHeight=FootHeight,Couleur1=Couleur1);
        }
    translate([3*Thick+7,(Thick)+PCBWidth+10,Thick/2]){
        foot(FootDia,FootHole,FootHeight,Thick=Thick,Filet=Filet,FootDia=FootDia,FootHeight=FootHeight,Couleur1=Couleur1);
    }

} // Fin du module Feet




 ////////////////////////////////////////////////////////////////////////
////////////////////// <- Holes Panel Manager -> ///////////////////////
////////////////////////////////////////////////////////////////////////

//                           <- Panel ->
module Panel(Length,Width,Thick,Filet,m){
    scale([0.5,1,1])
    minkowski(){
            cube([Thick,Width-(Thick*2+Filet*2+m),Height-(Thick*2+Filet*2+m)]);
            translate([0,Filet,Filet])
            rotate([0,90,0])
            cylinder(r=Filet,h=Thick, $fn=100);
      }
}



//                          <- Circle hole ->
// Cx=Cylinder X position | Cy=Cylinder Y position | Cdia= Cylinder dia | Cheight=Cyl height
module CylinderHole(OnOff,Cx,Cy,Cdia){
    if(OnOff==1)
    translate([Cx,Cy,-1])
        cylinder(d=Cdia,10, $fn=50);
}
//                          <- Square hole ->
// Sx=Square X position | Sy=Square Y position | Sl= Square Length | Sw=Square Width | Filet = Round corner
module SquareHole(OnOff,Sx,Sy,Sl,Sw,Filet){
    if(OnOff==1)
     minkowski(){
        translate([Sx+Filet/2,Sy+Filet/2,-1])
            cube([Sl-Filet,Sw-Filet,10]);
            cylinder(d=Filet,h=10, $fn=100);
       }
}



//                      <- Linear text panel ->
module LText(OnOff,Tx,Ty,Font,Size,Content){
    if(OnOff==1)
    translate([Tx,Ty,Thick+.5])
    linear_extrude(height = 0.5){
    text(Content, size=Size, font=Font);
    }
}
//                     <- Circular text panel->
module CText(OnOff,Tx,Ty,Font,Size,TxtRadius,Angl,Turn,Content){
      if(OnOff==1) {
      Angle = -Angl / len(Content);
      translate([Tx,Ty,Thick+.5])
          for (i= [0:len(Content)-1] ){
              rotate([0,0,i*Angle+90+Turn])
              translate([0,TxtRadius,0]) {
                linear_extrude(height = 0.5){
                text(Content[i], font = Font, size = Size,  valign ="baseline", halign ="center");
                    }
                }
             }
      }
}
////////////////////// <- New module Panel -> //////////////////////
module FPanL(Length=Length,Width=Width,Thick=Thick,Filet=Filet,m=m,Couleur1="black",Couleur2="blue"){
    difference(){
        color(Couleur2)
        Panel(Length,Width,Thick,Filet,m);


    rotate([90,0,90]){
        color(Couleur2){
//                     <- Cutting shapes from here ->
        CylinderHole(1, 29, 12+4, 8);
//                            <- To here ->
           }
       }
}

    color(Couleur1){
        translate ([-.5,0,0])
        rotate([90,0,90]){
//                      <- Adding text from here ->
        LText(1,3,24,"Arial Black",4,"TO PANEL");
        LText(1,3.5,5,"Arial Black",3,"Made by CSA");
//                            <- To here ->
            }
      }
}

module BPanL(Length=Length,Width=Width,Thick=Thick,Filet=Filet,m=m,Couleur1="black",Couleur2="blue"){
    difference(){
        color(Couleur2)
        Panel(Length,Width,Thick,Filet,m);


    rotate([90,0,90]){
        color(Couleur2){
        UsbHole=[13.5,5.5];
//                     <- Cutting shapes from here ->
        SquareHole  (1,27-m-(UsbHole.x/2),26-(UsbHole.y/2),UsbHole.x,UsbHole.y,1); //(On/Off, Xpos,Ypos,Length,Width,Filet)
//                            <- To here ->
           }
       }
}

    color(Couleur1){
        translate ([-.5,0,0])
        rotate([90,0,90]){
//                      <- Adding text from here ->
        LText(1,4,16,"Arial Black",5,"Z-Wave");
        LText(1,4, 8,"Arial Black",5,"Buzzer");
//                            <- To here ->
            }
      }
}


/////////////////////////// <- Main part -> /////////////////////////

module box_orig(part="all", Length=Length, Width=Width, Thick=Thick, Filet=Filet, m=m, Couleur1="Orange"/*shell color*/, Couleur2="OrangeRed"/*panels color*/, Resolution=Resolution, Vent=true, Vent_width=Vent_width, PCBPosX=PCBPosX, PCBPosY=PCBPosY, PCBFeet=true, FootDia=FootDia, FootHole=FootHole, FootHeight=FootHeight, PCBLength=PCBLength, PCBWidth=PCBWidth) {

// Thick X 2 - making decorations thicker if it is a vent to make sure they go through shell
Dec_Thick       = Vent ? Thick*2 : Thick;
// - Depth decoration
Dec_size        = Vent ? Thick*2 : 0.8;


if(part=="tshell"||part=="all")
// Coque haut - Top Shell
        color( Couleur1,1){
            translate([0,Width,Height+0.2]){
                rotate([0,180,180]){
                        Coque(Length=Length, Width=Width, Height=Height, Thick=Thick*2, Filet=Filet, m=m, Resolution=Resolution, Dec_Thick=Dec_Thick, Dec_size=Dec_size, Vent_width=Vent_width);
                        }
                }
        }

if(part=="bshell"||part=="all")
// Coque bas - Bottom shell
        color(Couleur1){
        Coque(Length=Length, Width=Width, Height=Height, Thick=Thick*2, Filet=Filet, m=m, Resolution=Resolution, Dec_Thick=Dec_Thick, Dec_size=Dec_size, Vent_width=Vent_width);
        }

// Pied support PCB - PCB feet
if (PCBFeet && (part=="bshell" || part=="all"))
// Feet
        translate([PCBPosX,PCBPosY,0]){
        Feet(Thick=Thick,Filet=Filet,FootDia=FootDia,FootHole=FootHole,FootHeight=FootHeight,PCBLength=PCBLength,PCBWidth=PCBWidth,Couleur1=Couleur1);
        }

// Panneau avant - Front panel  <<<<<< Text and holes only on this one.
//rotate([0,-90,-90])
if (part=="all"||part=="fpanl")
        translate([Length-(Thick*2+m/2),Thick+m/2,Thick+m/2])
        FPanL(Length=Length,Width=Width,Thick=Thick,Filet=Filet,m=m,Couleur1=Couleur1,Couleur2=Couleur2);

//Panneau arrière - Back panel
PanelCenter=[Thick/2,(Width-(Thick*2+m))/2,0];
if (part=="all"||part=="bpanl")
        color(Couleur2)
        translate([Thick+m/2,Thick+m/2,Thick+m/2])
        translate(PanelCenter) rotate([0,0,180]) translate(-PanelCenter)
        BPanL(Length=Length,Width=Width,Thick=Thick,Filet=Filet,m=m,Couleur1=Couleur1,Couleur2=Couleur2);
} // end of box_orig
