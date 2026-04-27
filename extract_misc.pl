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

my %b2c_menu = (
    "11" => "pt",
    "12" => "i",
    "13" => "m",
    "14" => "um",
    "16" => "Ret",
    "17" => "ir",
    "18" => "er",
    "19" => "",
    "1A" => "",
    "34" => "F",
    "35" => "o",
    "36" => "r",
    "37" => "m",
    "38" => ".",
    "94" => "i",
    "A3" => "u",
    "A4" => "ip",
    "B0" => "ui",
    "B1" => "ti",
    "D6" => "P",
    "DB" => "M",
    "DC" => "P",
    "DF" => "ns",
    "E4" => "tt",
    "E6" => "ll",
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

sub dump_item_names_menu {
    my ($filename, $start, $end) = @_;
    my @lines = ();
    my $offset = $start;
    my $index = 0;
    my %icon_markers = map { $_ => 1 } qw(BE BF E3 E7 E8 E9 EA EB EC ED EE EF F0 F1 F2 F3 F4);
    my %table = (%decode_table, "94" => "i", "95" => "n");

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
dump_fixed("effect_names.txt",                  0x270900, 0x270F8F, 16);
dump_fixed("magic_names_battle_menu.txt",       0x270F90, 0x27177F, 16);
dump_fixed("magic_names_battle_messages.txt",   0x271780, 0x27275F, 16);
dump_fixed("rare_items.txt",                    0x273560, 0x2736FF, 16);
dump_fixed("monster_specialties.txt",           0x273700, 0x273AF0, 16);
dump_pointer_table("item_descriptions.txt",     0x275100, 0x80, 0x275200);
dump_fixed("item_names_battle.txt",             0x275860, 0x27705F, 16);
dump_fixed("support_abilities_battle.txt",      0x277060, 0x27739F, 16);

dump_zero_split_with_extra("menu_shop.txt",     0x272F00, 0x2733FF, \%b2c_menu);
dump_item_names_menu("item_names_menu.txt",     0x111380, 0x111C7F);
dump_fixed("magic_names_field_menu.txt",        0x111C80, 0x111E87, 8);
dump_fixed("shop_names.txt",                    0x112D00, 0x112D3F, 8);
dump_fixed("character_names.txt",               0x115500, 0x11551D, 6);
dump_fixed("job_names.txt",                     0x115600, 0x1156AF, 8);
dump_fixed("support_abilities_menu.txt",        0x115800, 0x1159DF, 8);
dump_fixed("menu_ability_text.txt",             0x116200, 0x116307, 8);
