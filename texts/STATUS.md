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
- `job_names.txt`
- `shop_names.txt`
- `character_names.txt`

Current `partial` set:

- `ability_names.txt`
- `menu_shop.txt`
- `rare_items.txt`
- `item_names_battle.txt`
- `item_names_menu.txt`
- `monster_names.txt`
- `monster_specialties.txt`
- `effect_names.txt`
- `item_descriptions.txt`
- `magic_names_field_menu.txt`
- `magic_names_battle_menu.txt`
- `magic_names_battle_messages.txt`
- `support_abilities_battle.txt`

Current `broken` set:

- `area_headings.txt`
- `menu_ability_text.txt`
- `support_abilities_menu.txt`

Notes:

- `texts/jp/ok/dialog.txt` is the only Japanese extract currently available.
- `support_abilities_menu.txt` appears to be unused in the RPGe English/French/Corsican ROMs; the original `0x115800-0x1159DF` region is all `FF` there, while the Japanese ROM still has data.
- `extract_misc.pl` is still a first-pass extractor for non-dialog regions.
- The next most useful cleanup targets are `menu_ability_text.txt`, `area_headings.txt`, and whatever Japanese-only source remains useful from `support_abilities_menu.txt`.
