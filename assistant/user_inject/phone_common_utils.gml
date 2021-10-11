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
