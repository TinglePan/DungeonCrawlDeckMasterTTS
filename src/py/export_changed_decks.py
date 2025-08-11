import os
import subprocess
import json
from pathlib import Path
import hashlib
import re

build_record_filename = ".build_record.json"
deck_dir_path = Path("src/deck")
sheet_dir_path = Path("sheet")
deck_filename_pattern = re.compile(r"^(.*)DeckFile\.txt$")
sheet_filename_pattern = re.compile(r"^(.*)CardData\.xlsx$")
card_back_entries = {"card_back": "CardBack.txt", "card_back_black": "CardBackBlack.txt"}
extra_deck_card_back_entry = ("extra_deck_card_back", "ExtraDeckCardBack.txt")


def get_entry_paths():
    file_pairs = {}
    for deck_file_path in deck_dir_path.glob("*DeckFile.txt"):
        filename = deck_file_path.name
        match = deck_filename_pattern.match(filename)
        if match:
            identifier = match.group(1).lower()
            file_pairs.setdefault(identifier, []).append(deck_file_path)
    for sheet_file_path in sheet_dir_path.glob("*CardData.xlsx"):
        filename = sheet_file_path.name
        match = sheet_filename_pattern.match(filename)
        if match:
            identifier = match.group(1).lower()
            file_pairs.setdefault(identifier, []).append(sheet_file_path)
    return {k: v for k, v in file_pairs.items() if len(v) == 2}


def get_file_hash(file_path, algorithm='sha256', chunk_size=8192):
    try:
        hash_object = hashlib.new(algorithm)
        with open(file_path, 'rb') as f:
            while True:
                chunk = f.read(chunk_size)
                if not chunk:
                    break
                hash_object.update(chunk)
        return hash_object.hexdigest()
    except FileNotFoundError:
        return "Error: File not found."
    except Exception as e:
        return f"An error occurred: {e}"


def build_entry(entry_name, path):
    try:
        subprocess.run(["cmd", "/c", "start", "/MIN", "/WAIT",
                        "nanDeck", path, "/createpng", "/NOPDFDIAG", "output=build\\image"], check=True)
        print(f" Build successful: {entry_name}")
    except subprocess.CalledProcessError as e:
        print(f"Build failed: {e.returncode}")


def main():
    # 加载构建记录
    build_record = {}
    if os.path.exists(build_record_filename):
        with open(build_record_filename) as f:
            build_record = json.load(f)

    entry_paths = get_entry_paths()
    need_update_build_record = False
    need_export_extra_deck_card_back = False
    for entry_name, paths in entry_paths.items():
        deck_hash = get_file_hash(paths[0])
        sheet_hash = get_file_hash(paths[1])
        if entry_name in build_record:
            last_deck_hash, last_sheet_hash = build_record[entry_name]
            if deck_hash == last_deck_hash and sheet_hash == last_sheet_hash:
                print(f"{entry_name}: No changes detected, skipping build")
                continue
        build_entry(entry_name, paths[0])
        build_record[entry_name] = [deck_hash, sheet_hash]
        need_update_build_record = True
        if entry_name == "extra":
            need_export_extra_deck_card_back = True

    for entry_name, filename in card_back_entries.items():
        filepath = deck_dir_path / filename
        card_back_hash = get_file_hash(filepath)
        if entry_name in build_record:
            last_card_back_hash = build_record[entry_name]
            if card_back_hash == last_card_back_hash:
                print(f"{entry_name}: No changes detected, skipping build")
                continue
        build_entry(entry_name, filepath)
        build_record[entry_name] = card_back_hash
        need_update_build_record = True

    extra_deck_card_back_filepath = deck_dir_path / extra_deck_card_back_entry[1]
    extra_deck_card_back_hash = get_file_hash(extra_deck_card_back_filepath)
    if need_export_extra_deck_card_back or extra_deck_card_back_entry[0] not in build_record or \
            extra_deck_card_back_hash != build_record[extra_deck_card_back_entry[0]]:
        build_entry(extra_deck_card_back_entry[0], extra_deck_card_back_filepath)
        build_record[extra_deck_card_back_entry[0]] = extra_deck_card_back_hash
        need_update_build_record = True
    else:
        print(f"{extra_deck_card_back_entry[0]}: No changes detected, skipping build")

    if need_update_build_record:
        with open(build_record_filename, 'w') as f:
            json.dump(build_record, f, indent=2)
        print("Updated build record.")


if __name__ == "__main__":
    main()
