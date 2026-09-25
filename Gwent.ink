/*
@title Knucklebones
@author TheUltimateCarthaginian
*/

// Match State
VAR player_gems = 2
VAR ai_gems = 2
VAR leader_available = 1

// Round State
VAR player_passed = 0
VAR ai_passed = 0

// Active Weather
VAR weather_frost = 0  // Affects Melee
VAR weather_fog = 0    // Affects Ranged
VAR weather_rain = 0   // Affects Siege

// Player Row Horns (1 = Active)
VAR p_horn_melee = 0
VAR p_horn_ranged = 0
VAR p_horn_siege = 0

// Player Board Unit Counts (For Weather)
VAR p_count_melee = 0
VAR p_count_ranged = 0
VAR p_count_siege = 0

// Player Board Base Values (Non-Hero)
VAR p_base_melee = 0
VAR p_base_ranged = 0
VAR p_base_siege = 0

// Player Board Hero Totals
VAR p_hero_melee = 0
VAR p_hero_ranged = 0
VAR p_hero_siege = 0

// Player Row Calculated Totals
VAR p_melee = 0
VAR p_ranged = 0
VAR p_siege = 0
VAR p_total = 0

// AI Board State
VAR ai_horn_siege = 0
VAR ai_count_melee = 0
VAR ai_count_ranged = 0
VAR ai_count_siege = 0
VAR ai_base_melee = 0
VAR ai_base_ranged = 0
VAR ai_base_siege = 0
VAR ai_hero_melee = 0
VAR ai_hero_ranged = 0
VAR ai_hero_siege = 0
VAR ai_cards_left = 7
VAR ai_has_horn = 1
VAR ai_has_frost = 1

VAR ai_melee = 0
VAR ai_ranged = 0
VAR ai_siege = 0
VAR ai_total = 0

// Player Hand Flags (1 = in hand, 0 = not in hand)
VAR hand_geralt = 1    // Melee Hero 15
VAR hand_ciri = 1      // Melee Hero 15
VAR hand_yen = 1       // Ranged Hero 10
VAR hand_roche = 1     // Melee Hero 10
VAR hand_vesemir = 1   // Melee 6
VAR hand_archer = 1    // Ranged 6
VAR hand_trebuchet = 1 // Siege 6
VAR hand_spy = 1       // Spy Melee 1 (+2 cards draw)
VAR hand_frost = 1     // Weather Frost
VAR hand_fog = 0       // Weather Fog (Starts in deck/reserve)
VAR hand_rain = 0      // Weather Rain (Starts in deck/reserve)
VAR hand_horn = 1      // Commander's Horn

// Reserve Deck Flags (Unplayed Cards to Draw via Spy/Redraw)
VAR reserve_fog = 1
VAR reserve_rain = 1
VAR reserve_foot_soldier = 1

VAR redraws_left = 2

-> game_menu

== game_menu ==
--------------------------------
         GWENT For EENK       
--------------------------------

+ [Start Game]
    ~ player_gems = 2
    ~ ai_gems = 2
    ~ leader_available = 1
    -> mulligan_phase
+ [View Controls]
    -> show_controls

== show_controls ==
CONTROLS:
- UP: Use Leader Ability
- DOWN: Pass Round
- OK: Play Selected Card
- BACK: Toggle Board / Cards View

+ [Back to Menu]
    -> game_menu

== mulligan_phase ==
--------------------------------
         REDRAW PHASE           
--------------------------------
Redraws remaining: {redraws_left}

Select a card to redraw:

{redraws_left > 0:
    + {hand_frost == 1} Redraw Biting Frost
        ~ hand_frost = 0
        ~ hand_fog = 1
        ~ redraws_left = redraws_left - 1
        -> mulligan_phase
    + {hand_vesemir == 1} Redraw Vesemir
        ~ hand_vesemir = 0
        ~ hand_rain = 1
        ~ redraws_left = redraws_left - 1
        -> mulligan_phase
    + {hand_archer == 1} Redraw Archer
        ~ hand_archer = 0
        ~ reserve_foot_soldier = 0
        ~ hand_horn = 1
        ~ redraws_left = redraws_left - 1
        -> mulligan_phase
}

+ Keep Hand and Start Match
    -> start_round

== start_round ==
~ player_passed = 0
~ ai_passed = 0

~ p_count_melee = 0
~ p_count_ranged = 0
~ p_count_siege = 0
~ p_base_melee = 0
~ p_base_ranged = 0
~ p_base_siege = 0
~ p_hero_melee = 0
~ p_hero_ranged = 0
~ p_hero_siege = 0
~ p_horn_melee = 0
~ p_horn_ranged = 0
~ p_horn_siege = 0

~ ai_count_melee = 0
~ ai_count_ranged = 0
~ ai_count_siege = 0
~ ai_base_melee = 0
~ ai_base_ranged = 0
~ ai_base_siege = 0
~ ai_hero_melee = 0
~ ai_hero_ranged = 0
~ ai_hero_siege = 0
~ ai_horn_siege = 0

~ weather_frost = 0
~ weather_fog = 0
~ weather_rain = 0

-> recalculate_scores

== recalculate_scores ==
// Recalculate Player Melee
{weather_frost == 1:
    ~ p_melee = p_count_melee + p_hero_melee
    ~ ai_melee = ai_count_melee + ai_hero_melee
}
{weather_frost == 0:
    ~ p_melee = p_base_melee + p_hero_melee
    ~ ai_melee = ai_base_melee + ai_hero_melee
}
{p_horn_melee == 1 and weather_frost == 0:
    ~ p_melee = (p_base_melee * 2) + p_hero_melee
}

// Recalculate Player Ranged
{weather_fog == 1:
    ~ p_ranged = p_count_ranged + p_hero_ranged
    ~ ai_ranged = ai_count_ranged + ai_hero_ranged
}
{weather_fog == 0:
    ~ p_ranged = p_base_ranged + p_hero_ranged
    ~ ai_ranged = ai_base_ranged + ai_hero_ranged
}
{p_horn_ranged == 1 and weather_fog == 0:
    ~ p_ranged = (p_base_ranged * 2) + p_hero_ranged
}

// Recalculate Player Siege
{weather_rain == 1:
    ~ p_siege = p_count_siege + p_hero_siege
    ~ ai_siege = ai_count_siege + ai_hero_siege
}
{weather_rain == 0:
    ~ p_siege = p_base_siege + p_hero_siege
    ~ ai_siege = ai_base_siege + ai_hero_siege
}
{p_horn_siege == 1 and weather_rain == 0:
    ~ p_siege = (p_base_siege * 2) + p_hero_siege
}
{ai_horn_siege == 1 and weather_rain == 0:
    ~ ai_siege = (ai_base_siege * 2) + ai_hero_siege
}

// Totals
~ p_total = p_melee + p_ranged + p_siege
~ ai_total = ai_melee + ai_ranged + ai_siege

{player_passed == 1 and ai_passed == 1:
    -> resolve_round
}

{player_passed == 1:
    -> ai_turn
}

-> play_turn

== board_overview ==
--------------------------------
          BOARD OVERVIEW        
--------------------------------
AI Gems: {ai_gems}
AI Total Score: {ai_total}
Melee: {ai_melee} / Ranged: {ai_ranged} / Siege: {ai_siege}
AI Status: {ai_passed == 1: PASSED}
--------------------------------
Active Weather:
{weather_frost == 1: FROST}
{weather_fog == 1: FOG}
{weather_rain == 1: RAIN}
{weather_frost == 0 and weather_fog == 0 and weather_rain == 0: CLEAR}
--------------------------------
Your Gems: {player_gems}
Your Total Score: {p_total}
Melee: {p_melee} / Ranged: {p_ranged} / Siege: {p_siege}
Your Status: {player_passed == 1: PASSED}
--------------------------------

+ Return to Hand
    -> play_turn
+ Pass Round
    ~ player_passed = 1
    You passed the round.
    -> recalculate_scores

== play_turn ==
{player_gems <= 0:
    -> game_over_defeat
}
{ai_gems <= 0:
    -> game_over_victory
}

Your Score: {p_total}
AI Score: {ai_total}

Choose card to play:

+ {hand_geralt == 1} Play GERALT - Melee Hero 15
    ~ hand_geralt = 0
    ~ p_hero_melee = p_hero_melee + 15
    You played Geralt to Melee Row.
    -> ai_turn

+ {hand_ciri == 1} Play CIRI - Melee Hero 15
    ~ hand_ciri = 0
    ~ p_hero_melee = p_hero_melee + 15
    You played Ciri to Melee Row.
    -> ai_turn

+ {hand_yen == 1} Play YENNEFER - Ranged Hero 10
    ~ hand_yen = 0
    ~ p_hero_ranged = p_hero_ranged + 10
    You played Yennefer to Ranged Row.
    -> ai_turn

+ {hand_roche == 1} Play VERNON ROCHE - Melee Hero 10
    ~ hand_roche = 0
    ~ p_hero_melee = p_hero_melee + 10
    You played Vernon Roche to Melee Row.
    -> ai_turn

+ {hand_vesemir == 1} Play VESEMIR - Melee 6
    ~ hand_vesemir = 0
    ~ p_count_melee = p_count_melee + 1
    ~ p_base_melee = p_base_melee + 6
    You played Vesemir (6).
    -> ai_turn

+ {hand_archer == 1} Play ARCHER - Ranged 6
    ~ hand_archer = 0
    ~ p_count_ranged = p_count_ranged + 1
    ~ p_base_ranged = p_base_ranged + 6
    You played Archer (6).
    -> ai_turn

+ {hand_trebuchet == 1} Play TREBUCHET - Siege 6
    ~ hand_trebuchet = 0
    ~ p_count_siege = p_count_siege + 1
    ~ p_base_siege = p_base_siege + 6
    You played Trebuchet (6).
    -> ai_turn

+ {hand_spy == 1} Play THALER - Spy Melee 1
    ~ hand_spy = 0
    ~ ai_count_melee = ai_count_melee + 1
    ~ ai_base_melee = ai_base_melee + 1
    // Spy Effect: Draw reserve cards
    {reserve_fog == 1:
        ~ hand_fog = 1
        ~ reserve_fog = 0
    }
    {reserve_rain == 1:
        ~ hand_rain = 1
        ~ reserve_rain = 0
    }
    You played Thaler (+1 to AI Melee). SPY EFFECT: Drew 2 cards from your deck!
    -> ai_turn

+ {hand_frost == 1} Play BITING FROST
    ~ hand_frost = 0
    ~ weather_frost = 1
    You played Biting Frost.
    -> ai_turn

+ {hand_fog == 1} Play IMPENETRABLE FOG
    ~ hand_fog = 0
    ~ weather_fog = 1
    You played Impenetrable Fog.
    -> ai_turn

+ {hand_rain == 1} Play TORRENTIAL RAIN
    ~ hand_rain = 0
    ~ weather_rain = 1
    You played Torrential Rain.
    -> ai_turn

+ {hand_horn == 1} Play COMMANDER HORN on Ranged Row
    ~ hand_horn = 0
    ~ p_horn_ranged = 1
    You boosted your non-hero Ranged units!
    -> ai_turn

+ {leader_available == 1} Use Leader Ability - Clear Weather
    ~ leader_available = 0
    ~ weather_frost = 0
    ~ weather_fog = 0
    ~ weather_rain = 0
    Leader Ability Activated: Weather cleared! (Ability spent)
    -> ai_turn

+ View Board State
    -> board_overview

+ Pass Round
    ~ player_passed = 1
    You passed the round.
    -> recalculate_scores

== ai_turn ==
{ai_passed == 1:
    -> recalculate_scores
}

// Ensure scores reflect player's move immediately
// (Recalculate logic inline before making decision)
{weather_frost == 1:
    ~ p_melee = p_count_melee + p_hero_melee
    ~ ai_melee = ai_count_melee + ai_hero_melee
}
{weather_frost == 0:
    ~ p_melee = p_base_melee + p_hero_melee
    ~ ai_melee = ai_base_melee + ai_hero_melee
}
{p_horn_melee == 1 and weather_frost == 0:
    ~ p_melee = (p_base_melee * 2) + p_hero_melee
}
{weather_fog == 1:
    ~ p_ranged = p_count_ranged + p_hero_ranged
    ~ ai_ranged = ai_count_ranged + ai_hero_ranged
}
{weather_fog == 0:
    ~ p_ranged = p_base_ranged + p_hero_ranged
    ~ ai_ranged = ai_base_ranged + ai_hero_ranged
}
{p_horn_ranged == 1 and weather_fog == 0:
    ~ p_ranged = (p_base_ranged * 2) + p_hero_ranged
}
{weather_rain == 1:
    ~ p_siege = p_count_siege + p_hero_siege
    ~ ai_siege = ai_count_siege + ai_hero_siege
}
{weather_rain == 0:
    ~ p_siege = p_base_siege + p_hero_siege
    ~ ai_siege = ai_base_siege + ai_hero_siege
}
{p_horn_siege == 1 and weather_rain == 0:
    ~ p_siege = (p_base_siege * 2) + p_hero_siege
}
{ai_horn_siege == 1 and weather_rain == 0:
    ~ ai_siege = (ai_base_siege * 2) + ai_hero_siege
}
~ p_total = p_melee + p_ranged + p_siege
~ ai_total = ai_melee + ai_ranged + ai_siege

// AI Passes if out of cards
{ai_cards_left <= 0:
    ~ ai_passed = 1
    AI has no cards left and passed!
    -> recalculate_scores
}

// AI Passes if player passed and AI is strictly winning
{player_passed == 1 and ai_total > p_total:
    ~ ai_passed = 1
    AI is ahead and passes the round!
    -> recalculate_scores
}

// AI STRICTLY TAKES EXACTLY ONE ACTION PER TURN
{p_melee > 10 and weather_frost == 0 and ai_has_frost == 1:
    ~ weather_frost = 1
    ~ ai_has_frost = 0
    ~ ai_cards_left = ai_cards_left - 1
    AI plays Biting Frost!
    -> recalculate_scores
- else:
    {ai_total < p_total and ai_base_siege > 8 and ai_has_horn == 1:
        ~ ai_horn_siege = 1
        ~ ai_has_horn = 0
        ~ ai_cards_left = ai_cards_left - 1
        AI plays Commander Horn on Siege row!
        -> recalculate_scores
    - else:
        {weather_frost == 0 and ai_cards_left % 2 == 0:
            ~ ai_count_melee = ai_count_melee + 1
            ~ ai_base_melee = ai_base_melee + 5
            ~ ai_cards_left = ai_cards_left - 1
            AI plays Fiend (Melee 5).
            -> recalculate_scores
        - else:
            ~ ai_count_siege = ai_count_siege + 1
            ~ ai_base_siege = ai_base_siege + 8
            ~ ai_cards_left = ai_cards_left - 1
            AI plays Catapult (Siege 8).
            -> recalculate_scores
        }
    }
}

== resolve_round ==
--------------------------------
         ROUND OVER             
--------------------------------

{p_total > ai_total:
    ~ ai_gems = ai_gems - 1
    YOU WON THE ROUND! ({p_total} vs {ai_total})
}
{ai_total > p_total:
    ~ player_gems = player_gems - 1
    AI WON THE ROUND! ({ai_total} vs {p_total})
}
{p_total == ai_total:
    ~ player_gems = player_gems - 1
    ~ ai_gems = ai_gems - 1
    ROUND TIED! BOTH PLAYERS LOSE A GEM! ({p_total} vs {ai_total})
}

+ Next Round
    -> start_round

== game_over_victory ==
--------------------------------
           GAME OVER            
--------------------------------
RESULT: VICTORY!

Final Score:
Player Gems: {player_gems}
AI Gems: {ai_gems}

+ Main Menu
    -> game_menu

== game_over_defeat ==
--------------------------------
           GAME OVER            
--------------------------------
RESULT: DEFEAT!

Final Score:
Player Gems: {player_gems}
AI Gems: {ai_gems}

+ Main Menu
    -> game_menu