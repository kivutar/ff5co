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

- `menu_shop.txt`
- `rare_items.txt`
- `item_names_battle.txt`
- `monster_specialties.txt`
- `effect_names.txt`
- `magic_names_battle_messages.txt`

Current `broken` set:

- `ability_names.txt`
- `area_headings.txt`
- `item_names_menu.txt`
- `magic_names_battle_menu.txt`
- `magic_names_field_menu.txt`
- `menu_ability_text.txt`
- `monster_names.txt`
- `support_abilities_battle.txt`
- `support_abilities_menu.txt`
- `item_descriptions.txt`

Notes:

- `texts/jp/ok/dialog.txt` is the only Japanese extract currently available.
- `extract_misc.pl` is still a first-pass extractor for non-dialog regions.
- The next most useful cleanup targets are `menu_shop.txt` and `item_names_menu.txt`.
