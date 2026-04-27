Texts are grouped first by language, then by extraction quality.

Layout:

- `texts/<lang>/ok/`
  - trusted enough to edit/translate now
- `texts/<lang>/partial/`
  - partially decoded, usable as hints only
- `texts/<lang>/broken/`
  - not properly parsed yet, do not translate from these

Current `ok` set:

- `dialog.txt`
- `ability_names.txt`
- `area_headings.txt`
- `battle_record_text.txt`
- `job_names.txt`
- `shop_names.txt`
- `character_names.txt`
- `concepts_misc.txt`
- `effect_names.txt`
- `item_names_battle.txt`
- `item_descriptions.txt`
- `item_names_menu.txt`
- `magic_names_battle_menu.txt`
- `magic_names_battle_messages.txt`
- `magic_names_field_menu.txt`
- `menu_shop.txt`
- `menu_ability_text.txt`
- `monster_specialties.txt`
- `monster_names.txt`
- `rare_items.txt`
- `song_names.txt`
- `blue_magic_names.txt`
- `support_abilities_battle.txt`

Current `partial` set:

Current `broken` set:

Notes:

- `texts/jp/ok/dialog.txt` is the only Japanese extract currently available.
- `extract_misc.pl` is still a first-pass extractor for non-dialog regions.
