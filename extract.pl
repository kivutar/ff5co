use utf8;
use open qw(:std :encoding(UTF-8));
use File::Slurper qw(read_binary write_binary);
use Tie::IxHash;
use FindBin;
use lib $FindBin::Bin;
use FF5Japanese qw(%b2c_jp %b2c_jp_words);


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

my %c2b = reverse %b2c;

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
    "C9" => "’",
    "C5" => "-",
    "D0" => "«",
    "D1" => "»",
);

my %b2c_co = (
    %b2c_fr,
    "9C" => "ì",
    "9E" => "ò",
    "B6" => "ìt",
);


my $mode = "en";
my $rom = "ff5en.sfc";

if (defined $ARGV[0]) {
    if ($ARGV[0] eq "fr" || $ARGV[0] eq "co" || $ARGV[0] eq "en" || $ARGV[0] eq "jp") {
        $mode = $ARGV[0];
        $rom = "ff5jp.sfc" if $mode eq "jp";
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

my $offset = 0x2013F0;

sub printx {
    print unpack("H*", shift), "\n";
};

#decode using b2c (case insensitive on the hex addresses)
sub decode {
    my @bytes = unpack("C*", shift);
    my $string = "";

    for (my $i = 0; $i < @bytes; $i++) {
        my $byte = sprintf("%02X", $bytes[$i]);

        if ($byte eq "17" && defined $bytes[$i+1]) {
            my $word = $byte . sprintf("%02X", $bytes[$i+1]);
            if (exists $b2c_words{$word}) {
                $string .= $b2c_words{$word};
                $i++;
                next;
            }
        }

        $string .= exists $decode_table{$byte} ? $decode_table{$byte} : "\\" . $byte;
    }

    return $string;
};

sub decode_jp {
    my @bytes = unpack("C*", shift);
    my $string = "";

    for (my $i = 0; $i < @bytes; $i++) {
        my $byte = sprintf("%02X", $bytes[$i]);

        if ($byte eq "0C" && defined $bytes[$i+1]) {
            $string .= "\\0C" . sprintf("%02X", $bytes[$i+1]);
            $i++;
            next;
        }

        if (($byte eq "17" || $byte eq "1E" || $byte eq "1F") && defined $bytes[$i+1]) {
            my $word = $byte . sprintf("%02X", $bytes[$i+1]);
            $string .= exists $b2c_jp_words{$word} ? $b2c_jp_words{$word} : "\\" . $word;
            $i++;
            next;
        }

        $string .= exists $b2c_jp{$byte} ? $b2c_jp{$byte} : "\\" . $byte;
    }

    return $string;
};

my $prev = -1;

my $counter = 0;
if ($mode eq "jp") {
    my $speech_offset = 0x0A0000;
    my $jp_offset = 0x082220;

    for (my $i = $jp_offset; $i < $jp_offset+2*2160; $i += 2) {
        my $romindex = $speech_offset + unpack("v", substr($bytes, $i, 2));

        if ($prev != -1) {
            print($counter,"\t");
            printf("\$%06X\t", $romindex);
            printf($romindex - $prev ."\t ");

            my $string = substr($bytes, $prev, $romindex - $prev);
            print(decode_jp($string)."\n");
        }

        $prev = $romindex;
        $counter++;
    }
} else {
for (my $i = $offset; $i < $offset+3*2160; $i += 3) {
    my $addr = substr($bytes, $i, 3);

    # invert the 3 bytes using bitwise operators
    my $b3 = ord(substr($addr, 0, 1));
    my $b2 = ord(substr($addr, 1, 1));
    my $b1 = ord(substr($addr, 2, 1));

    my $index = ($b1 << 16) | ($b2 << 8) | $b3;
    my $romindex = $index - 0xC00000;

    if ($prev != -1) {
        print($counter,"\t");
        printf("\$%03X\t", $romindex);
        printf($romindex - $prev ."\t ");

        my $string = substr($bytes, $prev, $romindex - $prev);
        print(decode($string)."\n");
    }

    $prev = $romindex;
    $counter++;
}
}
