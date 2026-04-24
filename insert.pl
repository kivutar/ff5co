use File::Slurper qw(read_binary write_binary);


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
    "A8" => "ì",
    "A9" => "œ",
    "AB" => "-",
    "AD" => ",",
    "B0" => "il",
    "B2" => "li",
    "B3" => "ll",
    "B6" => "î",
    "BA" => "ïe",
    "C5" => "-",
    "C9" => "'",
    "D0" => "«",
    "D1" => "»",
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
my $script_file = "english.txt";
my $base_rom = "ff5en.sfc";
my $output_rom = "ff5co.sfc";

if (defined $ARGV[0]) {
    if ($ARGV[0] eq "co" || $ARGV[0] eq "en") {
        $mode = $ARGV[0];
        $script_file = $ARGV[1] if defined $ARGV[1];
    } else {
        $script_file = $ARGV[0];
    }
}

if ($mode eq "co") {
    $script_file = "corsu.txt" if !defined $ARGV[1] && defined $ARGV[0] && $ARGV[0] eq "co";
    $base_rom = "ff5co.sfc";
}

my %encode_table = %b2c;
if ($mode eq "co") {
    %encode_table = (%encode_table, %b2c_co);
}

my %c2b = reverse %encode_table;

sub encode {
    my $string = shift;
    my $hex = "";

    for (my $i = 0; $i < length($string); $i++) {
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

        die "Unknown character in script ($mode): " . unpack("H*", $c) . "\n"
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

my $bytes = read_binary($base_rom);
my $script = read_binary($script_file);

my @lines = split(/\n/, $script);
my @strings = ();

foreach my $line (@lines) {
    $line =~ s/\r$//;
    next if $line eq "";

    my ($counter, $offset, $length, $string) = split(/\t/, $line, 4);
    die "Malformed line in $script_file: $line\n" unless defined $string;

    push(@strings, $string);
}

die "Expected " . ($pointer_count - 1) . " strings, got " . scalar(@strings) . "\n"
    unless scalar(@strings) == $pointer_count - 1;

my $text_offset = length($bytes);
my $text_bytes = "";
my @pointers = ();

foreach my $string (@strings) {
    push(@pointers, $text_offset + length($text_bytes));
    $text_bytes .= encode($string);
}

push(@pointers, $text_offset + length($text_bytes));

my $pointer_bytes = "";
foreach my $romindex (@pointers) {
    $pointer_bytes .= pointer($romindex);
}

substr($bytes, $pointer_offset, 3 * $pointer_count) = $pointer_bytes;
$bytes .= $text_bytes;

write_binary($output_rom, $bytes);

printf("Inserted %d strings from %s into %s at \$%06X\n", scalar(@strings), $script_file, $output_rom, $text_offset);
