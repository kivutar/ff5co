use strict;
use warnings;
use File::Slurper qw(read_binary write_binary);


my $base_rom = $ARGV[0] || "ff5fr.sfc";
my $target_rom = $ARGV[1] || "ff5co.sfc";
my $offset = 0x03EF80;
my $tile_size = 12;

my $bytes = read_binary($target_rom);
my $base = read_binary($base_rom);

my $tile_a8 = substr($bytes, $offset + 0xA8 * $tile_size, $tile_size);
my $base_a8 = substr($base,  $offset + 0xA8 * $tile_size, $tile_size);

substr($bytes, $offset + 0xB6 * $tile_size, $tile_size) = $tile_a8;
substr($bytes, $offset + 0xA8 * $tile_size, $tile_size) = $base_a8;

write_binary($target_rom, $bytes);

print("Moved edited A8 tile to B6 and restored A8 from base ROM\n");
