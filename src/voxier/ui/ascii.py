import os
root = '/home/joeblack/Documents/Deepiri'
print("""
   ╭─────────────────────────────────────────╮
   │   💀 DEEPIRI VOX - ASCII ART GALLERY   │
   ╰─────────────────────────────────────────╯
""")

print("   [1]  ██████╗  ██████╗  ██████╗  █████╗ ██████╗ ")
print("   [2]  ██╔══██╗ ██╔══██╗ ██╔══██╗██╔══██╗██╔══██╗")
print("   [3]  ██████╔╝ ██████╔╝ ██████╔╝███████║██████╔╝")
print("   [4]  ██╔═══╝  ██╔══██╗ ██╔══██╗██╔══██║██╔══██╗")
print("   [5]  ██║     ██║  ██║ ██████║║██║  ██║██║  ██║")
print("   [6]  ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝")
print()

repos = [d for d in os.listdir(root) if os.path.isdir(os.path.join(root,d)) and (d.startswith('deepiri-') or d.startswith('diri-'))]
idx = 1
print([print(f"   [{idx:=2}] {r}") for idx, r in enumerate(repos, 1)])
print()
print("   ╭─────────────────────────────────────────╮")
print("   │   Total repos in workspace: " + str(len(repos)) + "            │")
print("   ╰─────────────────────────────────────────╯")