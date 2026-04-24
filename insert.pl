use File::Slurper qw(read_binary write_binary);


my %b2c = (
    "00" => "|",
    "01" => ">",
    "02" => "\x02", # hero's name
    "0C" => "\x0C",
    "17" => "\x17", # wait
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

my %c2b = reverse %b2c;

my $pointer_offset = 0x2013F0;
my $pointer_count = 2160;
my $script_file = $ARGV[0] || "english.txt";

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

        die "Unknown character in script: " . unpack("H*", $c) . "\n"
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

my $bytes = read_binary("ff5en.sfc");
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

write_binary("ff5co.sfc", $bytes);

printf("Inserted %d strings from %s at \$%06X\n", scalar(@strings), $script_file, $text_offset);
