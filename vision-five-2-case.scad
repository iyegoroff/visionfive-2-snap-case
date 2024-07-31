// clang-format off
include <lib.scad>;
// clang-format on

/* [Preview] */
show_front_lid = true;
show_back_lid = true;
show_board = true;

/* [Printing] */
top_face_supports = false;
bottom_face_supports = false;
support_thickness = 0.2;

/* [Board customization] */
emmc_storage_present = true;
ice_tower_fan_present = false;
m2_ssd_storage_width = 76.1;
m2_ssd_storage_length = 27.1;
m2_ssd_storage_height_ = -0.1;
m2_ssd_storage_height = max(0, m2_ssd_storage_height_);

/* [Gaps between board and case] */
left_case_gap = 0.5;
right_case_gap = 0.5;
front_case_gap = 0.5;
back_case_gap = 0.5;
bottom_case_gap = 5.7;
top_case_gap = 17.9;

/* [Case wall thickness] */
left_wall_thickness = 1.9;
right_wall_thickness = 1.9;
front_wall_thickness = 1.9;
back_wall_thickness = 1.9;
bottom_wall_thickness = 1.9;
top_wall_thickness = 1.9;

/* [Flatten case faces] */
flatten_left_face = false;
flatten_right_face = false;
flatten_front_face = false;
flatten_back_face = false;
flatten_bottom_face = false;
flatten_top_face = false;

/* [Snap levers] */
snap_knob_prop_enabled = false;
snap_knob_lug_enabled = true;
snap_knob_shape = "circle"; // [circle, teardrop, hexagon]
hide_left_snap_knob = false;
hide_right_snap_knob = false;

/* [Misc case parameters] */
case_fillet_radius = 1.5;
case_stands_height_ = -0.1;
case_stands_height = max(0, case_stands_height_);
board_clearance = 0.3;
lid_clearance = 0.15;
expand_back_lid_top = false;
expand_back_lid_bottom = false;
top_slot_shape = "rounded";    // [rect, rounded, none]
bottom_slot_shape = "rounded"; // [rect, rounded, none]

/* [Access slots] */
pin_header_back_slot_height_fraction = 0.9;
pin_header_top_slot_enabled = true;
reset_button_accessible = true;
reset_button_lever_enabled = true;
leds_visible_from_back_face = true;
usb_c_port_accessible = true;
audio_port_accessible = true;
left_usb_port_accessible = true;
right_usb_port_accessible = true;
hdmi_port_accessible = true;
left_ethernet_port_accessible = true;
right_ethernet_port_accessible = true;
two_lane_mipi_dsi_port_accessible = true;
four_lane_mipi_dsi_port_accessible = true;
mipi_csi_port_accessible = true;
tf_card_accessible = true;
m2_ssd_storage_bolt_shaft_accessible = true;

module customizer_limit() {}

// Board dimensions

board_size = [ 100.3, 74.2, 1.6 ];
board_pos = [ 0, 0, 0 ];
board_rear_pos = board_pos + board_size;

// Case dimensions

left_case_offset = left_case_gap + left_wall_thickness;
right_case_offset = right_case_gap + right_wall_thickness;
top_case_offset = top_case_gap + top_wall_thickness;
bottom_case_offset = bottom_case_gap + bottom_wall_thickness;
front_case_offset = front_case_gap + front_wall_thickness;
back_case_offset = back_case_gap + back_wall_thickness;

case_pos = board_pos - [ left_case_offset, front_case_offset, bottom_case_offset ];
case_size = board_size + [
  left_case_offset + right_case_offset, front_case_offset + back_case_offset,
  bottom_case_offset +
  top_case_offset
];
case_rear_pos = case_pos + case_size;

case_hollow_pos = board_pos - [ left_case_gap, front_case_gap, bottom_case_gap ];
case_hollow_size = board_size + [
  left_case_gap + right_case_gap, front_case_gap + back_case_gap, bottom_case_gap +
  top_case_gap
];
case_hollow_rear_pos = case_hollow_pos + case_hollow_size;

button_slot_gap = board_clearance * 3;

// Board plate

module board_plate(offset = [ 0, 0, 0 ]) {
  square_size = [ board_size.x + offset.x * 2, board_size.y + offset.y * 2 ];
  board_rounding = 1.5;

  color("black") translate(board_pos - offset)
    linear_extrude(board_size.z + offset.z * 2) offset(board_rounding)
      offset(-board_rounding) square(square_size);
}

// Pin header

pin_header_size = [ 50.6, 5.1, 9.5 ];
pin_header_pos = board_pos + [ 7.3, 68.1, board_size.z ];
pin_header_rear_pos = pin_header_pos + pin_header_size;

module pin_header(slot_gap) {
  color("navajowhite") translate(pin_header_pos) offset_cube(pin_header_size, slot_gap);
}

module pin_header_back_access() {
  pin_header_slot_top = case_hollow_rear_pos.z - (pin_header_pos.x - board_pos.x);
  pin_header_slot_height = (pin_header_slot_top - board_rear_pos.z) *
                           min(1, pin_header_back_slot_height_fraction);

  pin_header_slot_size =
    [ pin_header_size.x, case_rear_pos.y - pin_header_pos.y, pin_header_slot_height ];

  pin_header_slot_pos = [
    pin_header_pos.x, pin_header_pos.y, pin_header_slot_top - pin_header_slot_height
  ];

  translate(pin_header_slot_pos) offset_cube(pin_header_slot_size, board_clearance);

  pin_header_shaft_size =
    [ pin_header_size.x, pin_header_size.y, pin_header_slot_top - pin_header_pos.z ];

  translate(pin_header_pos) offset_cube(pin_header_shaft_size, board_clearance);
}

module pin_header_top_access() {
  pin_header_slot_size =
    [ pin_header_size.x, pin_header_size.y, case_rear_pos.z - pin_header_rear_pos.z ];
  pin_header_slot_pos = [ pin_header_pos.x, pin_header_pos.y, pin_header_rear_pos.z ];

  translate(pin_header_slot_pos) offset_cube(pin_header_slot_size, board_clearance);
}

// Reset button

reset_button_size = [ 4.5, 2.8, 3.3 ];
reset_button_pos = board_pos + [ 67.1, 70.8, board_size.z ];
reset_button_rear_pos = reset_button_pos + reset_button_size;
reset_button_knob_center =
  reset_button_pos +
  [ reset_button_size.x / 2, reset_button_size.y, reset_button_size.z / 2 ];
reset_button_knob_length = 0.7;
reset_button_knob_radius = 1;
reset_button_knob_rotation = [-90];

module reset_button(slot_gap) {
  color("silver") translate(reset_button_pos) offset_cube(reset_button_size, slot_gap);

  color("white") translate(reset_button_knob_center) rotate(reset_button_knob_rotation)
    offset_cylinder(h = reset_button_knob_length, r = reset_button_knob_radius,
                    offset = slot_gap);
}

module reset_button_access() {
  reset_button_knob_slot_length = back_case_offset + button_slot_gap;

  translate(reset_button_knob_center) rotate(reset_button_knob_rotation)
    offset_cylinder(h = reset_button_knob_slot_length, r = reset_button_knob_radius,
                    offset = button_slot_gap);
}

// USB-C port

usb_c_port_size = [ 9, 7.4, 3.3 ];
usb_c_port_pos = board_pos + [ 82.2, 68.2, board_size.z ];
usb_c_port_rear_pos = usb_c_port_pos + usb_c_port_size;

module usb_c_port(slot_gap) {
  color("silver") translate(usb_c_port_pos) offset_cube(usb_c_port_size, slot_gap);
}

module usb_c_port_access() {
  usb_c_port_slot_size =
    usb_c_port_size + [ 0, max(0, case_rear_pos.y - usb_c_port_rear_pos.y), 0 ];

  usb_c_connector_slot_y = usb_c_port_rear_pos.y + 1.5;

  usb_c_connector_slot_size =
    [ 12, max(0, case_rear_pos.y - usb_c_connector_slot_y), 5.5 ];

  usb_c_connector_slot_pos = [
    usb_c_port_pos.x - (usb_c_connector_slot_size.x - usb_c_port_size.x) / 2,
    usb_c_connector_slot_y,
    usb_c_port_pos.z - (usb_c_connector_slot_size.z - usb_c_port_size.z) / 2
  ];

  translate(usb_c_port_pos) offset_cube(usb_c_port_slot_size, board_clearance);

  translate(usb_c_connector_slot_pos)
    offset_cube(usb_c_connector_slot_size, board_clearance);
}

// Leds

leds_size = [ 7.4, 0.9, 0.9 ];
leds_pos = board_pos + [ 73.5, 71.9, board_size.z ];
leds_rear_pos = leds_pos + leds_size;

module leds(slot_gap) {
  color("white") translate(leds_pos) offset_cube(leds_size, slot_gap);
}

module leds_back_face_access() {
  leds_slot_size = [ leds_size.x + 5, case_rear_pos.y - leds_pos.y, usb_c_port_size.z ];

  translate(leds_pos) offset_cube(leds_slot_size, board_clearance);
}

// Audio port

audio_port_size = [ 7, 12.5, 6 ];
audio_port_pos = board_pos + [ 1.9, -0.9, board_size.z ];
audio_port_rear_pos = audio_port_pos + audio_port_size;
audio_port_head_center =
  audio_port_pos + [ audio_port_size.x / 2, 0, audio_port_size.z / 2 ];
audio_port_head_length = 2.5;
audio_port_head_radius = 3;
audio_port_head_rotation = [90];

module audio_port(slot_gap) {
  color("silver") translate(audio_port_pos) offset_cube(audio_port_size, slot_gap);
  color("black") translate(audio_port_head_center) rotate(audio_port_head_rotation)
    offset_cylinder(h = audio_port_head_length, r = audio_port_head_radius,
                    offset = slot_gap);
}

module audio_port_access() {
  audio_port_connector_center =
    audio_port_head_center + [ 0, -audio_port_head_length - 2.5, 0 ];

  audio_port_connector_radius = 4;

  translate(audio_port_head_center) rotate(audio_port_head_rotation)
    offset_cylinder(h = max(0, audio_port_head_center.y - case_pos.y),
                    r = audio_port_head_radius, offset = board_clearance);

  translate(audio_port_connector_center) rotate(audio_port_head_rotation)
    offset_cylinder(h = max(0, audio_port_connector_center.y - case_pos.y),
                    r = audio_port_connector_radius, offset = board_clearance);
}

// USB port

usb_port_size = [ 14.8, 17.7, 15.8 ];

module usb_port(usb_port_size, usb_port_pos, usb_port_rear_pos, slot_gap) {
  usb_port_base_size = [
    usb_port_size.x, usb_port_rear_pos.y - board_pos.y,
    usb_port_pos.z - board_rear_pos.z
  ];

  usb_port_base_pos = [ usb_port_pos.x, board_pos.y, board_rear_pos.z ];

  color("silver") {
    translate(usb_port_pos) offset_cube(usb_port_size, slot_gap);
    translate(usb_port_base_pos) offset_cube(usb_port_base_size, slot_gap);
  }
}

module usb_port_access(usb_port_size, usb_port_pos) {
  usb_port_slot_pos = [ usb_port_pos.x, case_pos.y, usb_port_pos.z ];

  usb_port_slot_size =
    [ usb_port_size.x, max(0, usb_port_pos.y - case_pos.y), usb_port_size.z ];

  usb_connector_slot_y = usb_port_pos.y - 3;

  usb_connector_slot_size = [ 18.2, max(0, usb_connector_slot_y - case_pos.y), 16.6 ];

  usb_connector_slot_pos = [
    usb_port_pos.x - (usb_connector_slot_size.x - usb_port_size.x) / 2, case_pos.y,
    usb_port_pos.z - (usb_connector_slot_size.z - usb_port_size.z) / 2
  ];

  translate(usb_port_slot_pos) offset_cube(usb_port_slot_size, board_clearance);
  translate(usb_connector_slot_pos)
    offset_cube(usb_connector_slot_size, board_clearance);
}

// Left USB

left_usb_port_size = usb_port_size;
left_usb_port_pos = board_pos + [ 12.3, -3.4, 0.4 + board_size.z ];
left_usb_port_rear_pos = left_usb_port_pos + left_usb_port_size;

module left_usb_port(slot_gap) {
  usb_port(usb_port_size = left_usb_port_size, usb_port_pos = left_usb_port_pos,
           usb_port_rear_pos = left_usb_port_rear_pos, slot_gap = slot_gap);
}

module left_usb_port_access() {
  usb_port_access(usb_port_size = left_usb_port_size, usb_port_pos = left_usb_port_pos);
}

// Right USB

right_usb_port_size = usb_port_size;
right_usb_port_pos = board_pos + [ 31.6, -3.4, 0.4 + board_size.z ];
right_usb_port_rear_pos = right_usb_port_pos + right_usb_port_size;

module right_usb_port(slot_gap) {
  usb_port(usb_port_size = right_usb_port_size, usb_port_pos = right_usb_port_pos,
           usb_port_rear_pos = right_usb_port_rear_pos, slot_gap = slot_gap);
}

module right_usb_port_access() {
  usb_port_access(usb_port_size = right_usb_port_size,
                  usb_port_pos = right_usb_port_pos);
}

// HDMI port

hdmi_port_size = [ 5.4, 23, 14.8 ];
hdmi_port_pos = board_pos + [ 52.6, -3.4, 3.1 + board_pos.z ];
hdmi_port_rear_pos = hdmi_port_pos + hdmi_port_size;

module hdmi_port(slot_gap) {
  hdmi_port_base_size = [
    hdmi_port_size.x, hdmi_port_rear_pos.y - board_pos.y,
    hdmi_port_pos.z - board_rear_pos.z
  ];

  hdmi_port_base_pos = [ hdmi_port_pos.x, board_pos.y, board_rear_pos.z ];

  color("silver") {
    translate(hdmi_port_pos) offset_cube(hdmi_port_size, slot_gap);
    translate(hdmi_port_base_pos) offset_cube(hdmi_port_base_size, slot_gap);
  }
}

module hdmi_port_access() {
  hdmi_port_slot_pos = [ hdmi_port_pos.x, case_pos.y, hdmi_port_pos.z ];

  hdmi_port_slot_size =
    [ hdmi_port_size.x, max(0, hdmi_port_pos.y - case_pos.y), hdmi_port_size.z ];

  hdmi_connector_slot_y = hdmi_port_pos.y - 2.5;

  hdmi_connector_slot_size = [ 11, max(0, hdmi_connector_slot_y - case_pos.y), 19.5 ];

  hdmi_connector_slot_pos = [
    hdmi_port_pos.x - (hdmi_connector_slot_size.x - hdmi_port_size.x) / 2, case_pos.y,
    hdmi_port_pos.z - (hdmi_connector_slot_size.z - hdmi_port_size.z) / 2
  ];

  translate(hdmi_port_slot_pos) offset_cube(hdmi_port_slot_size, board_clearance);
  translate(hdmi_connector_slot_pos)
    offset_cube(hdmi_connector_slot_size, board_clearance);
}

// Ethernet port

ethernet_port_size = [ 16.1, 21.3, 13.7 ];

module ethernet_port_access(ethernet_port_size, ethernet_port_pos) {
  ethernet_port_slot_size = [
    ethernet_port_size.x, max(0, ethernet_port_pos.y - case_pos.y), ethernet_port_size.z
  ];

  ethernet_port_slot_pos = [ ethernet_port_pos.x, case_pos.y, ethernet_port_pos.z ];

  translate(ethernet_port_slot_pos)
    offset_cube(ethernet_port_slot_size, board_clearance);
}

// Left Ethernet port

left_ethernet_port_size = ethernet_port_size;
left_ethernet_port_pos = board_pos + [ 62.8, -3.3, board_size.z ];
left_ethernet_port_rear_pos = left_ethernet_port_pos + left_ethernet_port_size;

module left_ethernet_port(slot_gap) {
  color("silver") translate(left_ethernet_port_pos)
    offset_cube(left_ethernet_port_size, slot_gap);
}

module left_ethernet_port_access() {
  ethernet_port_access(ethernet_port_size = left_ethernet_port_size,
                       ethernet_port_pos = left_ethernet_port_pos);
}

// Right Ethernet port

right_ethernet_port_size = ethernet_port_size;
right_ethernet_port_pos = board_pos + [ 82.5, -3.3, board_size.z ];
right_ethernet_port_rear_pos = right_ethernet_port_pos + right_ethernet_port_size;

module right_ethernet_port(slot_gap) {
  color("silver") translate(right_ethernet_port_pos)
    offset_cube(right_ethernet_port_size, slot_gap);
}

module right_ethernet_port_access() {
  ethernet_port_access(ethernet_port_size = right_ethernet_port_size,
                       ethernet_port_pos = right_ethernet_port_pos);
}

// 4-lane MIPI DSI port

four_lane_mipi_dsi_port_size = [ 3.3, 13.3, 0.9 ];
four_lane_mipi_dsi_port_pos = board_pos + [ 1.9, 27.5, board_size.z ];
four_lane_mipi_dsi_port_rear_pos =
  four_lane_mipi_dsi_port_pos + four_lane_mipi_dsi_port_size;

module four_lane_mipi_dsi_port(slot_gap) {
  color("gray") translate(four_lane_mipi_dsi_port_pos)
    offset_cube(four_lane_mipi_dsi_port_size, slot_gap);
}

module four_lane_mipi_dsi_port_access() {
  four_lane_mipi_dsi_port_slot_size = [
    four_lane_mipi_dsi_port_pos.x - case_pos.x, four_lane_mipi_dsi_port_size.y,
    four_lane_mipi_dsi_port_size.z
  ];

  four_lane_mipi_dsi_port_slot_pos =
    [ case_pos.x, four_lane_mipi_dsi_port_pos.y, four_lane_mipi_dsi_port_pos.z ];

  radius = four_lane_mipi_dsi_port_size.z / 2;

  hull() {
    translate([
      case_pos.x, four_lane_mipi_dsi_port_pos.y, four_lane_mipi_dsi_port_pos.z + radius
    ]) rotate([ 0, 90 ]) offset_cylinder(h = left_wall_thickness, r = radius,
                                         offset = board_clearance, $fn = 4);

    translate([
      case_pos.x, four_lane_mipi_dsi_port_pos.y + four_lane_mipi_dsi_port_size.y,
      four_lane_mipi_dsi_port_pos.z +
      radius
    ]) rotate([ 0, 90 ]) offset_cylinder(h = left_wall_thickness, r = radius,
                                         offset = board_clearance, $fn = 4);
  }
}

// 2-lane MIPI DSI port

two_lane_mipi_dsi_port_size = [ 2.5, 22, 5.4 ];
two_lane_mipi_dsi_port_pos = board_pos + [ 3, 44, board_size.z ];
two_lane_mipi_dsi_port_rear_pos =
  two_lane_mipi_dsi_port_pos + two_lane_mipi_dsi_port_size;

module two_lane_mipi_dsi_port(slot_gap) {
  color("wheat") translate(two_lane_mipi_dsi_port_pos)
    offset_cube(two_lane_mipi_dsi_port_size, slot_gap);
}

module two_lane_mipi_dsi_port_access() {
  length_fix = 2.5;

  two_lane_mipi_dsi_port_slot_size = [
    two_lane_mipi_dsi_port_size.x / 3, two_lane_mipi_dsi_port_size.y - length_fix * 2,
    case_rear_pos.z - two_lane_mipi_dsi_port_rear_pos.z
  ];

  two_lane_mipi_dsi_port_slot_pos = [
    two_lane_mipi_dsi_port_pos.x, two_lane_mipi_dsi_port_pos.y + length_fix,
    two_lane_mipi_dsi_port_rear_pos.z
  ];

  radius = two_lane_mipi_dsi_port_slot_size.x / 2;
  size_fix = case_fillet_radius / 3;

  hull() {
    translate([
      two_lane_mipi_dsi_port_slot_pos.x + radius, two_lane_mipi_dsi_port_slot_pos.y,
      case_hollow_rear_pos.z -
      size_fix
    ]) offset_cylinder(h = top_wall_thickness + size_fix, r = radius,
                       offset = board_clearance, $fn = 4);

    translate([
      two_lane_mipi_dsi_port_slot_pos.x + radius,
      two_lane_mipi_dsi_port_slot_pos.y + two_lane_mipi_dsi_port_slot_size.y,
      case_hollow_rear_pos.z -
      size_fix
    ]) offset_cylinder(h = top_wall_thickness + size_fix, r = radius,
                       offset = board_clearance, $fn = 4);
  }
}

// MIPI CSI port

mipi_csi_port_size = [ 2.5, 22, 5.4 ];
mipi_csi_port_pos = board_pos + [ 95, 44, board_size.z ];
mipi_csi_port_rear_pos = mipi_csi_port_pos + mipi_csi_port_size;

module mipi_csi_port(slot_gap) {
  color("wheat") translate(mipi_csi_port_pos) offset_cube(mipi_csi_port_size, slot_gap);
}

module mipi_csi_port_access() {
  length_fix = 2.5;

  mipi_csi_port_slot_size = [
    mipi_csi_port_size.x / 3, mipi_csi_port_size.y - length_fix * 2,
    case_rear_pos.z - mipi_csi_port_rear_pos.z
  ];

  mipi_csi_port_slot_pos = [
    mipi_csi_port_pos.x + mipi_csi_port_size.x / 3 * 2,
    mipi_csi_port_pos.y + length_fix, mipi_csi_port_rear_pos.z
  ];

  radius = mipi_csi_port_slot_size.x / 2;
  size_fix = case_fillet_radius / 3;

  hull() {
    translate([
      mipi_csi_port_slot_pos.x + radius, mipi_csi_port_slot_pos.y,
      case_hollow_rear_pos.z -
      size_fix
    ]) offset_cylinder(h = top_wall_thickness + size_fix, r = radius,
                       offset = board_clearance, $fn = 4);

    translate([
      mipi_csi_port_slot_pos.x + radius,
      mipi_csi_port_slot_pos.y + mipi_csi_port_slot_size.y, case_hollow_rear_pos.z -
      size_fix
    ]) offset_cylinder(h = top_wall_thickness + size_fix, r = radius,
                       offset = board_clearance, $fn = 4);
  }
}

// Fan pin header

fan_pin_header_size = [ 5.3, 7.9, 8.4 ];
fan_pin_header_pos = board_pos + [ 94.6, 32.1, board_size.z ];
fan_pin_header_rear_pos = fan_pin_header_pos + fan_pin_header_size;

module fan_pin_header(slot_gap) {
  color("wheat") translate(fan_pin_header_pos)
    offset_cube(fan_pin_header_size, slot_gap);
}

// Ice tower fan

ice_tower_fan_size = [ 63, 43, 26 ];
ice_tower_fan_pos = board_pos + [ 9, 19, board_size.z ];
ice_tower_fan_rear_pos = ice_tower_fan_pos + ice_tower_fan_size;

ice_tower_fan_top_size = [ 45, 43, 2.5 ];
ice_tower_fan_top_pos = board_pos + [ 21, 19, 26 + board_size.z ];
ice_tower_fan_top_rear_pos = ice_tower_fan_top_pos + ice_tower_fan_top_size;

ice_tower_fan_slot_rounding = 4;

module ice_tower_fan(slot_gap) {
  translate(ice_tower_fan_pos) linear_extrude(ice_tower_fan_size.z + slot_gap)
    offset(ice_tower_fan_slot_rounding) offset(-ice_tower_fan_slot_rounding)
      square([ ice_tower_fan_size.x + slot_gap, ice_tower_fan_size.y + slot_gap ]);

  color("silver") translate(ice_tower_fan_top_pos)
    offset_cube(ice_tower_fan_top_size, slot_gap);
}

module ice_tower_fan_access() {
  slot_size = [
    ice_tower_fan_top_size.x, ice_tower_fan_top_size.y,
    case_rear_pos.z - ice_tower_fan_top_pos.z
  ];

  translate(ice_tower_fan_top_pos) offset_cube(slot_size, board_clearance);
}

// TF card

tf_card_slot_size = [ 14.6, 15, 2 ];
tf_card_slot_pos = board_pos + [ 0, 46.3, -tf_card_slot_size.z ];
tf_card_slot_rear_pos = tf_card_slot_pos + tf_card_slot_size;

tf_card_size = [ 2.6, 11.1, 1 ];
tf_card_pos = board_pos + [ -tf_card_size.x, 47.2, -2 ];
tf_card_rear_pos = tf_card_pos + tf_card_size;

module tf_card(slot_gap) {
  color("silver") translate(tf_card_slot_pos) offset_cube(tf_card_slot_size, slot_gap);
  translate(tf_card_pos) offset_cube(tf_card_size, slot_gap);
}

module tf_card_access() {
  tf_card_access_slot_size =
    [ tf_card_slot_pos.x - case_pos.x, tf_card_size.y, tf_card_size.z ];

  tf_card_access_slot_pos = [ case_pos.x, tf_card_pos.y, tf_card_pos.z ];

  radius = tf_card_access_slot_size.z / 2 + board_clearance / 2;

  hull() {
    translate([
      case_pos.x, tf_card_access_slot_pos.y,
      tf_card_access_slot_pos.z + radius - board_clearance / 2
    ]) rotate([ 0, 90 ]) offset_cylinder(h = left_wall_thickness * 2, r = radius,
                                         offset = board_clearance, $fn = 4);

    translate([
      case_pos.x, tf_card_access_slot_pos.y + tf_card_access_slot_size.y,
      tf_card_access_slot_pos.z + radius - board_clearance / 2
    ]) rotate([ 0, 90 ]) offset_cylinder(h = left_wall_thickness * 2, r = radius,
                                         offset = board_clearance, $fn = 4);
  }

  finger_gap = tf_card_access_slot_size.y * 0.75;

  translate(tf_card_access_slot_pos +
            [ 0, tf_card_access_slot_size.y, tf_card_access_slot_size.z ] / 2)
    resize([
      (case_hollow_pos.x - case_pos.x) * 1.7 - board_clearance, finger_gap,
      finger_gap
    ]) sphere(d = finger_gap);
}

// eMMC storage

emmc_storage_size = [ 18.7, 13.1, 2.9 ];
emmc_storage_pos = board_pos + [ 63, 47.2, -emmc_storage_size.z ];
emmc_storage_rear_pos = emmc_storage_pos + emmc_storage_size;

module emmc_storage(slot_gap) {
  translate(emmc_storage_pos) offset_cube(emmc_storage_size, slot_gap);
}

// M.2 SSD storage

m2_ssd_storage_slot_size = [ 7, 21.9, 5.6 ];
m2_ssd_storage_slot_pos = board_pos + [ 88.3, 23.4, -m2_ssd_storage_slot_size.z ];
m2_ssd_storage_slot_rear_pos = m2_ssd_storage_slot_pos + m2_ssd_storage_slot_size;

m2_ssd_storage_size =
  [ m2_ssd_storage_width, m2_ssd_storage_length, m2_ssd_storage_height ];
m2_ssd_storage_pos = board_pos + [ 12.3, 20.9, -m2_ssd_storage_size.z ];
m2_ssd_storage_rear_pos = m2_ssd_storage_pos + m2_ssd_storage_size;

m2_ssd_storage_bolt_shaft_radius = 2;
m2_ssd_storage_bolt_shaft_height = 4;
m2_ssd_storage_bolt_shaft_pos =
  board_pos + [ 11, 34.3, -m2_ssd_storage_bolt_shaft_height ];
m2_ssd_storage_bolt_shaft_rear_pos =
  m2_ssd_storage_bolt_shaft_pos + [ 0, 0, m2_ssd_storage_bolt_shaft_height ];

module m2_ssd_storage_slot(slot_gap) {
  color("slategray") translate(m2_ssd_storage_slot_pos)
    offset_cube(m2_ssd_storage_slot_size, slot_gap);
}

module m2_ssd_storage(slot_gap) {
  translate(m2_ssd_storage_pos) offset_cube(m2_ssd_storage_size, slot_gap);
}

module m2_ssd_storage_bolt_shaft(slot_gap) {
  color("peru") translate(m2_ssd_storage_bolt_shaft_pos)
    offset_cylinder(h = m2_ssd_storage_bolt_shaft_height,
                    r = m2_ssd_storage_bolt_shaft_radius, offset = slot_gap);
}

module m2_ssd_storage_bolt_shaft_access() {
  slot_pos =
    [ m2_ssd_storage_bolt_shaft_pos.x, m2_ssd_storage_bolt_shaft_pos.y, case_pos.z ];

  translate(slot_pos)
    offset_cylinder(h = bottom_case_offset, r = m2_ssd_storage_bolt_shaft_radius,
                    offset = board_clearance, $fn = 6);
}

// top_case_gap should be big enough so that the case can contain components located on
// the top face of the board
assert(case_hollow_rear_pos.z > hdmi_port_rear_pos.z);

// sum of bottom_case_gap, bottom_wall_thickness and case_stands_height parameters
// should be big enough so that the case can contain components located
// on the bottom face of the board
assert((case_pos.z - case_stands_height) <
       min(m2_ssd_storage_pos.z, m2_ssd_storage_slot_pos.z));

// Board

module board(slot_gap = 0) {
  board_plate(offset = [ slot_gap, slot_gap, slot_gap ] * 1.3);
  pin_header(slot_gap);
  reset_button(slot_gap);
  leds(slot_gap);
  usb_c_port(slot_gap);
  audio_port(slot_gap);
  left_usb_port(slot_gap);
  right_usb_port(slot_gap);
  hdmi_port(slot_gap);
  left_ethernet_port(slot_gap);
  right_ethernet_port(slot_gap);
  four_lane_mipi_dsi_port(slot_gap);
  two_lane_mipi_dsi_port(slot_gap);
  mipi_csi_port(slot_gap);
  fan_pin_header(slot_gap);
  tf_card(slot_gap);
  m2_ssd_storage_bolt_shaft(slot_gap);

  if (ice_tower_fan_present)
    ice_tower_fan(slot_gap);
  if (emmc_storage_present)
    emmc_storage(slot_gap);

  m2_ssd_storage_slot(slot_gap);
  m2_ssd_storage(slot_gap);
}

module board_slot() {
  board(board_clearance);

  if (pin_header_back_slot_height_fraction > 0)
    pin_header_back_access();
  if (pin_header_top_slot_enabled)
    pin_header_top_access();
  if (reset_button_accessible && !reset_button_lever_enabled)
    reset_button_access();
  if (leds_visible_from_back_face)
    leds_back_face_access();
  if (usb_c_port_accessible)
    usb_c_port_access();
  if (audio_port_accessible)
    audio_port_access();
  if (left_usb_port_accessible)
    left_usb_port_access();
  if (right_usb_port_accessible)
    right_usb_port_access();
  if (hdmi_port_accessible)
    hdmi_port_access();
  if (left_ethernet_port_accessible)
    left_ethernet_port_access();
  if (right_ethernet_port_accessible)
    right_ethernet_port_access();
  if (four_lane_mipi_dsi_port_accessible)
    four_lane_mipi_dsi_port_access();
  if (two_lane_mipi_dsi_port_accessible)
    two_lane_mipi_dsi_port_access();
  if (mipi_csi_port_accessible)
    mipi_csi_port_access();
  if (tf_card_accessible)
    tf_card_access();
  if (ice_tower_fan_present)
    ice_tower_fan_access();
  if (m2_ssd_storage_bolt_shaft_accessible)
    m2_ssd_storage_bolt_shaft_access();
}

// Case blueprint

horizontal_slot_gap = 10;

function horizontal_slot_pos(pos_z) =
  case_pos + [ horizontal_slot_gap, horizontal_slot_gap, pos_z - case_pos.z - tiny ];

function horizontal_slot_size(wall_thickness) = [
  case_size.x - horizontal_slot_gap * 2,
  case_size.y - horizontal_slot_gap -
    (case_rear_pos.y - ice_tower_fan_rear_pos.y - board_clearance),
  wall_thickness + tiny * 2
];

module horizontal_slot(pos_z, wall_thickness, fillet) {
  translate(horizontal_slot_pos(pos_z))
    smooth_cube(horizontal_slot_size(wall_thickness), fillet);
}

reset_button_lever_height = reset_button_size.z * 3;
reset_button_lever_slot_gap = board_clearance * 2.7;
reset_button_lever_width = reset_button_size.x * 1.2;
reset_button_lever_pos_x =
  reset_button_pos.x - (reset_button_lever_width - reset_button_size.x) / 2;
reset_button_lever_angle = [ 0, -90 ];

module reset_button_lever_slot() {
  slot_pos =
    [ reset_button_lever_pos_x, case_hollow_rear_pos.y - tiny, reset_button_pos.z ];

  slot_size = [
    reset_button_lever_width, back_wall_thickness + 2 * tiny,
    reset_button_lever_height
  ];

  rotate_around(point = reset_button_knob_center, angle = reset_button_lever_angle)
    translate(slot_pos) offset_cube(slot_size, reset_button_lever_slot_gap);
}

module reset_button_lever() {
  bend_radius = 0.5;
  lever_thickness = 1;
  lever_pos =
    [ reset_button_lever_pos_x, case_rear_pos.y - lever_thickness, reset_button_pos.z ];
  lever_size = [
    reset_button_lever_width, lever_thickness, reset_button_lever_height +
    reset_button_lever_slot_gap
  ];

  rotate_around(point = reset_button_knob_center, angle = reset_button_lever_angle) {
    translate(lever_pos) difference() {
      translate([ lever_size.x, 0, lever_size.z + board_clearance + 0.5 ])
        rotate([ -90, 90 ]) linear_extrude(lever_size.y) offset(board_clearance * 2)
          offset(-board_clearance * 2)
            square([ lever_size.z + board_clearance + 0.5, lever_size.x ]);
      translate([ -tiny, 0, lever_size.z - bend_radius ]) rotate([ 0, 90 ])
        cylinder(h = reset_button_lever_width + tiny * 2, r = bend_radius);
    }

    translate([
      reset_button_knob_center.x, board_rear_pos.y + board_clearance,
      reset_button_knob_center.z
    ]) rotate(reset_button_knob_rotation)
      cylinder(h = case_rear_pos.y - board_rear_pos.y - board_clearance,
               r = reset_button_knob_radius);
  }
}

module case_hollow() {
  translate(case_hollow_pos) smooth_cube(case_hollow_size, case_fillet_radius);
}

module case_shape() {
  shifted_case_pos = case_pos + [
    flatten_left_face ? -1 : 0, flatten_front_face ? -1 : 0,
    flatten_bottom_face ? -1 : 0
  ] * case_fillet_radius;

  shifted_case_size = case_size + [
    (flatten_left_face ? 1 : 0) + (flatten_right_face ? 1 : 0),
    (flatten_front_face ? 1 : 0) + (flatten_back_face ? 1 : 0),
    (flatten_bottom_face ? 1 : 0) + (flatten_top_face ? 1 : 0),
  ] * case_fillet_radius;

  difference() {
    translate(shifted_case_pos) difference() {
      smooth_cube(shifted_case_size, case_fillet_radius);

      if (flatten_left_face)
        translate([ -tiny, 0 ])
          cube([ case_fillet_radius + tiny, shifted_case_size.y, shifted_case_size.z ]);

      if (flatten_right_face)
        translate([ shifted_case_size.x - case_fillet_radius, 0 ])
          cube([ case_fillet_radius + tiny, shifted_case_size.y, shifted_case_size.z ]);

      if (flatten_front_face)
        translate([ 0, -tiny ])
          cube([ shifted_case_size.x, case_fillet_radius + tiny, shifted_case_size.z ]);

      if (flatten_back_face)
        translate([ 0, shifted_case_size.y - case_fillet_radius ])
          cube([ shifted_case_size.x, case_fillet_radius + tiny, shifted_case_size.z ]);

      if (flatten_bottom_face)
        translate([ 0, 0, -tiny ])
          cube([ shifted_case_size.x, shifted_case_size.y, case_fillet_radius + tiny ]);

      if (flatten_top_face)
        translate([ 0, 0, shifted_case_size.z - case_fillet_radius ])
          cube([ shifted_case_size.x, shifted_case_size.y, case_fillet_radius + tiny ]);
    }
    case_hollow();
  }
}

module case_stands() {
  radius = 3;

  stand_offset = flatten_bottom_face ? max(case_fillet_radius, radius) :
                                       (case_fillet_radius + radius);
  stand_offset_front_y =
    flatten_front_face ? min(stand_offset, horizontal_slot_gap / 2) : stand_offset;

  stand_offset_right_x =
    flatten_right_face ? min(stand_offset, horizontal_slot_gap / 2) : stand_offset;

  stand_offset_left_x =
    flatten_left_face ? min(stand_offset, horizontal_slot_gap / 2) : stand_offset;

  module stand(pos) {
    r = radius - 1;

    translate([ pos.x, pos.y, case_pos.z ]) hull() {
      resize([ r * 2, r * 2, case_stands_height ]) sphere(r);
      cylinder(h = tiny, r = radius);
    }
  }

  stand([ case_pos.x + stand_offset_right_x, case_pos.y + stand_offset_front_y ]);
  stand([ case_pos.x + stand_offset_right_x, case_rear_pos.y - stand_offset ]);
  stand([ case_rear_pos.x - stand_offset_left_x, case_rear_pos.y - stand_offset ]);
  stand([ case_rear_pos.x - stand_offset_left_x, case_pos.y + stand_offset_front_y ]);
}

module case_blueprint() {
  difference() {
    case_shape();

    board_slot();

    if (top_slot_shape != "none")
      horizontal_slot(case_hollow_rear_pos.z, top_wall_thickness,
                      top_slot_shape == "rect" ? 0 : case_fillet_radius);

    if (bottom_slot_shape != "none")
      horizontal_slot(case_pos.z, bottom_wall_thickness,
                      bottom_slot_shape == "rect" ? 0 : case_fillet_radius);

    if (reset_button_lever_enabled)
      reset_button_lever_slot();
  }

  if (reset_button_lever_enabled)
    reset_button_lever();

  if (case_stands_height > 0)
    case_stands();
}

// Snap case

back_lid_top_expand = expand_back_lid_top && top_slot_shape != "none";

back_lid_bottom_expand = expand_back_lid_bottom && bottom_slot_shape != "none";

ice_tower_slot_exists = top_slot_shape == "none" &&
                        case_hollow_rear_pos.z <= ice_tower_fan_rear_pos.z &&
                        ice_tower_fan_present;

back_lid_ice_tower_slot_expand = expand_back_lid_top && ice_tower_slot_exists;

ice_tower_top_slot_exists = top_slot_shape == "none" && !ice_tower_slot_exists &&
                            case_hollow_rear_pos.z <= ice_tower_fan_top_rear_pos.z &&
                            ice_tower_fan_present;

back_lid_ice_tower_top_slot_expand = expand_back_lid_top && ice_tower_top_slot_exists;

m2_ssd_storage_slot_exists = bottom_slot_shape == "none" &&
                             case_hollow_pos.z >= m2_ssd_storage_pos.z &&
                             m2_ssd_storage_size.z > 0;

back_lid_m2_ssd_storage_slot_expand =
  expand_back_lid_bottom && m2_ssd_storage_slot_exists;

module case_splitter(intersection_gap = 0, difference_gap = 0) {
  inner_gap = difference_gap == 0 ? 0 : case_fillet_radius;

  translate([
    case_hollow_pos.x + intersection_gap, case_hollow_rear_pos.y - inner_gap - tiny,
    case_hollow_pos.z - intersection_gap + case_hollow_size.z
  ]) rotate([-90]) linear_extrude(back_wall_thickness + inner_gap + tiny * 2) hull() {
    translate([ case_fillet_radius, case_fillet_radius ]) circle(case_fillet_radius);

    translate([
      case_hollow_size.x - intersection_gap * 2 - case_fillet_radius, case_fillet_radius
    ]) circle(case_fillet_radius);

    translate([
      case_hollow_size.x - intersection_gap * 2 - case_fillet_radius,
      case_hollow_size.z - intersection_gap * 2 -
      case_fillet_radius
    ]) circle(case_fillet_radius);

    translate([
      case_fillet_radius, case_hollow_size.z - intersection_gap * 2 -
      case_fillet_radius
    ]) circle(case_fillet_radius);
  }

  z_offset = max(case_stands_height, tiny);

  bottom_expand_pos = [
    case_pos.x + horizontal_slot_gap + intersection_gap,
    ice_tower_fan_rear_pos.y -
      (bottom_slot_shape == "rounded" ? case_fillet_radius : 0),
    case_pos.z -
    z_offset
  ];

  bottom_expand_size = [
    case_size.x - horizontal_slot_gap * 2 - intersection_gap * 2,
    case_rear_pos.y - bottom_expand_pos.y + tiny, z_offset + bottom_wall_thickness +
    case_fillet_radius
  ];

  m2_ssd_storage_slot_expand_pos = [
    m2_ssd_storage_pos.x + intersection_gap - board_clearance,
    m2_ssd_storage_rear_pos.y, bottom_expand_pos.z
  ];

  m2_ssd_storage_slot_expand_size = [
    m2_ssd_storage_size.x - intersection_gap * 2 + board_clearance * 2,
    case_rear_pos.y - m2_ssd_storage_slot_expand_pos.y + tiny, bottom_expand_size.z
  ];

  top_expand_pos = [
    bottom_expand_pos.x,
    ice_tower_fan_rear_pos.y - (top_slot_shape == "rounded" ? case_fillet_radius : 0),
    case_hollow_rear_pos.z -
    case_fillet_radius
  ];

  top_expand_size = [
    bottom_expand_size.x, case_rear_pos.y - top_expand_pos.y + tiny,
    top_wall_thickness + case_fillet_radius +
    tiny
  ];

  ice_tower_slot_expand_pos = [
    ice_tower_fan_pos.x + intersection_gap,
    ice_tower_fan_rear_pos.y - ice_tower_fan_slot_rounding, top_expand_pos.z
  ];

  ice_tower_slot_expand_size = [
    ice_tower_fan_size.x - intersection_gap * 2 + board_clearance,
    case_rear_pos.y - ice_tower_slot_expand_pos.y + tiny, top_expand_size.z
  ];

  ice_tower_top_slot_expand_pos = [
    ice_tower_fan_top_pos.x + intersection_gap - board_clearance,
    ice_tower_fan_top_rear_pos.y, top_expand_pos.z
  ];

  ice_tower_top_slot_expand_size = [
    ice_tower_fan_top_size.x - intersection_gap * 2 + board_clearance * 2,
    case_rear_pos.y - ice_tower_top_slot_expand_pos.y + tiny, top_expand_size.z
  ];

  if (back_lid_bottom_expand)
    translate(bottom_expand_pos) cube(bottom_expand_size);

  if (back_lid_top_expand)
    translate(top_expand_pos) cube(top_expand_size);

  if (back_lid_ice_tower_slot_expand)
    translate(ice_tower_slot_expand_pos) cube(ice_tower_slot_expand_size);

  if (back_lid_ice_tower_top_slot_expand)
    translate(ice_tower_top_slot_expand_pos) cube(ice_tower_top_slot_expand_size);

  if (back_lid_m2_ssd_storage_slot_expand)
    translate(m2_ssd_storage_slot_expand_pos) cube(m2_ssd_storage_slot_expand_size);
}

module board_holder(width, length) {
  holder_size = [ width, length, 4 ];
  holder_radius = 1;

  rotate([-90]) linear_extrude(holder_size.x) {
    mirror_copy([ 0, 1, 0 ]) translate([ 0, board_size.z / 2 + board_clearance ])
      hull() {
      square([ tiny, holder_size.z ]);
      translate([ holder_size.y - holder_radius, holder_radius ]) circle(holder_radius);
    }

    translate([ 0, -board_size.z / 2 - board_clearance ])
      square([ holder_size.y - holder_radius, board_size.z + board_clearance * 2 ]);
  }
}

holder_clamp_length = 3.5;

module back_lid_board_holders() {
  module back_board_holder(from, to) {
    translate([
      from + board_clearance, case_hollow_rear_pos.y, board_pos.z + board_size.z / 2
    ]) rotate([ 0, 0, -90 ]) board_holder(to - from - board_clearance * 2,
                                          front_case_gap + holder_clamp_length);
  }

  back_board_holder(board_pos.x + case_fillet_radius / 3,
                    pin_header_pos.x - board_clearance * 6);
  back_board_holder(usb_c_port_rear_pos.x + board_clearance * 6,
                    board_rear_pos.x - case_fillet_radius / 3);
  if (!reset_button_lever_enabled)
    back_board_holder(reset_button_pos.x - 2.5, reset_button_pos.x);
  back_board_holder(reset_button_rear_pos.x, leds_pos.x);

  translate([ pin_header_pos.x + pin_header_size.x / 3, board_rear_pos.y, board_pos.z ])
    cube([ 5, back_case_gap, board_size.z ]);

  translate(
    [ pin_header_pos.x + pin_header_size.x / 3 * 2, board_rear_pos.y, board_pos.z ])
    cube([ 5, back_case_gap, board_size.z ]);
}

module front_lid_board_holders() {
  module front_board_holder(from, to) {
    translate(
      [ to - board_clearance, case_hollow_pos.y, board_pos.z + board_size.z / 2 ])
      rotate([ 0, 0, 90 ]) board_holder(to - from - board_clearance * 2,
                                        front_case_gap + holder_clamp_length);
  }

  front_board_holder(audio_port_rear_pos.x, left_usb_port_pos.x);
  front_board_holder(left_usb_port_rear_pos.x, right_usb_port_pos.x);
  front_board_holder(right_usb_port_rear_pos.x, hdmi_port_pos.x);
  front_board_holder(hdmi_port_rear_pos.x, left_ethernet_port_pos.x);
  front_board_holder(left_ethernet_port_rear_pos.x, right_ethernet_port_pos.x);

  translate([ case_hollow_pos.x, board_pos.y + case_fillet_radius, board_pos.z ]) {
    cube([ left_case_gap, case_hollow_size.y - case_fillet_radius * 2, board_size.z ]);
    linear_extrude(board_size.z)
      polygon([ [ 0, 0 ], [ 0, -left_case_gap ], [ left_case_gap, 0 ] ]);
  }

  translate([ board_rear_pos.x, board_pos.y + case_fillet_radius, board_pos.z ]) {
    cube([ right_case_gap, case_hollow_size.y - case_fillet_radius * 2, board_size.z ]);
    linear_extrude(board_size.z)
      polygon([ [ 0, 0 ], [ right_case_gap, -right_case_gap ], [ right_case_gap, 0 ] ]);
  }
}

max_snap_lever_length = case_hollow_rear_pos.y - tf_card_pos.y;
snap_lever_pos_z = max(mipi_csi_port_rear_pos.z, two_lane_mipi_dsi_port_rear_pos.z) + 2;
snap_knob_radius = min(5, ((case_hollow_rear_pos.z - case_fillet_radius -
                            snap_lever_pos_z - board_clearance / 2) /
                           2));

module snap_lever(wall_thickness, joint_reach, enable_lug, difference_gap = 0) {
  snap_prop_radius = 0.5;
  skew_angle = -25;
  snap_lever_thickness = wall_thickness / 1.5;
  snap_joint_reach = difference_gap == 0 ? min(joint_reach, 3) : joint_reach;
  snap_knob_height = snap_lever_thickness + snap_joint_reach + board_clearance + tiny;
  skew_offset = snap_knob_height * tan(skew_angle);
  snap_lever_length =
    max_snap_lever_length - (tf_card_size.y / 2 - snap_knob_radius) - skew_offset;

  snap_arm_length = snap_lever_length - snap_knob_radius;

  module snap_prop() {
    offset_cylinder(h = snap_knob_height, r = snap_prop_radius, offset = difference_gap,
                    $fn = 3);
  }

  module nail_lug(y) {
    translate(
      [ y + snap_knob_height * tan(skew_angle), snap_knob_radius, snap_knob_height ])
      rotate([ 90, -30 ]) cylinder(h = snap_knob_radius * 2, r = 1, $fn = 3);
  }

  rotate([ 90, 0, -90 ]) {
    offset_cube([ snap_arm_length, snap_knob_radius * 2, snap_lever_thickness ],
                difference_gap);

    is_hex = snap_knob_shape == "hexagon";
    is_tear = snap_knob_shape == "teardrop";

    translate([ snap_arm_length, snap_knob_radius ]) difference() {
      union() {
        skew(xz = skew_angle) hull() {
          offset_cylinder(h = snap_knob_height,
                          r = (snap_knob_radius + difference_gap / 2) /
                              (is_hex ? cos(30) : 1),
                          offset = difference_gap, $fn = (is_hex ? 6 : $fn));

          if (is_tear)
            translate([ -snap_knob_radius * 1.5, 0 ]) snap_prop();
        }

        if (snap_knob_prop_enabled) {
          translate(
            [ skew_offset + (is_tear ? 0 : snap_prop_radius), 0, snap_knob_height ])
            skew(xz = 45) rotate([180]) hull() {
            snap_prop();
            translate([
              (-snap_knob_radius * (is_tear ? 1.5 : 1) - difference_gap / 2) /
                (is_hex ? cos(30) : 1),
              0
            ]) snap_prop();
          }
        }
      }

      if (enable_lug && difference_gap == 0)
        intersection() {
          for (y = [-2:2])
            nail_lug(y);

          skew(xz = skew_angle)
            cylinder(h = snap_knob_height + tiny, r = snap_knob_radius * 0.67);
        }
    }

    for (y = [
           snap_lever_thickness, snap_knob_radius + snap_lever_thickness / 2,
           snap_knob_radius * 2
         ])
      translate([ 0, y, -snap_lever_thickness * 3 ]) rotate([90])
        linear_extrude(snap_lever_thickness) polygon([
          [ 0, 0 ], [ snap_arm_length, snap_lever_thickness * 3 ],
          [ 0, snap_lever_thickness * 3 ]
        ]);
  }
}

right_snap_lever_reach = right_wall_thickness + board_clearance * 1.5;
left_snap_lever_reach = left_wall_thickness + board_clearance * 1.5;
snap_lever_gap = lid_clearance * 2;

module snap_levers(difference_gap = 0) {
  translate([
    case_hollow_rear_pos.x - back_wall_thickness / 1.5 - board_clearance -
      (hide_right_snap_knob ? right_snap_lever_reach + snap_lever_gap + tiny * 2 : 0),
    case_hollow_rear_pos.y,
    snap_lever_pos_z
  ]) mirror([ 1, 0, 0 ])
    snap_lever(back_wall_thickness, right_snap_lever_reach,
               !hide_right_snap_knob && snap_knob_lug_enabled, difference_gap);

  translate([
    case_hollow_pos.x + back_wall_thickness / 1.5 + board_clearance +
      (hide_left_snap_knob ? left_snap_lever_reach + snap_lever_gap + tiny * 2 : 0),
    case_hollow_rear_pos.y,
    snap_lever_pos_z
  ]) snap_lever(back_wall_thickness, left_snap_lever_reach,
                !hide_left_snap_knob && snap_knob_lug_enabled, difference_gap);
}

snap_sealing_height = snap_knob_radius * 2 + 2;
right_snap_sealing_pos_z = mipi_csi_port_rear_pos.z + 1;
left_snap_sealing_pos_z = two_lane_mipi_dsi_port_rear_pos.z + 1;

module snap_sealing() {
  left_sealing_width = hide_left_snap_knob ? left_snap_lever_reach : 1;
  right_sealing_width = hide_right_snap_knob ? right_snap_lever_reach : 1;

  translate([
    case_hollow_rear_pos.x - right_sealing_width + tiny,
    case_hollow_rear_pos.y - max_snap_lever_length,
    right_snap_sealing_pos_z
  ]) {
    cube([ right_sealing_width, max_snap_lever_length, snap_sealing_height ]);
    linear_extrude(snap_sealing_height) polygon([
      [ 0, 0 ], [ right_sealing_width, 0 ],
      [ right_sealing_width, -right_sealing_width ]
    ]);
  }

  translate([
    case_hollow_pos.x - tiny, case_hollow_rear_pos.y - max_snap_lever_length,
    left_snap_sealing_pos_z
  ]) {
    cube([ left_sealing_width, max_snap_lever_length, snap_sealing_height ]);
    linear_extrude(snap_sealing_height)
      polygon([ [ 0, 0 ], [ left_sealing_width, 0 ], [ 0, -left_sealing_width ] ]);
  }
}

module back_lid_stops(slot = false) {
  stop_size = [
    back_wall_thickness * 3 + (slot ? (lid_clearance * 8) : 0),
    horizontal_slot_gap - back_wall_thickness - board_clearance,
    back_wall_thickness * (slot ? 10 : 0.7)
  ];

  module lid_stop(point, angle) {
    translate([ point.x, point.y - lid_clearance, point.z ]) rotate([ 0, angle ])
      linear_extrude(stop_size.x) polygon([
        [ 0, 0 ], [ 0, stop_size.y + (slot ? 1 : 0) ], [ stop_size.z, stop_size.y ]
      ]);
  }

  module bottom_lid_stop(pos_x) {
    lid_stop([ pos_x, case_hollow_rear_pos.y - stop_size.y, case_hollow_pos.z ], -90);
  }

  module top_lid_stop(pos_x) {
    lid_stop([ pos_x, case_hollow_rear_pos.y - stop_size.y, case_hollow_rear_pos.z ],
             90);
  }

  lid_offset = case_fillet_radius + 5;
  start_x = board_pos.x + lid_offset;
  end_x = board_rear_pos.x - lid_offset;
  size_x = end_x - start_x;
  slot_offset = slot ? lid_clearance : 0;

  if (!back_lid_bottom_expand) {
    bottom_lid_stop(back_lid_m2_ssd_storage_slot_expand ?
                      (m2_ssd_storage_pos.x - board_clearance + slot_offset * 4) :
                      (start_x + stop_size.x - slot_offset * 4));
    bottom_lid_stop(
      back_lid_m2_ssd_storage_slot_expand ?
        (m2_ssd_storage_rear_pos.x + stop_size.x + board_clearance - slot_offset * 4) :
        (end_x + slot_offset * 4));
    if (!back_lid_m2_ssd_storage_slot_expand) {
      bottom_lid_stop(start_x + size_x / 2 + stop_size.x / 2);
      bottom_lid_stop(start_x + size_x / 3 - stop_size.x / 4 + slot_offset * 6);
      bottom_lid_stop(start_x + size_x / 3 * 2 + stop_size.x / 3 * 4 - slot_offset * 6);
    }
  } else {
    bottom_lid_stop(case_pos.x + horizontal_slot_gap + slot_offset * 3);
    bottom_lid_stop(case_rear_pos.x - horizontal_slot_gap + stop_size.x -
                    slot_offset * 3);
  }

  if (!back_lid_top_expand) {
    if (!back_lid_ice_tower_slot_expand) {
      top_lid_stop(start_x + (hide_left_snap_knob ? stop_size.x / 2 : 0) -
                   slot_offset * 4);
      if (!back_lid_ice_tower_top_slot_expand) {
        top_lid_stop(start_x + size_x / 2 - stop_size.x / 2);
        top_lid_stop(start_x + size_x / 3 - stop_size.x / 3 * 4 + slot_offset * 6);
        top_lid_stop(start_x + size_x / 3 * 2 + stop_size.x / 4 - slot_offset * 6);
      } else
        top_lid_stop(ice_tower_fan_top_rear_pos.x + board_clearance - slot_offset * 4);
    }
    top_lid_stop(end_x - stop_size.x * (hide_right_snap_knob ? 1.5 : 1) +
                 slot_offset * 8);
  }
}

module front_lid_stops() {
  module lid_stop(angle) {
    side = 2;

    rotate([ 0, angle ]) linear_extrude(case_hollow_size.x - case_fillet_radius * 2)
      hull() {
      polygon([ [ 0, 0 ], [ 0, -side ], [ side * 1.5, 0 ] ]);
      translate([ side / 4, -side ]) circle(side / 4);
    }
  }

  difference() {
    if (!flatten_back_face) {
      if (!flatten_top_face)
        translate([
          case_hollow_pos.x + case_fillet_radius, case_hollow_rear_pos.y,
          case_hollow_rear_pos.z -
          lid_clearance
        ]) lid_stop(90);

      if (!flatten_bottom_face)
        translate([
          case_hollow_rear_pos.x - case_fillet_radius, case_hollow_rear_pos.y,
          case_hollow_pos.z +
          lid_clearance
        ]) lid_stop(-90);
    }

    back_lid_stops(slot = true);
  }
}

module lid() {
  difference() {
    children();

    board_slot();
  }
}

module front_lid() {
  lid() {
    difference() {
      union() {
        case_blueprint();
        intersection() {
          snap_sealing();
          case_hollow();
        }
      }

      case_splitter(difference_gap = lid_clearance);
      snap_levers(snap_lever_gap);
    }

    intersection() {
      front_lid_board_holders();
      case_hollow();
    }

    back_lid_stops();
  }
}

module back_lid() {
  lid() {
    intersection() {
      case_blueprint();
      case_splitter(intersection_gap = lid_clearance);
    }

    back_lid_board_holders();
    snap_levers();

    front_lid_stops();
  }
}

if (!$preview) {
  translate(
    [ 0, case_size.z / 2 + 5, case_size.y - front_case_gap - front_wall_thickness ])
    rotate([-90]) back_lid();

  translate([ 0, 0, front_case_gap + front_wall_thickness ]) {
    rotate([90]) front_lid();

    if (bottom_face_supports) {
      bottom_seq = [
        [ bottom_wall_thickness / 2, bottom_wall_thickness - support_thickness ],
        [ bottom_wall_thickness / 2, -bottom_wall_thickness + support_thickness ],
      ];

      if (bottom_slot_shape != "none" && !expand_back_lid_bottom) {
        translate([
          horizontal_slot_pos(0).x + board_clearance,
          -case_hollow_pos.z + support_thickness / 2, horizontal_slot_pos(0).y
        ])
          support(
            [
              horizontal_slot_size(0).x - board_clearance * 2, bottom_wall_thickness,
              horizontal_slot_size(0).y
            ],
            bottom_seq, support_thickness);
      }

      if (bottom_slot_shape == "none" && m2_ssd_storage_bolt_shaft_accessible) {
        translate([
          m2_ssd_storage_bolt_shaft_pos.x - m2_ssd_storage_bolt_shaft_radius / 2,
          -case_hollow_pos.z + support_thickness / 2,
          m2_ssd_storage_bolt_shaft_pos.y - m2_ssd_storage_bolt_shaft_radius,
        ])
          support(
            [
              m2_ssd_storage_bolt_shaft_radius, bottom_wall_thickness,
              m2_ssd_storage_bolt_shaft_radius * 2
            ],
            bottom_seq, support_thickness);
      }

      if (!expand_back_lid_bottom && m2_ssd_storage_slot_exists)
        translate([
          m2_ssd_storage_pos.x + board_clearance,
          -case_hollow_pos.z + support_thickness / 2, m2_ssd_storage_pos.y -
          board_clearance
        ])
          support(
            [
              m2_ssd_storage_size.x - board_clearance * 2, bottom_wall_thickness,
              m2_ssd_storage_size.y + board_clearance * 2
            ],
            bottom_seq, support_thickness);
    }

    if (top_face_supports) {
      top_seq = [
        [ top_wall_thickness / 2, top_wall_thickness - support_thickness ],
        [ top_wall_thickness / 2, -top_wall_thickness + support_thickness ],
      ];

      if (pin_header_top_slot_enabled)
        translate([
          pin_header_pos.x + board_clearance, -case_rear_pos.z + support_thickness / 2,
          pin_header_pos.y -
          board_clearance
        ])
          support(
            [
              pin_header_size.x - board_clearance * 2, top_wall_thickness,
              pin_header_size.y + board_clearance * 2
            ],
            top_seq, support_thickness);

      if (top_slot_shape != "none" && !expand_back_lid_top) {
        translate([
          horizontal_slot_pos(0).x + board_clearance,
          -case_rear_pos.z + support_thickness / 2, horizontal_slot_pos(0).y
        ])
          support(
            [
              horizontal_slot_size(0).x - board_clearance * 2, top_wall_thickness,
              horizontal_slot_size(0).y
            ],
            top_seq, support_thickness);
      }

      if (!expand_back_lid_top && ice_tower_slot_exists)
        translate([
          ice_tower_fan_pos.x + board_clearance,
          -case_rear_pos.z + support_thickness / 2, ice_tower_fan_pos.y
        ])
          support(
            [
              ice_tower_fan_size.x - board_clearance * 2, top_wall_thickness,
              ice_tower_fan_size.y +
              board_clearance
            ],
            top_seq, support_thickness);

      if (!expand_back_lid_top && ice_tower_top_slot_exists)
        translate([
          ice_tower_fan_top_pos.x, -case_rear_pos.z + support_thickness / 2,
          ice_tower_fan_top_pos.y -
          board_clearance
        ])
          support(
            [
              ice_tower_fan_top_size.x, top_wall_thickness,
              ice_tower_fan_top_size.y + board_clearance * 2
            ],
            top_seq, support_thickness);
    }
  }
} else {
  if (show_back_lid)
    back_lid();

  if (show_front_lid)
    front_lid();

  % if (show_board) board();
}
