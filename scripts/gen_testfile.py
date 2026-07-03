import numpy as np
import random
from pathlib import Path
n_lines = 25
fold_path = Path("testfiles")
fold_path.mkdir(parents=True, exist_ok=True)
with open(fold_path/"data.txt", "a") as f:
    for i in range(n_lines):
        n_entries = random.randint(4, 12)
        f.write(str(n_entries)+" ")
        for j in range(n_entries):
            f.write(f"{random.randrange(16**2):02x} ")
        f.write("\n")
