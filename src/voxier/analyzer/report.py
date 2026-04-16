import sys
print("\n[ DEEPIRI WORKSPACE PULSE ]")
print("===========================")
print([print(f"  > {line.strip().split('|')[0].split(':')[1]:<25} | Type: {line.strip().split('|')[1]}") for line in sys.stdin if "TYPE:" in line])
print("===========================")
print("[ TRANSMISSION COMPLETE ]\n")
print([print(f"SIZE:{line.strip().split('|')[0].split(':')[1]}: {line.strip().split('|')[1]} bytes") for line in sys.stdin if "SIZE:" in line])
