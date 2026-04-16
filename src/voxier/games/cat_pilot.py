#!/usr/bin/env python3
import os, random

def clear():
    os.system('cls' if os.name == 'nt' else 'clear')

def title():
    clear()
    print(r"""
      _n_     ___   ___   ___   ___   ___   ___   ___   ___ 
     ( _{_}  |_|  |_|  |_|  |_|  |_|  |_|  |_|  |_|
     / / \  _|_   |_|  |_|  |_|  |_|  |_|  |_|  |_|
    (__\_) |___| |___| |___| |___| |___| |___| |___|
                                                    
   ██████╗ ██████╗ ██╗██████╗ ███████╗ ██████╗ ███████╗██╗  ██╗
  ██╔════╝██╔═══██╗██║██╔══██╗██╔════╝██╔═══██╗██╔════╝██║  ██║
  ██║    ██║  ██║██║██████╔╝█████╗  ██║  ██║█████╗  ███████║
  ██║    ██║  ██║██║██╔══██╗██╔══╝  ██║  ██║██╔══╝  ██╔══██║
  ╚██████╗╚██████╔╝██║██║  ██║███████╗╚██████╔╝██║     ██║  ██║
   ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝  ╚═╝

                 <>‿‿‿‿‿‿‿‿‿‿‿‿‿‿‿<>
               < HOW DEEP CAN U GO? >
                 `‿‿‿‿‿‿‿‿‿‿‿‿‿‿´

                      [1] START MISSION
                      [2] SELECT LEVEL
                      [3] HOW TO PLAY
                      [Q] QUIT GAME
""")
    return input("SELECT: ").strip().upper()

def levels():
    clear()
    print(r"""
╔═══════════════════════════════════════════════════════════════════════╗
║                    ★ MISSION SELECTOR ★                        ║
╚═════════════════════════════════════════════════════════════════════╝

    [1] LEVEL 1 - NEBULA DRIFT       ★☆☆☆☆ EASY
         Just a few asteroids. Easy going.

    [2] LEVEL 2 - ASTEROID BELT     ★★☆☆☆ NORMAL
         More rocks. Dodging gets tricky.

    [3] LEVEL 3 - ALIEN SWARM        ★★★☆☆ HARD
         Asteroids AND hostile aliens!

    [4] LEVEL 4 - METEOR STORM     ★★★★☆ EPIC
         Fast objects from all directions!

    [5] LEVEL 5 - VOID ZONE       ★★★★★ IMPOSSIBLE
         EVERYTHING flies at you!

    [B] BACK
""")
    c = input("SELECT: ").strip().upper()
    if c in "12345":
        return int(c)
    return None

def help_():
    clear()
    print(r"""
╔═══════════════════════════════════════════════════════════════════════╗
║                    ★ MISSION BRIEFING ★                          ║
╚═══════════════════════════════════════════════════════════════════════╝

  HOW TO PLAY:
  ───────────
  Each turn, objects fall from the sky!
  
  Type [L] to move LEFT
  Type [R] to move RIGHT  
  Type [Q] to abort mission

  GOAL:
  ────
  Dodge all incoming debris!
  Survive 20 turns to complete a level.

  SCORING:
  ───────
  +10 points per dodge
  +100 bonus for level completion

  GOOD LUCK, SPACEKITTY!
  ═════════════
      ||
     /||\
    //||\\
   ///||\\
  ////||\\\\
     CAT
""")
    input("\n[PRESS ENTER]")

LEVELS = {
    1: {"name": "Nebula Drift", "chance": 0.25, "types": ["asteroid"]},
    2: {"name": "Asteroid Belt", "chance": 0.35, "types": ["asteroid"]},
    3: {"name": "Alien Swarm", "chance": 0.45, "types": ["asteroid", "alien"]},
    4: {"name": "Meteor Storm", "chance": 0.55, "types": ["asteroid", "alien", "star"]},
    5: {"name": "VOID ZONE", "chance": 0.7, "types": ["asteroid", "alien", "star", "boss"]},
}

def draw_board(px, objs, score, lvl_nm, turn):
    clear()
    lvl_bar = "█" * (turn * 5) + "░" * (100 - turn * 5)
    
    print("╔" + "═"*58 + "╗")
    print("║★ C.A.T. PILOT ★" + lvl_nm[:20].center(30) + f"SCORE:{score:>4} ║")
    print("╠" + "═"*58 + "╣")
    
    for y in range(15):
        line = "║"
        if y == 13:
            lr = "< " if px < 25 else "> "
            line = "║ " + lr + "🐱 "
            line += "─" * px + "🚀"
        else:
            for x in range(56):
                hit = False
                for ox, oy, ot in objs:
                    if ox == x and oy == y:
                        if ot == "asteroid": line += "●"
                        elif ot == "alien": line += "✖"
                        elif ot == "star": line += "✦"
                        elif ot == "boss": line += "§"
                        else: line += "o"
                        hit = True
                        break
                if not hit:
                    line += "·"
        line = line[:56] + " ║"
        print(line)
    
    print("╠" + "═"*58 + "╣")
    print("║ [L] LEFT | [R] RIGHT | [Q] ABORT ║")
    print("╚" + "═"*58 + "╝")
    print(f" TURN:{turn}/20 | POS:{px} | PROGRESS:{lvl_bar[:20]}")

def game(lvl_num):
    lvl = LEVELS[lvl_num]
    score = 0
    px = 25
    objs = []
    turn = 0
    
    while turn < 20:
        turn += 1
        draw_board(px, objs, score, lvl["name"], turn)
        
        if random.random() < lvl["chance"]:
            otype = random.choice(lvl["types"])
            ox = random.randint(2, 52)
            objs.append([ox, 0, otype])
        
        for obj in objs:
            obj[1] += 1
        
        hit = False
        for ox, oy, ot in objs:
            if oy >= 13 and abs(ox - px) < 2:
                hit = True
                break
        
        if hit:
            draw_board(px, objs, score, lvl["name"], turn)
            print(r"""
╔═══════════════════════════════════════════════════════════════════════╗
║                     💀 CRITICAL FAILURE 💀                      ║
╚═══════════════════════════════════════════════════════════════════════╝
              
                  .     .       .
               .  |\\  |\\    /|  |/
                \\||\\ ||//  //||//
                 \\|| //     // ||//
         CAT      \\||/      //  ||//
          <>       |||      ||   ||
                  _||_      ||_  ||_
                 
  COLLISION DETECTED AT TURN {}!
  FINAL SCORE: {}
""".format(turn, score))
            input("\n[PRESS ENTER]")
            return
        
        escaped = [o for o in objs if o[1] > 14]
        score += len(escaped) * 10
        objs = [o for o in objs if o[1] <= 14]
        
        move = input("MOVE (L/R/Q): ").strip().upper()
        if move == "Q":
            return
        elif move == "L":
            px = max(2, px - 4)
        elif move == "R":
            px = min(52, px + 4)
    
    clear()
    print(r"""
╔═══════════════════════════════════════════════════════════════════════╗
║                    ★ LEVEL COMPLETE ★                        ║
╚═══════════════════════════════════════════════════════════════╝

       ★ ═══════════════ ★
     ★  ║  MISSION DONE! ║  ★
       ★ ═══════════════ ★
           
     ★★★★★★★★★★★★★★★★★★★

  SCORE: {}
  LEVEL: {}

""".format(score + 100, lvl["name"]))
    input("\n[PRESS ENTER]")

def main():
    level = None
    while True:
        c = title()
        if c == "Q":
            clear()
            print(r"""
╔═══════════════════════════════════════════════════════════════════════╗
║                      ★ GOODBYE ★                            ║
╚═══════════════════════════════════════════════════════════════════════╝

        /|      /|       /|       /|
       //|___  //|___   //|___   //|___
      // /   ||// /   ||// /   ||// /
     // /    ||// /    ||// /    ||// /
    // /____||// /____||// /____||// /
   //  /   ||//  /   ||//  /   ||// /
  //__/    ||//__/    ||//__/    ||// /
 
  SEE U IN SPACE, PILOT!
""")
            break
        elif c == "1":
            if not level:
                level = 1
            game(level)
        elif c == "2":
            level = levels()
        elif c == "3":
            help_()

if __name__ == "__main__":
    main()