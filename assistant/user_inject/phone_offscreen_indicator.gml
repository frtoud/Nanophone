//===========================================
/*
 DESCRIPTION:
  Renders offsceen indicators for tracked objects.

 STRUCTURES:
  - OFFSCREENOBJtype
     x: real
     y: real
     phone_offscr_leeway: real
     phone_offscr_x_offset: real
     phone_offscr_y_offset: real
     phone_offscr_sprite: sprite
     phone_offscr_index: real

 DEPENDS ON:
  - Sprites:
   - "_pho_offscreen_strip8.png"

 USED IN:
  - INIT event
  - HUD draw event

 INPUTS:
  - phone_offscreen: [OFFSCREENOBJtype]

ORIGINAL DOCUMENTATION:
  phone_offscreen
    This is an array that stores the instance IDs of objects (e.g. articles,
    projectiles, or whatever you want) which should have an offscreen indicator
    drawn for them. To use this, run this code from within that object, e.g.
    in hitbox_init or articleX_init:

    array_push(player_id.phone_offscreen, self);
    phone_offscr_sprite = sprite_get("..."); // icon to display
    phone_offscr_index = 0; // image_index of the icon
    phone_offscr_x_offset = 0; // x offset to draw the arrow at; uses spr_dir
    phone_offscr_y_offset = 0; // y offset to draw the arrow at
    phone_offscr_leeway = 16; // approximate width/height of obj

    An example icon can be found in the sprites folder:

    _pho_offscreen_example.png

    (it doesn't need a load.gml offset)

*/
//===========================================

//================================================================================
#define offscreen_indicators_init()
// USED IN: INIT event
// creates the phone_offscreen array.
//================================================================================
phone_offscreen = []; //list of objects to track in offscreen indicators

//================================================================================
#define offscreen_indicators_draw()
// USED IN: HUD draw event
// Draws offscreen indicators for objects in phone_offscreen.
//================================================================================
if !array_equals(phone_offscreen, [])
{
    var array_empty = true;

    var spr_pho_offscreen = sprite_get("_pho_offscreen");

    for (var i = 0; i < array_length(phone_offscreen); i++)
    {
        if (phone_offscreen[i] != noone)
        {
            array_empty = false;
            if !instance_exists(phone_offscreen[i])
            { phone_offscreen[i] = noone; }
            else with (phone_offscreen[i])
            {
                var leeway = phone_offscr_leeway;

                var x_ = x + phone_offscr_x_offset * spr_dir;
                var y_ = y + phone_offscr_y_offset;

                var off_l = x_ < view_get_xview() - leeway;
                var off_r = x_ > view_get_xview() + view_get_wview() + leeway;
                var off_u = y_ < view_get_yview() - leeway;
                var off_d = y_ > view_get_yview() + view_get_hview() - 52 + leeway;

                //Check which direction offscreen bubble points towards  
                var idx = noone;
                if (off_l)
                {
                    idx = 0;
                    if (off_u) idx = 1;
                    if (off_d) idx = 7;
                }
                else if (off_r)
                {
                    idx = 4;
                    if (off_u) idx = 3;
                    if (off_d) idx = 5;
                }
                else if (off_u) idx = 2;
                else if (off_d) idx = 6;

                if (idx != noone)
                {
                    var margin = 34;
                    draw_sprite_ext(spr_pho_offscreen, idx, 
                                    clamp(x_ - view_get_xview(), margin, view_get_wview() - margin) - 32, 
                                    clamp(y_ - view_get_yview(), margin, view_get_hview() - 52 - margin) - 32, 
                                    2, 2, 0, get_player_hud_color(player), 1);

                    with other shader_start();
                    draw_sprite_ext(phone_offscr_sprite, phone_offscr_index, 
                                    clamp(x_ - view_get_xview(), margin, view_get_wview() - margin) - 32, 
                                    clamp(y_ - view_get_yview(), margin, view_get_hview() - 52 - margin) - 32, 
                                    2, 2, 0, c_white, 1);
                    with other shader_end();
                }
            }
        }
    }
    //Clear array if no element left to track (optimizes check above)
    if (array_empty) phone_offscreen = [];
}