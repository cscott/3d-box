/* [Global] */
part = "rpi-all"; // [box1-tshell,box1-bshell,box1-fpanel,box1-bpanel,box2-tshell,box2-bshell,box2-fpanel,box2-bpanel,mbox-tshell,mbox-bshell,mbox-fpanel,mbox-bpanel,rpi-tshell,rpi-bshell,rpi-fpanel,rpi-bpanel]
/* [Hidden] */
use <./box.scad>
use <./atx.scad>
use <common/strutil.scad>
use <common/extrude.scad> /* for rotate_mat */

piece(part);

module piece(part) {
  p = split(part, "-");
  if (p[0]=="box1") ex_box1(part=p[1]); // Extrudrboard thunk box
  if (p[0]=="box2") ex_box2(part=p[1]); // Extrudrboard x2 box
  if (p[0]=="mbox") mosfet_box(part=p[1]); // Mosfet heat controller box
  if (p[0]=="rpi") rpi_box(part=p[1]); // Raspberry pi expansion board box
}

// open side is y
module ex_box1(part="all") {
  box(part=part, pcbsize=[46,44,22], outset=[2,4,0.5],
      foot_inset=[0,0], foot_diam=3, foot_hole_diam=0,
      foot_height=2.5);
}

module ex_box2(part="all") {
  onepcb = [61,40];
  outset = 2;
  pcbsize = [onepcb.x,2*onepcb.y+outset,31];
  foot_inset = [(onepcb.x-53)/2, (onepcb.y-32)/2];
  box(part=part, pcbsize=pcbsize,
      outset=[outset,outset,0.5], foot_height=2.5,
      foot_inset=foot_inset,
      foot_pos = [
        [foot_inset.x     , foot_inset.y + 32],
        [foot_inset.x + 53, foot_inset.y + 32],
        [foot_inset.x     , pcbsize.y - foot_inset.y - 32],
        [foot_inset.x + 53, pcbsize.y - foot_inset.y - 32]
      ],
      foot_height=4 /* M3x8 screws */,
      foot_hole_diam=2.5 /* 2.5mm for M3 tap drill + 0.5 hole expansion*/,
      foot_diam=5.6);
}

module mosfet_box(part="all") {
  box(part=part,
      pcbsize=[88,67,32],
      vent_width=2,
      foot_inset=[(88-80)/2, (67-59)/2],
      foot_height=4 /* M3x8 screws */,
      foot_hole_diam=2.5 /* 2.5mm for M3 tap drill + 0.5 hole expansion*/,
      foot_diam=8);
}

module rpi_box(part="all", ghost_pcb=true) {
  pcbsize=[39,126,25];
  wall = 2;
  foot_height = 4;
  outset = [2,2,0.5];
  clearance = 1;
  pcb_shift = 17;
  atx_shift = [3*wall + outset.x + clearance,
               3.2*inch() + wall + outset.y + pcb_shift,
               wall + foot_height + outset.z];
  atx_xform = trans_mat([0,3.2*inch() + pcb_shift,0]) * rotate_matz(-90);
  if (part=="all") {
    rpi_box("bshell", ghost_pcb=false); rpi_box("tshell", ghost_pcb=false);
    rpi_box("fpanel", ghost_pcb=false); rpi_box("bpanel", ghost_pcb=false);
    rpi_box("pcb", ghost_pcb=false);
  } else if (part=="pcb") {
    translate(atx_shift)
      rotate([0,0,-90])
        board();
  } else difference() {
    box(part=part,
        pcbsize=pcbsize, wall = wall, outset = outset, clearance = clearance,
        foot_pos = [(affine2(atx_xform, standoff1())),
                    (affine2(atx_xform, standoff2()))],
        foot_height=foot_height, /* M3x8 screws */,
        foot_hole_diam=2.5 /* 2.5mm for M3 tap drill + 0.5 hole expansion*/,
        foot_diamx = .12*inch());
    translate(atx_shift) rotate([0,0,-90]) {
      if (part=="bpanel" || part=="fpanel") {
        atx_connector(extra=30,down=10,clearance=1.5);
        usb_connector(extra=30,down=10,clearance=1.5);
        translate([0,0,31 + atx_shift.z + pcbsize.z - wall])
          rotate([-90,0,0]) rpi_connector(extra=60,clearance=1.5);
      }
      if (part=="tshell") {
        shutdown_button(extra=40, clearance=1);
      }
    }
  }
  // show pcb
  if (part!="all" && ghost_pcb) %rpi_box("pcb", ghost_pcb=false);
}
