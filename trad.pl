use File::Slurper qw(read_binary write_binary);
use Tie::IxHash;

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

tie my %sentences, Tie::IxHash;
%sentences = (
    ">            Nothing happened." =>
    ">           Nunda he accadutu.",

    ">          Please select a name." =>
    ">              Scegli un nome.  ",

    "Lenna:  Father! " => 
    "Lenna:  O Babbu!",

    "Lenna:  Do you really have to go?" => 
    "Lenna:  Avete veramente da anda ?",

    "King:  Lenna, you need to protect >  the castle.  You mustn't follow >  me.>Lenna:  But..." =>
    "Re:  Lenna, avete bisognu di > prutezzione di u castellu. > Un mi seguitate.>Lenna:  Ma...",

    "King:  Something about the wind >  bothers me...>  I must go check the crystal of >  the Wind Shrine." =>
    "Re:  U ventu mi preoccupa...>  Aghju da anda a verifica >  u cristallu di u Tempiu >  di u Ventu.    ",

    "Lenna:  Yes... I can feel it, too...>  But, by yourself...?" =>
    "Lenna:  Ie... mi sentu ancu...>  Ma.. da se stessu?...?    ",

    "Faris:  The wind...    \x17>>  stopped...    " => 
    "Faris:  U ventu...     \x17>>  he firmatu... ",

    "King:  Don't worry." =>
    "Re:  Un ti ne fa.  ",

    "The wind stopped!!  I've got to >  hurry!!" =>
    "U ventu he firmatu!!  Aghju da >  anda!!  ",

    "Lenna:  The wind...!!  Has something>  happened...    \x17>>  to Father!?" =>
    "Lenna:  U ventu...!!  He accadutu >  qualcosa...    \x17>>  a Babbu !?   ",

    "King Tycoon:  What!?" =>
    "Re Tycoon:  Ohime !?",

    "Boco, let's go!" =>
    "O Boco, andemu!",

    "Boco, wait here." =>
    "0 Boco, aspetta.",

    "Are you okay?>Lenna:  Y..., yes..." =>
    "Va be?>Lenna:  I..., Ie...        ",,

    "\x02:  I'm \x02.  >  Journeying with a chocobo to >  nowhere in particular...>>Lenna:  \x02..." =>
    "\x02:  Mi chjama \x02.  >  Viaghja cu un chocobo >  senza destinazione...>>Lenna:  \x02...    ",

    "Lenna:  Thank you very much for >  helping me.  I'm Lenna.>  And you...?>\xABI'm..." =>
    "Lenna:  Ti ringraziu tantu per >  l'aiutu.  So Lenna.>  E tu...?>\xABSocu...       ",

    # FIXME this corrupts the display
    "Lenna:  This thing suddenly came >  falling from the sky...>  the blast sent me flying, and I fell>  unconscious...>\x02:  Is it a meteor?>Lenna:  A meteor...?>  Might it have something to do >  with the wind stopping?" =>
    "Lenna:  Sta cosa ha caduta di >  colpu...>  u scoppu mi ha mandatu in aria, >  e mi so svenuta...>\x02:  Sara un meteoru ?>Lenna:  Un meteoru... ?>  Puderebbe esse legatu a u ventu ?                                    ",

    "Lenna:  Thank you so much.  I wish>  I could repay you, but I must >  hurry..." =>
    "Lenna:  Ti ringraziu tantu.  Mi >  piacerebbe ripagarti ma aghju >  da anda...",

    "\x02:  Hey, wait a sec..." =>
    "\x02:  Aspetta...        ",

    "Lenna:  Did you hear something?>\x02:  Huh?>>>Ugh......" =>
    "Lenna:  Hai sentitu nunda?>\x02:  Eh ?>>>Mhh ......    ",

    "Unnh...    \x0C>  Help..." =>
    "Mhh...    \x0C>  Aiutu...",

    "\x02:  It's coming from over>  there!" =>
    "\x02:  Vene da quassu!               ",

    "Lenna:  Are you all right?>>>>Old Man:  Where am I...?>  Ooh... my head..." =>
    "Lenna:  Stai bonu ?>>>>Vecchiettu:  Induve so ?... ?>  Ooh... u mo capu...",

    "Old Man:  What... what's with >  me...?  I can't remember...  I can't>  remember a thing!!>>\x02:  You hit your head...  >  is it amnesia...?" =>
    "Vecchiettu: Chi succede ? >  Un mi ricordu... >  Un mi ricordu nunda !!>>\x02:  Tu si colpitu u capu... >  he amnesia...?                    ",

    "Old Man:  ...ah!>  That's right, my name's Galuf!>>>Lenna:  Anything else?>>>>Galuf:  ...  No...>  I can't remember anything >  besides my name..." =>
    "Vecchiettu:  ...ah !>  Ie, mi chjama Galuf !>>>Lenna:  E nunda di piu ?>>>>Galuf:  ...  No...>  Un mi ricordu nunda >  oltre u mo nome...         ",

    "Lenna:  I'm really very sorry, but I >  have to hurry.>>>\x02:  Where're you going?>Lenna:  The Wind Shrine..." =>
    "Lenna:  Mi dispiace tantu ma aghju >  da anda.>>>\x02:  Induve vai ? >Lenna:  U Tempiu di u Ventu...          ",

    "Galuf:  The Wind Shrine!!  I have a >  feeling that's where I needed to >  go, too!>>Galuf:  I'll go with you!>Lenna:  But..." =>
    "Galuf:  U Tempiu di u Ventu !!  Aghju >  a sensazione ch'aghju da anda >  anch'io !>>Galuf:  Andu cun te !>Lenna:  Ma...     ",

    "Galuf:  I MUST go.>  Please take me with you!!" =>
    "Galuf:  Aghju da anda.>  Ti pregu !!          ",

    "Lenna:  \x02...>  What about you?>>>\x02:  I'll continue my >  journey." =>
    "Lenna:  \x02...>  E tu ?>>>>\x02:  Aghju da cuntinua >  u mo viaghju.  ",

    "Lenna:  \x02...>  Thank you so much!  Goodbye...>Galuf:  Farewell!" =>
    "Lenna:  \x02...>  Ti ringraziu tantu !  Addiu...>Galuf:  Addiu !  ",

    "\x02:  Ouch...  Boco!>  Don't stop so suddenly!" =>
    "\x02:  Ahi...  O Boco !>  Un ti ferma cusi !   ",

    "\x02:  Why are you giving >  me that look!?>Wark!  Wark, wark!" =>
    "\x02:  Perche mi guardi >  cusi !?>Wark !  Wark, wark !       ",

    "\x02:  ... I know... It's an old >  man and a girl...  And there are >  lots of Goblins around here.  Got >  it, Boco." =>
    "\x02:  ... Ie...  Un vecchiettu e >  una zitella...  E ci so tanti >  Gobulini quassu.  Aghju capitu, Boco...         ",

    "Lenna:  Eeeek!>Galuf:  Aaggh!" =>
    "Lenna:  Aaaah!>Galuf:  Aaaah!",

    "\x02:  Boco, let's hurry!!>Wark!!" =>
    "\x02:  O Boco, aio !!>Wark !!    ",

    "\x02:  Hey!>Lenna:  \x02!!" =>
    "\x02:  Mi !>Lenna:  \x02!!",

    "Lenna:  Thank you so very much...>\x02:  Aw, stop that." =>
    "Lenna:  Ti ringraziu tantu...>\x02:  Oh, basta.        ",

    "\x02:  The meteor's shock's >  collapsed cliffs and made the >  ground split.>>\x02:  And now, the road to >  Tule's been blocked..." =>
    "\x02:  U scoppu di u meteoru >  ha crollatu i scoglii e >  ha fessu u terrenu.>>\x02:  E oramai, u caminu per >  Tule he chjusu...  ",

    "Lenna:  But I have to get to the >  Wind Shrine...>Galuf:  Ugh... unnh..." =>
    "Lenna:  Ma aghju da anda a u >  Tempiu di u Ventu...>Galuf:  Mhh... mhh..",

    "Galuf:  To the Wind Shrine... got to >  hurry... to the Wind Shrine...>>>\x02:  This old geezer too..." =>
    "Galuf:  A u Tempiu... >  aghju da anda... a u Tempiu di u >  Ventu...>>>\x02:  Anche stu vecchiettu...",

    "\x02:  You know what?  I'm >  going to go with you.>Lenna:  What?>  Really!!>\x02:  My dad...  He said for >  me to travel the world and see >  things...>>And besides... the wind is calling.>>>>Galuf:  Say what you want, but >  isn't the truth that you just want>  to be with this girl?" =>
    "\x02:  Sai cosa ?  Andu cun te.>Lenna:  Eh !>  Veramente ?!>\x02:  U mo babbu...  Mi ha dettu >  di viaghja u mondu e >  di vede cose...>>E poi... u ventu mi chjama.>>>>Galuf:  Dici cio che ti pare, ma >  u veru he ch'aghju voglia di >  sta cun sta zitella.                             ",

    "\x02:  Hey, you were >  awake!!>Galuf:  Of course I was!" =>
    "\x02:  Eh, eri svegliu !!>Galuf:  Ma certu !            ",

    "Galuf:  But the road has been >  blocked...  What will we do?>\x02:  ...>Lenna:  ..." =>
    "Galuf:  Ma u caminu he chjusu... >  Chi avemu da fa ava ?>\x02:  ...>Lenna:  ...    ",

    "Lenna:  But we must go!>>>>Galuf:  Yeah.>\x02:  Well, then!  Let's go!!" =>
    "Lenna:  Ma aghju da anda !>>>>Galuf:  Ie.>\x02:  Allora !  Andemu !!   ",

    "Lenna:  A cave in such a place...>\x02:  It must have been >  formed by that earthquake..." =>
    "Lenna:  Una grotta in un locu >  cusi...>\x02:  He stata fessuta da >  quellu scoppu...   ",

    "\x02:  Boco, it's dangerous >  ahead.  You've got stay back >  here." =>
    "\x02:  Boco, he pericolosu >  avanti.  Un ti ne avvicina.           ",

    "\x02:  Let's go, Boco!" =>
    "\x02:  O Boco, andemu.",

    "\x02:  That spring...!" =>
    "\x02:  Una sorgente ! ",

    "This is a Spring of Recovery.>>>>HP/MP restored!>Status restored!>Recovered from 'Wounded' status!" =>
    "He una Sorgente di Vita.>>>>HP/MP ripristinati !>Stato ripristinato !>Ripristinato da 'Ferito' !  ",

    "\x02:  That button...?" =>
    "\x02:  Una leva...?   ",

    "\x02:  That ship...?>  How does it sail without wind...?" =>
    "\x02:  Sta nave... ?>  Comu fa a naviga senza ventu... ?",

    "\x02:  This must be the >  pirates' hideout...  so that ship >  we saw was a pirate ship?" =>
    "\x02:  He u rifugiu di i >  pirati...  quellu ch'aghju vistu >  he una nave pirata ?     ",

    "Lenna:  I wonder if we couldn't get>  a ride?" =>
    "Lenna:  Forse piglianu passageri ?           ",

    "\x02:  Uhh... these are >  PIRATES we're talking about >  here..." =>
    "\x02:  Quale... ? i pirati... ??                                 ",

    "Galuf:  Well, then we haven't but >  to sneak the ship ourselves!" =>
    "Galuf:  Tuttu cio chi avemu da fa he arruba a stu nave !         ",

    "\x02:  Hey old man, you're >  more daring than I thought!" =>
    "\x02:  O vecchiettu ! Si piu bravu>  di cio chi pensava !",

    "\x02:  He's sleeping..." =>
    "\x02:  Dorme...        ",

    "Pirate:  Mumble... mumble..." =>
    "Pirata:  Mumble... mumble...",

    "\x02:  We're off!!" =>
    "\x02:  Aio !!     ",

    "Zzz... zzz...>  I fixed the ship's wheel, Captain...>>>Zzz... zzz...>  Take the wheel... Syldra'll..." =>
    "Zzz... zzz...>  Aghju riparatu u timone, Capitano...>>>Zzz... zzz...>  Prendi u timone... Syldra...  ",

    "Galuf:  \x02...>  What's wrong?>>>\x02:  It's no use.>  It won't move at all.  What's >  going on here??" =>
    "Galuf:  \x02...>  Chi succede ?>>>>\x02:  Un serve a nunda.>  Un si muove affattu.  Chi he >  successu ?",

    "And just what do you think you're >  doing!?" =>
    "E chi pensi di fa !?                        ",

    "Faris:  How bold you are!  Just >  going to sneak in here and steal >  my ship, eh?" =>
    "Faris:  Comu ti permetti !?  Vieni >  quassu a rubami a nave ?                     ",

    "Lenna:  I am Tycoon's princess >  Lenna.  I apologize for trying to >  just take your ship like that." =>
    "Lenna:  So Lenna, principessa di >  Tycoon.  Mi dispiace per >  a nave.                              ",

    "\x02:  Tycoon's...>Galuf:  ... princess!?" =>
    "\x02:  Principessa..>Galuf:  di Tycoon !?",

    "\x02:  But that sure was a >  shock... that Lenna was the >  princess of Tycoon...>>Lenna:  I'm sorry...  I wasn't >  intending to hide it...>>>\x02:  But why were you >  going to the Wind Shrine by >  yourself?>>Lenna:  Because my father is >  there.  And when the wind >  stopped... I thought something >  bad had happened...>Lenna:  So I snuck out of the castle>  alone... and then, that meteor >  came falling from the sky..." =>
    "\x02:  Ma he stata una >  sorpresa... ch'era Lenna la >  principessa di Tycoon...>>Lenna:  Mi dispiace...  Un >  vuleva nasconde nunda...>>>\x02:  Ma perche andavi >  da se stessu a u Tempiu di u >  Ventu ? >>Lenna:  Perche u mo babbu he >  quassu.  E quandu u ventu >  he firmatu...  Aghju pensatu >  ch'era un prublema...>Lenna:  E allora, mi so scappata >  di u castellu... >  e dopu, u meteoru he cadutu >  di colpu...       ",

    "Lenna:  Please!>  Please lend us your ship!  I must >  get to the Wind Shrine!  My >  father is in danger!" =>
    "Lenna:  Ti pregu !>  Prestami a nave !  Aghju da >  anda a u Tempiu ! >  U mo babbu he in periculu !      ",

    "Faris:  Eh!  You're Tycoon's >  princess!  This one's gonna be >  worth a lot!>>\x02:  Stop!!" =>
    "Faris:  Eh !  Sei a principessa >  di Tycoon !  Sta vale tantu !>>\x02:  Basta !!            ",

    "Lenna:  I beg you!!" =>
    "Lenna:  Ti pregu !!",

    "Faris:  That pendant..." =>
    "Faris:  Stu pendente...",

    "Faris:  Keep them locked up!>Pirates:  Yes Cap'n!!" =>
    "Faris:  Incarceli !>Pirati:  Ie Capitanu !!       ",

    "Galuf:  This is great...  Who the >  heck said we should steal this >  boat, anyways?" =>
    "Galuf:  Geniale ! Quale ha >  avutu l'idea di arruba sta nave ?                      ",

    "\x02:  Hey there old man, I >  think it was YOU!" =>
    "\x02:  O vecchiettu ! Credo >  ch'eri TU !      ",

    "Galuf:  Ooo... my head hurts!  I... >  can't remember...>>>\x02:  ...>  What a convenient excuse..." =>
    "Galuf:  Ooo... u mo capu...  Un... >  mi ricordu...>>>\x02:  ...>  Che scusa comoda...             ",

    "Faris:  Why would the princess of >  Tycoon have the same pendant >  as me...?" =>
    "Faris:  Perche a principessa di >  Tycoon ha avutu un >  pendente cum'e me ?  ",

    "Faris:  She said her father is at the>  Wind Shrine..." =>
    "Faris:  E so babbu he >  a u Tempiu di u Ventu...     ",

    "Faris:  We're heading for the Wind >  Shrine!" =>
    "Faris:  Andemu versu u Tempiu di u >  Ventu !",

    "Pirates:  Captain, what should we >  do with these people?>>>Faris:  Untie their ropes!" =>
    "Pirati:  Capitanu, chi facemu di >  sti genti ?>>>Faris:  Liberali !                   ",

    "Faris:  Hurry up!!" =>
    "Faris:  Subittu !!",

    "Lenna:  Why...?>>>>Faris:  I'm saying that I'm going to >  lend you my help.>  Isn't that good enough?>>Faris:  We're off!>  To the Wind Shrine!>>>Pirates:  ...>>>>Faris:  Are you guys going to listen >  to me?" =>
    "Lenna:  Perche...?>>>>Faris:  Ti dicu ch'aghju da aiutati.>  Un site micca felice ?>>>>Faris:  Andemu !>  Versu u Tempiu di u Ventu !>>>Pirati:  ...>>>>Faris:  Vulete ascoltami o no ?                           ",

    "Faris:  Answer me!>>>>Pirates:  A... ay\xC5ay, sir!" =>
    "Faris:  Rispondi !>>>>Pirati:  Ie\xC5Ie, Capitanu !",

    "Faris:  We're off!" =>
    "Faris:  Andemu !  ",

    "Lenna:  But, with the wind >  stopped... how will the ship >  move?>>Faris:  You really wanna know!?" =>
    "Lenna:  Ma, senza ventu... >  comu fa a nave per naviga ? >>Faris:  Vuleti sapiri !?                ",

    "Faris:  Syldra!>  Why don't you introduce youself?" =>
    "Faris:  O Syldra !>  Mostrati !                   ",

    "Faris:  How about that!>  Syldra and I grew up together.  >  We're basically brothers!" =>
    "Faris:  E allora !>  Eiu e Syldra avemu crisciutu >  inseme.  Semu fratelli !         ",

    "Would you like me to navigate until>  we get to the Wind Shrine?" =>
    "Vulete anda a u Tempiu di >  u Ventu, no ?                      ",

    "I'm seasick..." =>
    "Aghju nausea..",

    "Captain!>  Please take these with you!>>>Received 8 Potions!" =>
    "Capitanu !>  Prendi sti Pozioni !>>>Riceveti 8 Pozioni !    ",

    "Received 8 Potions!" =>
    "Riceveti 8 Pozioni.",

    "Be careful!" =>
    "Forza !!   ",

    "Captain...>  I... I love you...." =>
    "Capitanu...>  Vi... amu tantu...",

    "The earthquake connected our >  hideout to a weird cave." =>
    "U scoppu ha connessu u rifugiu >  cun una grotta strana.",

    "We'll be alright while the Captain's >  away." =>
    "Staremu bonu finche u Capitanu >  he via.    ", # FIXME

    "\x02:  What's that...?" =>
    "\x02:  Chi he...?     ",
);

sub encode {
    pack("H*", join("", map { $c2b{$_} } split(//, shift)));
};

#decode using b2c case insensitive
sub decode {
    join("", map { $b2c{uc($_)} || "\\".uc($_) } unpack("H*", shift) =~ /../g);
};

sub decode2 {
    join(" ", map { $_ } unpack("H*", shift) =~ /../g);
};

sub printx {
    print unpack("H*", shift), "\n";
};

my $bytes = read_binary("ff5en.sfc");

# for every sentence, decode it, and replace it in the bytes by the encoded version of the corresponding translation
foreach my $sentence (keys %sentences) {
    my $translation = $sentences{$sentence};
    my $encoded_sentence = encode($sentence);
    my $encoded_translation = encode($translation);
    #print($sentence), "\n";
    printx($encoded_sentence);
    #print($translation), "\n";
    printx($encoded_translation);

    # check that the lenght matches
    if (length($encoded_sentence) != length($encoded_translation)) {
        print "ERROR: $sentence\n";
        print "ERROR: $translation\n";
        print "ERROR: $encoded_sentence\n";
        print "ERROR: $encoded_translation\n";
        die;
    }

    $bytes =~ s/\Q$encoded_sentence\E/$encoded_translation/g;
}

write_binary("ff5co.sfc", $bytes);

# for (my $i = 0; $i < length($bytes); $i += 36) {
#     my $line = substr($bytes, $i, 36);
#     print decode2($line), "\t", decode($line), "\n";
# }

# for (my $i = 0; $i < length($bytes); $i++) {
#     my $c = substr($bytes, $i, 1);
#     my $dc = decode($c);
#     if ($dc eq "|") {
#         print "\n";
#     }
#     print $dc;
# }
