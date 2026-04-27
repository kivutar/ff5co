use utf8;
use File::Slurper qw(read_binary write_binary);
use Encode qw(decode);


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
    "AB" => "\xAB",
    "C5" => "\xC5",

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

my %b2c_co = (
    "94" => "Ç",
    "95" => "ç",
    "97" => "â",
    "98" => "à",
    "99" => "é",
    "9A" => "è",
    "9B" => "!",
    "9C" => "ê",
    "9D" => "ù",
    "9E" => "ò",
    "9F" => "û",
    "A5" => ".",
    "A8" => "…",
    "A9" => "œ",
    "AB" => "-",
    "AD" => ",",
    "B0" => "il",
    "B2" => "li",
    "B3" => "ll",
    "B6" => "ì",
    "BA" => "ïe",
    "C5" => "-",
    "C9" => "'",
    "D0" => "«",
    "D1" => "»",
);

my %c2b_en = (
    "|" => "00",
    ">" => "01",
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
    "A" => "60",
    "B" => "61",
    "C" => "62",
    "D" => "63",
    "E" => "64",
    "F" => "65",
    "G" => "66",
    "H" => "67",
    "I" => "68",
    "J" => "69",
    "K" => "6A",
    "L" => "6B",
    "M" => "6C",
    "N" => "6D",
    "O" => "6E",
    "P" => "6F",
    "Q" => "70",
    "R" => "71",
    "S" => "72",
    "T" => "73",
    "U" => "74",
    "V" => "75",
    "W" => "76",
    "X" => "77",
    "Y" => "78",
    "Z" => "79",
    "0" => "53",
    "1" => "54",
    "2" => "55",
    "3" => "56",
    "4" => "57",
    "5" => "58",
    "6" => "59",
    "7" => "5A",
    "8" => "5B",
    "9" => "5C",
    "a" => "7A",
    "b" => "7B",
    "c" => "7C",
    "d" => "7D",
    "e" => "7E",
    "f" => "7F",
    "g" => "80",
    "h" => "81",
    "i" => "82",
    "j" => "83",
    "k" => "84",
    "l" => "85",
    "m" => "86",
    "n" => "87",
    "o" => "88",
    "p" => "89",
    "q" => "8A",
    "r" => "8B",
    "s" => "8C",
    "t" => "8D",
    "u" => "8E",
    "v" => "8F",
    "w" => "90",
    "x" => "91",
    "y" => "92",
    "z" => "93",
    "!" => "A1",
    "?" => "A2",
    "." => "A3",
    "'" => "99",
    "\"" => "9A",
    ":" => "9B",
    "," => "9D",
    "(" => "9E",
    ")" => "9F",
    "/" => "A0",
    " " => "FF",
);

my %c2b_fr = (
    %c2b_en,
    "Ç" => "94",
    "ç" => "95",
    "â" => "97",
    "à" => "98",
    "é" => "99",
    "è" => "9A",
    "!" => "9B",
    "ê" => "9C",
    "ù" => "9D",
    "ô" => "9E",
    "û" => "9F",
    "." => "A5",
    "…" => "A8",
    "œ" => "A9",
    ":" => "AB",
    "," => "AD",
    "il" => "B0",
    "li" => "B2",
    "ll" => "B3",
    "ît" => "B6",
    "ïe" => "BA",
    "'" => "C9",
    "’" => "C9",
    "«" => "D0",
    "»" => "D1",
    "-" => "C5",
);

my %c2b_co = (
    %c2b_fr,
    "ì" => "9C",
    "ìt" => "B6",
    "ò" => "9E",
);

my %token2b = (
    "[P1]" => "1701",
    "[P2]" => "1702",
    "[P3]" => "1703",
    "[P4]" => "1704",
    "[P5]" => "1705",
    "[P6]" => "1706",
);

my $pointer_offset = 0x2013F0;
my $pointer_count = 2160;
my $mode = "en";
my $script_file = "texts/en/dialog.txt";
my $base_rom = "ff5en.sfc";
my $output_rom = "ff5co.sfc";
my $debug_line;

if (defined $ARGV[0]) {
    if ($ARGV[0] eq "co-debug") {
        $mode = "co-debug";
        $debug_line = $ARGV[1] if defined $ARGV[1];
        $script_file = $ARGV[2] if defined $ARGV[2];
    } elsif ($ARGV[0] eq "fr" || $ARGV[0] eq "co" || $ARGV[0] eq "en") {
        $mode = $ARGV[0];
        $script_file = $ARGV[1] if defined $ARGV[1];
    } else {
        $script_file = $ARGV[0];
    }
}

if ($mode eq "fr") {
    $script_file = "texts/fr/dialog.txt" if !defined $ARGV[1] && defined $ARGV[0] && $ARGV[0] eq "fr";
    $base_rom = "ff5fr.sfc";
} elsif ($mode eq "co" || $mode eq "co-debug") {
    $script_file = "texts/co/dialog.txt" if !defined $script_file || $script_file eq "texts/en/dialog.txt";
    $base_rom = "ff5co.sfc";
}

my %c2b = %c2b_en;
if ($mode eq "fr") {
    %c2b = %c2b_fr;
} elsif ($mode eq "co" || $mode eq "co-debug") {
    %c2b = %c2b_co;
    $c2b{"ô"} = "9E";
    $c2b{"À"} = "98";
    $c2b{"È"} = "9A";
    $c2b{"É"} = "99";
    $c2b{"Ò"} = "9E";
    $c2b{"Ù"} = "9D";
    $c2b{"’"} = "C9";
}

my @text_tokens = sort { length($b) <=> length($a) || $a cmp $b }
    grep { length($_) > 1 && substr($_, 0, 1) ne "[" }
    keys %c2b;

sub encode {
    my ($string, $line_number) = @_;
    my $hex = "";

    CHAR: for (my $i = 0; $i < length($string); $i++) {
        my $c = substr($string, $i, 1);

        if ($c eq "\\" && $i + 2 < length($string)) {
            my $escaped = substr($string, $i + 1, 2);
            if ($escaped =~ /^[0-9A-Fa-f]{2}$/) {
                $hex .= uc($escaped);
                $i += 2;
                next;
            }
        }

        if ($c eq "[") {
            my $end = index($string, "]", $i);
            if ($end != -1) {
                my $token = substr($string, $i, $end - $i + 1);

                if (exists $token2b{$token}) {
                    $hex .= $token2b{$token};
                    $i = $end;
                    next;
                }

                if (exists $c2b{$token}) {
                    $hex .= $c2b{$token};
                    $i = $end;
                    next;
                }
            }
        }

        foreach my $token (@text_tokens) {
            next if $i + length($token) > length($string);
            next unless substr($string, $i, length($token)) eq $token;

            $hex .= $c2b{$token};
            $i += length($token) - 1;
            next CHAR;
        }

        die "Unknown character in script ($mode) at line $line_number: " . unpack("H*", $c) . " in [$string]\n"
            unless exists $c2b{$c};

        $hex .= $c2b{$c};
    }

    pack("H*", $hex);
};

sub pointer {
    my $romindex = shift;
    my $index = $romindex + 0xC00000;

    chr($index & 0xFF) .
    chr(($index >> 8) & 0xFF) .
    chr(($index >> 16) & 0xFF);
};

sub unpointer {
    my $addr = shift;
    my $b3 = ord(substr($addr, 0, 1));
    my $b2 = ord(substr($addr, 1, 1));
    my $b1 = ord(substr($addr, 2, 1));
    my $index = ($b1 << 16) | ($b2 << 8) | $b3;

    $index - 0xC00000;
};

my $bytes = read_binary($base_rom);
my $script = decode("UTF-8", read_binary($script_file));

my @lines = split(/\n/, $script);
my @strings = ();
my @entries = ();

foreach my $line (@lines) {
    $line =~ s/\r$//;
    next if $line eq "";

    my ($counter, $offset, $length, $string) = split(/\t/, $line, 4);
    die "Malformed line in $script_file: $line\n" unless defined $string;
    $string =~ s/^ //;

    push(@strings, $string);
    push(@entries, {
        counter => $counter,
        offset => hex(substr($offset, 1)),
        length => $length + 0,
        string => $string,
    });
}

if ($mode eq "co-debug") {
    die "Usage: perl insert.pl co-debug LINE [texts/co/dialog.txt]\n" unless defined $debug_line;
    die "Invalid debug line: $debug_line\n" unless $debug_line =~ /^\d+$/;
    die "Debug line out of range: $debug_line\n" unless $debug_line >= 1 && $debug_line <= scalar(@entries);

    my $entry = $entries[$debug_line - 1];
    my $start = $entry->{offset} - $entry->{length};
    my $encoded = encode($entry->{string}, $debug_line);
    my $encoded_length = length($encoded);

    die sprintf("Debug line %d is too long: %d bytes > %d bytes\n", $debug_line, $encoded_length, $entry->{length})
        if $encoded_length > $entry->{length};

    my $padding = chr(0xFF) x ($entry->{length} - $encoded_length);
    substr($bytes, $start, $entry->{length}) = $encoded . $padding;

    write_binary($output_rom, $bytes);

    printf(
        "Inserted line %d from %s into %s at \$%06X (%d/%d bytes)\n",
        $debug_line,
        $script_file,
        $output_rom,
        $start,
        $encoded_length,
        $entry->{length},
    );
    exit 0;
}

die "Expected " . ($pointer_count - 1) . " strings, got " . scalar(@strings) . "\n"
    unless scalar(@strings) == $pointer_count - 1;

my @existing_pointers = ();
for (my $i = 0; $i < $pointer_count; $i++) {
    push(@existing_pointers, unpointer(substr($bytes, $pointer_offset + 3 * $i, 3)));
}

my $text_offset = $existing_pointers[0];
my $text_end = $existing_pointers[-1];
my $text_region_size = $text_end - $text_offset;
my $text_bytes = "";
my @pointers = ();

for (my $i = 0; $i < @strings; $i++) {
    my $string = $strings[$i];
    push(@pointers, $text_offset + length($text_bytes));
    $text_bytes .= encode($string, $i + 1);
}

push(@pointers, $text_offset + length($text_bytes));

die sprintf(
    "Rebuilt script is too large for original text region: %d bytes > %d bytes (\$%06X-\$%06X)\n",
    length($text_bytes),
    $text_region_size,
    $text_offset,
    $text_end,
)
    if length($text_bytes) > $text_region_size;

my $pointer_bytes = "";
foreach my $romindex (@pointers) {
    $pointer_bytes .= pointer($romindex);
}

substr($bytes, $pointer_offset, 3 * $pointer_count) = $pointer_bytes;
substr($bytes, $text_offset, $text_region_size) = $text_bytes . (chr(0xFF) x ($text_region_size - length($text_bytes)));

write_binary($output_rom, $bytes);

printf(
    "Inserted %d strings from %s into %s at \$%06X-\$%06X (%d/%d bytes)\n",
    scalar(@strings),
    $script_file,
    $output_rom,
    $text_offset,
    $text_end,
    length($text_bytes),
    $text_region_size,
);
