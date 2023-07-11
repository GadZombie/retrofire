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
  katwidzenia = 70;

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



implementation

end.
