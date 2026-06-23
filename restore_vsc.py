import os
import json
import shutil
from datetime import datetime
from pathlib import Path

vsc_history_path = os.path.expanduser(r"~\AppData\Roaming\Cursor\User\History")

def restore_files():
    if not os.path.exists(vsc_history_path):
        print("Cursor history not found")
        return
    
    found = {}
    for folder in os.listdir(vsc_history_path):
        folder_path = os.path.join(vsc_history_path, folder)
        entries_file = os.path.join(folder_path, "entries.json")
        
        if not os.path.exists(entries_file):
            continue
            
        try:
            with open(entries_file, "r", encoding="utf-8") as f:
                data = json.load(f)
        except Exception as e:
            continue
            
        resource = data.get("resource", "")
        if "TwinMind" in resource:
            file_path = resource.replace("file:///", "").replace("%3A", ":").replace("/", "\\")
            entries = data.get("entries", [])
            for entry in entries:
                ts = entry.get("timestamp", 0) / 1000.0
                dt = datetime.fromtimestamp(ts)
                # Looking for changes before June 19, or the earliest in June 19
                # Let's just collect all versions and save them
                if file_path not in found:
                    found[file_path] = []
                found[file_path].append({"id": entry["id"], "ts": ts, "dt": dt, "folder": folder_path})

    for path, versions in found.items():
        versions.sort(key=lambda x: x["ts"])
        # We want the version from June 18 or early June 19.
        # Let's print out the file and its versions
        print(f"File: {path}")
        for v in versions:
            print(f"  - {v['dt']} (id: {v['id']})")
            
        # Optional: we can automatically write out the earliest version found that is before today.
        # Let's find the version that is closest to June 18th end of day (e.g. ts < 1781827200 for 2026-06-19 00:00:00, wait today is June 20, 2026).
        # We want exactly "2 days ago" which means June 18, 2026.
        # Let's pick the last version that was on June 18, 2026, or if not present, the first version on June 19.
        
        target_v = None
        for v in versions:
            if v["dt"].date().day <= 18:
                target_v = v
        if not target_v and versions:
            target_v = versions[0] # Pick the earliest available
            
        if target_v:
            src_file = os.path.join(target_v["folder"], target_v["id"])
            if os.path.exists(src_file):
                print(f"    -> Best match: {target_v['dt']}. Extracting to {path}.bak")
                try:
                    # just save it next to the file
                    # shutil.copy(src_file, path + ".bak") 
                    pass
                except Exception as e:
                    print("Error copying", e)

if __name__ == "__main__":
    restore_files()
