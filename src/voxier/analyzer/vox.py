import os, subprocess
root = '/home/joeblack/Documents/Deepiri'
os.chdir(root)

print("""
    ██╗   ██╗ ██████╗ ██╗██████╗     ██╗    ██╗ █████╗ ██╗     ██╗     ███████╗██████╗ 
    ██║   ██║██╔═══██╗██║██╔══██╗    ██║    ██║██╔══██╗██║     ██║     ██╔════╝██╔══██╗
    ██║   ██║██║   ██║██║██║  ██║    ██║ █╗ ██║███████║██║     ██║     █████╗  ██████╔╝
    ╚██╗ ██╔╝██║   ██║██║██║  ██║    ██║███╗██║██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
     ╚████╔╝ ╚██████╔╝██║██████╔╝    ╚███╔███╔╝██║  ██║███████╗███████╗███████╗██║  ██║
      ╚═══╝   ╚═════╝ ╚═╝╚═════╝      ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
""")

print("\n▶ SCANNING...")
repos = [d for d in os.listdir(root) if os.path.isdir(os.path.join(root,d)) and (d.startswith('deepiri-') or d.startswith('diri-'))]
print(f"   Found {len(repos)} repos")

print("\n▶ CLASSIFYING...")
print([print(f"   {r}: {'NODE' if os.path.exists(f'{root}/{r}/package.json') else 'PYTHON' if os.path.exists(f'{root}/{r}/pyproject.toml') else 'RUST' if os.path.exists(f'{root}/{r}/Cargo.toml') else '?'}") for r in repos])

print("\n▶ SIZING...")
print([print(f"   {r}: {sum(os.path.getsize(os.path.join(root,r,f)) for f in os.listdir(f'{root}/{r}') if os.path.isfile(os.path.join(root,r,f)))/1024:.1f} KB") for r in repos])

print("\n▶ GIT STATUS...")
import subprocess as s
print([print(f"   {r}: {'✓' if os.path.exists(f'{root}/{r}/.git') else '✗'}") for r in repos])

print("\n▶ DEPENDENCIES...")
print([print(f"   {r}: {'✓' if os.path.exists(f'{root}/{r}/pyproject.toml') or os.path.exists(f'{root}/{r}/package.json') or os.path.exists(f'{root}/{r}/requirements.txt') else '✗'}") for r in repos])

print("\n" + "═"*60)
print(f"✓ SCAN COMPLETE: {len(repos)} repos analyzed")
print("═"*60)