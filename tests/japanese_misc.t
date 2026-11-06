use strict;
use warnings;
use utf8;
use Test::More;
use File::Temp qw(tempdir);
use File::Slurper qw(read_binary read_text write_binary);
use FindBin;
use IPC::Open3;
use Symbol qw(gensym);
use lib "$FindBin::Bin/..";
use FF5Japanese qw(decode_misc);

my $root = "$FindBin::Bin/..";
my $rom = "$root/ff5jp.sfc";
plan skip_all => "ff5jp.sfc is required" unless -f $rom;
my $scratch = tempdir(CLEANUP => 1);
my $destination = "$scratch/texts";

sub extract_jp {
    my ($input, $output_dir) = @_;
    my $error = gensym;
    my $pid = open3(my $in, my $out, $error, $^X,
        "$root/extract_misc.pl", "jp", $input, $output_dir);
    close $in;
    local $/;
    my $stdout = <$out> // "";
    my $stderr = <$error> // "";
    waitpid($pid, 0);
    return ($? >> 8, $stdout, $stderr);
}

my ($status, $stdout, $stderr) = extract_jp($rom, $destination);
is($status, 0, "Japanese misc extraction succeeds") or diag $stderr;
is($stderr, "", "Extraction produces no warnings");
my %counts = (
    ability_descriptions => 111, ability_names => 96, area_headings => 163,
    battle_dialog => 234, battle_messages => 81, blue_magic_names => 30,
    character_names => 5, concepts_misc => 24, effect_names => 105,
    item_descriptions => 128, item_names_battle => 256, item_names_menu => 256,
    job_descriptions => 22, job_names => 22, magic_names_battle_menu => 169,
    magic_names_battle_messages => 169, magic_names_field_menu => 87,
    menu_ability_text => 33, menu_shop => 139, monster_names => 384,
    monster_specialties => 64, rare_items => 24, shop_names => 8,
    song_names => 8, support_abilities_battle => 33,
);
my %rows;
for my $name (sort keys %counts) {
    my @lines = split /\n/, read_text("$destination/$name.txt");
    is(scalar @lines, $counts{$name}, "$name has the expected number of records");
    $rows{$name} = [map { [split /\t/, $_, 4] } @lines];
    my @bad = grep {
        my $r = $rows{$name}[$_];
        $r->[0] != $_ || $r->[1] !~ /^\$[0-9A-F]{6}$/ ||
            $r->[2] !~ /^\d+$/ || ($r->[3] // "") =~ /\\[0-9A-F]{2}/
    } 0 .. $#lines;
    is_deeply(\@bad, [], "$name has sequential IDs and no undecoded bytes");
}
sub text_at {
    my ($name, $index) = @_;
    return $rows{$name}[$index][3];
}

is(text_at("monster_names", 0), "ゴブリン", "Monster-name table starts with Goblin");
is(text_at("monster_names", 49), "32ページ", "Library monster boundaries are correct");
is(text_at("ability_names", 5), "たたかう", "Original five-byte command records decode");
is(text_at("magic_names_field_menu", 18), "[WhiteMagic]ケアル", "Spell icons are preserved");
is(text_at("item_descriptions", 1), "HPかいふく", "Item descriptions use Japanese text");
is(text_at("battle_messages", 17), "レベル [BattleVar:00]", "Zero battle argument is preserved");
is(text_at("battle_messages", 18), "HP [BattleVar:01]/[BattleVar:02]", "Multiple battle arguments decode");
is(text_at("battle_messages", 41), "戦いに勝った!", "Victory message uses the original table");
is(text_at("battle_messages", 42), "全滅した……", "Battle messages preserve ellipses");
like(text_at("battle_dialog", 8), qr/イフリート……$/, "Battle dialogue preserves ellipses");
is(text_at("area_headings", 162), "地下大河", "Last heading ends at the sentinel pointer");
is(text_at("rare_items", 0), "ガラフのうでわ", "Key items skip the eight unused slots");
is(text_at("menu_shop", 13), "TIME", "Temporary menu alphabet decodes");
is(text_at("menu_shop", 20), "LEVEL", "Latin menu labels do not become kana");
is(text_at("menu_shop", 82), "OK", "OK label uses the menu alphabet");
is(text_at("menu_shop", 90), "EMPTY", "EMPTY label uses the menu alphabet");
is_deeply([map { text_at("menu_shop", $_) } 109 .. 111], [qw(R G B)], "Color labels decode");
is(text_at("menu_shop", 112), "[ColorPreview]", "Color preview remains a control token");
is(text_at("menu_shop", 138), "ひとつづつはあるように ちょうせいしてください",
    "Final menu entry includes its full text");
ok(!-e "$destination/battle_record_text.txt", "No RPGe-only battle record is fabricated");
ok(!-e "$destination/dialog.txt", "Misc extraction does not overwrite dialogue");

is(decode_misc(pack("C*", 0x1E, 0x00), "message"), "王", "Zero kanji argument is preserved");
is(decode_misc(pack("C*", 0x05, 0x00), "message"), "[BattleCtrl05:00]", "Zero control argument is preserved");
is(decode_misc(pack("C", 0xE3), "message"), "、", "Large font has its own symbols");
is(decode_misc(pack("C", 0xE3), "fixed"), "[Sword]", "Small font has equipment icons");
is(decode_misc(pack("C*", 0xC7, 0xC7), "message"), "……", "Large font decodes C7 as an ellipsis");
for my $context (qw(fixed menu menu_latin)) {
    is(decode_misc(pack("C", 0xC7), $context), "_", "$context preserves the small-font underscore");
}
is(decode_misc(pack("C", 0xF6), "fixed"), "\\F6", "Unknown bytes remain lossless escapes");

write_binary("$scratch/headered.sfc", ("\0" x 512) . read_binary($rom));
($status, $stdout, $stderr) = extract_jp("$scratch/headered.sfc", "$scratch/headered");
is($status, 0, "Headered Japanese ROM is supported") or diag $stderr;
my @different = grep {
    read_binary("$destination/$_.txt") ne read_binary("$scratch/headered/$_.txt")
} sort keys %counts;
is_deeply(\@different, [], "Copier header does not affect ROM offsets or decoded text");

my $bad_rom = read_binary($rom);
substr($bad_rom, 0xF987, 2, "\0\0");
write_binary("$scratch/invalid.sfc", $bad_rom);
($status, $stdout, $stderr) = extract_jp("$scratch/invalid.sfc", "$scratch/invalid");
isnt($status, 0, "Invalid pointer is rejected");
like($stderr, qr/menu_shop\[0\] points outside/, "Pointer failure identifies the table and record");
ok(!-d "$scratch/invalid", "Invalid ROM does not leave partial output");

($status, $stdout, $stderr) = extract_jp("$root/ff5en.sfc", "$scratch/western");
isnt($status, 0, "Expanded Western ROM is rejected");
like($stderr, qr/original 2 MiB Japanese ROM/, "Wrong-ROM failure explains the layout requirement");

done_testing;
