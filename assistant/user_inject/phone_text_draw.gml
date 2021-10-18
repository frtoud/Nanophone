//===========================================
/*
 DESCRIPTION:
  Common function that draws text.

 STRUCTURES:
  - SIZEtype:
     width: real
     height: real

 DEPENDS ON:
  - phone.last_text_size: SIZEtype (size of last text drawn)
*/
//===========================================

//=====================================================================
#define textDraw(x1, y1, font, color, line_sep, line_max, align, scale, outlined, alpha, text, get_size)
// Draw text at position x1, y1, using scale, alpha, align, font and color.
// line_sep is the vertical separation between text.
// line_max is the maximum length for a line of text.
// if outlined is TRUE, draws a 2px black contour.
// if get_size is TRUE, outputs the size of the written string to 
// phone.last_text_size.width and phone.last_test_size.height
//=====================================================================
{
    x1 = round(x1);
    y1 = round(y1);

    draw_set_font(asset_get(font));
    draw_set_halign(align);

    if (outlined)
    {
        for (var i = -1; i < 2; i++) 
        {
            for (var j = -1; j < 2; j++) 
            {
                draw_text_ext_transformed_color(x1 + i * 2, y1 + j * 2, text, 
                    line_sep, line_max, scale, scale, 0, c_black, c_black, c_black, c_black, alpha);
            }
        }
    }

    if (alpha > 0.01) 
        draw_text_ext_transformed_color(x1, y1, text, line_sep, line_max, 
                    scale, scale, 0, color, color, color, color, alpha);

    if (get_size)
    {
        phone.last_text_size.width = string_width_ext(text, line_sep, line_max); 
        phone.last_text_size.height = string_height_ext(text, line_sep, line_max);
    }
}
//=====================================================================