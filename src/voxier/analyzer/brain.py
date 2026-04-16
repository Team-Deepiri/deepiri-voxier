import sys, os
print([print(f"TYPE:{line.strip().split(':')[1]}|{'NODE' if os.path.exists('../'+line.strip().split(':')[1]+'/package.json') else 'PYTHON' if os.path.exists('../'+line.strip().split(':')[1]+'/pyproject.toml') else 'RUST' if os.path.exists('../'+line.strip().split(':')[1]+'/Cargo.toml') else 'UNKNOWN'}") for line in sys.stdin if line.startswith("FOUND:")])
