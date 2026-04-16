import os
root = '/home/joeblack/Documents/Deepiri'
print("╔═══════════════════════════════════════════════════════════════════╗")
print("║             📊 DEEPIRI VOX - COMPLETE STATISTICS                  ║")
print("╚═══════════════════════════════════════════════════════════════════╝")
print()

repos = [d for d in os.listdir(root) if os.path.isdir(os.path.join(root,d)) and (d.startswith('deepiri-') or d.startswith('diri-'))]
python = len([r for r in repos if os.path.exists(f'{root}/{r}/pyproject.toml')])
node = len([r for r in repos if os.path.exists(f'{root}/{r}/package.json')])
rust = len([r for r in repos if os.path.exists(f'{root}/{r}/Cargo.toml')])
unknown = len([r for r in repos]) - python - node - rust

print(f"   Total Repos: {len(repos)}")
print(f"   Python: {python}  |  Node: {node}  |  Rust: {rust}  |  Unknown: {unknown}")
print()

total_size = sum(sum(os.path.getsize(os.path.join(root,r,f)) for f in os.listdir(f'{root}/{r}') if os.path.isfile(os.path.join(root,r,f))) for r in repos)
print(f"   Total Size: {total_size:,} bytes ({total_size/1024/1024:.2f} MB)")
print()

git_repos = [r for r in repos if os.path.exists(f'{root}/{r}/.git')]
print(f"   Git Tracked: {len(git_repos)}/{len(repos)}")
print()

print("═══════════════════════════════════════════════════════════════════")
print(f"   Repos without dependencies: {len([r for r in repos if not (os.path.exists(f'{root}/{r}/pyproject.toml') or os.path.exists(f'{root}/{r}/requirements.txt') or os.path.exists(f'{root}/{r}/package.json'))])}")
print("═══════════════════════════════════════════════════════════════════")