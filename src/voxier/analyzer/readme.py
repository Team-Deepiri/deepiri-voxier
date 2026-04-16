import os
root = '/home/joeblack/Documents/Deepiri'
print("╔═══════════════════════════════════════════════════════════════════╗")
print("║             DEEPIRI VOX - PROJECT DOCS CHECK                    ║")
print("╚═══════════════════════════════════════════════════════════════════╝")
print()

repos = [d for d in os.listdir(root) if os.path.isdir(os.path.join(root,d)) and (d.startswith('deepiri-') or d.startswith('diri-'))]
print([print(f"   {r:<30} | {'✓ README' if os.path.exists(f'{root}/{r}/README.md') else '✗ no-readme'}") for r in repos])
print("═══════════════════════════════════════════════════════════════════")
