/* [Global] */
part = "box1-bshell"; // [box1-tshell,box1-bshell,box1-fpanel,box1-bpanel,box2-tshell,box2-bshell,box2-fpanel,box2-bpanel]
/* [Hidden] */
use <./box.scad>
use <common/strutil.scad>

piece(part);

module piece(part) {
  p = split(part, "-");
  if (p[0]=="box1") ex_box1(part=p[1]); // Extrudrboard thunk box
  if (p[0]=="box2") ex_box2(part=p[1]); // Extrudrboard x2 box
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
