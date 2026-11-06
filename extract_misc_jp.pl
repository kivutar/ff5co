use strict;
use warnings;
use utf8;
use open qw(:std :encoding(UTF-8));
use File::Slurper qw(read_binary write_text);
use File::Path qw(make_path);
use FindBin;
use lib $FindBin::Bin;
use FF5Japanese qw(decode_misc);

die "Usage: perl extract_misc.pl jp [rom.sfc [output_dir]]\n" if @ARGV > 2;
my ($rom, $output_dir) = @ARGV;
$rom //= "ff5jp.sfc";
$output_dir //= "texts/jp";
my $bytes = read_binary($rom);
substr($bytes, 0, 512, "") if length($bytes) == 0x200200;
die "$rom must be an original 2 MiB Japanese ROM\n" unless length($bytes) == 0x200000;
my %outputs;

sub read_range {
    my ($offset, $size) = @_;
    die sprintf("Japanese ROM range out of bounds: \$%06X + %d\n", $offset, $size)
        if $offset < 0 || $size < 0 || $offset + $size > length($bytes);
    return substr($bytes, $offset, $size);
}

sub row {
    my ($index, $offset, $record, $context) = @_;
    return join("\t", $index, sprintf('$%06X', $offset), length($record),
        decode_misc($record, $context));
}

sub dump_fixed_jp {
    my ($name, $start, $count, $width) = @_;
    my @rows;
    for my $index (0 .. $count - 1) {
        my $offset = $start + $index * $width;
        my $record = read_range($offset, $width);
        $record =~ s/\x00.*$//s;
        $record =~ s/\xFF+$//;
        push @rows, row($index, $offset, $record, "fixed");
    }
    $outputs{$name} = \@rows;
}

sub read_terminated {
    my ($offset, $end, $context) = @_;
    my $record = "";
    for (my $cursor = $offset; $cursor < $end; $cursor++) {
        my $byte = ord(read_range($cursor, 1));
        return $record if $byte == 0;
        $record .= chr($byte);

        # Kanji and battle controls have an argument that may itself be zero.
        if ($context eq "message" &&
            ($byte == 0x05 || $byte == 0x10 || $byte == 0x1E || $byte == 0x1F)) {
            die sprintf("Truncated Japanese text code at \$%06X\n", $cursor)
                if ++$cursor >= $end;
            $record .= read_range($cursor, 1);
        }
    }
    die sprintf("Unterminated Japanese string at \$%06X\n", $offset);
}

sub dump_pointers_jp {
    my ($name, $table, $count, $base, $start, $end, $context, $spans) = @_;
    my @pointers = unpack("v*", read_range($table, 2 * ($count + ($spans ? 1 : 0))));
    # These UI labels load Latin glyphs into the voiced-kana slots.
    my %latin_menu_ids = map { $_ => 1 } (1, 2, 13, 20, 82, 90, 109, 110, 111);
    my @rows;
    for my $index (0 .. $count - 1) {
        my $offset = $base + $pointers[$index];
        die sprintf("%s[%d] points outside its text block: \$%06X\n", $name, $index, $offset)
            if $offset < $start || $offset >= $end;
        my $record;
        if ($spans) {
            my $next = $base + $pointers[$index + 1];
            die "Invalid Japanese $name span at index $index\n"
                if $next < $offset || $next > $end;
            $record = read_range($offset, $next - $offset);
        } else {
            $record = read_terminated($offset, $end, $context);
        }
        my $row_context = $context eq "menu" && $latin_menu_ids{$index}
            ? "menu_latin" : $context;
        push @rows, row($index, $offset, $record, $row_context);
    }
    $outputs{$name} = \@rows;
}

# Layouts: everything8215/ff5, tools/rip_list_jp.json and src/text/*_jp.json.
# RPGe menu/battle copies share these original tables; keep matching record IDs.
my @fixed_tables = (
    ["monster_names",               0x105C00, 384, 8],
    ["monster_specialties",         0x108700, 64, 8],
    ["ability_names",               0x115800, 96, 5],
    ["item_names_menu",             0x111380, 256, 9],
    ["item_names_battle",           0x111380, 256, 9],
    ["magic_names_field_menu",      0x111C80, 87, 6],
    ["magic_names_battle_menu",     0x111E8A, 169, 9],
    ["magic_names_battle_messages", 0x111E8A, 169, 9],
    ["song_names",                  0x111E8A, 8, 9],
    ["blue_magic_names",            0x11200D, 30, 9],
    ["effect_names",                0x116700, 105, 9],
    ["concepts_misc",               0x1128B6, 24, 8],
    ["shop_names",                  0x112D00, 8, 8],
    ["character_names",             0x115500, 5, 6],
    ["job_names",                   0x115600, 22, 8],
    ["menu_ability_text",           0x116200, 33, 8],
    ["support_abilities_battle",    0x116200, 33, 8],
    # The original 32-slot key-item table has eight leading unused slots.
    ["rare_items",                  0x00E540, 24, 8],
);
dump_fixed_jp(@$_) for @fixed_tables;

dump_pointers_jp("area_headings", 0x107000, 163, 0x107200,
    0x107200, 0x107668, "message", 1);
dump_pointers_jp("menu_shop", 0x00F987, 139, 0x000000,
    0x00FA9D, 0x00FEBB, "menu");
# The remaining 175 battle-message pointers all refer to the same empty string.
dump_pointers_jp("battle_messages", 0x1139A9, 81, 0x110000,
    0x113BA9, 0x113F0E, "message");
dump_pointers_jp("item_descriptions", 0x114000, 128, 0x110000,
    0x114100, 0x1143FE, "message");
dump_pointers_jp("battle_dialog", 0x10F000, 234, 0x100000,
    0x10F1D4, 0x10FEBC, "message");
dump_pointers_jp("job_descriptions", 0x117140, 22, 0x110000,
    0x11724A, 0x117337, "message");
dump_pointers_jp("ability_descriptions", 0x11716C, 111, 0x110000,
    0x117337, 0x1177BA, "message");

make_path($output_dir) unless -d $output_dir;
for my $name (sort keys %outputs) {
    my $path = "$output_dir/$name.txt";
    write_text($path, join("\n", @{$outputs{$name}}) . "\n");
    printf "%s (%d entries)\n", $path, scalar @{$outputs{$name}};
}
print "battle_record_text: no Japanese table (RPGe addition)\n";
