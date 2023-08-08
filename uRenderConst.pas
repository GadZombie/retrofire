unit uRenderConst;

interface
uses
  GL;

var
  widocznosc: integer = 80; { dla 1300 bylo 60 }
  widocznoscpil: integer = 20; // pilotow
  widocznoscdzial: integer = 80; // dzialka
  widocznoscscen: integer = 53; // sceneria
  widocznoscscencien: integer = 25; // cien scenerii
  widocznosckrzak: integer = 10; // krzaki
  odlwidzenia: integer = 2000;

const
  ile_tekstur = 19;
  katwidzenia = 70;
  GROUND_COLORS_MAX = 15;

var
  mat_spec: array [0 .. 3] of GLFloat = (
    1.00,
    1.00,
    1.00,
    1.0
  );
  mat_1a: array [0 .. 3] of GLFloat = (
    0.70,
    0.70,
    0.70,
    1.0
  );
  mat_1d: array [0 .. 3] of GLFloat = (
    0.70,
    0.70,
    0.70,
    1.0
  );
  mat_1s: array [0 .. 3] of GLFloat = (
    1.00,
    1.00,
    1.00,
    1.0
  );

  pos1: array [0 .. 3] of GLFloat = (
    200.0,
    200.0,
    100.0,
    1.0
  );
  pos1win: array [0 .. 3] of GLFloat = (
    -4200,
    2700,
    -3000,
    1.0
  );
  light_ka0: array [0 .. 3] of GLFloat = (
    0.30,
    0.30,
    0.25,
    1.0
  );
  light_kd0: array [0 .. 3] of GLFloat = (
    0.30,
    0.30,
    0.25,
    1.0
  );
  light_ks0: array [0 .. 3] of GLFloat = (
    0.30,
    0.30,
    0.25,
    1.0
  );

  light_ka1: array [0 .. 3] of GLFloat = (
    0.80,
    0.80,
    0.75,
    1.0
  );
  light_kd1: array [0 .. 3] of GLFloat = (
    0.80,
    0.80,
    0.75,
    1.0
  );
  light_ks1: array [0 .. 3] of GLFloat = (
    1.00,
    1.00,
    0.95,
    1.0
  );

  right: array [0 .. 2] of GLFloat;  // ={viewMatrix[0], viewMatrix[4], viewMatrix[8]};
  up: array [0 .. 2] of GLFloat;  // ={viewMatrix[1], viewMatrix[5], viewMatrix[9]};

  groundColors: array[0..GROUND_COLORS_MAX, 0..3] of GLFloat = (
    ( 0.78, 0.54, 0.38 , 1.0 ),
    ( 0.89, 0.84, 0.6 , 1.0 ),
    ( 0.22, 0.77, 0.15 , 1.0 ),
    ( 0.27, 0.58, 0.29 , 1.0 ),
    ( 0.49, 0.84, 0.12 , 1.0 ),
    ( 0.62, 0.74, 0.81 , 1.0 ),
    ( 0.77, 0.77, 0.77 , 1.0 ),
    ( 0.82, 0.8, 0.69 , 1.0 ),
    ( 0.39, 0.45, 0.31 , 1.0 ),
    ( 0.84, 0.24, 0.14 , 1.0 ),
    ( 0.29, 0.28, 0.25 , 1.0 ),
    ( 0.81, 0.81, 0.74 , 1.0 ),
    ( 0.55, 0.58, 0.62 , 1.0 ),
    ( 0.84, 0.68, 0.51 , 1.0 ),
    ( 0.64, 0.52, 0.22 , 1.0 ),
    ( 0.6, 0.68, 0.4 , 1.0 )
  );




implementation

end.
