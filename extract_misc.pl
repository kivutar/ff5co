use utf8;
use open qw(:std :encoding(UTF-8));
use File::Slurper qw(read_binary write_text);
use File::Path qw(make_path);


my %b2c = (
    "00" => "|",
    "01" => ">",
    "02" => "[Bartz]",
    "08" => "[TAB1]",
    "09" => "[TAB2]",
    "0A" => "[TAB3]",
    "0C" => "[FixedPause]",
    "0F" => "[AutoClose]",
    "10" => "[DialogueGil]",
    "11" => "[DialogueItem]",
    "12" => "[DialogueAbility]",
    "17" => "[Wait]",

    "60" => "A",
    "61" => "B",
    "62" => "C",
    "63" => "D",
    "64" => "E",
    "65" => "F",
    "66" => "G",
    "67" => "H",
    "68" => "I",
    "69" => "J",
    "6A" => "K",
    "6B" => "L",
    "6C" => "M",
    "6D" => "N",
    "6E" => "O",
    "6F" => "P",
    "70" => "Q",
    "71" => "R",
    "72" => "S",
    "73" => "T",
    "74" => "U",
    "75" => "V",
    "76" => "W",
    "77" => "X",
    "78" => "Y",
    "79" => "Z",

    "53" => "0",
    "54" => "1",
    "55" => "2",
    "56" => "3",
    "57" => "4",
    "58" => "5",
    "59" => "6",
    "5A" => "7",
    "5B" => "8",
    "5C" => "9",

    "7A" => "a",
    "7B" => "b",
    "7C" => "c",
    "7D" => "d",
    "7E" => "e",
    "7F" => "f",
    "80" => "g",
    "81" => "h",
    "82" => "i",
    "83" => "j",
    "84" => "k",
    "85" => "l",
    "86" => "m",
    "87" => "n",
    "88" => "o",
    "89" => "p",
    "8A" => "q",
    "8B" => "r",
    "8C" => "s",
    "8D" => "t",
    "8E" => "u",
    "8F" => "v",
    "90" => "w",
    "91" => "x",
    "92" => "y",
    "93" => "z",

    "A1" => "!",
    "A2" => "?",
    "A3" => ".",

    "99" => "'",
    "9A" => "\"",
    "9B" => ":",

    "9D" => ",",
    "9E" => "(",
    "9F" => ")",
    "A0" => "/",

    "FF" => " ",
);

my %b2c_words = (
    "1701" => "[P1]",
    "1702" => "[P2]",
    "1703" => "[P3]",
    "1704" => "[P4]",
    "1705" => "[P5]",
    "1706" => "[P6]",
);

my %b2c_fr = (
    "94" => "Ç",
    "95" => "ç",
    "97" => "â",
    "98" => "à",
    "99" => "é",
    "9A" => "è",
    "9B" => "!",
    "9C" => "ê",
    "9D" => "ù",
    "9E" => "ô",
    "9F" => "û",
    "A5" => ".",
    "A8" => "…",
    "A9" => "œ",
    "AB" => ":",
    "AD" => ",",
    "B0" => "il",
    "B2" => "li",
    "B3" => "ll",
    "B6" => "ît",
    "BA" => "ïe",
    "C5" => "-",
    "C9" => "’",
    "D0" => "«",
    "D1" => "»",
);

my %b2c_co = (
    %b2c_fr,
    "9C" => "ì",
    "9E" => "ò",
    "B6" => "ìt",
);

my %b2c_menu_common = (
    "34" => "F",
    "35" => "o",
    "36" => "r",
    "37" => "m",
    "38" => ".",
    "CD" => "%",
    "CF" => ":",
);

my %b2c_menu_fr = (
    "11" => "p",
    "12" => "t",
    "13" => "i",
    "14" => "mum",
    "16" => "Ret",
    "17" => "ir",
    "18" => "er",
    "19" => "",
    "1A" => "",
    "94" => "i",
    "A3" => "u",
    "A4" => "ip",
    "B0" => "il",
    "B1" => "ti",
    "D6" => "'",
    "DF" => "ns",
    "AE" => "Fin",
);

my %b2c_menu_fr_words = (
    "2D35" => "Niv",
    "BBBA" => "aid",
    "DBDC" => "lan",
);

my %b2c_menu_en = (
    "94" => "il",
    "95" => "it",
    "96" => " ",
    "97" => "li",
    "98" => "ll",
    "99" => "'",
    "A5" => "fi",
    "A4" => "ti",
    "AA" => "",
    "B0" => "tt",
    "C5" => "-",
);

my %b2c_effect_fr = (
    "52" => " ",
);

my %b2c_effect_en = (
    "96" => " ",
    "C5" => "-",
);

my %b2c_item_en = (
    "94" => "li",
    "96" => " ",
    "97" => "li",
    "98" => "ll",
    "A4" => "ti",
    "AF" => "ir",
    "C5" => "-",
);

my %b2c_item_fr = (
    "94" => "i",
    "95" => "n",
    "9B" => "ï",
    "AC" => " n",
    "BC" => "î",
);

my $mode = "fr";
my $rom = "ff5fr.sfc";

if (defined $ARGV[0]) {
    if ($ARGV[0] eq "en" || $ARGV[0] eq "fr" || $ARGV[0] eq "co") {
        $mode = $ARGV[0];
        $rom = "ff5en.sfc" if $mode eq "en";
        $rom = "ff5co.sfc" if $mode eq "co";
        $rom = $ARGV[1] if defined $ARGV[1];
    } else {
        $rom = $ARGV[0];
    }
}

my %decode_table = %b2c;
if ($mode eq "fr") {
    %decode_table = (%decode_table, %b2c_fr);
} elsif ($mode eq "co") {
    %decode_table = (%decode_table, %b2c_co);
}

my $bytes = read_binary($rom);
my $output_dir = "texts/$mode";

make_path($output_dir) unless -d $output_dir;
make_path("$output_dir/ok", "$output_dir/partial", "$output_dir/broken");

sub output_path {
    my $filename = shift;
    my %ok = map { $_ => 1 } qw(
        character_names.txt
        job_names.txt
        shop_names.txt
    );
    my %partial = map { $_ => 1 } qw(
        effect_names.txt
        item_names_battle.txt
        item_names_menu.txt
        magic_names_battle_messages.txt
        menu_shop.txt
        monster_specialties.txt
        rare_items.txt
    );

    return "$output_dir/ok/$filename" if $ok{$filename};
    return "$output_dir/partial/$filename" if $partial{$filename};
    return "$output_dir/broken/$filename";
}

sub decode {
    my @bytes = unpack("C*", shift);
    my $string = "";

    for (my $i = 0; $i < @bytes; $i++) {
        my $byte = sprintf("%02X", $bytes[$i]);

        if ($byte eq "17" && defined $bytes[$i + 1]) {
            my $word = $byte . sprintf("%02X", $bytes[$i + 1]);
            if (exists $b2c_words{$word}) {
                $string .= $b2c_words{$word};
                $i++;
                next;
            }
        }

        $string .= exists $decode_table{$byte} ? $decode_table{$byte} : "\\" . $byte;
    }

    return $string;
}

sub trim_record {
    my $record = shift;
    $record =~ s/\x00.*$//s;
    $record =~ s/\xFF+$//s;
    return $record;
}

sub dump_fixed {
    my ($filename, $start, $end, $width) = @_;
    my @lines = ();
    my $count = int((($end - $start) + 1) / $width);

    for (my $i = 0; $i < $count; $i++) {
        my $offset = $start + ($i * $width);
        my $record = substr($bytes, $offset, $width);
        my $trimmed = trim_record($record);
        my $decoded = decode($trimmed);
        my $rawlen = length($trimmed);
        push @lines, join("\t", $i, sprintf('$%06X', $offset), $rawlen, $decoded);
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path ($count entries)\n";
}

sub dump_zero_split {
    my ($filename, $start, $end) = @_;
    my $block = substr($bytes, $start, ($end - $start) + 1);
    my @parts = split(/\x00/, $block, -1);
    my @lines = ();
    my $offset = $start;
    my $index = 0;

    for my $part (@parts) {
        my $trimmed = trim_record($part);
        my $decoded = decode($trimmed);
        push @lines, join("\t", $index, sprintf('$%06X', $offset), length($trimmed), $decoded);
        $offset += length($part) + 1;
        $index++;
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path ($index entries)\n";
}

sub dump_zero_split_with_extra {
    my ($filename, $start, $end, $extra) = @_;
    my $block = substr($bytes, $start, ($end - $start) + 1);
    my @parts = split(/\x00/, $block, -1);
    my @lines = ();
    my $offset = $start;
    my $index = 0;
    my %table = (%decode_table, %$extra);

    for my $part (@parts) {
        my $trimmed = trim_record($part);
        my @raw = unpack("C*", $trimmed);
        my $decoded = "";

        for my $b (@raw) {
            my $hex = sprintf("%02X", $b);
            $decoded .= exists $table{$hex} ? $table{$hex} : "\\" . $hex;
        }

        push @lines, join("\t", $index, sprintf('$%06X', $offset), length($trimmed), $decoded);
        $offset += length($part) + 1;
        $index++;
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path ($index entries)\n";
}

sub menu_shop_extra_table {
    if ($mode eq "en") {
        return (%b2c_menu_common, %b2c_menu_en);
    }

    return (%b2c_menu_common, %b2c_menu_fr);
}

sub menu_shop_word_table {
    return %b2c_menu_fr_words if $mode eq "fr" || $mode eq "co";
    return ();
}

sub normalize_menu_shop {
    my $decoded = shift;

    if ($mode eq "en") {
        $decoded =~ s/^ +//;
        $decoded =~ s/ +$//;
        $decoded =~ s/Opiptimum/Optimum/g;
        $decoded =~ s/Opipmum/Optimum/g;
        $decoded =~ s/Strgth\./Strength/g;
        $decoded =~ s/Def\./Defense/g;
        $decoded =~ s/Evade +%/Evade %/g;
        $decoded =~ s/How may I help you\?'+/How may I help you?/g;
        $decoded =~ s/What do you want\?'+/What do you want?/g;
        $decoded =~ s/How many\?'+/How many?/g;
        $decoded =~ s/Not enough money\.+/Not enough money!/g;
        $decoded =~ s/You have too many\.+/You have too many!/g;
        $decoded =~ s/You already have it\.+/You already have it!/g;
        $decoded =~ s/Thank you!'+/Thank you!/g;
        $decoded =~ s/Bat\.Mode/Bat. Mode/g;
        $decoded =~ s/Bat\.Speed/Bat. Speed/g;
        $decoded =~ s/Msg\.Speed/Msg. Speed/g;
        $decoded =~ s/Cmd\.Set/Cmd Set/g;
        $decoded =~ s/^ipped$/Equipped/g;
        $decoded =~ s/equEquipped/equipped/g;
        $decoded =~ s/Equip "Optimum'/Equip "Optimum"/g;
        $decoded =~ s/Don't move!!/Don't move!/g;
        $decoded =~ s/([!?])'+$/$1/g;
        $decoded =~ s/button\.+/button./g;
        return $decoded;
    }

    $decoded =~ s/^ +//;
    $decoded =~ s/ +$//;
    $decoded =~ s/Puis-je vous aidïeer\?/Puis-je vous aider?/g;
    $decoded =~ s/Vous lPavez déjà\./Vous l’avez déjà./g;
    $decoded =~ s/Merci beaucoup’/Merci beaucoup !/g;
    $decoded =~ s/ser Trie/Sort. Trés/g;
    $decoded =~ s/r Rares/Obj. rares/g;
    $decoded =~ s/BMPche/Blanche/g;
    $decoded =~ s/Qu\\A6ter/Quitter/g;
    $decoded =~ s/Con\\B5gurar/configurer/g;
    $decoded =~ s/âp\\B4mo/optimo/g;
    $decoded =~ s/botên/botón/g;
    $decoded =~ s/^ipé$/Équipé/g;
    $decoded =~ s/A\\E4\\E6nte/Attente/g;
    $decoded =~ s/Fonds insuffisants’/Fonds insuffisants !/g;
    $decoded =~ s/Vous,là-bas’/Vous, là-bas !/g;
    $decoded =~ s/Pas un geste’/Pas un geste !/g;
    return $decoded;
}

sub dump_menu_shop {
    my ($filename, $start, $end) = @_;
    my $block = substr($bytes, $start, ($end - $start) + 1);
    my @parts = split(/\x00/, $block, -1);
    my @lines = ();
    my $offset = $start;
    my $index = 0;
    my %table = (%decode_table, menu_shop_extra_table());
    my %words = menu_shop_word_table();

    for my $part (@parts) {
        my $trimmed = trim_record($part);
        my @raw = unpack("C*", $trimmed);
        my $decoded = "";

        for (my $i = 0; $i < @raw; $i++) {
            my $hex = sprintf("%02X", $raw[$i]);

            if ($i + 1 < @raw) {
                my $pair = $hex . sprintf("%02X", $raw[$i + 1]);
                if (exists $words{$pair}) {
                    $decoded .= $words{$pair};
                    $i++;
                    next;
                }
            }

            $decoded .= exists $table{$hex} ? $table{$hex} : "\\" . $hex;
        }

        $decoded = normalize_menu_shop($decoded);
        push @lines, join("\t", $index, sprintf('$%06X', $offset), length($trimmed), $decoded);
        $offset += length($part) + 1;
        $index++;
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path ($index entries)\n";
}

sub dump_pointer_table {
    my ($filename, $pointer_offset, $pointer_count, $text_offset) = @_;
    my @offsets = ();
    my @lines = ();

    for (my $i = 0; $i < $pointer_count; $i++) {
        my $raw = substr($bytes, $pointer_offset + ($i * 2), 2);
        push @offsets, unpack("v", $raw);
    }

    my $limit = length($bytes) - $text_offset;

    for (my $i = 0; $i < $pointer_count; $i++) {
        my $start = $offsets[$i];
        my $next = $i + 1 < $pointer_count ? $offsets[$i + 1] : $limit;
        my $length = $next - $start;
        my $offset = $text_offset + $start;
        my $record = substr($bytes, $offset, $length);
        $record =~ s/\x00+$//s;
        $record =~ s/\xFF+$//s;
        my $decoded = decode($record);
        push @lines, join("\t", $i, sprintf('$%06X', $offset), length($record), $decoded);
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path ($pointer_count entries)\n";
}

sub dump_fixed_with_extra {
    my ($filename, $start, $end, $width, $extra) = @_;
    my @lines = ();
    my $count = int((($end - $start) + 1) / $width);
    my %table = (%decode_table, %$extra);

    for (my $i = 0; $i < $count; $i++) {
        my $offset = $start + ($i * $width);
        my $record = substr($bytes, $offset, $width);
        my $trimmed = trim_record($record);
        my @raw = unpack("C*", $trimmed);
        my $decoded = "";

        for my $b (@raw) {
            my $hex = sprintf("%02X", $b);
            $decoded .= exists $table{$hex} ? $table{$hex} : "\\" . $hex;
        }

        push @lines, join("\t", $i, sprintf('$%06X', $offset), length($trimmed), $decoded);
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path ($count entries)\n";
}

sub dump_effect_names {
    my ($filename, $start, $end) = @_;
    my @lines = ();
    my $count = int((($end - $start) + 1) / 16);
    my %table = %decode_table;

    if ($mode eq "fr" || $mode eq "co") {
        %table = (%table, %b2c_effect_fr);
    } elsif ($mode eq "en") {
        %table = (%table, %b2c_effect_en);
    }

    for (my $i = 0; $i < $count; $i++) {
        my $offset = $start + ($i * 16);
        my $record = substr($bytes, $offset, 16);
        my $trimmed = trim_record($record);
        my $decoded = "";

        for my $b (unpack("C*", $trimmed)) {
            my $hex = sprintf("%02X", $b);
            $decoded .= exists $table{$hex} ? $table{$hex} : "\\" . $hex;
        }

        push @lines, join("\t", $i, sprintf('$%06X', $offset), length($trimmed), $decoded);
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path ($count entries)\n";
}

sub dump_item_names_menu {
    my ($filename, $start, $end) = @_;
    my @lines = ();
    my $offset = $start;
    my $index = 0;
    my %icon_markers = map { $_ => 1 } qw(AD AE BE BF C6 E3 E7 E8 E9 EA EB EC ED EE EF F0 F1 F2 F3 F4);
    my %table = %decode_table;

    if ($mode eq "en") {
        %table = (%table, %b2c_item_en);
    } elsif ($mode eq "fr" || $mode eq "co") {
        %table = (%table, %b2c_item_fr);
    }

    while ($offset + 9 <= $end + 1) {
        my $record = substr($bytes, $offset, 9);
        my @raw = unpack("C*", $record);
        my $marker = sprintf("%02X", $raw[0]);
        my $text = $icon_markers{$marker} ? substr($record, 1) : $record;
        my $trimmed = trim_record($text);
        my $decoded = "";
        for my $b (unpack("C*", $trimmed)) {
            my $hex = sprintf("%02X", $b);
            $decoded .= exists $table{$hex} ? $table{$hex} : "\\" . $hex;
        }

        if ($mode eq "en") {
            $decoded =~ s/^Orihalcn$/Orihalcon/;
            $decoded =~ s/^KillerBow$/Killer Bow/;
            $decoded =~ s/^Full Moon$/Full Moon/;
            $decoded =~ s/^AntiMagic$/AntiMagic/;
            $decoded =~ s/^L-Hand$/L-Hand/;
            $decoded =~ s/^R-Hand$/R-Hand/;
            $decoded =~ s/^\\ADem0+$/Dummy/;
        } else {
            $decoded =~ s/^Gaïa$/Gaïa/;
            $decoded =~ s/^Yoïchi$/Yoïchi/;
            $decoded =~ s/^Chaîne$/Chaîne/;
            $decoded =~ s/^Aig\. noir$/Aig. noir/;
            $decoded =~ s/^Chaînne$/Chaîne/;
            $decoded =~ s/^Main I$/Main G/;
            $decoded =~ s/^Dummy\\AF$/Dummy/;
        }

        push @lines, join("\t", $index++, sprintf('$%06X', $offset), length($trimmed), $decoded);
        $offset += 9;
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path (" . scalar(@lines) . " entries)\n";
}

dump_fixed("monster_names.txt",                 0x200000, 0x200F4F, 16);
dump_fixed("ability_names.txt",                 0x201150, 0x2013EF, 16);
dump_fixed("area_headings.txt",                 0x270000, 0x2708FF, 8);
dump_effect_names("effect_names.txt",           0x270900, 0x270F8F);
dump_fixed("magic_names_battle_menu.txt",       0x270F90, 0x27177F, 16);
dump_fixed("magic_names_battle_messages.txt",   0x271780, 0x27275F, 16);
dump_fixed("rare_items.txt",                    0x273560, 0x2736FF, 16);
dump_fixed("monster_specialties.txt",           0x273700, 0x273AF0, 16);
dump_pointer_table("item_descriptions.txt",     0x275100, 0x80, 0x275200);
dump_fixed("item_names_battle.txt",             0x275860, 0x27705F, 16);
dump_fixed("support_abilities_battle.txt",      0x277060, 0x27739F, 16);

dump_menu_shop("menu_shop.txt",                 0x272F00, 0x2733FF);
dump_item_names_menu("item_names_menu.txt",     0x111380, 0x111C7F);
dump_fixed("magic_names_field_menu.txt",        0x111C80, 0x111E87, 8);
dump_fixed("shop_names.txt",                    0x112D00, 0x112D3F, 8);
dump_fixed("character_names.txt",               0x115500, 0x11551D, 6);
dump_fixed("job_names.txt",                     0x115600, 0x1156AF, 8);
dump_fixed("support_abilities_menu.txt",        0x115800, 0x1159DF, 8);
dump_fixed("menu_ability_text.txt",             0x116200, 0x116307, 8);
