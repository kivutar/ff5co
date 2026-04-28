#!/bin/sh
set -eu
cp ff5fr.sfc ff5co.sfc
magick corsican_font.bmp pbm:/tmp/ff5co-font.pbm
perl import_font.pl ff5co.sfc /tmp/ff5co-font.pbm 03EF80 1080 16
perl insert.pl co texts/co/dialog.txt
perl insert_menu_shop.pl co texts/co/menu_shop.txt ff5co.sfc
perl insert_shop_names.pl co texts/co/shop_names.txt ff5co.sfc
perl insert_ability_names.pl co texts/co/ability_names.txt ff5co.sfc
perl insert_item_descriptions.pl co texts/co/item_descriptions.txt ff5co.sfc
perl insert_area_headings.pl co texts/co/area_headings.txt ff5co.sfc
