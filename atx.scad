/* Enclosures for ATX board projects */
// dimensions relative to eagle, so origin is
// lower-left corner of PCB.

/* [Global] */
// This design is composed of a number of separate printable parts:
part = "assembly"; // [top:Box Top,bottom:Box Bottom,assembly:All Parts Assembled]

/* [Hidden] */

function inch() = 25.4;
function standoff1() = [.175*inch(), 1.375*inch(), 0];
function standoff2() = [2.65*inch(), .625*inch(), 0];
function button() = [2.65*inch(), 0.95*inch(), 0];


if (part=="assembly") {
  main();
} else {
  main(part);
}

module main(part="all") {
  if (part=="bottom" || part=="all") {
    box_bottom();
  }
  if (part=="top" || part=="all") {
    box_top();
  }
  if (part=="pcb" || part=="all") {
    board();
  }
}

module box_top(spaceup=20) {
  intersection() {
    box(spaceup=spaceup);
    splitter();
  }
  push_button(spaceup=spaceup);
  difference() {
    push_button(outer=true, c=2, short=true, spaceup=spaceup);
    push_button(outer=true, c=0.5, e=.1, spaceup=spaceup);
    rpi_connector(extra=spaceup+10, clearance=1.5);
  }
}

module box_bottom() {
  difference() {
    box();
    splitter();
  }
}

module splitter() {
  translate([-100,-100,1])
    cube([200,200,200]);
}

module box(thick=2, spaceup=15 /* should be >10 */) {
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
        board(extra=30, clearance=1.5);
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

module board(extra=0, clearance=0) {
  c=clearance; c2=2*clearance;
  difference() {
    union() {
      // pcb
      pcb_board(clearance=c);
      // atx connector
      atx_connector(extra=extra, clearance=c);
      // usb connector
      usb_connector(extra=extra, clearance=c);
      // raspberry pi connector
      rpi_connector(extra=extra, clearance=c);
      // shutdown button
      shutdown_button(extra=extra, clearance=c);
      // powertail cable, etc
      power_out(extra=extra, clearance=c);
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

module atx_connector(extra=0, clearance=0) {
  c=clearance; c2=2*clearance;
  translate([.49*inch()-c, .25*inch()-extra-c, 1.6-c])// to mounting hole
    // from data sheet
    translate([(46.2-51.8)/2, -6.6, 0])
      cube([51.8+c2, 12.6+extra+c2, 10+c2]);
}

module usb_connector(extra=0, clearance=0) {
  c=clearance; c2=2*clearance;
  translate([2.54*inch()-c, .25*inch()-extra-c, 1.6-c]) // to mounting hole
    // from data sheet
    translate([(13.14-14.3)/2,-10.3,0])
      cube([14.3+c2,14.4+extra+c2,c2+1.5+5.12+(7-5.12)/2]);
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
