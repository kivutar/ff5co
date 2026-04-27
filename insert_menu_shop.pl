use utf8;
use open qw(:std :encoding(UTF-8));
use File::Slurper qw(read_binary write_binary);

my $mode = $ARGV[0] // "co";
my $script_file = $ARGV[1] // "texts/$mode/menu_shop.txt";
my $output_rom = $ARGV[2] // ($mode eq "fr" ? "ff5fr.sfc" : "ff5co.sfc");
my $base_rom = "ff5fr.sfc";
my $reference_file = "texts/fr/menu_shop.txt";

my $pointer_offset = 0x00F987;
my $pointer_count = 139;
my $base_offset = 0x270000;
my $text_start = 0x272F00;
my $text_end = 0x2733FF;
my $text_start_rel = $text_start - $base_offset;
my $text_capacity = ($text_end - $text_start) + 1;

my %c2b_base = (
    "A" => "60", "B" => "61", "C" => "62", "D" => "63", "E" => "64", "F" => "65",
    "G" => "66", "H" => "67", "I" => "68", "J" => "69", "K" => "6A", "L" => "6B",
    "M" => "6C", "N" => "6D", "O" => "6E", "P" => "6F", "Q" => "70", "R" => "71",
    "S" => "72", "T" => "73", "U" => "74", "V" => "75", "W" => "76", "X" => "77",
    "Y" => "78", "Z" => "79",
    "0" => "53", "1" => "54", "2" => "55", "3" => "56", "4" => "57",
    "5" => "58", "6" => "59", "7" => "5A", "8" => "5B", "9" => "5C",
    "a" => "7A", "b" => "7B", "c" => "7C", "d" => "7D", "e" => "7E", "f" => "7F",
    "g" => "80", "h" => "81", "i" => "82", "j" => "83", "k" => "84", "l" => "85",
    "m" => "86", "n" => "87", "o" => "88", "p" => "89", "q" => "8A", "r" => "8B",
    "s" => "8C", "t" => "8D", "u" => "8E", "v" => "8F", "w" => "90", "x" => "91",
    "y" => "92", "z" => "93",
    "'" => "99", "’" => "C9", "\"" => "9A", ":" => "AB", "," => "AD",
    "(" => "9E", ")" => "9F", "/" => "A0", "-" => "C5", " " => "FF",
    "!" => "9B", "?" => "A2", "." => "A5", "%" => "CD",
    "à" => "98", "â" => "97", "ç" => "95", "Ç" => "94", "é" => "99", "è" => "9A",
    "ê" => "9C", "ù" => "9D", "û" => "9F", "ô" => "9E", "œ" => "A9",
    "«" => "D0", "»" => "D1",
);

my %c2b_co = (
    %c2b_base,
    "ì" => "9C",
    "ò" => "9E",
);

my %special_tokens = (
    "[ColorPreview]" => "0A080808080808080810",
);

sub parse_table {
    my ($path) = @_;
    my @lines = ();
    open(my $fh, "<", $path) or die "Could not open $path: $!\n";
    while (my $line = <$fh>) {
        chomp $line;
        my ($index, $offset, $rawlen, $text) = split(/\t/, $line, 4);
        $text = "" if !defined $text;
        push @lines, $text;
    }
    close($fh);
    return @lines;
}

sub read_menu_entry_bytes {
    my ($bytes, $index) = @_;
    my $raw = substr($bytes, $pointer_offset + ($index * 2), 2);
    my $start = unpack("v", $raw);
    my $offset = $base_offset + $start;
    my $record = "";

    while ($offset < length($bytes)) {
        my $byte = substr($bytes, $offset, 1);
        last if ord($byte) == 0x00;
        $record .= $byte;
        $offset++;
    }

    return $record;
}

sub encode_menu_text {
    my ($text) = @_;

    return pack("H*", $special_tokens{$text}) if exists $special_tokens{$text};

    my $bytes = "";
    my $source = $text;
    my %map = $mode eq "co" ? %c2b_co : %c2b_base;

    while (length($source) > 0) {
        if ($source =~ s/^\\([0-9A-Fa-f]{2})//) {
            $bytes .= pack("H*", uc($1));
            next;
        }

        my $char = substr($source, 0, 1, "");
        die "Unsupported menu_shop character '$char' in '$text'\n"
            if !exists $map{$char};
        $bytes .= pack("H*", $map{$char});
    }

    return $bytes;
}

my @reference_lines = parse_table($reference_file);
my @target_lines = parse_table($script_file);

die "Expected $pointer_count lines in $reference_file, got " . scalar(@reference_lines) . "\n"
    if scalar(@reference_lines) != $pointer_count;
die "Expected $pointer_count lines in $script_file, got " . scalar(@target_lines) . "\n"
    if scalar(@target_lines) != $pointer_count;

my $base_bytes = read_binary($base_rom);
my $output_bytes = read_binary($output_rom);
my @reference_raw = map { read_menu_entry_bytes($base_bytes, $_) } 0 .. $pointer_count - 1;

my $pointer_bytes = "";
my $text_bytes = "";
my $current_rel = $text_start_rel;

for my $i (0 .. $pointer_count - 1) {
    my $text = $target_lines[$i];
    my $encoded = $text eq $reference_lines[$i]
        ? $reference_raw[$i]
        : encode_menu_text($text);

    $pointer_bytes .= pack("v", $current_rel);
    $text_bytes .= $encoded . "\x00";
    $current_rel += length($encoded) + 1;
}

die "menu_shop block too large: " . length($text_bytes) . " > $text_capacity bytes\n"
    if length($text_bytes) > $text_capacity;

substr($output_bytes, $pointer_offset, length($pointer_bytes)) = $pointer_bytes;
substr($output_bytes, $text_start, $text_capacity) = $text_bytes . ("\x00" x ($text_capacity - length($text_bytes)));

write_binary($output_rom, $output_bytes);
print "Inserted $pointer_count menu_shop strings from $script_file into $output_rom at "
    . sprintf('$%06X-$%06X', $text_start, $text_end) . " (" . length($text_bytes) . "/$text_capacity bytes)\n";
