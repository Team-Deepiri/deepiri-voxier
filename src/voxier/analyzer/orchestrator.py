import subprocess
import os
import sys

def main():
    # Get the directory of the current script
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    scripts = [
        'sensor.py', 'brain.py', 'size.py', 'git.py', 
        'health.py', 'stats.py', 'filetypes.py', 'readme.py'
    ]
    
    # help.py was moved to ui/, but I'll check if it's still needed here or if I should adjust.
    # The original had 'help.py'.
    
    print("╔═══════════════════════════════════════════════════════════════════╗")
    print("║                         DEEPIRI VOX                               ║")
    print("╚═══════════════════════════════════════════════════════════════════╝")
    print()

    for script in scripts:
        script_path = os.path.join(current_dir, script)
        if os.path.exists(script_path):
            print(f"RUNNING: {script}")
            p = subprocess.run([sys.executable, script_path], capture_output=True, text=True, cwd=current_dir)
            print(p.stdout)
        else:
            print(f"SKIPPING: {script} (not found at {script_path})")

    print("═══════════════════════════════════════════════════════════════════")
    print("DEEPIRI VOX TRANSMISSION COMPLETE")
    print("═══════════════════════════════════════════════════════════════════")

if __name__ == "__main__":
    main()
