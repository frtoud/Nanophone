//===========================================
/*
 DESCRIPTION:
  Renders offsceen indicators for tracked objects.

 STRUCTURES:

 DEPENDS ON:
  - Sprites:
   - "_pho_offscreen_strip8.png"

 USED IN:
  - HUD draw event
*/
//===========================================


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

                var margin = 34;

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

    if (array_empty) phone_offscreen = [];
}