use strict;
use warnings;
use File::Slurper qw(read_binary write_binary);


my $rom = $ARGV[0] || "ff5fr.sfc";
my $offset = defined $ARGV[1] ? hex($ARGV[1]) : 0x03EF80;
my $length = defined $ARGV[2] ? hex($ARGV[2]) : 0x1080;
my $columns = defined $ARGV[3] ? $ARGV[3] : 16;
my $tile_w = 8;
my $tile_h = 12;

my $bytes = read_binary($rom);
my $font = substr($bytes, $offset, $length);

die "Could not read font block\n" unless length($font) == $length;
die "Length must be a multiple of $tile_h bytes\n" unless $length % $tile_h == 0;

my $glyphs = $length / $tile_h;
my $rows = int(($glyphs + $columns - 1) / $columns);
my $width = $columns * $tile_w;
my $height = $rows * $tile_h;

my @pixels = map { [ (0) x $width ] } 1 .. $height;

for (my $g = 0; $g < $glyphs; $g++) {
    my $gx = ($g % $columns) * $tile_w;
    my $gy = int($g / $columns) * $tile_h;

    for (my $y = 0; $y < $tile_h; $y++) {
        my $row = ord(substr($font, $g * $tile_h + $y, 1));

        for (my $x = 0; $x < $tile_w; $x++) {
            my $bit = ($row >> (7 - $x)) & 1;
            $pixels[$gy + $y]->[$gx + $x] = $bit;
        }
    }
}

my $pbm = "P1\n$width $height\n";
for my $row (@pixels) {
    $pbm .= join(" ", @$row) . "\n";
}

my $out = sprintf("font_%06X_%04X.pbm", $offset, $length);
write_binary($out, $pbm);
print("$out\n");
