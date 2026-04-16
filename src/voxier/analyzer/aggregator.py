import sys, subprocess
p = subprocess.run(['python3', 'sensor.py'], capture_output=True, text=True, cwd='/home/joeblack/Documents/Deepiri/deepiri-vox')
print(p.stdout)
p = subprocess.run(['python3', 'size.py'], capture_output=True, text=True, cwd='/home/joeblack/Documents/Deepiri/deepiri-vox')
print(p.stdout)
p = subprocess.run(['python3', 'git.py'], capture_output=True, text=True, cwd='/home/joeblack/Documents/Deepiri/deepiri-vox')
print(p.stdout)
p = subprocess.run(['python3', 'health.py'], capture_output=True, text=True, cwd='/home/joeblack/Documents/Deepiri/deepiri-vox')
print(p.stdout)