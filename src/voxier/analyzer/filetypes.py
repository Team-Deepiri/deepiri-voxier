import os, sys
root = '/home/joeblack/Documents/Deepiri'
print("╔═══════════════════════════════════════════════════════════════════╗")
print("║             🔍 DEEPIRI VOX - FILE EXTENSIONS                      ║")
print("╚═══════════════════════════════════════════════════════════════════╝")
print()

repos = [d for d in os.listdir(root) if os.path.isdir(os.path.join(root,d)) and (d.startswith('deepiri-') or d.startswith('diri-'))]
exts = {}
for r in repos:
    for f in os.listdir(f'{root}/{r}'):
        if os.path.isfile(f'{root}/{r}/{f}'):
            e = f.split('.')[-1] if '.' in f else 'no-ext'
            exts[e] = exts.get(e, 0) + 1

for ext, count in sorted(exts.items(), key=lambda x: -x[1])[:10]:
    print(f"   .{ext}: {count} files")
print("═══════════════════════════════════════════════════════════════════")