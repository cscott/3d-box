/* Enclosures for ATX board projects */
// dimensions relative to eagle, so origin is
// lower-left corner of PCB.

/* [Global] */
// This design is composed of a number of separate printable parts:
part = "1_all"; // [1_top:RPi Box Top,1_bottom:RPi Box Bottom,1_all:RPi Box Assembled, 2_top:ATX Power Box Top,2_bottom:ATX Power Box Bottom,2_all:ATX Power Box Assembled]

/* [Hidden] */

function inch() = 25.4;
function standoff1() = [.175*inch(), 1.375*inch(), 0];
function standoff2() = [2.65*inch(), .625*inch(), 0];
function button() = [2.65*inch(), 0.95*inch(), 0];


main(part);

module main(part="2_all") {
  if (part=="1_bottom" || part=="1_all") {
    rpi_box_bottom();
  }
  if (part=="1_top" || part=="1_all") {
    rpi_box_top();
  }
  if (part=="1_pcb" || part=="1_all") {
    board();
  }
  if (part=="2_bottom" || part=="2_all") {
    power_box_bottom();
  }
  if (part=="2_top" || part=="2_all") {
    power_box_top();
  }
  if (part=="2_pcb" || part=="2_all") {
    board(atx=true, usb=false, rpi=false, button=false, screw=false);
  }
  if (part=="2_all") {
    rocker();
  }
}

module rpi_box_top(spaceup=20) {
  intersection() {
    rpi_box(spaceup=spaceup);
    splitter();
  }
  push_button(spaceup=spaceup);
  difference() {
    push_button(outer=true, c=2, short=true, spaceup=spaceup);
    push_button(outer=true, c=0.5, e=.1, spaceup=spaceup);
    rpi_connector(extra=spaceup+10, clearance=1.5);
  }
}

module rpi_box_bottom() {
  difference() {
    rpi_box();
    splitter();
  }
}

module splitter() {
  translate([-100,-100,1])
    cube([200,200,200]);
}

module rpi_box(thick=2, spaceup=15 /* should be >10 */,
           atx=true, usb=true, rpi=true, button=true, screw=true) {
  spacexy=2; spacedown=5;
  difference() {
    union() {
      difference() {
        translate([-spacexy-thick,-spacexy-thick,-spacedown-thick])
          cube([3.2*inch()+2*spacexy+2*thick, 1.5*inch()+2*spacexy+2*thick, spacedown+1.6+spaceup+2*thick]);
        // hollow out
        translate([-spacexy,-spacexy,-spacedown])
          cube([3.2*inch()+2*spacexy, 1.5*inch()+2*spacexy, spacedown+1.6+spaceup]);

        // space around connectors, etc
        board(extra=30, clearance=1.5, atx=atx, usb=usb, rpi=rpi, button=button, screw=screw);
      }
      standoffs(spacedown=spacedown, spaceup=spaceup, thick=thick, holes=false);
    }
    standoffs(spacedown=spacedown, spaceup=spaceup, thick=thick, holes=true);
  }
}

module standoffs(spacedown=5, spaceup=15, thick=2, holes=false) {
  four_tap = .0890*inch(); // tap drill for a #4-40 screw
  four_clear = .1285*inch(); // clearance drill for a #4 screw
  c = holes ? thick/2 + .1 : 0; c2 = 2*c;
  res=25;
  // standoffs
  translate(standoff1()+[0,0,-spacedown-thick/2-c])
    cylinder(d=holes?four_clear:8, h=spacedown+thick/2+c2, $fn=res);
  translate(standoff2()+[0,0,-spacedown-thick/2-c])
    cylinder(d=holes?four_clear:10, h=spacedown+thick/2+c2, $fn=res);
  translate(standoff1()+[0,0,2-c])
    cylinder(d=holes?four_tap:5, h=1.6+spaceup-2+thick/2+c, $fn=res);
  translate(standoff2()+[0,0,2-c])
    cylinder(d=holes?four_tap:7, h=1.6+spaceup-2+thick/2+c, $fn=res);
}

module board(extra=0, clearance=0, atx=true, usb=true, rpi=true, button=true, screw=true) {
  c=clearance; c2=2*clearance;
  difference() {
    union() {
      // pcb
      pcb_board(clearance=c);
      // atx connector
      if (atx) { atx_connector(extra=extra, clearance=c); }
      // usb connector
      if (usb) { usb_connector(extra=extra, clearance=c); }
      // raspberry pi connector
      if (rpi) { rpi_connector(extra=extra, clearance=c); }
      // shutdown button
      if (button) { shutdown_button(extra=extra, clearance=c); }
      // powertail cable, etc
      if (screw) { power_out(extra=extra, clearance=c); }
    }
    if (extra==0) {
      // mounting holes
      translate(standoff1()+[0,0,-1])
        cylinder(d=.12*inch() /*#4*/, h=3, $fn=10);
      translate(standoff2()+[0,0,-1])
        cylinder(d=.12*inch() /*#4*/, h=3, $fn=10);
    }
  }
}

module pcb_board(clearance=0) {
  c=clearance; c2=2*clearance;
  color("purple")
    translate([-c,-c,-c])
      cube([3.2*inch()+c2, 1.5*inch()+c2, 1.6+c2]);
}

module atx_connector(extra=0, clearance=0, down=0) {
  c=clearance; c2=2*clearance;
  translate([.49*inch()-c, .25*inch()-extra-c, 1.6-c-down])// to mounting hole
    // from data sheet
    translate([(46.2-51.8)/2, -6.6, 0]) {
      cube([51.8+c2, 12.6+extra+c2, 10+c2+down]);
      // notch at top
      translate([(51.8+c2)/2 - (14+c2)/2, 0, down])
        cube([14+c2,12.6+extra+c2,10+c2+(2+c)]);
    }
}

module usb_connector(extra=0, clearance=0, down=0) {
  c=clearance; c2=2*clearance;
  translate([2.54*inch()-c, .25*inch()-extra-c, 1.6-c-down]) // to mounting hole
    // from data sheet
    translate([(13.14-14.3)/2,-10.3,0])
      cube([14.3+c2,14.4+extra+c2,c2+1.5+5.12+(7-5.12)/2+down]);
}

module rpi_connector(extra=0, clearance=0) {
  c=clearance; c2=2*clearance;
  translate([1.55*inch()-c, 1.3*inch()-c, 1.6-c]) // to center of PCB pins
    translate([0,0,(9.1+extra+c2)/2])
      cube([58.42+c2,8.75+c2,9.1+extra+c2], center=true);
}

module shutdown_button(extra=0, clearance=0) {
  c=clearance; c2=2*clearance;
  translate(button()+[0, 0, 1.6-c]) // to center of switch
    cylinder(d=3.5+c2, h=2+extra+c2, $fn=10);
}

module push_button(spaceup=15, thick=2, outer=false, short=false, c=0, e=0) {
  buttop=1.6 + 7;// top of button is 7mm up from board
  boxtop=1.6 + spaceup + thick;
  keeper=5; // 5mm keeper
  travel=outer ? 3 : 0; // 3mm max travel
  c2 = 2*c;
  res=10;
  translate(button()) {
    if (!short) {
      translate([0,0,buttop-e])
        cylinder(d=3.5+c2, h=boxtop-(buttop-e)-keeper-travel, $fn=res);
    }
    translate([0,0,boxtop-keeper-travel])
      cylinder(d1=3.5+c2, d2=5+c2, h=keeper/2, $fn=res);
    if (travel > 0) {
      translate([0,0,boxtop-keeper/2-travel])
        cylinder(d=5+c2, h=travel, $fn=res);
    }
    translate([0,0,boxtop-keeper/2])
      cylinder(d1=5+c2, d2=3.5+c2, h=keeper/2 + e, $fn=res);
  }
}

module power_out(extra=0, clearance=0) {
  // power tail
  translate([0.15*inch(), 0.35*inch(), 1.6])
    screw_terminal(extra=extra,clearance=clearance);
  // +12V (1)
  translate([0.15*inch(), 0.7437*inch(), 1.6])
    screw_terminal(extra=extra,clearance=clearance);
  // +12V (2)
  translate([0.15*inch(), 1.1374*inch(), 1.6])
    screw_terminal(extra=extra,clearance=clearance);
  // +3.3V
  translate([3.05*inch(), 1.0937*inch(), 1.6])
    rotate([0,0,180])
    screw_terminal(extra=extra,clearance=clearance);
  // +5V
  translate([3.05*inch(), 0.7*inch(), 1.6])
    rotate([0,0,180])
    screw_terminal(extra=extra,clearance=clearance);
}

module screw_terminal(extra=0,clearance=0) {
  c=clearance; c2=2*clearance;
  front=7.5-4.2;
  translate([-front-extra-c,-(5+3.1)-c,-c])
    cube([7.5+extra+c2,3.1+5+3.1+c2,10+c2]);
}

module bananas(h=10, spacexy=2, thick=2, hole=true) {
  cl=.008*inch(); res=40;
  translate([32,1.5*inch()+spacexy+thick,18]) rotate([-90,0,0])
  // two rows of three, on standard .75 in spacing
  for (x=[-1,0,1]) {
    for (y=[-.5,.5]) {
      translate([x*.75*inch(), y*.75*inch(), 0]) {
        intersection() {
          cylinder(d=.298*inch() + cl, h=h, center=true, $fn=res);
          cube([.265*inch() + cl, .4*inch() + cl, h + 1], center=true);
        }
      }
    }
  }
}

module rocker(h=10, spacexy=2, thick=2, hole=false) {
  cl=.008*inch(); res=40;
  translate([2.8*inch()+1,1.5*inch()+spacexy+thick,18]) rotate([-90,-90,0])
  if (hole) {
    cylinder(d=20.2+cl, h=h, center=true, $fn=res);
    translate([-.079*inch()/2,0,-h/2])
      cube([.079*inch()+cl, ((.822-.778) + .778/2)*inch() + cl, h]);
  } else {
    cylinder(d=.901*inch(), h=.18*inch(), $fn=res);
    translate([0,0,-.185*inch()])
      cylinder(d=.779*inch(), h=.19*inch(), $fn=res);
    translate([0,0,-.3*inch()])
      cube([.661*inch(), .469*inch(), .6*inch()], center=true);
  }
}

module power_box(spaceup=33) {
  thick=2;
  difference() {
    rpi_box(thick=thick, spaceup=spaceup, atx=true, usb=false, rpi=false, button=false, screw=false);
    rocker(hole=true);
    bananas();
  }
  // reinforcement
  difference() {
    union() {
      translate(standoff1()+[-8,-3,16.6]) cube([10,9.5,19.5]);
      translate(standoff2()+[-2.5,-19,16.6]) cube([19.5,21.4,19.5]);
    }
    standoffs(spaceup=spaceup, holes=true);
    translate(standoff2()+[7,-9,16]) #cylinder(d=15, h=19);
  }
}

module power_box_top() {
  difference() {
    power_box();
    splitter2();
  }
}

module power_box_bottom() {
  intersection() {
    power_box();
    splitter2();
  }
}

module splitter2(spacexy=2, spaceup=33, thick=2) {
  large=50; e=.02;
  difference() {
    translate([-spacexy-thick-1,0,0])
      scale([1,1,-1])
      rotate([0,90,0])
      linear_extrude(height=3.2*inch()+2*spacexy+2*thick+2)
      // x coordinate is z here.
      polygon(points=[[-large,-large],[1,-large],[1,-spacexy],[1.6+spaceup,1.5*inch()+spacexy-0.1],[1.6+spaceup,large],[-large,large]]);
    translate([-spacexy+e,-spacexy+e,1])
      cube([3.2*inch()+2*spacexy -2*e, 1.5*inch()+2*spacexy -2*e, 1.6 + spaceup - 1 + e]);
  }
}
