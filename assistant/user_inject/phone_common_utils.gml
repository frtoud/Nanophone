//===========================================
/*
 DESCRIPTION:
  Simple common functions used by Phone's backend

 STRUCTURES:
  - NONE (by design)

 DEPENDS ON:
  - NONE (by design)
*/
//===========================================

//================================================================================
#define detect_online()
//return TRUE if detecting online mode
//================================================================================
for (var cur = 0; cur < 4; cur++)
{
    if (get_player_hud_color(cur+1) == $64e542) //online-only color 
        return true;
}
return false;

//================================================================================
#define decimalToString(input)
// returns input as a string value, up to two decimal places.
//================================================================================
//Not a number: attempt to convert to string but leave as is
if !is_number(input) return(string(input));

input = input % 1000; //maximum

input = string(input); //converted to string (two decimal places)

if (string_length(input) > 2)
{
    var last_char = string_char_at(input, string_length(input));
    var third_last_char = string_char_at(input, string_length(input) - 2);
    // crops "1.20" to "1.2"
    if (last_char == "0" && third_last_char == ".") 
    { input = string_delete(input, string_length(input), 1); }
}

if (string_char_at(input, 1) == "0") input = string_delete(input, 1, 1);

return input;

//================================================================================
#define maskHeader
// Mask renderer utility: disables Normal draw.
// Draw shapes or sprites to be used as the stencil(s) by maskMidder.
//================================================================================
{
    gpu_set_blendenable(false);
    gpu_set_colorwriteenable(false,false,false,true);
    draw_set_alpha(0);
    draw_rectangle_color(0,0, room_width, room_height, c_white, c_white, c_white, c_white, false);
    draw_set_alpha(1);
}
//================================================================================
#define maskMidder
// Reenables draw but only within the region drawn between maskHeader and maskMidder.
// Lasts until maskFooter is called.
//================================================================================
{
    gpu_set_blendenable(true);
    gpu_set_colorwriteenable(true,true,true,true);
    gpu_set_blendmode_ext(bm_dest_alpha,bm_inv_dest_alpha);
    gpu_set_alphatestenable(true);
}
//================================================================================
#define maskFooter
// Restores normal drawing parameters
//================================================================================
{
    gpu_set_alphatestenable(false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}

//=====================================================================
#define rectDraw(x1, y1, width, height, color)
// Draws a colored rectangle (width and height effective size -1)
//=====================================================================
draw_rectangle_color(x1, y1, x1 + width - 1, y1 + height - 1, color, color, color, color, false);
