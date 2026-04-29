use utf8;
use open qw(:std :encoding(UTF-8));
use File::Slurper qw(read_binary write_binary);

my $mode = $ARGV[0] // "co";
my $script_file = $ARGV[1] // "texts/$mode/battle_messages.txt";
my $output_rom = $ARGV[2] // ($mode eq "fr" ? "ff5fr.sfc" : "ff5co.sfc");
my $base_rom = "ff5fr.sfc";
my $reference_file = "texts/fr/battle_messages.txt";

my $count = 81;
my $pointer_offset = 0x1139A9;
my $base_offset = 0x270000;
my $start_rel = 0x2760;
my $text_start = $base_offset + $start_rel;
my $text_capacity = 1646;
my $eol_byte = 0x00;
my $escape_byte = 0x10;

my %c2b_base = (
    ">" => "01",
    "|" => "00",
    "[Bartz]" => "02",
    "[TAB1]" => "08",
    "[TAB2]" => "09",
    "[TAB3]" => "0A",
    "[FixedPause]" => "0C",
    "[AutoClose]" => "0F",
    "[DialogueGil]" => "10",
    "[DialogueItem]" => "11",
    "[DialogueAbility]" => "12",
    "[Wait]" => "17",
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
    "!" => "9B", "?" => "A2", "." => "A5",
    "à" => "98", "â" => "97", "ç" => "95", "Ç" => "94", "é" => "99", "è" => "9A",
    "ê" => "9C", "ù" => "9D", "û" => "9F", "ô" => "9E", "œ" => "A9",
    "…" => "A8", "«" => "D0", "»" => "D1",
);

my %c2b_co = (
    %c2b_base,
    "'" => "D6",
    "’" => "D6",
    "ì" => "9C",
    "ò" => "9E",
);

my %multi = (
    "[Bartz]" => "02",
    "[TAB1]" => "08",
    "[TAB2]" => "09",
    "[TAB3]" => "0A",
    "[FixedPause]" => "0C",
    "[AutoClose]" => "0F",
    "[DialogueGil]" => "10",
    "[DialogueItem]" => "11",
    "[DialogueAbility]" => "12",
    "[Wait]" => "17",
    "[P1]" => "1701",
    "[P2]" => "1702",
    "[P3]" => "1703",
    "[P4]" => "1704",
    "[P5]" => "1705",
    "[P6]" => "1706",
    "il"   => "B0",
    "li"   => "B2",
    "ll"   => "B3",
    "ît"   => "B6",
    "ìt"   => "B6",
    "ïe"   => "BA",
    "œ"    => "A9",
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

sub read_battle_message_bytes {
    my ($bytes, $index) = @_;
    my $rel = unpack("v", substr($bytes, $pointer_offset + ($index * 2), 2));
    my $offset = $base_offset + $rel;
    my $record = "";
    my $prev = undef;

    while ($offset < length($bytes)) {
        my $byte = ord(substr($bytes, $offset, 1));
        if ($byte == $eol_byte) {
            last if !defined($prev) || $prev != $escape_byte;
        }
        $record .= chr($byte);
        $prev = $byte;
        $offset++;
    }

    return $record;
}

sub encode_best {
    my ($text, $map_ref) = @_;
    my %memo;
    my @tokens = sort {
        length($b->[0]) <=> length($a->[0]) ||
        length(pack("H*", $a->[1])) <=> length(pack("H*", $b->[1]))
    } map { [$_, $multi{$_}] } keys %multi;

    my $solve;
    $solve = sub {
        my ($source) = @_;
        return "" if $source eq "";
        return $memo{$source} if exists $memo{$source};

        my $best;

        if ($source =~ /^\\([0-9A-Fa-f]{2})(.*)$/) {
            my $rest = $solve->($2);
            if (defined $rest) {
                $best = pack("H*", uc($1)) . $rest;
            }
        }

        for my $entry (@tokens) {
            my ($token, $hex) = @$entry;
            next if index($source, $token) != 0;
            my $rest = $solve->(substr($source, length($token)));
            next if !defined $rest;
            my $candidate = pack("H*", $hex) . $rest;
            if (!defined($best) || length($candidate) < length($best)) {
                $best = $candidate;
            }
        }

        if (length($source) > 0) {
            my $char = substr($source, 0, 1);
            if (exists $map_ref->{$char}) {
                my $rest = $solve->(substr($source, 1));
                if (defined $rest) {
                    my $candidate = pack("H*", $map_ref->{$char}) . $rest;
                    if (!defined($best) || length($candidate) < length($best)) {
                        $best = $candidate;
                    }
                }
            }
        }

        $memo{$source} = $best;
        return $best;
    };

    return $solve->($text);
}

my @reference_lines = parse_table($reference_file);
my @target_lines = parse_table($script_file);

die "Expected $count lines in $reference_file, got " . scalar(@reference_lines) . "\n"
    if scalar(@reference_lines) != $count;
die "Expected $count lines in $script_file, got " . scalar(@target_lines) . "\n"
    if scalar(@target_lines) != $count;

my $base_bytes = read_binary($base_rom);
my $output_bytes = read_binary($output_rom);
my %map = $mode eq "co" ? %c2b_co : %c2b_base;

my @reference_raw = map { read_battle_message_bytes($base_bytes, $_) } 0 .. $count - 1;

my $pointer_bytes = "";
my $text_bytes = "";
my $rel = $start_rel;

for my $i (0 .. $count - 1) {
    my $text = $target_lines[$i];
    my $encoded = $text eq $reference_lines[$i]
        ? $reference_raw[$i]
        : encode_best($text, \%map);

    die "Unsupported battle_messages text '$text' at index $i\n" if !defined $encoded;

    $pointer_bytes .= pack("v", $rel);
    $text_bytes .= $encoded . "\x00";
    $rel += length($encoded) + 1;
}

die "battle_messages block too large: " . length($text_bytes) . " > $text_capacity bytes\n"
    if length($text_bytes) > $text_capacity;

substr($output_bytes, $pointer_offset, length($pointer_bytes)) = $pointer_bytes;
substr($output_bytes, $text_start, $text_capacity) = $text_bytes . ("\x00" x ($text_capacity - length($text_bytes)));

write_binary($output_rom, $output_bytes);
print "Inserted $count battle_messages strings from $script_file into $output_rom at "
    . sprintf('$%06X-$%06X', $text_start, $text_start + $text_capacity - 1) . "\n";
