import pandas as pd
import json


entry = [
    {"file_path": "datasheet/MonsterCardData.xlsx", "export_name": "monster_tags.json", "innate_tags": ["Monster", "怪物"]},
    {"file_path": "datasheet/TrapCardData.xlsx", "export_name": "trap_tags.json", "innate_tags": ["Trap", "陷阱"]},
]


def export_sheet(file_path, export_name, innate_tags=None):
    # 读取Excel文件
    df = pd.read_excel(file_path)  # 替换为你的Excel文件名

    # 处理数据
    result = []
    for _, row in df.iterrows():
        tags = innate_tags.copy() if innate_tags else []
        card_name = row['cardName'].strip()
        card_name_en = row['cardNameEn'].strip()
        max_count = row['maxCount']
        tags += [card_name, card_name_en]
        if 'tags' in row:
            raw_tags = str(row['tags']).split(',') if pd.notna(row['tags']) else []
            cleaned_tags = [tag.strip() for tag in raw_tags if tag.strip()]
            tags += cleaned_tags
        if 'tagsEn' in row:
            raw_tags_en = str(row['tagsEn']).split(',') if pd.notna(row['tagsEn']) else []
            cleaned_tags_en = [tag.strip() for tag in raw_tags_en if tag.strip()]
            tags += cleaned_tags_en

        # 构建字典并添加到结果列表
        for i in range(max_count):
            result.append(tags)

    export_path = 'json/' + export_name
    # 导出JSON文件
    with open(export_path, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)


if __name__ == '__main__':
    for item in entry:
        export_sheet(item['file_path'], item['export_name'], item.get('innate_tags'))