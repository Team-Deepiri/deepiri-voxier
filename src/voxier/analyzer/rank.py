import os
root = '/home/joeblack/Documents/Deepiri'
print("╔═══════════════════════════════════════════════════════════════════╗")
print("║           📊 DEEPIRI VOX - REPO SIZE RANKINGS                     ║")
print("╚═══════════════════════════════════════════════════════════════════╝")
print()

repos = [d for d in os.listdir(root) if os.path.isdir(os.path.join(root,d)) and (d.startswith('deepiri-') or d.startswith('diri-'))]
sizes = [(r, sum(os.path.getsize(os.path.join(root,r,f)) for f in os.listdir(f'{root}/{r}') if os.path.isfile(os.path.join(root,r,f)))) for r in repos]
sizes.sort(key=lambda x: -x[1])

print([print(f"   {i:2}. {r:<30} {s:>10} KB") for i, (r,s) in enumerate(sizes[:10], 1)])
print()
print("═══════════════════════════════════════════════════════════════════")