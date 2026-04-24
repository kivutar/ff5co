use strict;
use warnings;
use File::Slurper qw(read_binary write_binary);


my $rom = $ARGV[0] || "ff5co.sfc";
my $pbm = $ARGV[1] || "corsican_font.pbm";
my $offset = defined $ARGV[2] ? hex($ARGV[2]) : 0x03EF80;
my $length = defined $ARGV[3] ? hex($ARGV[3]) : 0x1080;
my $columns = defined $ARGV[4] ? $ARGV[4] : 16;
my $tile_w = 8;
my $tile_h = 12;

my $raw = read_binary($pbm);
my $cursor = 0;

sub next_token {
    while ($cursor < length($raw)) {
        if (substr($raw, $cursor, 1) =~ /\s/) {
            $cursor++;
            next;
        }

        if (substr($raw, $cursor, 1) eq "#") {
            $cursor++ while $cursor < length($raw) && substr($raw, $cursor, 1) ne "\n";
            next;
        }

        my $start = $cursor;
        $cursor++ while $cursor < length($raw) && substr($raw, $cursor, 1) !~ /[\s#]/;
        return substr($raw, $start, $cursor - $start);
    }

    return undef;
}

my $magic = next_token();
die "Unsupported PBM format\n" unless defined $magic && ($magic eq "P1" || $magic eq "P4");

my $width = next_token();
my $height = next_token();
die "Malformed PBM header\n" unless defined $width && defined $height;

$width = int($width);
$height = int($height);

my $glyphs = $length / $tile_h;
my $rows = int(($glyphs + $columns - 1) / $columns);
my $expected_width = $columns * $tile_w;
my $expected_height = $rows * $tile_h;

die "Unexpected image size ${width}x${height}, expected ${expected_width}x${expected_height}\n"
    unless $width == $expected_width && $height == $expected_height;

my @pixels;

if ($magic eq "P1") {
    for (my $y = 0; $y < $height; $y++) {
        for (my $x = 0; $x < $width; $x++) {
            my $token = next_token();
            die "Not enough PBM pixel data\n" unless defined $token;
            $pixels[$y][$x] = $token eq "1" ? 1 : 0;
        }
    }
} else {
    $cursor++ while $cursor < length($raw) && substr($raw, $cursor, 1) =~ /\s/;

    my $row_bytes = int(($width + 7) / 8);
    for (my $y = 0; $y < $height; $y++) {
        my $row = substr($raw, $cursor, $row_bytes);
        die "Not enough PBM bitmap data\n" unless length($row) == $row_bytes;
        $cursor += $row_bytes;

        for (my $x = 0; $x < $width; $x++) {
            my $byte = ord(substr($row, int($x / 8), 1));
            $pixels[$y][$x] = ($byte >> (7 - ($x % 8))) & 1;
        }
    }
}

my $font = "";

for (my $g = 0; $g < $glyphs; $g++) {
    my $gx = ($g % $columns) * $tile_w;
    my $gy = int($g / $columns) * $tile_h;

    for (my $y = 0; $y < $tile_h; $y++) {
        my $byte = 0;

        for (my $x = 0; $x < $tile_w; $x++) {
            $byte |= ($pixels[$gy + $y][$gx + $x] & 1) << (7 - $x);
        }

        $font .= chr($byte);
    }
}

my $bytes = read_binary($rom);
substr($bytes, $offset, $length) = $font;
write_binary($rom, $bytes);

printf("Patched %s into %s at \$%06X (%d bytes)\n", $pbm, $rom, $offset, $length);
