unit Language;

interface
uses
  GlobalConsts, GlobalTypes;

//{$DEFINE LANGUAGE_PL}
{$DEFINE LANGUAGE_EN}

const
{$IFDEF LANGUAGE_PL}
  PROGRAM_TITLE = 'Retrofire';
  STR_PROGRAM_VER = 'wer.';
  MISSIONS_USE_STORYLINE = TRUE;

  titleScrollLines: array [0 .. 35] of string = ('POMYS� NA GR�', 'GRZEGORZ DROZD', '', '', '', 'PROGRAM', 'GRZEGORZ DROZD',
    '', '', '', 'GRAFIKA', 'GRZEGORZ DROZD', '', '', '', 'MUZYKA W MENU', 'FATER (PRO-CREATION, THE ODOURS)',
    'WWW.PRO-CREATION.PL', 'WWW.THEODOURS.NET', '', '', '', 'T�O MUZYCZNE W GRZE I INTRO/OUTRO', 'GRZEGORZ DROZD', '',
    '', '', 'TESTOWANIE', 'KRZYSZTOF RZEPKA', 'GRZEGORZ DROZD', '', '', '2007-2023 GADZ.PL',
    'WERSJA ' + PROGRAM_VERSION, 'HTTPS://GADZ.PL/', '');

  mainIntroLines: array [0 .. 3] of TMainIntroLine =
    ((s: 'GADZ.PL'; i: 3), (s: 'PREZENTUJE'; i: 2), (s: 'GR� GRZEGORZA DROZDA'; i: 2), (s: 'RETROFIRE'; i: 4));

  STR_MISSION_RESCUE_PEOPLE = 'MISJA: ZABIERZ LUDZI';
  STR_MISSION_DESTROY_ENEMY = 'MISJA: ZNISZCZ DZIA�KA WROGA';
  STR_MISSION_BOARDED = 'na pok�adzie:';
  STR_MISSION_LEFT = 'pozosta�o:';
  STR_MISSION_RESCUED = 'uratowanych:';
  STR_MISSION_KILLED = 'zgin�o:';
  STR_MISSION_DESTROYED = 'zniszczonych:';

  STR_CHEAT_SHIELDS = 'NIEZNISZCZALNO��';
  STR_CHEAT_FUEL = 'MAX PALIWA';
  STR_CHEAT_WEAPONS = 'MAX BRONI';
  STR_CHEAT_LOAD = 'MAX �ADOWNO�CI';
  STR_CHEAT_TIME = 'MAX CZASU';

  STR_WARN_LOW_FUEL = 'PALIWO SI� KO�CZY!';
  STR_WARN_NO_FUEL = 'KONIEC PALIWA';
  STR_WARN_TEMP_CRITICAL = 'TEMPERATURA KRYTYCZNA!';
  STR_WARN_HIGH_TEMP = 'TEMPERATURA!';
  STR_WARN_TOO_HIGH = 'JESTE� ZA WYSOKO!';
  STR_WARN_TIME_OUT = 'CZAS SI� KO�CZY!';
  STR_WARN_TIME_OVER = 'KONIEC CZASU';
  STR_WARN_ENEMY_ON_BOARD = 'ALARM! WR�G NA POK�ADZIE!';
  STR_WARN_LANDER_DESTROYED = 'L�DOWNIK ZNISZCZONY!';

  STR_START_TIP = 'PODNIE� L�DOWNIK I LE� W Dӣ, POD STATEK-MATK�';
  STR_GAME_OVER = 'KONIEC GRY';
  STR_MISSION_FINISHED = 'MISJA ZAKO�CZONA';
  STR_PRESS_KEY_TO_CONTINUE = 'WCI�NIJ [%s] BY KONTYNUOWA�';
  STR_PAUSED = 'PAUZA';
  STR_PRESS_KEY_TO_CONTINUE_GAME = 'WCI�NIJ [%s] BY KONTYNUOWA� GR�';
  STR_PRESS_KEY_TO_QUIT = 'WCI�NIJ [%s] BY PRZERWA�';

  STR_MISSION_PLANET = 'PLANETA';
  STR_MISSION_RESCUE_TASK = 'URATUJ CO NAJMNIEJ %1 LUDZI Z WSZYSTKICH %2' + #13 +
    'ZANIM WYSADZIMY PLANET�. CZAS NA WYKONANIE MISJI: %5.'#13 + 'POWODZENIA!';
  STR_MISSION_RESCUE_WIN = 'MISJA WYKONANA. DOBRA ROBOTA.';
  STR_MISSION_RESCUE_LOST = 'NIE WYKONA�E� MISJI!'#13 + 'ZA�OGA STATKU-MATKI NIE CHCE CI� WI�CEJ WIDZIE�'#13 +
    'PRZEZ TO, �E NIE URATOWA�E� ICH LUDZI... PRZEZ CIEBIE'#13 + 'WSZYSCY POZOSTALI NA PLANECIE ZGIN�.';

  STR_MISSION_DESTROY_TASK = 'ZNISZCZ CO NAJMNIEJ %3 DZIA� WROGA Z WSZYSTKICH %4'#13 +
    'Z PLANETY. CZAS NA WYKONANIE MISJI: %5.'#13 + 'POWODZENIA!';
  STR_MISSION_DESTROY_WIN = 'MISJA WYKONANA. DOBRA ROBOTA.';
  STR_MISSION_DESTROY_LOST = 'NIE WYKONA�E� MISJI!'#13 + 'NASZA PLANETA ZOSTA�A OPANOWANA PRZEZ WROGA, BO'#13 +
    'ZAWIOD�E�...';

  STR_MISSION = 'MISJA';
  STR_MISSION_ACCOMPLISHED = 'WYKONANA!';
  STR_MISSION_FAILED = 'STRACONA...';

  STR_MISSION_YOU_ARE_DEAD = 'NIESTETY ZGIN��E�...';
  STR_MISSION_END_TIME_LEFT_BONUS = 'PREMIA ZA POZOSTA�Y CZAS:'#13' PKT: %d, KASA: %d';
  STR_MISSION_END_SURVIVORS_BONUS = 'PREMIA ZA WZI�CIE DODATKOWYCH PILOT�W:'#13' PKT: %d, KASA: %d';
  STR_MISSION_END_TURRETS_BONUS = 'PREMIA ZA ZNISZCZENIE DODATKOWYCH DZIA�EK:'#13' PKT: %d, KASA: %d';

  STR_TITLE_NEW_GAME_NORMAL = 'nowa gra: misja pocz�tkowa: %d';
  STR_TITLE_NEW_GAME_RANDOM = 'nowa gra: misje losowe: %d';
  STR_TITLE_ADDITIONAL_MISSIONS = 'misje dodatkowe';
  STR_TITLE_LOAD_GAME = 'wczytanie gry';
  STR_TITLE_EXIT = 'wyj�cie';
  STR_TITLE_VERSION = 'WERSJA ';

  STR_TITLE_LS_SAVE_GAME = 'ZAPIS GRY';
  STR_TITLE_LS_LOAD_GAME = 'ODCZYT GRY';
  STR_TITLE_LS_NORMAL_GAME = 'NORMALNA GRA';
  STR_TITLE_LS_RANDOM_GAME = 'MISJE LOSOWE';
  STR_TITLE_LS_ADDITIONAL_GAME = 'MISJE DODATKOWE';
  STR_TITLE_LS_STATE_MISSION = 'MISJA:';
  STR_TITLE_LS_STATE_SCORE = 'PKT:';
  STR_TITLE_LS_STATE_LANDERS = 'L�DOWNIKI:';
  STR_TITLE_LS_STATE_CASH = 'KASA:';
  STR_TITLE_LS_EMPTY = '--PUSTY--';
  STR_TITLE_LS_RETURN = 'POWR�T';

  STR_TITLE_SH_SHOP = 'SKLEP';
  STR_TITLE_SH_CASH = 'KASA: ';

  STR_TITLE_SH_FUEL_TANK = 'ZBIORNIK PALIWA';
  STR_TITLE_SH_ROCKETS = 'RAKIETY';
  STR_TITLE_SH_GUN = 'DZIA�O MASZYNOWE';
  STR_TITLE_SH_SHIELD = 'OS�ONA';
  STR_TITLE_SH_COOLING_SYSTEM = 'UK�AD CH�ODZ�CY';
  STR_TITLE_SH_LOAD_CAPACITY = '�ADOWNO��';
  STR_TITLE_SH_OWNED = 'MASZ: ';
  STR_TITLE_SH_BUY = 'KUP: %d, CENA: %d';
  STR_TITLE_SH_BUY_LANDER = 'KUP, CENA: %d';
  STR_TITLE_SH_LANDER = 'DODATKOWY L�DOWNIK';

  STR_TITLE_AM_MISSION = '%d: %s, MISJI: %d';
  STR_TITLE_AM_NO_MISSIONS = 'BRAK MISJI DODATKOWYCH';
  STR_TITLE_AM_RETURN = '[esc] powr�t do winiety';

  STR_APP_ERROR = 'B��d';
  STR_APP_ERROR_OPENING_FILE = 'B��d podczas odczytu pliku %s';
  STR_APP_LOADING = '�adowanie danych...';


{$ELSE IF LANGUAGE_EN}
  PROGRAM_TITLE = 'Retrofire';
  STR_PROGRAM_VER = 'ver.';
  MISSIONS_USE_STORYLINE = FALSE;

  titleScrollLines: array [0 .. 35] of string = ('GAME CONCEPT BY', 'GRZEGORZ DROZD', '', '', '', 'CODING', 'GRZEGORZ DROZD',
    '', '', '', 'GRAPHICS', 'GRZEGORZ DROZD', '', '', '', 'MENU MUSIC', 'FATER (PRO-CREATION, THE ODOURS)',
    'WWW.PRO-CREATION.PL', 'WWW.THEODOURS.NET', '', '', '', 'IN-GAME MUSIC AND INTRO/OUTRO MUSIC', 'GRZEGORZ DROZD', '',
    '', '', 'GAME TESTING', 'KRZYSZTOF RZEPKA', 'GRZEGORZ DROZD', '', '', '2007-2023 GADZ.PL',
    'VERSION ' + PROGRAM_VERSION, 'HTTPS://GADZ.PL/', '');

  mainIntroLines: array [0 .. 3] of TMainIntroLine =
    ((s: 'GADZ.PL'; i: 3), (s: 'PRESENTS'; i: 2), (s: 'A GAME BY GRZEGORZ DROZD'; i: 2), (s: 'RETROFIRE'; i: 4));

  STR_MISSION_RESCUE_PEOPLE = 'MISSION %d:'#13'RESCUE SURVIVORS';
  STR_MISSION_DESTROY_ENEMY = 'MISSION %d:'#13'DESTROY ENEMY TURRETS';
  STR_MISSION_BOARDED = 'BOARDED:';
  STR_MISSION_LEFT = 'LEFT:';
  STR_MISSION_RESCUED = 'RESCUED:';
  STR_MISSION_KILLED = 'KILLED:';
  STR_MISSION_DESTROYED = 'DESTROYED:';

  STR_CHEAT_SHIELDS = 'MAX SHIELDS';
  STR_CHEAT_FUEL = 'MAX FUEL';
  STR_CHEAT_WEAPONS = 'MAX WEAPONS';
  STR_CHEAT_LOAD = 'MAX LOAD CAPACITY';
  STR_CHEAT_TIME = 'MAX TIME';

  STR_WARN_LOW_FUEL = 'LOW FUEL!';
  STR_WARN_NO_FUEL = 'FUEL TANK EMPTY';
  STR_WARN_TEMP_CRITICAL = 'CRITICAL TEMPERATURE';
  STR_WARN_HIGH_TEMP = 'HIGH TEMPERATURE!';
  STR_WARN_TOO_HIGH = 'YOU ARE TOO HIGH!';
  STR_WARN_TIME_OUT = 'TIME IS RUNNING OUT!';
  STR_WARN_TIME_OVER = 'OUT OF TIME';
  STR_WARN_ENEMY_ON_BOARD = 'ALERT! THE ENEMY ON BOARD!';
  STR_WARN_LANDER_DESTROYED = 'LANDER DESTROYED!';

  STR_START_TIP = 'PULL UP AND FLY UNDER THE MOTHERSHIP';
  STR_GAME_OVER = 'GAME OVER';
  STR_MISSION_FINISHED = 'MISSION FINISHED';
  STR_PRESS_KEY_TO_CONTINUE = 'PRESS [%s] TO CONTINUE';
  STR_PAUSED = 'PAUSED';
  STR_PRESS_KEY_TO_CONTINUE_GAME = 'PRESS [%s] TO CONTINUE';
  STR_PRESS_KEY_TO_QUIT = 'PRESS [%s] TO QUIT';

  STR_MISSION_PLANET = 'PLANET';
  STR_MISSION_RESCUE_TASK = 'RESCUE AT LEAST %1 OF SURVIVORS OF ALL %2' + #13 +
    'BEFORE WE BLOW UP THE PLANET. YOU HAVE %5 FOR YOUR MISSION.'#13 + 'GOOD LUCK!';
  STR_MISSION_RESCUE_WIN = 'YOUR MISSION IS ACCOMPLISHED. GOOD WORK.';
  STR_MISSION_RESCUE_LOST = 'YOU HAVEN''T COMPLETED THE MISSION.'#13 +
    'THE MOTHERSHIP CREW DON''T WANT TO SEE YOU AGAIN'#13 +
    'BECAUSE YOU DIDN''T RESCUE THEIR PEOPLE...'#13 +
    'ALL SURVIVORS ON THE PLANET'#13 + 'WILL DIE AND IT''S ALL YOUR FAULT.';

  STR_MISSION_DESTROY_TASK = 'DESTROY AT LEAST %3 ENEMY TURRETS OF ALL %4.'#13 +
    'YOU HAVE %5 FOR YOUR MISSION.'#13 + 'GOOD LUCK!';
  STR_MISSION_DESTROY_WIN = 'YOUR MISSION IS ACCOMPLISHED. GOOD WORK.';
  STR_MISSION_DESTROY_LOST = 'YOU HAVEN''T COMPLETED THE MISSION.'#13 +
    'OUR PLANET HAS BEEN CONQUERED BY THE ENEMY BECAUSE'#13 +
    'YOU FAILED. IT'' ALL YOUR FAULT.';

  STR_MISSION = 'MISSION';
  STR_MISSION_ACCOMPLISHED = 'ACCOMPLISHED!';
  STR_MISSION_FAILED = 'FAILED...';

  STR_MISSION_YOU_ARE_DEAD = 'UNFORTUNATELY YOU DIED...';
  STR_MISSION_END_TIME_LEFT_BONUS = 'BONUS FOR THE TIME LEFT:'#13' POINTS: %d, CASH: %d';
  STR_MISSION_END_SURVIVORS_BONUS = 'BONUS FOR ADDITIONAL SURVIVORS RESCUED:'#13' POINTS: %d, CASH: %d';
  STR_MISSION_END_TURRETS_BONUS = 'BONUS FOR ADDITIONAL TURRETS DESTROYED:'#13' POINTS: %d, CASH: %d';

  STR_TITLE_NEW_GAME_NORMAL = 'NEW GAME: STARTING MISSION: %d';
  STR_TITLE_NEW_GAME_RANDOM = 'NEW GAME: RANDOM MISSIONS: %d';
  STR_TITLE_ADDITIONAL_MISSIONS = 'EXTRA MISSIONS';
  STR_TITLE_LOAD_GAME = 'LOAD GAME STATE';
  STR_TITLE_EXIT = 'QUIT';
  STR_TITLE_VERSION = 'VERSION ';

  STR_TITLE_LS_SAVE_GAME = 'SAVE GAME';
  STR_TITLE_LS_LOAD_GAME = 'LOAD GAME';
  STR_TITLE_LS_NORMAL_GAME = 'STANDARD GAME';
  STR_TITLE_LS_RANDOM_GAME = 'RANDOM MISSIONS';
  STR_TITLE_LS_ADDITIONAL_GAME = 'EXTRA MISSIONS';
  STR_TITLE_LS_STATE_MISSION = 'MISSION:';
  STR_TITLE_LS_STATE_SCORE = 'POINTS:';
  STR_TITLE_LS_STATE_LANDERS = 'LANDERS:';
  STR_TITLE_LS_STATE_CASH = 'CASH:';
  STR_TITLE_LS_EMPTY = '-- EMPTY SLOT --';
  STR_TITLE_LS_RETURN = 'BACK';

  STR_TITLE_SH_SHOP = 'THE SHOP';
  STR_TITLE_SH_CASH = 'CASH: ';

  STR_TITLE_SH_FUEL_TANK = 'FUEL TANK';
  STR_TITLE_SH_ROCKETS = 'ROCKETS';
  STR_TITLE_SH_GUN = 'MACHINE GUN';
  STR_TITLE_SH_SHIELD = 'SHIELDS';
  STR_TITLE_SH_COOLING_SYSTEM = 'COOLING SYSTEM';
  STR_TITLE_SH_LOAD_CAPACITY = 'LOAD CAPACITY';
  STR_TITLE_SH_OWNED = 'OWNED: ';
  STR_TITLE_SH_BUY = 'BUY: %d, PRICE: %d';
  STR_TITLE_SH_BUY_LANDER = 'BUY ONE FOR: %d';
  STR_TITLE_SH_LANDER = 'EXTRA LANDER';

  STR_TITLE_AM_MISSION = '%d: %s, MISSIONS: %d';
  STR_TITLE_AM_NO_MISSIONS = 'NO EXTRA MISSIONS IN YOUR LIBRARY';
  STR_TITLE_AM_RETURN = '[esc] BACK TO TITLE SCREEN';

  STR_APP_ERROR = 'Error';
  STR_APP_ERROR_OPENING_FILE = 'Error while loading the file %s';
  STR_APP_LOADING = 'Loading data...';


{$ENDIF}

implementation

end.
