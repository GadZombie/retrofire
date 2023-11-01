unit GlobalConsts;

interface
uses
  GlobalTypes;

const
  PROGRAM_VERSION = '1.3.1';
  PROGRAM_COPYRIGHT = '2007 - 2023 gadz.pl';

  DATA_FOLDER = 'Data\';
  EXTRA_MISSIONS_FOLDER = 'ExtraMissions\';

const
  pi180 = pi / 180;

  ob_gracz = 0;
  ob_pilot = 1;
  ob_matka = 2;
  ob_dzialko = 3;
  ob_dzialkolufa = 4;
  ob_rakieta = 5;
  ob_dzialkokawalki = 6;
  ob_dzialkowieza = 7;
  ob_mysliwiec = 8;
  ob_dzialkowieza2 = 9;
  ob_dzialkolufa2 = 10;
  ob_kokpit = 11;
  ob_kamien = 12;
  ob_stone_small = 13;

  ob_sceneria1 = 14;
  ile_obiektow_scenerii = 6;

  upgrade: array [0 .. 5, 0 .. 9] of TUpgradeItem = (
    { paliwo } ((ile: 150; cena: 0), (ile: 180; cena: 450), (ile: 200; cena: 900), (ile: 250; cena: 1395), (ile: 300;
    cena: 2070), (ile: 350; cena: 2430), (ile: 380; cena: 3150), (ile: 420; cena: 3630), (ile: 490;
    cena: 4380), (ile: 550; cena: 5100)),
    { rakiety } ((ile: 10; cena: 0), (ile: 20; cena: 270), (ile: 30; cena: 450), (ile: 40; cena: 630), (ile: 55;
    cena: 810), (ile: 65; cena: 960), (ile: 80; cena: 1140), (ile: 100; cena: 1500), (ile: 120; cena: 2250), (ile: 140;
    cena: 4140)),
    { dzialko } ((ile: 100; cena: 0), (ile: 150; cena: 240), (ile: 200; cena: 440), (ile: 280; cena: 600), (ile: 350;
    cena: 720), (ile: 450; cena: 890), (ile: 530; cena: 1100), (ile: 600; cena: 1400), (ile: 650;
    cena: 2100), (ile: 700; cena: 3950)),
    { sila } ((ile: 0.8; cena: 0), (ile: 1.2; cena: 360), (ile: 1.5; cena: 510), (ile: 2; cena: 750), (ile: 2.5;
    cena: 1140), (ile: 3; cena: 1560), (ile: 3.5; cena: 2340), (ile: 4; cena: 2700), (ile: 4.5; cena: 3450), (ile: 5;
    cena: 4820)),
    { chlodzenie } ((ile: 0.3; cena: 0), (ile: 0.5; cena: 270), (ile: 0.6; cena: 510), (ile: 0.7; cena: 690), (ile: 0.8;
    cena: 972), (ile: 1; cena: 1110), (ile: 1.5; cena: 1537), (ile: 2; cena: 1975), (ile: 2.5; cena: 2360), (ile: 3;
    cena: 2998)),
    { ladownosc } ((ile: 8; cena: 0), (ile: 9; cena: 600), (ile: 10; cena: 930), (ile: 11; cena: 1240), (ile: 12;
    cena: 1620), (ile: 14; cena: 1980), (ile: 16; cena: 2375), (ile: 18; cena: 2827), (ile: 20; cena: 4080), (ile: 24;
    cena: 6250)));

  cenazycia = 3000;
  maxoslonablysk = 1.2;
  maxcheats = 10;
  cheatcodes: array [0 .. maxcheats] of string = ('FULL', 'GOD', 'FUEL', 'WEAPON', 'LIVES', 'LOAD', 'TIME', 'FINISH', 'MOTHER', 'DOWN', 'BIGHEADS');

  MAIN_SCENARIO_MAX_LEVELS = 25;
  RANDOM_GAME_MAX_LEVELS = 25;
  DIFFICULTY_MULTIPLIER = 3;

implementation

end.
