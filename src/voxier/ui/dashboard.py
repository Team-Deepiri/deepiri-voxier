import sys, subprocess, os

print("╔══════════════════════════════════════════════════════════════════╗")
print("║                    DEEPIRI VOX TERMINAL                          ║")
print("║              ═══════════════════════════════════════════        ║")
print("╚══════════════════════════════════════════════════════════════════╝")
print()

p = subprocess.run(['python3', 'sensor.py'], capture_output=True, text=True, cwd='/home/joeblack/Documents/Deepiri/deepiri-vox')
print(p.stdout)

p = subprocess.run(['python3', 'brain.py'], capture_output=True, text=True, cwd='/home/joeblack/Documents/Deepiri/deepiri-vox')
print(p.stdout)

print("--- WORKSPACE SIZE ANALYSIS ---")
p = subprocess.run(['python3', 'size.py'], capture_output=True, text=True, cwd='/home/joeblack/Documents/Deepiri/deepiri-vox')
print(p.stdout)

print("--- GIT STATUS ---")
p = subprocess.run(['python3', 'git.py'], capture_output=True, text=True, cwd='/home/joeblack/Documents/Deepiri/deepiri-vox')
print(p.stdout)

print("--- DEPENDENCIES ---")
p = subprocess.run(['python3', 'deps.py'], capture_output=True, text=True, cwd='/home/joeblack/Documents/Deepiri/deepiri-vox')
print(p.stdout)

print("══════════════════════════════════════════════════════════════════")
print("[ TRANSMISSION COMPLETE ]")
print("══════════════════════════════════════════════════════════════════")