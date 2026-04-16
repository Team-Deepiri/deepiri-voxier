import subprocess, sys

cmds = [
    ('sensor.py', 'SCANNING WORKSPACE...'),
    ('brain.py', 'CLASSIFYING REPOS...'),
    ('size.py', 'CALCULATING SIZES...'),
    ('git.py', 'CHECKING GIT STATUS...'),
    ('health.py', 'ASSESSING HEALTH...'),
]

for cmd, label in cmds:
    print(f"\n▶ {label}")
    p = subprocess.run(['python3', cmd], capture_output=True, text=True)
    print(p.stdout, end='')

print("\n" + "="*50)
print("✓ ALL SYSTEMS REPORTING")
print("="*50)