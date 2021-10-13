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
  - DATAPAGEtype (FrameData page Union)
     name: string
     type: int -> [1,2,3] (Union selection)
    DATAPAGEtype::1 (Stats Page)
    DATAPAGEtype::2 (Move Page)
     index: int (Attack index of this move)
     length: string
     ending_lag: string
     landing_lag: string
     hitboxes: [HBDATAtype] (List of hitbox data)
     num_hitboxes: int ()
     page_starts: [int] (See: Page subsystem)
     timeline: [int] (indexes of windows in the order they should execute, used for startup/active/endlag calcultions)
     misc: string (Additional information)
    DATAPAGEtype::3 (Custom Data Page)

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
  - phone.data: [DATAPAGEtype]
  - phone_common_utils
     decimalToString
  - AG_MUNO_WINDOW_INVUL
  - AG_MUNO_ATTACK_COOLDOWN

ORIGINAL DOCUMENTATION:
  General Attack Indexes - frame data correction

  AG_MUNO_ATTACK_EXCLUDE
    Set to 1 to exclude this move from the list of moves
  AG_MUNO_ATTACK_NAME
    Enter a string to override the move's name in the attack list
  AG_MUNO_ATTACK_FAF
    Enter a string to override FAF
  AG_MUNO_ATTACK_ENDLAG
    Enter a string to override endlag
  AG_MUNO_ATTACK_LANDING_LAG
    Enter a string to override landing lag
  AG_MUNO_ATTACK_MISC
    Enter a string to OVERRIDE the move's "Notes" section, which automatically
    includes the Cooldown System and Misc. Window Traits found below
  AG_MUNO_ATTACK_MISC_ADD
    Enter a string to ADD TO the move's "Notes" section (preceded by the auto-
    generated one, then a line break)

  P.S. Adding Notes to a move is good for if a move requires a long explanation of
    the data, or if a move overall has certain behavior that should be listed, such
    as a manually coded cancel window.

  General Window Indexes - frame data correction

  AG_MUNO_WINDOW_EXCLUDE
    0: include window in timeline (default)
    1: exclude window from timeline
    2: exclude window from timeline, only for the on-hit time
    3: exclude window from timeline, only for the on-whiff time
  AG_MUNO_WINDOW_ROLE
    0: none (acts identically to AG_MUNO_WINDOW_EXCLUDE = 1)
    1: startup
    2: active (or IN BETWEEN active frames, eg between multihits)
    3: endlag
  AG_MUNO_ATTACK_USES_ROLES
    Must be set to 1 for AG_MUNO_WINDOW_ROLE to take effect

  P.S. If your move's windows are structured non-linearly, you can use
    AG_MUNO_WINDOW_ROLE to force the frame data system to parse the window order
    correctly (to a certain extent).

  General Hitbox Indexes - frame data correction

  HG_MUNO_HITBOX_EXCLUDE
    Set to 1 to exclude this hitbox from the frame data guide
  HG_MUNO_HITBOX_NAME
    Enter a string to override the hitbox's name, very useful if the move has
    multiple hitboxes

  HG_MUNO_HITBOX_ACTIVE
    Enter a string to override active frames
  HG_MUNO_HITBOX_DAMAGE
    Enter a string to override damage
  HG_MUNO_HITBOX_BKB
    Enter a string to override base knockback
  HG_MUNO_HITBOX_KBG
    Enter a string to override knockback growth
  HG_MUNO_HITBOX_ANGLE
    Enter a string to override angle
  HG_MUNO_HITBOX_PRIORITY
    Enter a string to override priority
  HG_MUNO_HITBOX_GROUP
    Enter a string to override group
  HG_MUNO_HITBOX_BHP
    Enter a string to override base hitpause
  HG_MUNO_HITBOX_HPG
    Enter a string to override hitpause scaling
  HG_MUNO_HITBOX_MISC
    Enter a string to override the auto-generated misc notes (which include misc
    properties like angle flipper or elemental effect)
  HG_MUNO_HITBOX_MISC_ADD
    Enter a string to ADD TO the auto-generated misc notes, not override (line
    break will be auto-inserted)

*/
//===========================================

//=======================================================================================
#define initStats
// Reserves a page for general character stats
//=======================================================================================
array_push(phone.data, {
    name: "Stats",
    type: 1 // stats
});

//=======================================================================================
#define initCustom
// Reserves a page for special character stats
//=======================================================================================
array_push(phone.data, {
    name: phone.custom_name,
    type: 3 // custom
});

//=======================================================================================
#define initMove(atk_index, default_move_name)
// Parses Attack grid data and assembles a data page for one move.
// Inserts this page into the phone.data array.
//=======================================================================================

var def = "-"; //default value, considered as string-equivalent to "null" for certain functions
var stored_name = pullAttackValue(atk_index, AG_MUNO_ATTACK_NAME, default_move_name);

var stored_timeline = [];
if get_attack_value(atk_index, AG_MUNO_ATTACK_USES_ROLES)
{
    for (var n = 0; get_window_value(atk_index, n+1, AG_WINDOW_LENGTH); n++)
    {
        if get_window_value(atk_index, n+1, AG_MUNO_WINDOW_ROLE) 
            stored_timeline[array_length(stored_timeline)] = n+1;
    }
}
else if get_attack_value(atk_index, AG_NUM_WINDOWS) 
{
    for (var n = 0; n < get_attack_value(atk_index, AG_NUM_WINDOWS); n++)
    {
        if !(get_window_value(atk_index, n+1, AG_MUNO_WINDOW_EXCLUDE) == 1)
            stored_timeline[array_length(stored_timeline)] = n+1;
    }
}
else
{
    stored_timeline = noone;
}

var stored_length = def;
if is_array(stored_timeline)
{
    stored_length = 0;
    for (var n = 0; n < array_length(stored_timeline); n++)
    {
        if (get_window_value(atk_index, stored_timeline[n], AG_MUNO_WINDOW_EXCLUDE) != 2) 
            stored_length += get_window_value(atk_index, stored_timeline[n], AG_WINDOW_LENGTH);
    }
    var stored_length_w = 0;
    for (var n = 0; n < array_length_1d(stored_timeline); n++)
    {
        if (get_window_value(atk_index, stored_timeline[n], AG_MUNO_WINDOW_EXCLUDE) != 3) 
            stored_length_w += ceil( get_window_value(atk_index, stored_timeline[n], AG_WINDOW_LENGTH) 
                                  * (get_window_value(atk_index, stored_timeline[n], AG_WINDOW_HAS_WHIFFLAG) ? 1.5 : 1) );
    }
    //If there's no whifflag, don't include second number
    stored_length = decimalToString(stored_length);
    if (stored_length != stored_length_w) 
        stored_length += " (" + decimalToString(stored_length_w) + ")";
}
stored_length = pullAttackValue(atk_index, AG_MUNO_ATTACK_FAF, stored_length);

var stored_ending_lag = def;
if (is_array(stored_timeline))
{
    var time_int = 0;
    var time_int_whiff = 0;
    if get_attack_value(atk_index, AG_MUNO_ATTACK_USES_ROLES)
    {
        for (var n = 0; n < array_length(stored_timeline); n++)
        {
            if (get_window_value(atk_index, stored_timeline[n], AG_MUNO_WINDOW_ROLE) == 3)
            {
                if (get_window_value(atk_index, stored_timeline[n], AG_MUNO_WINDOW_EXCLUDE) != 2) 
                    time_int += get_window_value(atk_index, stored_timeline[n], AG_WINDOW_LENGTH);

                if (get_window_value(atk_index, stored_timeline[n], AG_MUNO_WINDOW_EXCLUDE) != 3) 
                    time_int_whiff += ceil( get_window_value(atk_index, stored_timeline[n], AG_WINDOW_LENGTH) 
                                         * (get_window_value(atk_index, stored_timeline[n], AG_WINDOW_HAS_WHIFFLAG) ? 1.5 : 1) );
            }
        }
    }
    else
    {
        for (var n = 0; n < array_length(stored_timeline); n++)
        {
            var last_hitbox_frame = 0;
            var test_me = 0;
            for (var hh = 0; get_hitbox_value(atk_index, hh, HG_HITBOX_TYPE); hh++)
            {
                if (get_hitbox_value(atk_index, hh, HG_WINDOW) == stored_timeline[n])
                {
                    test_me = get_hitbox_value(atk_index, hh, HG_LIFETIME) 
                            + get_hitbox_value(atk_index, hh, HG_WINDOW_CREATION_FRAME);

                    if (get_hitbox_value(atk_index, hh, HG_HITBOX_TYPE) == 2) test_me = -1;
                    if (abs(test_me) > last_hitbox_frame) last_hitbox_frame = test_me;
                }
            }
            if (last_hitbox_frame > 0)
            {
                if (get_window_value(atk_index, stored_timeline[n], AG_MUNO_WINDOW_EXCLUDE) != 2) 
                    time_int = get_window_value(atk_index, stored_timeline[n], AG_WINDOW_LENGTH) - last_hitbox_frame;

                if (get_window_value(atk_index, stored_timeline[n], AG_MUNO_WINDOW_EXCLUDE) != 3) 
                    time_int_whiff = ceil( get_window_value(atk_index, stored_timeline[n], AG_WINDOW_LENGTH) 
                                        * (get_window_value(atk_index, stored_timeline[n], AG_WINDOW_HAS_WHIFFLAG) ? 1.5 : 1) - last_hitbox_frame);
            }
            else if (last_hitbox_frame == -1) // projectile
            {
                if (get_window_value(atk_index, stored_timeline[n], AG_MUNO_WINDOW_EXCLUDE) != 2)
                    time_int = get_window_value(atk_index, stored_timeline[n], AG_WINDOW_LENGTH);

                if (get_window_value(atk_index, stored_timeline[n], AG_MUNO_WINDOW_EXCLUDE) != 3)
                    time_int_whiff = ceil( get_window_value(atk_index, stored_timeline[n], AG_WINDOW_LENGTH) 
                                        * (get_window_value(atk_index, stored_timeline[n], AG_WINDOW_HAS_WHIFFLAG) ? 1.5 : 1) );
            }
            else
            {
                if (get_window_value(atk_index, stored_timeline[n], AG_MUNO_WINDOW_EXCLUDE) != 2) 
                    time_int += get_window_value(atk_index, stored_timeline[n], AG_WINDOW_LENGTH);

                if (get_window_value(atk_index, stored_timeline[n], AG_MUNO_WINDOW_EXCLUDE) != 3) 
                    time_int_whiff += ceil( get_window_value(atk_index, stored_timeline[n], AG_WINDOW_LENGTH) 
                                         * (get_window_value(atk_index, stored_timeline[n], AG_WINDOW_HAS_WHIFFLAG) ? 1.5 : 1) );
            }
        }
    }
    
    if (time_int) && (decimalToString(time_int) != stored_length)
    {
        //If there's no whifflag, don't include second number
        stored_ending_lag = decimalToString(time_int);
        if (time_int != time_int_whiff) 
        stored_ending_lag += " (" + decimalToString(time_int_whiff) + ")";
    }
}
stored_ending_lag = pullAttackValue(atk_index, AG_MUNO_ATTACK_ENDLAG, stored_ending_lag);

//Landing Lag
var stored_landing_lag = def;
if (get_attack_value(atk_index, AG_HAS_LANDING_LAG) 
    && get_attack_value(atk_index, AG_CATEGORY) == 1)
{
    stored_landing_lag = decimalToString(get_attack_value(atk_index, AG_LANDING_LAG));
    if (get_attack_value(atk_index, AG_LANDING_LAG)) 
        stored_landing_lag += " (" + decimalToString(ceil(get_attack_value(atk_index, AG_LANDING_LAG) * 1.5)) + ")";
}
stored_landing_lag = pullAttackValue(atk_index, AG_MUNO_ATTACK_LANDING_LAG, stored_landing_lag);

//Miscellaneous information
var stored_misc = def;

// Misc: Charge frame
if (get_attack_value(atk_index, AG_STRONG_CHARGE_WINDOW) != 0)
{
    var found = false;
    var strong_charge_frame = 0;
    //iterate through timeline to add up frames
    for (var n = 0; n < array_length(stored_timeline) && !found; n++)
    {
        strong_charge_frame += ceil( get_window_value(atk_index, stored_timeline[n], AG_WINDOW_LENGTH) 
                                  * (get_window_value(atk_index, stored_timeline[n], AG_WINDOW_HAS_WHIFFLAG) ? 1.5 : 1) );
        if (stored_timeline[n] == get_attack_value(atk_index, AG_STRONG_CHARGE_WINDOW))
        {
            found = true; break;
        }
    }
    if (found)
    {
        stored_misc = checkAndAdd(stored_misc, "Charge frame: " + decimalToString(strong_charge_frame));
    }
}

//Misc: Invulnerability type
//[DEV FEATURE]
if is_array(stored_timeline)
{
    var total_frames = 0;
    for (var n = 0; n < array_length(stored_timeline); n++)
    {
        var frames = string(total_frames + 1) + "-" 
                   + string(total_frames + get_window_value(atk_index, stored_timeline[n], AG_WINDOW_LENGTH));
        switch (get_window_value(atk_index, stored_timeline[n], AG_MUNO_WINDOW_INVUL)){
            case -1:
                stored_misc = checkAndAdd(stored_misc, "Invincible f" + frames);
                break;
            case -2:
                stored_misc = checkAndAdd(stored_misc, "Super Armor f" + frames);
                break;
            case 0:
                break;
            default:
                var soft_armor = get_window_value(atk_index, stored_timeline[n], AG_MUNO_WINDOW_INVUL);
                stored_misc = checkAndAdd(stored_misc, string(soft_armor) + " Soft Armor f" + frames);
                break;
        }
        total_frames += get_window_value(atk_index, stored_timeline[n], AG_WINDOW_LENGTH);
    }
}

//Misc: Cooldown
//[DEV FEATURE]
if (get_attack_value(atk_index, AG_MUNO_ATTACK_COOLDOWN) != 0)
{
    stored_misc = checkAndAdd(stored_misc, "Cooldown: " 
                  + string(abs(get_attack_value(atk_index, AG_MUNO_ATTACK_COOLDOWN))) + "f" 
                  + ((get_attack_value(atk_index, AG_MUNO_ATTACK_COOLDOWN) > 0) ? "" : " until land/walljump/hit"));
}

//Misc: Additional info
if (get_attack_value(atk_index, AG_MUNO_ATTACK_MISC_ADD) != 0)
{ stored_misc = checkAndAdd(stored_misc, get_attack_value(atk_index, AG_MUNO_ATTACK_MISC_ADD)); }
//Misc override
if (get_attack_value(atk_index, AG_MUNO_ATTACK_MISC) != 0)
{ stored_misc = get_attack_value(atk_index, AG_MUNO_ATTACK_MISC); }

//Insert into move array
var current_move = {
    type: 2, // an actual move
    index: atk_index,
    name: stored_name,
    length: stored_length,
    ending_lag: stored_ending_lag,
    landing_lag: stored_landing_lag,
    hitboxes: [], //filled below
    page_starts: [0],
    num_hitboxes: get_num_hitboxes(atk_index),
    timeline: stored_timeline,
    misc: stored_misc
};
array_push(phone.data, current_move);

//parse through all hitboxes of this attack and register them
for (var hb = 1; get_hitbox_value(atk_index, hb, HG_HITBOX_TYPE); hb++)
{
    if !get_hitbox_value(atk_index, hb, HG_MUNO_HITBOX_EXCLUDE)
    { initHitbox(current_move, hb); }
}

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
