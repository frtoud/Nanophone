//===========================================
/*
 DESCRIPTION:
  Spawns basegame's dust vfx from specific events.

 STRUCTURES:
  - DUSTQUERYtype: []
     [0] "x": real
     [1] "y": real
     [2] "dust type": string
     [3] "direction": real

 DEPENDS ON:
  - phone_dust_query: [DUSTQUERYtype]

 USED IN:
  - UPDATE event

 INPUTS:
  - phone_dust_query: [DUSTQUERYtype] (fill with entires to spawn dusts)

ORIGINAL DOCUMENTATION:
  phone_dust_query
    This is an array that, itself, stores arrays. Its purpose is to provide easy
    access to the spawn_base_dust() function written by Supersonic, which lets
    you spawn RoA dust effects (e.g. the ones made when dashing) whenever you
    want!

    To spawn dust, just run this code from one of your character's scripts:
    array_push(phone_dust_query, [x_pos, y_pos, dust_type, direction]);

    e.g.
    array_push(phone_dust_query, [x, y, "dash_start", spr_dir]);

    Here's a list of all of the valid dust types:
    - "dash_start"
    - "dash" 
    - "jump"
    - "doublejump"
    - "djump"
    - "walk"
    - "land"
    - "walljump"
    - "n_wavedash"
    - "wavedash"
*/
//===========================================

//========================================================================================================
#define process_dust_queries
//processes all requests within phone_dust_query, spawning their vfx.
//========================================================================================================
if (array_length(phone_dust_query) > 0)
{
    for(var i = 0; i < array_length(phone_dust_query); i++)
    {
        var cur = phone_dust_query[i];
        //implied X, Y, dust type, and spr_dir parameters
        spawn_base_dust(cur[0], cur[1], cur[2], cur[3]);
    }

    //clearing array
    phone_dust_query = [];
}


//========================================================================================================
#define spawn_base_dust
///spawn_base_dust(x, y, name, dir = 0)
///spawn_base_dust(x, y, name, ?dir)
// originally by supersonic
//This function spawns base cast dusts. Names can be found below.
//========================================================================================================
var x = argument[0], 
    y = argument[1], 
    name = argument[2];
var dir = argument_count > 3 ? argument[3] : 0;

var dlen; //dust_length value
var dfx; //dust_fx value
var dfg; //fg_sprite value
var dfa = 0; //draw_angle value
var dust_color = 0;

switch (name) 
{
    default: 
    // warning: sprite assets magic numbers
    case "dash_start": dlen = 21; dfx = 3;  dfg = 2626; break;
    case "dash":       dlen = 16; dfx = 4;  dfg = 2656; break;
    case "jump":       dlen = 12; dfx = 11; dfg = 2646; break;
    case "doublejump": 
    case "djump":      dlen = 21; dfx = 2;  dfg = 2624; break;
    case "walk":       dlen = 12; dfx = 5;  dfg = 2628; break;
    case "land":       dlen = 24; dfx = 0;  dfg = 2620; break;
    case "walljump":   dlen = 24; dfx = 0;  dfg = 2629; dfa = -90 *(dir != 0 ? dir : spr_dir); break;
    case "n_wavedash": dlen = 24; dfx = 0;  dfg = 2620; dust_color = 1; break;
    case "wavedash":   dlen = 16; dfx = 4;  dfg = 2656; dust_color = 1; break;
}
var newdust = spawn_dust_fx(round(x),round(y),asset_get("empty_sprite"),dlen);
if (newdust == noone) return noone;

newdust.draw_angle = dfa;
newdust.dust_fx = dfx; //set the fx id
newdust.dust_color = dust_color; //set the dust color
if (dfg != -1) newdust.fg_sprite = dfg; //set the foreground sprite
if (dir != 0) newdust.spr_dir = dir; //set the spr_dir
return newdust;
