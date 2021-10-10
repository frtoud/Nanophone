//===========================================
/*
 DESCRIPTION:
  Functions that collect and format Frame Data pages.
  Part of the "DATA" phone feature.

STRUCTURES:
  - NONE

 DEPENDS ON:
  - phone_common_utils
     decimalToString
*/
//===========================================


//================================================================================
#define pullHitboxValue(move, hbox, index, def)
// returns move's hbox's data value of index (converted to string as necessary).
// if it is zero, returns def instead. considers HG_PARENT_HITBOX inheritance.

if (get_hitbox_value(move, hbox, HG_PARENT_HITBOX) != 0) 
switch(index)
{
    case HG_HITBOX_TYPE:
    case HG_WINDOW:
    case HG_WINDOW_CREATION_FRAME:
    case HG_LIFETIME:
    case HG_HITBOX_X:
    case HG_HITBOX_Y:
    case HG_HITBOX_GROUP:
        break;
    default:
        if (index < 70) hbox = get_hitbox_value(move, hbox, HG_PARENT_HITBOX);
        break;
}

var value = get_hitbox_value(move, hbox, index);
//convert to string
if (value != 0) || is_string(value) return decimalToString(value);
else return string(def);


//================================================================================
#define checkAndAdd(orig, add)
// concatenates strings using separators.
// inserts line breaks automatically if it doesnt fit a full line.

var orig_str = decimalToString(orig);
var add_str = decimalToString(add);

//Trivial case: orig is empty
if (orig == "-") return add_str;

var separator = "   |   ";
var line_break = "
"; //formatting pls

var line_w = 560;
if (string_height_ext(orig_str + separator + add_str, 10, line_w) 
    == string_height_ext(orig_str, 10, line_w))
{
    return orig_str + separator + add_str;
}
return orig_str + line_break + add_str;
