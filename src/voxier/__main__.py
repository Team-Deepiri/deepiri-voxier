import sys
import argparse
import subprocess
import os
from .games import cat_pilot
from .analyzer import orchestrator

def run_godot():
    # Attempt to run the Godot project
    root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    start_sh = os.path.join(root_dir, "start.sh")
    if os.path.exists(start_sh):
        print("🚀 Launching Godot Engine for Fox Rocket...")
        subprocess.run(["bash", start_sh])
    else:
        print("Error: start.sh not found. Ensure you are in the project root.")

def main():
    parser = argparse.ArgumentParser(description="Voxier - Deepiri Unified Tool")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--game", choices=["cat", "fox"], help="Run C.A.T. Pilot (CLI) or Fox Rocket (Godot)")
    group.add_argument("--scan", action="store_true", help="Run the repository scanner")

    args = parser.parse_args()

    if args.game == "cat":
        cat_pilot.main()
    elif args.game == "fox":
        run_godot()
    elif args.scan:
        orchestrator.main()

if __name__ == "__main__":
    main()
