#!/usr/bin/env python3
import zipfile, io, glob, os, sys

oracle_home = os.environ.get("ORACLE_HOME", "/u01/oracle")
search_dir = sys.argv[1] if len(sys.argv) > 1 else "/u01"

print(f"🚀 Extracting Oracle Forms 14c & FMW Infrastructure components to {oracle_home}...")
os.makedirs(oracle_home, exist_ok=True)

# Find all zip, jar, bin files
candidates = []
for root, dirs, files in os.walk(search_dir):
    for f in files:
        if f.endswith(".zip") or f.endswith(".jar") or f.endswith(".bin"):
            candidates.append(os.path.join(root, f))

extracted_components = 0

def process_archive(file_path, depth=0):
    global extracted_components
    if depth > 2:
        return
    try:
        zf = zipfile.ZipFile(file_path)
        for name in zf.namelist():
            if name.endswith(".jar") and "DataFiles" in name:
                try:
                    data = zf.read(name)
                    sub_zf = zipfile.ZipFile(io.BytesIO(data))
                    sub_zf.extractall(oracle_home)
                    extracted_components += 1
                except Exception:
                    pass
            elif (name.endswith(".jar") or name.endswith(".bin")) and depth == 0:
                try:
                    data = zf.read(name)
                    sub_zf = zipfile.ZipFile(io.BytesIO(data))
                    for sub_name in sub_zf.namelist():
                        if sub_name.endswith(".jar") and "DataFiles" in sub_name:
                            try:
                                sub_data = sub_zf.read(sub_name)
                                fg_zf = zipfile.ZipFile(io.BytesIO(sub_data))
                                fg_zf.extractall(oracle_home)
                                extracted_components += 1
                            except Exception:
                                pass
                except Exception:
                    pass
    except Exception:
        pass

for c in sorted(candidates):
    print(f"  Processing {os.path.basename(c)}...")
    process_archive(c)

print(f"🎉 Successfully extracted {extracted_components} components into {oracle_home}!")
