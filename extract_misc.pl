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

my %b2c_ability_en = (
    "C5" => "-",
);

my %b2c_ability_fr = (
    "52" => " ",
    "B5" => "œ",
);

my %b2c_ability_fr_words = (
    "A7B4" => "ôle",
    "D9DE" => "ou",
    "E4D4" => "tta",
    "E4E6" => "r",
    "E5DD" => "chi",
);

my %b2c_magic_menu_en = (
    "94" => "il",
    "95" => "it",
    "96" => " ",
    "97" => "li",
    "98" => "ll",
    "A4" => "ti",
    "AC" => "if",
    "AF" => "ir",
    "B0" => "tt",
    "C5" => "-",
    "C4" => "",
);

my %b2c_magic_menu_en_words = (
    "AD7A" => "lta",
    "AD93" => "ltz",
    "E3AD" => "It",
);

my %b2c_magic_menu_fr = (
    "52" => " ",
    "A6" => "it",
    "B0" => "il",
    "B1" => "ti",
    "B5" => "œ",
    "C4" => "",
);

my %b2c_magic_field_en = (
    %b2c_magic_menu_en,
    "E3" => "",
    "E4" => "",
    "E5" => "",
    "E6" => "",
);

my %b2c_magic_field_fr = (
    "52" => " ",
    "A6" => "it",
    "B0" => "il",
    "B1" => "ti",
    "B5" => "œ",
    "C4" => "",
);

my %b2c_magic_field_fr_words = (
    "B7BA" => "sid",
    "BBDE" => "aig",
    "D3D5" => "été",
    "D7D8" => "él",
    "E5B8" => "cla",
);

my %b2c_support_battle_en = (
    "C5" => "-",
    "CD" => "%",
    "96" => " ",
);

my %b2c_support_battle_fr = (
    "B5" => "œ",
    "CD" => "%",
    "E2" => "+",
    "F6" => " ",
);

my %b2c_menu_ability_en = (
    "96" => " ",
    "A4" => "ti",
    "C5" => "-",
    "CD" => "%",
    "E2" => "+",
);

my %b2c_menu_ability_fr = (
    "A3" => "p",
    "A4" => "ip",
    "A6" => "it",
    "B0" => "il",
    "B1" => "ti",
    "B5" => "œ",
    "CD" => "%",
    "E2" => "+",
);

my %b2c_monster_en = (
    "94" => "il",
    "95" => "it",
    "96" => " ",
    "97" => "li",
    "98" => "ll",
    "99" => "'",
    "A4" => "ti",
    "A5" => "fi",
    "A6" => "Bla",
    "A7" => "",
    "A8" => "pel",
    "AC" => "if",
    "AD" => "lt",
    "AE" => "tl",
    "AF" => "ir",
    "B0" => "tt",
);

my %b2c_monster_fr = (
    "52" => " ",
    "A6" => "it",
    "B0" => "il",
    "B2" => "li",
);

my %b2c_monster_fr_words = (
    "AFB4" => "ble",
    "D7D8" => "ir",
    "D9AC" => "l",
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
        ability_names.txt
        area_headings.txt
        effect_names.txt
        item_names_battle.txt
        item_descriptions.txt
        item_names_menu.txt
        magic_names_battle_menu.txt
        magic_names_battle_messages.txt
        magic_names_field_menu.txt
        menu_ability_text.txt
        menu_shop.txt
        monster_names.txt
        monster_specialties.txt
        rare_items.txt
        support_abilities_battle.txt
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

sub dump_fixed_count {
    my ($filename, $start, $count, $width) = @_;
    my @lines = ();

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
    my ($filename, $pointer_offset, $base_offset, $count) = @_;
    my @lines = ();
    my %table = (%decode_table, menu_shop_extra_table());
    my %words = menu_shop_word_table();

    for (my $index = 0; $index < $count; $index++) {
        my $raw = substr($bytes, $pointer_offset + ($index * 2), 2);
        my $start = unpack("v", $raw);
        my $offset = $base_offset + $start;
        my $record = "";
        my $j = $offset;

        while ($j < length($bytes)) {
            my $byte = substr($bytes, $j, 1);
            last if ord($byte) == 0x00;
            $record .= $byte;
            $j++;
        }

        my $trimmed = trim_record($record);
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
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path ($count entries)\n";
}

sub dump_offset_table_strings {
    my ($filename, $pointer_offset, $pointer_count, $base_offset, $eol_byte) = @_;
    my @lines = ();
    for (my $i = 0; $i < $pointer_count; $i++) {
        my $raw = substr($bytes, $pointer_offset + ($i * 2), 2);
        my $start = unpack("v", $raw);
        my $offset = $base_offset + $start;
        my $record = "";
        my $j = $offset;

        while ($j < length($bytes)) {
            my $byte = substr($bytes, $j, 1);
            last if ord($byte) == $eol_byte;
            $record .= $byte;
            $j++;
        }

        my $decoded = decode($record);
        push @lines, join("\t", $i, sprintf('$%06X', $offset), length($record), $decoded);
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path ($pointer_count entries)\n";
}

sub dump_offset_span_table {
    my ($filename, $pointer_offset, $pointer_count, $base_offset, $final_limit) = @_;
    my @offsets = ();
    my @lines = ();

    for (my $i = 0; $i < $pointer_count; $i++) {
        my $raw = substr($bytes, $pointer_offset + ($i * 2), 2);
        push @offsets, unpack("v", $raw);
    }
    push @offsets, $final_limit;

    for (my $i = 0; $i < $pointer_count; $i++) {
        my $start = $offsets[$i];
        my $next = $offsets[$i + 1];
        my $length = $next - $start;
        my $offset = $base_offset + $start;
        my $record = substr($bytes, $offset, $length);
        if ($i == $pointer_count - 1) {
            my $end_pos = index($record, "END");
            next if $end_pos >= 0;
        }
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

sub dump_fixed_count_with_extra {
    my ($filename, $start, $count, $width, $extra) = @_;
    my @lines = ();
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

sub dump_ability_names {
    my ($filename, $start, $end) = @_;
    my @lines = ();
    my $width = 7;
    my $count = int((($end - $start) + 1) / $width);
    my %table = %decode_table;
    my %words = ();

    if ($mode eq "en") {
        %table = (%table, %b2c_ability_en);
    } elsif ($mode eq "fr" || $mode eq "co") {
        %table = (%table, %b2c_ability_fr);
        %words = %b2c_ability_fr_words;
    }

    for (my $i = 0; $i < $count; $i++) {
        my $offset = $start + ($i * $width);
        my $record = substr($bytes, $offset, $width);
        my $trimmed = trim_record($record);
        my @raw = unpack("C*", $trimmed);
        my $decoded = "";

        for (my $j = 0; $j < @raw; $j++) {
            my $hex = sprintf("%02X", $raw[$j]);

            if ($j + 1 < @raw) {
                my $pair = $hex . sprintf("%02X", $raw[$j + 1]);
                if (exists $words{$pair}) {
                    $decoded .= $words{$pair};
                    $j++;
                    next;
                }
            }

            $decoded .= exists $table{$hex} ? $table{$hex} : "\\" . $hex;
        }

        $decoded =~ s/^ +$//;

        if ($mode eq "fr" || $mode eq "co") {
            $decoded =~ s/^Tooueri$/Toucher/;
            $decoded =~ s/^Contrôle$/Contrôle/;
            $decoded =~ s/^Alchimie$/Alchimie/;
            $decoded =~ s/^Cacher$/Cacher/;
        }

        push @lines, join("\t", $i, sprintf('$%06X', $offset), length($trimmed), $decoded);
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path ($count entries)\n";
}

sub dump_magic_names_battle_menu {
    my ($filename, $start, $end) = @_;
    my @lines = ();
    my $width = 12;
    my $count = int((($end - $start) + 1) / $width);
    my %table = %decode_table;
    my %words = ();

    if ($mode eq "en") {
        %table = (%table, %b2c_magic_menu_en);
        %words = %b2c_magic_menu_en_words;
    } elsif ($mode eq "fr" || $mode eq "co") {
        %table = (%table, %b2c_magic_menu_fr);
    }

    for (my $i = 0; $i < $count; $i++) {
        my $offset = $start + ($i * $width);
        my $record = substr($bytes, $offset, $width);
        my $trimmed = trim_record($record);
        my @raw = unpack("C*", $trimmed);
        my $decoded = "";

        for (my $j = 0; $j < @raw; $j++) {
            my $hex = sprintf("%02X", $raw[$j]);

            if ($j + 1 < @raw) {
                my $pair = $hex . sprintf("%02X", $raw[$j + 1]);
                if (exists $words{$pair}) {
                    $decoded .= $words{$pair};
                    $j++;
                    next;
                }
            }

            $decoded .= exists $table{$hex} ? $table{$hex} : "\\" . $hex;
        }

        $decoded =~ s/^ +//;
        $decoded =~ s/ +$//;

        if ($mode eq "en") {
            $decoded =~ s/^\\ADemMagic0\d$/Item Magic/;
            $decoded =~ s/^Power$/Power/;
            $decoded =~ s/^Speed$/Speed/;
            $decoded =~ s/^Vitality$/Vitality/;
            $decoded =~ s/^Magic$/Magic/;
            $decoded =~ s/^Whisper Wind$/Whisper Wind/;
            $decoded =~ s/^Earth Wall$/Earth Wall/;
            $decoded =~ s/^Waterbug$/Jitterbug/ if $decoded eq "WaltzJitterbug" || $decoded eq "Waltz Jitterbug";
            $decoded =~ s/^WaltzJitterbug$/Waltz Jitterbug/;
            $decoded =~ s/^MagicBarrier$/Magic Barrier/;
            $decoded =~ s/^MagictBarrier$/Magic Barrier/;
            $decoded =~ s/^Fight$/Fight/;
            $decoded =~ s/^Specialty$/Specialty/;
            $decoded =~ s/^White Wind$/White Wind/;
            $decoded =~ s/^GblinPunch$/GoblinPunch/;
            $decoded =~ s/^Attack$/Attack/;
            $decoded =~ s/^Delta Attack$/Delta Attack/;
            $decoded =~ s/^Targeting$/Targeting/;
            $decoded =~ s/^No-Dmg Magic$/No-Dmg Magic/;
            $decoded =~ s/^Variant Atak$/Variant Atak/;
            $decoded =~ s/^ItemMagic0(\d)$/Item Magic 0$1/;
            $decoded =~ s/^ItemMagic$/Item Magic/;
        } else {
            $decoded =~ s/^Ga!a$/Gaïa/;
            $decoded =~ s/^Ga!a Muraille$/Gaïa Muraille/;
            $decoded =~ s/^Lance S\\BBïenée$/Lance Saignée/;
            $decoded =~ s/^Coûûû’$/Coûûû’/;
            $decoded =~ s/^Séduc\B1on$/Séduction/;
            $decoded =~ s/^Diges\B1on$/Digestion/;
            $decoded =~ s/^Electrocu\B1on$/Electrocution/;
            $decoded =~ s/^Ypér\A6e$/Hypérite/;
            $decoded =~ s/^Fu\A6e$/Fuite/;
            $decoded =~ s/^Espr\A6$/Esprit/;
        }

        push @lines, join("\t", $i, sprintf('$%06X', $offset), length($trimmed), $decoded);
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path ($count entries)\n";
}

sub normalize_magic_field_entry {
    my ($mode, $index, $decoded) = @_;

    $decoded =~ s/^ +//;
    $decoded =~ s/ +$//;

    if ($mode eq "en") {
        $decoded =~ s/^Sylph $/Sylph/;
        $decoded =~ s/^Shiva $/Shiva/;
        $decoded =~ s/^Ramuh $/Ramuh/;
        $decoded =~ s/^Ifrit $/Ifrit/;
        $decoded =~ s/^Titan $/Titan/;
        $decoded =~ s/^Golem $/Golem/;
        $decoded =~ s/^Odin  $/Odin/;
        return $decoded;
    }

    $decoded =~ s/^Feu   $/Feu/;
    $decoded =~ s/^Glace $/Glace/;
    $decoded =~ s/^Venin $/Venin/;
    $decoded =~ s/^Sommeil$/Sommeil/;
    $decoded =~ s/^Saignée$/Saignée/;
    $decoded =~ s/^Fossile$/Fossile/;
    $decoded =~ s/^sidéral$/Sidéral/;
    $decoded =~ s/^Récup$/Récup/;
    $decoded =~ s/^Vitesse$/Vitesse/;
    $decoded =~ s/^Léviter$/Léviter/;
    $decoded =~ s/^M!étéîte$/Météo/;
    $decoded =~ s/^Météîte$/Météo/;
    $decoded =~ s/^Célrité$/Célérité/;
    $decoded =~ s/^Catob\.Ah$/Catob. Ah/;
    $decoded =~ s/^Syldra$/Syldra/;
    $decoded =~ s/^Baha$/Baha/;
    return $decoded;
}

sub dump_magic_names_field_menu {
    my ($filename, $start, $end) = @_;
    my @lines = ();
    my $offset = $start;
    my $index = 0;

    my %table = %decode_table;
    my %words = ();

    if ($mode eq "en") {
        %table = (%table, %b2c_magic_field_en);
    } elsif ($mode eq "fr" || $mode eq "co") {
        %table = (%table, %b2c_magic_field_fr);
        %words = %b2c_magic_field_fr_words;
    }

    for (my $i = 0; $i < 72; $i++) {
        my $record = substr($bytes, $offset, 6);
        my $trimmed = trim_record($record);
        my @raw = unpack("C*", $trimmed);
        my $decoded = "";

        for (my $j = 0; $j < @raw; $j++) {
            my $hex = sprintf("%02X", $raw[$j]);

            if ($j + 1 < @raw) {
                my $pair = $hex . sprintf("%02X", $raw[$j + 1]);
                if (exists $words{$pair}) {
                    $decoded .= $words{$pair};
                    $j++;
                    next;
                }
            }

            $decoded .= exists $table{$hex} ? $table{$hex} : "\\" . $hex;
        }

        $decoded = normalize_magic_field_entry($mode, $index, $decoded);
        push @lines, join("\t", $index++, sprintf('$%06X', $offset), length($trimmed), $decoded);
        $offset += 6;
    }

    while ($offset <= $end) {
        my $remaining = ($end - $offset) + 1;
        my $width = $remaining >= 6 ? 6 : $remaining;
        my $record = substr($bytes, $offset, $width);
        my $trimmed = trim_record($record);
        my $decoded = "";

        for my $b (unpack("C*", $trimmed)) {
            my $hex = sprintf("%02X", $b);
            $decoded .= exists $table{$hex} ? $table{$hex} : "\\" . $hex;
        }

        $decoded = normalize_magic_field_entry($mode, $index, $decoded);
        push @lines, join("\t", $index++, sprintf('$%06X', $offset), length($trimmed), $decoded);
        $offset += 6;
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path (" . scalar(@lines) . " entries)\n";
}

sub dump_support_abilities_battle {
    my ($filename, $start, $count, $width) = @_;
    my @lines = ();
    my %table = %decode_table;

    if ($mode eq "en") {
        %table = (%table, %b2c_support_battle_en);
    } elsif ($mode eq "fr" || $mode eq "co") {
        %table = (%table, %b2c_support_battle_fr);
    }

    for (my $i = 0; $i < $count; $i++) {
        my $offset = $start + ($i * $width);
        my $record = substr($bytes, $offset, $width);
        my $trimmed = trim_record($record);
        my $decoded = "";
        for my $b (unpack("C*", $trimmed)) {
            my $hex = sprintf("%02X", $b);
            $decoded .= exists $table{$hex} ? $table{$hex} : "\\" . $hex;
        }

        if ($mode eq "en") {
            $decoded =~ s/^2-handed Grip$/2-handed Grip/;
        } else {
            $decoded =~ s/^œil lynx$/Œil lynx/;
        }

        push @lines, join("\t", $i, sprintf('$%06X', $offset), length($trimmed), $decoded);
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path ($count entries)\n";
}

sub dump_menu_ability_text {
    my ($filename, $start, $count, $width) = @_;
    my @lines = ();
    my %table = %decode_table;

    if ($mode eq "en") {
        %table = (%table, %b2c_menu_ability_en);
    } elsif ($mode eq "fr" || $mode eq "co") {
        %table = (%table, %b2c_menu_ability_fr);
    }

    for (my $i = 0; $i < $count; $i++) {
        my $offset = $start + ($i * $width);
        my $record = substr($bytes, $offset, $width);
        my $trimmed = trim_record($record);
        my $decoded = "";

        for my $b (unpack("C*", $trimmed)) {
            my $hex = sprintf("%02X", $b);
            $decoded .= exists $table{$hex} ? $table{$hex} : "\\" . $hex;
        }

        if ($mode eq "en") {
            $decoded =~ s/^Equip (.+)$/Equip $1/;
            $decoded =~ s/^HP\+10%$/HP +10%/;
            $decoded =~ s/^HP\+20%$/HP +20%/;
            $decoded =~ s/^HP\+30%$/HP +30%/;
            $decoded =~ s/^MP\+10%$/MP +10%/;
            $decoded =~ s/^MP\+30%$/MP +30%/;
            $decoded =~ s/^Dbl Grip$/Dbl Grip/;
            $decoded =~ s/^2-Handed$/2-Handed/;
            $decoded =~ s/^Preemptiv$/Preemptive/;
            $decoded =~ s/^DmgFloor$/Damage Floor/;
        } else {
            $decoded =~ s/^HP\+10%$/HP +10%/;
            $decoded =~ s/^HP\+20%$/HP +20%/;
            $decoded =~ s/^HP\+30%$/HP +30%/;
            $decoded =~ s/^MP\+10%$/MP +10%/;
            $decoded =~ s/^MP\+30%$/MP +30%/;
            $decoded =~ s/^Initive$/Initiative/;
            $decoded =~ s/^œil lynx$/Œil lynx/;
        }

        push @lines, join("\t", $i, sprintf('$%06X', $offset), length($trimmed), $decoded);
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path ($count entries)\n";
}

sub dump_monster_names {
    my ($filename, $start, $count, $width) = @_;
    my @lines = ();
    my %table = %decode_table;
    my %words = ();

    if ($mode eq "en") {
        %table = (%table, %b2c_monster_en);
    } else {
        %table = (%table, %b2c_monster_fr);
        %words = %b2c_monster_fr_words;
    }

    for (my $i = 0; $i < $count; $i++) {
        my $offset = $start + ($i * $width);
        my $record = substr($bytes, $offset, $width);
        my $trimmed = trim_record($record);
        my @raw = unpack("C*", $trimmed);
        my $decoded = "";

        for (my $j = 0; $j < @raw; $j++) {
            my $hex = sprintf("%02X", $raw[$j]);

            if ($j + 1 < @raw) {
                my $pair = $hex . sprintf("%02X", $raw[$j + 1]);
                if (exists $words{$pair}) {
                    $decoded .= $words{$pair};
                    $j++;
                    next;
                }
            }

            $decoded .= exists $table{$hex} ? $table{$hex} : "\\" . $hex;
        }

        push @lines, join("\t", $i, sprintf('$%06X', $offset), length($trimmed), $decoded);
    }

    my $path = output_path($filename);
    write_text($path, join("\n", @lines) . "\n");
    print "$path ($count entries)\n";
}

dump_monster_names("monster_names.txt",         0x200050, 384, 10);
dump_ability_names("ability_names.txt",         0x201150, 0x2013EF);
dump_offset_span_table("area_headings.txt",     0x107000, 164, 0x270000, 2304);
dump_effect_names("effect_names.txt",           0x270900, 0x270F8F);
dump_magic_names_battle_menu("magic_names_battle_menu.txt", 0x270F90, 0x27177F);
dump_fixed_count("magic_names_battle_messages.txt", 0x271780, 169, 24);
dump_fixed_count_with_extra("rare_items.txt",   0x273568, 24, 13, ($mode eq "en" ? \%b2c_item_en : \%b2c_item_fr));
dump_fixed_count("monster_specialties.txt",     0x273700, 64, 16);
dump_offset_table_strings("item_descriptions.txt", 0x114000, 0x80, 0x110000, 0x00);
dump_fixed_count_with_extra("item_names_battle.txt", 0x275860, 256, 24, ($mode eq "en" ? \%b2c_item_en : \%b2c_item_fr));
dump_support_abilities_battle("support_abilities_battle.txt", 0x277060, 33, 24);

dump_menu_shop("menu_shop.txt",                 0x00F987, 0x270000, 139);
dump_item_names_menu("item_names_menu.txt",     0x111380, 0x111C7F);
dump_magic_names_field_menu("magic_names_field_menu.txt", 0x111C80, 0x111E87);
dump_fixed("shop_names.txt",                    0x112D00, 0x112D3F, 8);
dump_fixed("character_names.txt",               0x115500, 0x11551D, 6);
dump_fixed("job_names.txt",                     0x115600, 0x1156AF, 8);
dump_menu_ability_text("menu_ability_text.txt", 0x116200, 33, 8);
