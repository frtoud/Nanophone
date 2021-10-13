//===========================================
/*
 DESCRIPTION:
  Functions that collect and format Frame Data pages.
  Part of the "DATA" phone feature.

 DECLARATIONS:
  - Attack Grid Index overrides
   - AG_MUNO_ATTACK_EXCLUDE
   - AG_MUNO_ATTACK_NAME
   - AG_MUNO_ATTACK_FAF
   - AG_MUNO_ATTACK_ENDLAG
   - AG_MUNO_ATTACK_LANDING_LAG
   - AG_MUNO_ATTACK_MISC
   - AG_MUNO_ATTACK_MISC_ADD
   - AG_MUNO_ATTACK_USES_ROLES

  - Window Grid Index overrides
   - AG_MUNO_WINDOW_EXCLUDE
   - AG_MUNO_WINDOW_ROLE

  - Hitbox Grid Index overrides
   - HG_MUNO_HITBOX_EXCLUDE
   - HG_MUNO_HITBOX_NAME
   - HG_MUNO_HITBOX_ACTIVE
   - HG_MUNO_HITBOX_DAMAGE
   - HG_MUNO_HITBOX_BKB
   - HG_MUNO_HITBOX_KBG
   - HG_MUNO_HITBOX_ANGLE
   - HG_MUNO_HITBOX_PRIORITY
   - HG_MUNO_HITBOX_GROUP
   - HG_MUNO_HITBOX_BHP
   - HG_MUNO_HITBOX_HPG
   - HG_MUNO_HITBOX_MISC
   - HG_MUNO_HITBOX_MISC_ADD

 STRUCTURES:
  - DATAtype (FrameData page Union)
     name: string
     type: int -> [1,2,3] (Union selection)
    DATAtype::1 (Stats Page)
    DATAtype::2 (Move Page)
     index: int (Attack index of this move)
     length: string
     ending_lag: string
     landing_lag: string
     hitboxes: [HBDATAtype] (List of hitbox data)
     num_hitboxes: int ()
     page_starts: [int] (See: Page subsystem)
     timeline: [int] (indexes of windows in the order they should execute)
     misc: string (Additional information)
    DATAtype::3 (Custom Data Page)

  - HBDATAtype (compiled hitbox data strings)
     name: string
     active: string
     damage: string
     base_kb: string
     kb_scale: string
     angle: string
     priority: string
     base_hitpause: string
     hitpause_scale: string
     parent_hbox: int
     misc: string

 DEPENDS ON:
  - phone_common_utils
     decimalToString
*/
//===========================================


//================================================================================
#define initHitbox(move, index)
// Parses attack grid data and assembles the description for one hitbox.
// inserted directly in move.hitboxes.
//================================================================================

var def = "-"; //default value, considered as string-equivalent to "null" for certain functions

var atk_index = move.index;
var parent = get_hitbox_value(atk_index, index, HG_PARENT_HITBOX);
if (parent == index) parent = 0; // Cannot be parent to self

//find active frames
var stored_active = def;
if is_array(move.timeline)
{
    var win = get_hitbox_value(atk_index, index, HG_WINDOW);
    var w_f = get_hitbox_value(atk_index, index, HG_WINDOW_CREATION_FRAME);
    var lif = get_hitbox_value(atk_index, index, HG_LIFETIME);
    var frames_before = 0;
    var has_found = false;
    //Scan forward to find creation frame
    for (var n = 0; n < array_length(move.timeline) && !has_found; n++)
    {
        if (win == move.timeline[n])
        {
            frames_before += w_f;
            has_found = true;
        }
        else
        {
            frames_before += get_window_value(atk_index, move.timeline[n], AG_WINDOW_LENGTH);
        }
    }
    if (has_found)
    {
        stored_active = decimalToString(frames_before + 1);
        //Add lifetime to find last active frame
        if (lif > 1)
        {
            stored_active += "-";
            if (get_hitbox_value(atk_index, index, HG_HITBOX_TYPE) == 1)
            { stored_active += decimalToString(frames_before + lif); }
        }
    }
}
stored_active = pullHitboxValue(atk_index, index, HG_MUNO_HITBOX_ACTIVE, stored_active);

//Basic properties
var stored_damage = pullHitboxValue(atk_index, index, HG_MUNO_HITBOX_DAMAGE, 
                                    pullHitboxValue(atk_index, index, HG_DAMAGE, def));

var stored_base_kb = pullHitboxValue(atk_index, index, HG_MUNO_HITBOX_BKB, 
                                     pullHitboxValue(atk_index, index, HG_BASE_KNOCKBACK, "0"));
if get_hitbox_value(atk_index, index, HG_FINAL_BASE_KNOCKBACK) stored_base_kb += "-" + decimalToString(get_hitbox_value(atk_index, index, HG_FINAL_BASE_KNOCKBACK));

var stored_kb_scale = pullHitboxValue(atk_index, index, HG_MUNO_HITBOX_KBG, 
                                      pullHitboxValue(atk_index, index, HG_KNOCKBACK_SCALING, "0"));

var stored_angle = def;
if get_hitbox_value(atk_index, index, HG_BASE_KNOCKBACK) stored_angle = decimalToString(get_hitbox_value(atk_index, index, HG_ANGLE));
else if get_hitbox_value(atk_index, parent, HG_BASE_KNOCKBACK) stored_angle = decimalToString(get_hitbox_value(atk_index, parent, HG_ANGLE));

var stored_base_hitpause = pullHitboxValue(atk_index, index, HG_MUNO_HITBOX_BHP, 
                                           pullHitboxValue(atk_index, index, HG_BASE_HITPAUSE, "0"));
var stored_hitpause_scale = pullHitboxValue(atk_index, index, HG_MUNO_HITBOX_HPG, 
                                            pullHitboxValue(atk_index, index, HG_HITPAUSE_SCALING, "0"));

//Those two only make sense when a move has multiple hitboxes so default value can be different
var stored_priority = pullHitboxValue(atk_index, index, HG_MUNO_HITBOX_PRIORITY, 
                                      pullHitboxValue(atk_index, index, HG_PRIORITY, (move.num_hitboxes > 1) ? "0" : def));
var stored_group = pullHitboxValue(atk_index, index, HG_MUNO_HITBOX_GROUP, 
                                   pullHitboxValue(atk_index, index, HG_HITBOX_GROUP, (move.num_hitboxes > 1) ? "0" : def));

//Miscellaneous information 
var stored_misc = def;
if (stored_group != def) stored_misc = checkAndAdd(stored_misc, "Group " + stored_group);

// Inherit from parent; so just note parent
if (parent) stored_misc = checkAndAdd(stored_misc, "Parent: Hitbox [NUMBER-SYMBOL]" + string(parent));
else
{
    //Misc. information common strings in array format
    var flipper_desc = [
        "sends at the exact same angle every time",
        "sends away from the center of the user",
        "sends toward the center of the user",
        "horizontal KB sends away from the hitbox center",
        "horizontal KB sends toward the hitbox center",
        "horizontal KB is reversed",
        "horizontal KB sends away from the user",
        "horizontal KB sends toward the user",
        "sends away from the hitbox center",
        "sends toward the hitbox center",
        "sends along the user's movement direction"
    ];
    var effect_desc = ["nothing", "burn", "burn consume", "burn stun", "wrap", "freeze", "mark", 
                        "???", "auto wrap", "polite", "poison", "plasma stun", "crouchable"];
    var ground_desc = ["woag", "Hits only grounded enemies", "Hits only airborne enemies"];
    var tech_desc = ["woag", "Untechable", "Hit enemy goes through platforms", "Untechable, doesn't bounce"];
    var flinch_desc = ["woag", "Forces grounded foes to flinch", "Cannot force flinch", "Forces crouching opponents to flinch"];
    var rock_desc = ["woag", "Throws rocks", "Ignores rocks"];

    //Extract from hitbox
    var flipper = get_hitbox_value(atk_index, index, HG_ANGLE_FLIPPER);
    if (flipper > 0)
        stored_misc = checkAndAdd(stored_misc, "Flipper " + decimalToString(flipper) + " (" + flipper_desc[flipper] + ")");
    if (pullHitboxValue(atk_index, index, HG_EFFECT, def) != def)
        stored_misc = checkAndAdd(stored_misc, "Effect " + decimalToString(get_hitbox_value(atk_index, index, HG_EFFECT)) 
                                  + ((real(pullHitboxValue(atk_index, index, HG_EFFECT, def)) < array_length(effect_desc)) ? 
                                         " (" + effect_desc[real(pullHitboxValue(atk_index, index, HG_EFFECT, def))] + ")" : " (Custom)"));
    if (pullHitboxValue(atk_index, index, HG_EXTRA_HITPAUSE, def) != def)
        stored_misc = checkAndAdd(stored_misc, decimalToString(get_hitbox_value(atk_index, index, HG_EXTRA_HITPAUSE)) + " Extra Hitpause");
    if (pullHitboxValue(atk_index, index, HG_GROUNDEDNESS, def) != def)
        stored_misc = checkAndAdd(stored_misc, ground_desc[real(pullHitboxValue(atk_index, index, HG_GROUNDEDNESS, def))]);
    if (pullHitboxValue(atk_index, index, HG_IGNORES_PROJECTILES, def) != def)
        stored_misc = checkAndAdd(stored_misc, "Cannot break projectiles");
    if (pullHitboxValue(atk_index, index, HG_HIT_LOCKOUT, def) != def)
        stored_misc = checkAndAdd(stored_misc, decimalToString(get_hitbox_value(atk_index, index, HG_HIT_LOCKOUT)) + "f Hit Lockout");
    if (pullHitboxValue(atk_index, index, HG_EXTENDED_PARRY_STUN, def) != def)
        stored_misc = checkAndAdd(stored_misc, "Has extended parry stun");
    if (pullHitboxValue(atk_index, index, HG_HITSTUN_MULTIPLIER, def) != def)
        stored_misc = checkAndAdd(stored_misc, decimalToString(get_hitbox_value(atk_index, index, HG_HITSTUN_MULTIPLIER)) + "x Hitstun");
    if (pullHitboxValue(atk_index, index, HG_DRIFT_MULTIPLIER, def) != def)
        stored_misc = checkAndAdd(stored_misc, decimalToString(get_hitbox_value(atk_index, index, HG_DRIFT_MULTIPLIER)) + "x Drift");
    if (pullHitboxValue(atk_index, index, HG_SDI_MULTIPLIER, def) != def)
        stored_misc = checkAndAdd(stored_misc, decimalToString(get_hitbox_value(atk_index, index, HG_SDI_MULTIPLIER) + 1) + "x SDI");
    if (pullHitboxValue(atk_index, index, HG_TECHABLE, def) != def)
        stored_misc = checkAndAdd(stored_misc, tech_desc[real(pullHitboxValue(atk_index, index, HG_TECHABLE, def))]);
    if (pullHitboxValue(atk_index, index, HG_FORCE_FLINCH, def) != def)
        stored_misc = checkAndAdd(stored_misc, flinch_desc[real(pullHitboxValue(atk_index, index, HG_FORCE_FLINCH, def))]);
    if (pullHitboxValue(atk_index, index, HG_THROWS_ROCK, def) != def)
        stored_misc = checkAndAdd(stored_misc, rock_desc[real(pullHitboxValue(atk_index, index, HG_THROWS_ROCK, def))]);
    if (pullHitboxValue(atk_index, index, HG_PROJECTILE_PARRY_STUN, def) != def)
        stored_misc = checkAndAdd(stored_misc, "Has parry stun");
    if (pullHitboxValue(atk_index, index, HG_PROJECTILE_DOES_NOT_REFLECT, def) != def)
        stored_misc = checkAndAdd(stored_misc, "Does not reflect on parry");
    if (pullHitboxValue(atk_index, index, HG_PROJECTILE_IS_TRANSCENDENT, def) != def)
        stored_misc = checkAndAdd(stored_misc, "Transcendent");
    if (pullHitboxValue(atk_index, index, HG_PROJECTILE_PLASMA_SAFE, def) != def)
        stored_misc = checkAndAdd(stored_misc, "Immune to Clairen's plasma field");
    if (pullHitboxValue(atk_index, index, HG_MUNO_OBJECT_LAUNCH_ANGLE, def) != def)
        stored_misc = checkAndAdd(stored_misc, decimalToString(get_hitbox_value(atk_index, index, HG_MUNO_OBJECT_LAUNCH_ANGLE)) 
                                               + " Workshop Object launch angle");
}

//Miscellaneous override
if (get_hitbox_value(atk_index, index, HG_MUNO_HITBOX_MISC_ADD) != 0)
    stored_misc = checkAndAdd(stored_misc, get_hitbox_value(atk_index, index, HG_MUNO_HITBOX_MISC_ADD));
if (get_hitbox_value(atk_index, index, HG_MUNO_HITBOX_MISC) != 0)
    stored_misc = get_hitbox_value(atk_index, index, HG_MUNO_HITBOX_MISC);

//Name (else, uses "Melee" or "Proj.")
var default_name = (get_hitbox_value(atk_index, index, HG_HITBOX_TYPE) == 1) ? "Melee" : "Proj.";
var stored_name = string(index) + ": " + pullHitboxValue(atk_index, index, HG_MUNO_HITBOX_NAME, default_name);

//Insert into hitboxes array
array_push(move.hitboxes, {
    name: stored_name,
    active: stored_active,
    damage: stored_damage,
    base_kb: stored_base_kb,
    kb_scale: stored_kb_scale,
    angle: stored_angle,
    priority: stored_priority,
    base_hitpause: stored_base_hitpause,
    hitpause_scale: stored_hitpause_scale,
    misc: stored_misc,
    parent_hbox: parent
});


//================================================================================
#define pullAttackValue(atk_index, index, def)
// returns move's value of index if it is a string, otherwise returns def.
//================================================================================
var value = get_attack_value(atk_index, index);
return is_string(value) ? value : def;


//================================================================================
#define pullHitboxValue(atk_index, hbox, index, def)
// returns atk_index's hbox's data value of index (converted to string as necessary).
// if it is zero, returns def instead. considers HG_PARENT_HITBOX inheritance.
//================================================================================
if (get_hitbox_value(atk_index, hbox, HG_PARENT_HITBOX) != 0) 
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
        if (index < 70) hbox = get_hitbox_value(atk_index, hbox, HG_PARENT_HITBOX);
        break;
}

var value = get_hitbox_value(atk_index, hbox, index);
//convert to string
if (value != 0) || is_string(value) return decimalToString(value);
else return string(def);


//================================================================================
#define checkAndAdd(orig, add)
// concatenates strings using separators.
// inserts line breaks automatically if it doesnt fit a full line.
//================================================================================
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
