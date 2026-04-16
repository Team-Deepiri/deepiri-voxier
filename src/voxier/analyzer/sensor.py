import os
print([print(f"FOUND:{d}") for d in os.listdir('..') if os.path.isdir(d) and (d.startswith('deepiri-') or d.startswith('diri-'))])
