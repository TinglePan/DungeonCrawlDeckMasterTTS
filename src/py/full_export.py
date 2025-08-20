import os.path

import pandas as pd
import json
import re
import export_deck_image_of_changed_decks


tag_entries = [
    {"file_path": "sheet/MonsterCardData.xlsx", "innate_tags": ["Monster", "怪物"]},
    {"file_path": "sheet/TrapCardData.xlsx", "innate_tags": ["Trap", "陷阱"]},
]


def entry_name_from_sheet_name(sheet_name):
    basename = os.path.splitext(os.path.basename(sheet_name))[0]
    match = re.fullmatch(r"(.+?)CardData", basename)
    if match:
        prefix = match.group(1)
        return prefix[0].lower() + prefix[1:]
    raise f"Unexpected sheet name {sheet_name}"


def entry_name_to_card_file_name(entry_name, index = 1):
    res = entry_name[0].upper() + entry_name[1:] + "Cards"
    if index > 1:
        res += str(index)
    res += ".png"
    return res


def entry_name_to_card_back_file_name(entry_name):
    entry_name_2_back_name_map = {
        "monster": "monster",
        "trap": "trap",
        "event": "incident",
        "loot": "incident",
        "item": "artifact",
        "trinket": "artifact",
        "gear": "artifact",
        "skill": "upgrade",
        "attribute": "upgrade",
        "challenge": "challenge",
        "extra": "extra"
    }
    if entry_name not in entry_name_2_back_name_map:
        raise f"Unexpected entry name {entry_name}"
    card_back_name = entry_name_2_back_name_map[entry_name]
    return "CardBack" + card_back_name[0].upper() + card_back_name[1:] + ".png"


def relative_path2github_url(relative_path):
    import time
    return f"https://raw.githubusercontent.com/TinglePan/DungeonCrawlDeckMaster/main/{relative_path}?dummy={int(time.time())}"


def process_sheets(sheet_dir_path):
    # 遍历dir_path目录下的所有文件
    sheet_source = {}
    for root, _, files in os.walk(sheet_dir_path):
        for file in files:
            if file.endswith('.xlsx') and not file.startswith('~'):
                file_path = os.path.join(root, file)
                df = pd.read_excel(file_path)
                entry_count = 0
                if 'maxCount' in df.columns:
                    for _, row in df.iterrows():
                        entry_count += row['maxCount']
                else:
                    entry_count = len(df)
                entry_name = entry_name_from_sheet_name(file)
                sheet_source[entry_name] = []
                n_files = entry_count // 70 + 1
                for i in range(n_files):
                    sheet_source[entry_name].append([
                        relative_path2github_url(f"build/image/{entry_name_to_card_file_name(entry_name, i + 1)}"),
                        relative_path2github_url(f"build/image/{entry_name_to_card_back_file_name(entry_name)}"),
                        False if entry_name != "extra" else True,
                        min(70, entry_count - i * 70)
                    ])
    export_path = f'build/json/deck_defs.json'
    with open(export_path, 'w', encoding='utf-8') as f:
        json.dump(sheet_source, f, ensure_ascii=False, indent=2)


def get_field_as_str(field_value):
    if field_value is None or pd.isna(field_value):
        return ""
    return field_value


def get_field_as_int(field_value):
    if field_value is None or pd.isna(field_value):
        return 0
    try:
        return int(field_value)
    except ValueError:
        return 0


def extract_tags(file_path, innate_tags=None):
    # 读取Excel文件
    df = pd.read_excel(file_path)  # 替换为你的Excel文件名

    # 处理数据
    result = []
    for _, row in df.iterrows():
        tags = innate_tags.copy() if innate_tags else []
        card_name = get_field_as_str(row['cardName']).strip()
        card_name_en = get_field_as_str(row['cardNameEn']).strip()
        max_count = get_field_as_int(row['maxCount'])
        tags += [card_name, card_name_en]
        if 'tags' in row:
            raw_tags = re.split('[,，]', get_field_as_str(row['tags'])) if pd.notna(row['tags']) else []
            cleaned_tags = [tag.strip() for tag in raw_tags if tag.strip() != ""]
            tags += cleaned_tags
        if 'tagsEn' in row:
            raw_tags_en = re.split('[,，]', get_field_as_str(row['tagsEn'])) if pd.notna(row['tagsEn']) else []
            cleaned_tags_en = [tag.strip() for tag in raw_tags_en if tag.strip() != ""]
            tags += cleaned_tags_en

        # 构建字典并添加到结果列表
        for i in range(max_count):
            result.append(tags)
    n_files = (len(result) - 1) // 70 + 1

    urls = []
    entry_name = entry_name_from_sheet_name(file_path)
    for i in range(n_files):
        export_path = f'build/json/{entry_name}_tags.json' if i == 0 else f"build/json/{entry_name}_tags_{i + 1}.json"
        data = result[i * 70: (i + 1) * 70 if (i + 1) * 70 < len(result) else len(result)]
        # 导出JSON文件
        with open(export_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        urls.append(relative_path2github_url(export_path))
    return entry_name, urls


def process_tags():
    tag_source = {}
    for entry in tag_entries:
        entry_name, urls = extract_tags(entry['file_path'], entry.get('innate_tags'))

        tag_source[entry_name] = urls
    export_path = f'build/json/tag_files.json'
    with open(export_path, 'w', encoding='utf-8') as f:
        json.dump(tag_source, f, ensure_ascii=False, indent=2)


def main():
    need_update = export_deck_image_of_changed_decks.main()
    if need_update:
        process_tags()
        process_sheets("sheet/")
    else:
        print("No changes detected, skipping tag and sheet processing.")


if __name__ == '__main__':
    main()
