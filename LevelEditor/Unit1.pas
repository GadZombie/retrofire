unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Menus, Buttons;

const
  WM_START = WM_USER+1;
  ilekol=5;

upgrade:array[0..5,0..9] of record
     ile:real;
     cena:integer;
   end=(
{paliwo}    ((ile:150;cena:0),(ile:180;cena:450),(ile:200;cena:900),(ile:240;cena:1395),(ile:290;cena:2070),(ile:320;cena:2430),(ile:340;cena:3150),(ile:360;cena:3630),(ile:400;cena:4380),(ile:450;cena:5100)),
{rakiety}   ((ile:8;cena:0),(ile:12;cena:270),(ile:16;cena:450),(ile:20;cena:630),(ile:26;cena:810),(ile:32;cena:960),(ile:36;cena:1140),(ile:40;cena:1500),(ile:46;cena:2250),(ile:54;cena:4140)),
{dzialko}   ((ile:50;cena:0),(ile:80;cena:240),(ile:130;cena:440),(ile:160;cena:600),(ile:200;cena:720),(ile:250;cena:890),(ile:300;cena:1100),(ile:340;cena:1400),(ile:380;cena:2100),(ile:500;cena:3950)),
{sila}      ((ile:0.8;cena:0),(ile:0.9;cena:360),(ile:1;cena:510),(ile:1.2;cena:750),(ile:1.5;cena:1140),(ile:2;cena:1560),(ile:2.5;cena:2340),(ile:3;cena:2700),(ile:3.5;cena:3450),(ile:4;cena:4820)),
{chlodzenie}((ile:0.3;cena:0),(ile:0.5;cena:270),(ile:0.6;cena:510),(ile:0.7;cena:690),(ile:0.8;cena:972),(ile:1;cena:1110),(ile:1.5;cena:1537),(ile:2;cena:1975),(ile:2.5;cena:2360),(ile:3;cena:2998)),
{ladownosc} ((ile:8;cena:0),(ile:9;cena:600),(ile:10;cena:930),(ile:11;cena:1240),(ile:12;cena:1620),(ile:14;cena:1980),(ile:16;cena:2375),(ile:18;cena:2827),(ile:20;cena:4080),(ile:24;cena:6250))
       );


type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Mapka1: TMenuItem;
    Stwrzpust1: TMenuItem;
    Wygenerujlosow1: TMenuItem;
    Wczytaj1: TMenuItem;
    Zapisz1: TMenuItem;
    N1: TMenuItem;
    Wyjcie1: TMenuItem;
    Wygadcablur1: TMenuItem;
    N2: TMenuItem;
    Operacjenamapce1: TMenuItem;
    ColorDialog1: TColorDialog;
    ScrollBox1: TScrollBox;
    rys: TPaintBox;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    PageControl1: TPageControl;
    TabTworzenie: TTabSheet;
    Panel1: TPanel;
    Kolor: TShape;
    trskala: TTrackBar;
    trjasnosc: TTrackBar;
    trrozmiar: TTrackBar;
    narzedzie: TRadioGroup;
    Pokazuj: TRadioGroup;
    ChPokLadowiska: TCheckBox;
    ChPokDziala: TCheckBox;
    GroupBoxLadowiska: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    EditLadRX: TEdit;
    UpDownLadRX: TUpDown;
    UpDownLadRZ: TUpDown;
    EditLadRZ: TEdit;
    UpDownLadPilotow: TUpDown;
    EditLadPilotow: TEdit;
    GroupBox3: TGroupBox;
    myszx: TLabel;
    myszz: TLabel;
    myszy: TLabel;
    tr3d: TTrackBar;
    TabUstawienia: TTabSheet;
    Panel3: TPanel;
    GroupBox4: TGroupBox;
    BtnMisja1: TSpeedButton;
    BtnMisja2: TSpeedButton;
    MisjaPoziom: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    RadioMisja1: TRadioButton;
    RadioMisja2: TRadioButton;
    EditMisja1: TEdit;
    UpDownMisja1: TUpDown;
    UpDownMisja2: TUpDown;
    EditMisja2: TEdit;
    EditMisjaPoziom: TEdit;
    UpDownMisjaPoziom: TUpDown;
    EditMisjaGrawitacja: TEdit;
    UpDownMisjaGrawitacja: TUpDown;
    EditMisjaGestosc: TEdit;
    UpDownMisjaGestosc: TUpDown;
    EditMisjaWiatr: TEdit;
    UpDownMisjaWiatr: TUpDown;
    EditWysMatki: TEdit;
    UpDownWysMatki: TUpDown;
    GroupBox1: TGroupBox;
    Kolornieba: TShape;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    BtnZmienWymiar: TSpeedButton;
    Label3: TLabel;
    EditWymX: TEdit;
    UpDownWymX: TUpDown;
    EditWymZ: TEdit;
    UpDownWymZ: TUpDown;
    UpDownWymWlk: TUpDown;
    EditWymWlk: TEdit;
    TabOperacje: TTabSheet;
    Panel4: TPanel;
    GroupBoxKolorowanie: TGroupBox;
    BtnLosujKol: TSpeedButton;
    BtnNalozKolory: TSpeedButton;
    GroupBox2: TGroupBox;
    BtnLosDzial: TSpeedButton;
    EditLosDzial: TEdit;
    UpDownLosDzial: TUpDown;
    Label11: TLabel;
    GroupBox5: TGroupBox;
    BtnLosLad: TSpeedButton;
    Label12: TLabel;
    EditLosLad: TEdit;
    UpDownLosLad: TUpDown;
    GroupBox6: TGroupBox;
    MemoIntro: TMemo;
    GroupBox7: TGroupBox;
    MemoNazwa: TEdit;
    GroupBox8: TGroupBox;
    MemoOutroWin: TMemo;
    GroupBox9: TGroupBox;
    MemoOutroLost: TMemo;
    EditCzasMin: TEdit;
    UpDownCzasMin: TUpDown;
    EditCzasSek: TEdit;
    UpDownCzasSek: TUpDown;
    Label13: TLabel;
    Label14: TLabel;
    LadKolor: TShape;
    LadKoloruj: TCheckBox;
    BtnDomyslneTeksty: TSpeedButton;
    BtnBlur: TSpeedButton;
    Znieksztaca1: TMenuItem;
    BtnZnieksztalc: TSpeedButton;
    ChLadDobre: TCheckBox;
    GroupBoxDzialka: TGroupBox;
    RodzajDzialka: TRadioGroup;
    ChLadLosJakie: TCheckBox;
    UpDownMisjaPoziomDo: TUpDown;
    EditMisjaPoziomDo: TEdit;
    Label15: TLabel;
    Label16: TLabel;
    EditMisjaGrawitacjaDo: TEdit;
    UpDownMisjaGrawitacjaDo: TUpDown;
    Label17: TLabel;
    EditMisjaGestoscDo: TEdit;
    UpDownMisjaGestoscDo: TUpDown;
    Label18: TLabel;
    EditMisjaWiatrDo: TEdit;
    UpDownMisjaWiatrDo: TUpDown;
    Label19: TLabel;
    EditMaxMysliwcow: TEdit;
    UpDownMaxMysliwcow: TUpDown;
    Label20: TLabel;
    EditMaxMysliwcowDo: TEdit;
    UpDownMaxMysliwcowDo: TUpDown;
    GroupBoxRysowanie: TGroupBox;
    KsztaltPedzla: TRadioGroup;
    trpedzel: TTrackBar;
    Label21: TLabel;
    ChRysWygladz: TCheckBox;
    BtnZmienWys: TSpeedButton;
    EditZmienWys: TEdit;
    UpDownZmienWys: TUpDown;
    LabJasnosc: TLabel;
    Edytorepizodw1: TMenuItem;
    BtnSkalujWys: TSpeedButton;
    EditSkalujWys: TEdit;
    UpDownSkalujWys: TUpDown;
    TabUstawienia2: TTabSheet;
    Panel5: TPanel;
    GroupBoxMinUpgrade: TGroupBox;
    BtnSceneria: TSpeedButton;
    Automatyczniewyznaczsceneri1: TMenuItem;
    EditScenTolerancja: TEdit;
    UpDownScenTolerancja: TUpDown;
    EditScenIle: TEdit;
    UpDownScenIle: TUpDown;
    Label22: TLabel;
    Label23: TLabel;
    Bevel1: TBevel;
    Splitter1: TSplitter;
    GroupBox10: TGroupBox;
    EditMuzyka: TEdit;
    Label24: TLabel;
    ChRysZmianaKoloru: TCheckBox;
    Label25: TLabel;
    Label26: TLabel;
    SpeedButton1: TSpeedButton;
    procedure btngenerujClick(Sender: TObject);
    procedure rysPaint(Sender: TObject);
    procedure trskalaChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rysMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pobierz_spod_myszy;
    procedure rysMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure rysMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure rysuj(btn:byte);
    procedure trrozmiarChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure trpedzelChange(Sender: TObject);
    procedure btnrozmyjClick(Sender: TObject);
    procedure Wyjcie1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnZmienWymiarClick(Sender: TObject);
    procedure Stwrzpust1Click(Sender: TObject);
    procedure KolorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PokazujClick(Sender: TObject);
    procedure KolorniebaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure narzedzieClick(Sender: TObject);
    procedure BtnMisja1Click(Sender: TObject);
    procedure BtnMisja2Click(Sender: TObject);
    procedure tr3dChange(Sender: TObject);
    procedure BtnLosujKolClick(Sender: TObject);
    procedure BtnNalozKoloryClick(Sender: TObject);
    procedure BtnLosDzialClick(Sender: TObject);
    procedure BtnLosLadClick(Sender: TObject);
    procedure RadioMisja1Click(Sender: TObject);
    procedure RadioMisja2Click(Sender: TObject);
    procedure ChPokLadowiskaClick(Sender: TObject);
    procedure ChPokDzialaClick(Sender: TObject);
    procedure BtnDomyslneTekstyClick(Sender: TObject);
    procedure Znieksztaca1Click(Sender: TObject);
    procedure UpDownMisjaPoziomClick(Sender: TObject; Button: TUDBtnType);
    procedure UpDownMisjaPoziomDoClick(Sender: TObject;
      Button: TUDBtnType);
    procedure UpDownMisjaGrawitacjaClick(Sender: TObject;
      Button: TUDBtnType);
    procedure UpDownMisjaGrawitacjaDoClick(Sender: TObject;
      Button: TUDBtnType);
    procedure UpDownMisjaGestoscClick(Sender: TObject; Button: TUDBtnType);
    procedure UpDownMisjaGestoscDoClick(Sender: TObject;
      Button: TUDBtnType);
    procedure UpDownMisjaWiatrClick(Sender: TObject; Button: TUDBtnType);
    procedure UpDownMisjaWiatrDoClick(Sender: TObject; Button: TUDBtnType);
    procedure UpDownMaxMysliwcowClick(Sender: TObject; Button: TUDBtnType);
    procedure UpDownMaxMysliwcowDoClick(Sender: TObject;
      Button: TUDBtnType);
    procedure BtnZmienWysClick(Sender: TObject);
    procedure UpDownWymWlkClick(Sender: TObject; Button: TUDBtnType);
    procedure trjasnoscChange(Sender: TObject);
    procedure Edytorepizodw1Click(Sender: TObject);
    procedure BtnSkalujWysClick(Sender: TObject);
    procedure BtnSceneriaClick(Sender: TObject);

    procedure rysrepaint(x0,y0, x1,y1: real; rmysz:boolean=true);
    procedure rysrepaint_wokol_myszy(b: boolean);
    procedure MemoIntroExit(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }

    k_sh:array[0..ilekol] of TShape;
    k_ed:array[0..ilekol] of TEdit;
    k_up:array[0..ilekol] of TUpDown;

    mu_cb:array[0..5] of Tcombobox;
    mu_lab:array[0..5] of TLabel;

    rysrepaintrect: Trect;
    rysrepaintmysz: boolean;

  end;

var
  Form1: TForm1;

ziemia:record
   px,pz:real;
   wx,wz:integer;
   pk:array of array of record
         p:real;
         kr,kg,kb:real;
         rodzaj: byte; {0-nic, 1-ladowisko}
         scen: boolean;
      end;
   wlk:integer;

   grawitacja: real;
   gestoscpowietrza: real;

   end;

dzialko:array of record
    x,z:integer; //INACZEJ NIZ W GRZE! PO WCZYTANIU W GRZE TRZEBA PRZEMNOZYC PRZEZ ZIEMIA.WLK !!!!!
    rodzaj:byte;
   end;

ladowiska:array of record
    x,z:integer;//pozycja w kratkach
    rx,rz:integer;//rozmiar

    pilotow:byte;
    dobre:boolean;
   end;

rozmiar:integer=5;
skala:real=1;

mysz:record
    l,p,sr:boolean;
    x,y:integer;

    pedzel:integer;
   end;

   function wczytajstring(var plik:TStream):string;
   procedure zapiszstring(var plik:TStream;t:string);

implementation

uses UnitEpizody, Types;

{$R *.DFM}

function wczytajstring(var plik:TStream):string;
var
  buf:shortstring;
  bufa:array[0..254] of byte;
  d:word;
  d1:byte;
  m,dl:longint;
  t:string;
begin
    plik.readbuffer(dl,sizeof(dl)); {length(t):=dl}
    m:=1;
    t:='';
    while m<=dl do begin
       if dl-(m-1)>255 then d:=255
          else d:=dl-(m-1);
       plik.readbuffer(bufa,d);
       move(bufa,buf[1],d);
       d1:=d;
       buf[0]:=chr(d1);

       t:=t+copy(buf,1,d);
       inc(m,d);
    end;
    if t=#1#2 then t:='';
    wczytajstring:=t;
end;

procedure zapiszstring(var plik:TStream;t:string);
var
  buf:shortstring;
  d:word;
  m,l:longint;
  bufa:array[0..254] of byte;
begin
 {$I-}
    if t='' then t:=#1#2;
    l:=length(t);
    plik.WriteBuffer(l,sizeof(l));
    m:=1;
    while m<=length(t) do begin
       if length(t)-(m-1)>255 then d:=255
          else d:=length(t)-(m-1);
       buf:=copy(t,m,d);
       move(buf[1],bufa,d);
       plik.WriteBuffer(bufa,d);
       inc(m,d);
    end;
end;

function sqrt2(v:real):real;
begin
if v=0 then result:=0
   else result:=sqrt(v);
end;

procedure TForm1.btngenerujClick(Sender: TObject);
var a,b,c,ax,az,bx,bz:integer;
kolory:array[0..5,0..2] of real; {0..5 to wysokosci, gdzie jest dany kolor}
rozwys,rozwys2,r:real;
ok:boolean;

dsz, sz, dtz, tz, sw: real;
_s,_t: integer;
najwyzszy, najnizszy, koldziel: real;

rodzaj_gor:integer;

begin
{ziemia.wlk:=30;
ziemia.wx:=154;
ziemia.wz:=154;
}

rodzaj_gor:= random(2);


setlength(ziemia.pk,ziemia.wx);
for a:=0 to high(ziemia.pk) do
    setlength(ziemia.pk[a],ziemia.wz);

//decyzja jakie beda kolory
for b:=0 to 2 do kolory[0,b]:=random;
for a:=1 to 5 do begin
    for b:=0 to 2 do begin
        kolory[a,b]:=kolory[a-1,b]-0.3+random*0.6;
        if kolory[a,b]<0 then kolory[a,b]:=0;
        if kolory[a,b]>1 then kolory[a,b]:=1;
    end;
end;


//generowanie terenu

rozwys:=10+random*100;
rozwys2:=rozwys/2;


case rodzaj_gor of
  0:begin //gory po staremu (randomowe)

      for a:=0 to high(ziemia.pk) do begin
          for b:=0 to high(ziemia.pk[a]) do begin
              ziemia.pk[a,b].rodzaj:=0;
              if (a=0) and (b=0) then
                 ziemia.pk[a,b].p:=random*130
              else
                  if b=0 then ziemia.pk[a,b].p:=ziemia.pk[a-1,b].p+random*rozwys-rozwys2
              else
                  if a=0 then ziemia.pk[a,b].p:=ziemia.pk[a,b-1].p+random*rozwys-rozwys2
              else begin
                  case random(3) of
                    0:ziemia.pk[a,b].p:=(ziemia.pk[a,b-1].p+ziemia.pk[a-1,b].p)/2+random*rozwys-rozwys2;
                    1:ziemia.pk[a,b].p:=ziemia.pk[a,b-1].p+random*rozwys-rozwys2;
                    2:ziemia.pk[a,b].p:=ziemia.pk[a-1,b].p+random*rozwys-rozwys2;
                  end;
              end;

              if ziemia.pk[a,b].p<1 then ziemia.pk[a,b].p:=1;
              if ziemia.pk[a,b].p>800-100 then ziemia.pk[a,b].p:=800-100;

          end;
      end;

    end;
  1:begin //gory skladane z trojkatow

      ax:=random(100)-50;
      for a:=0 to high(ziemia.pk) do
          for b:=0 to high(ziemia.pk[a]) do begin
              ziemia.pk[a,b].rodzaj:=0;
              ziemia.pk[a,b].p:=ax;
          end;

      for a:=0 to 30+random(35) do begin
          ax:=random(high(ziemia.pk)*2) - high(ziemia.pk); //od x
          bx:=random(high(ziemia.pk)*2-ax)+ax; //do x

          sz:=random(high(ziemia.pk[0]));
          tz:=random(high(ziemia.pk[0]));
          dsz:=random*10-5;
          dtz:=random*10-5;

          sw:=random*170-70;

          for b:=ax to bx do begin
              if sz<=tz then begin
                  _s:=round(sz);
                  _t:=round(tz);
              end else begin
                  _s:=round(tz);
                  _t:=round(sz);
              end;

              for c:=_s to _t do begin
                  if (b>=0) and (b<=high(ziemia.pk)) and
                     (c>=0) and (c<=high(ziemia.pk[0])) then begin
                     ziemia.pk[b,c].p:=ziemia.pk[b,c].p+sw;

                     if ziemia.pk[b,c].p<-700 then ziemia.pk[b,c].p:=-700;
                     if ziemia.pk[b,c].p>700 then ziemia.pk[b,c].p:=700;

                  end;
              end;

              sz:=sz+dsz;
              tz:=tz+dtz;

              dsz:=dsz+(random-0.5)*0.7;
              dtz:=dtz+(random-0.5)*0.7;

          end;

      end;

    end;
end;

//wyszukaj najnizszy i najwyzszy punkt
najnizszy:=9999;
najwyzszy:=-9999;
for a:=0 to high(ziemia.pk) do
    for b:=0 to high(ziemia.pk[a]) do begin
        if ziemia.pk[a,b].p>najwyzszy then najwyzszy:=ziemia.pk[a,b].p;
        if ziemia.pk[a,b].p<najnizszy then najnizszy:=ziemia.pk[a,b].p;
    end;

koldziel:=(najwyzszy-najnizszy)/5;

//kolorowanie
for a:=0 to high(ziemia.pk) do begin
    for b:=0 to high(ziemia.pk[a]) do begin

//        r:=ziemia.pk[a,b].p/200;
        r:=(ziemia.pk[a,b].p-najnizszy)/koldziel{200};
        if (frac(r)<0.05) then r:=r-random*0.1
           else
           if (frac(r)>0.95) then r:=r+random*0.1;

        if r<0 then r:=0;
        if r>5 then r:=5;

        ziemia.pk[a,b].kr:=kolory[trunc(r),0];
        ziemia.pk[a,b].kg:=kolory[trunc(r),1];
        ziemia.pk[a,b].kb:=kolory[trunc(r),2];

    end;
end;
ziemia.px:=-(ziemia.wx/2)*ziemia.wlk;
ziemia.pz:=-(ziemia.wz/2)*ziemia.wlk;


setlength(dzialko,5+random(10));
for a:=0 to high(dzialko) do begin
    with dzialko[a] do begin
       repeat
         ax:=(2+random(ziemia.wx-4));
         az:=(2+random(ziemia.wz-4));
         ok:=true;
         for bx:=ax-2 to ax+2 do
             for bz:=az-2 to az+2 do begin
                 if ziemia.pk[bx,bz].rodzaj<>0 then ok:=false;
             end;

         x:=ax;
         z:=az;

         if a>=1 then
            for b:=0 to a-1 do
                if (dzialko[b].x>=x-2) and
                   (dzialko[b].x<=x+2) and
                   (dzialko[b].z>=z-2) and
                   (dzialko[b].z<=z+2) then ok:=false;

       until ok;

    end;
end;


setlength(ladowiska,1+random(5));
for a:=0 to high(ladowiska) do begin
    //rozmiar ladowiska
    ladowiska[a].rx:=5;//1+random(4);
    ladowiska[a].rz:=4;//1+random(4);

    //pozycja ladowiska
    ladowiska[a].x:=random(ziemia.wx-ladowiska[a].rx*2)+ladowiska[a].rx;
    ladowiska[a].z:=random(ziemia.wz-ladowiska[a].rz*2)+ladowiska[a].rz;

    if LadKoloruj.Checked then begin
       for ax:=ladowiska[a].x-ladowiska[a].rx to ladowiska[a].x+ ladowiska[a].rx-1 do
           for az:=ladowiska[a].z-ladowiska[a].rz to ladowiska[a].z+ ladowiska[a].rz-1 do begin
               ziemia.pk[ax,az].kr:=(LadKolor.Brush.Color and $000000FF)/256;
               ziemia.pk[ax,az].kg:=((LadKolor.Brush.Color and $0000FF00) shr 8)/256;
               ziemia.pk[ax,az].kb:=((LadKolor.Brush.Color and $00FF0000) shr 16)/256;
           end;
    end;

    ladowiska[a].pilotow:=1+random(20);
    ladowiska[a].dobre:=true;

end;


//---
for a:=1 to random(3) do
    Znieksztaca1Click(nil);

for a:=1 to random(5) do
    btnrozmyjClick(nil);

rys.Repaint;
end;

procedure TForm1.rysPaint(Sender: TObject);
var a,b:integer; k,l:integer; co:integer; d3, nz:real;
begin
if (ziemia.wx=0) or (ziemia.wz=0) then exit;

  if rysrepaintrect.Left<0 then rysrepaintrect.Left:=0;
  if rysrepaintrect.Left>ziemia.wx-1 then rysrepaintrect.Left:=ziemia.wx-1;

  if rysrepaintrect.Top<0 then rysrepaintrect.Top:=0;
  if rysrepaintrect.Top>ziemia.wz-1 then rysrepaintrect.Top:=ziemia.wz-1;

  if rysrepaintrect.Right<0 then rysrepaintrect.Right:=0;
  if rysrepaintrect.Right>ziemia.wx-1 then rysrepaintrect.Right:=ziemia.wx-1;

  if rysrepaintrect.Bottom<0 then rysrepaintrect.Bottom:=0;
  if rysrepaintrect.Bottom>ziemia.wz-1 then rysrepaintrect.Bottom:=ziemia.wz-1;


(sender as tpaintbox).width:=ziemia.wx*rozmiar;
(sender as tpaintbox).Height:=ziemia.wz*rozmiar;

co:=Pokazuj.ItemIndex;
if tr3d.Position=0 then d3:=0
                   else d3:=ln(sqr(32-tr3d.Position));

with (sender as tpaintbox).canvas do begin
    pen.mode:=pmCopy;
    brush.style:=bsSolid;
end;

for a:=rysrepaintrect.Left to rysrepaintrect.Right do
    for b:=rysrepaintrect.Top to rysrepaintrect.Bottom do begin
        with (sender as tpaintbox).canvas do begin
           k:=(round(ziemia.pk[a,b].p*skala)) mod 256;
           if k>=0 then begin
              case co of
                 0:brush.color:=$00000000+k+k shl 8+ k shl 16;
                 1:brush.color:=$00+trunc(ziemia.pk[a,b].kr*256)+ trunc(ziemia.pk[a,b].kg*256) shl 8+ trunc(ziemia.pk[a,b].kb*256) shl 16;
                 2:brush.color:=$00+trunc(ziemia.pk[a,b].kr*k)+ trunc(ziemia.pk[a,b].kg*k) shl 8+ trunc(ziemia.pk[a,b].kb*k) shl 16;
                 3:begin
                   if ziemia.pk[a,b].scen then
                      brush.color:=$00000000+(k div 2+127) shl 8
                   else
                      brush.color:=$00000000+k+k shl 8+ k shl 16;
                   end;
              end;
           end else begin
              case co of
                 0:brush.color:=$00000000+abs(k);
                 1:brush.color:=$00+trunc(ziemia.pk[a,b].kr*256)+ trunc(ziemia.pk[a,b].kg*256) shl 8+ trunc(ziemia.pk[a,b].kb*256) shl 16;
                 2:brush.color:=$00+trunc(ziemia.pk[a,b].kr*abs(k))+ trunc(ziemia.pk[a,b].kg*abs(k)) shl 8+ trunc(ziemia.pk[a,b].kb*abs(k)) shl 16;
                 3:begin
                   if ziemia.pk[a,b].scen then
                      brush.color:=$00000000+(k div 2+127) shl 8
                   else
                      brush.color:=$00000000+k+k shl 8+ k shl 16;
                   end;
              end;
           end;
           if d3=0 then
              FillRect(rect(a*rozmiar,b*rozmiar,(a+1)*rozmiar,(b+1)*rozmiar))
           else begin
              if k>=0 then
                 FillRect(rect(a*rozmiar,round(b*rozmiar-(ziemia.pk[a,b].p/d3)),(a+1)*rozmiar,(b+1)*rozmiar))
              else if (b>=1){ and (ziemia.pk[a,b-1].p>=ziemia.pk[a,b].p) }then
                 FillRect(rect(a*rozmiar,     round((b-1)*rozmiar-(ziemia.pk[a,b-1].p/d3)),
                               (a+1)*rozmiar, round(b*rozmiar-(ziemia.pk[a,b].p/d3)) ));
           end;
        end;
    end;

if ChPokDziala.Checked then
  with (sender as tpaintbox).canvas do begin
      for a:=0 to high(dzialko) do begin
          if dzialko[a].rodzaj=0 then brush.color:=$0000ff00
                                 else brush.color:=$0000bfff;
          pen.color:=brush.color;

          if d3=0 then nz:=0
                  else nz:=(ziemia.pk[dzialko[a].x,dzialko[a].z].p/d3);

          Ellipse(rect(round((dzialko[a].x)*rozmiar),
                       round((dzialko[a].z)*rozmiar-nz),
                       round((dzialko[a].x)*rozmiar+rozmiar),
                       round((dzialko[a].z)*rozmiar-nz+rozmiar)
                       ));
      end;
  end;

if ChPokLadowiska.Checked then
  with (sender as tpaintbox).canvas do begin
      for a:=0 to high(ladowiska) do begin
          if ladowiska[a].dobre then brush.color:=$00ff6000
                                else brush.color:=$002020ff;
          pen.color:=brush.color;
          brush.style:=bsDiagCross;

          if d3=0 then nz:=0
                  else nz:=(ziemia.pk[ladowiska[a].x,ladowiska[a].z].p/d3);

          Rectangle(rect(round( (ladowiska[a].x-ladowiska[a].rx )*rozmiar),
                         round( (ladowiska[a].z-ladowiska[a].rz )*rozmiar-nz),
                         round( (ladowiska[a].x+ladowiska[a].rx )*rozmiar),
                         round( (ladowiska[a].z+ladowiska[a].rz )*rozmiar-nz)
                       ));

          brush.style:=bsClear;
          font.name:='Arial';
          font.size:=7;
          font.color:=clblack;
          TextOut(1+round( (ladowiska[a].x-ladowiska[a].rx div 2)*rozmiar),
                  1+round( (ladowiska[a].z-ladowiska[a].rz div 2)*rozmiar-nz),
                  inttostr(ladowiska[a].pilotow));
          font.color:=clwhite;
          TextOut(round( (ladowiska[a].x-ladowiska[a].rx div 2)*rozmiar),
                  round( (ladowiska[a].z-ladowiska[a].rz div 2)*rozmiar-nz),
                  inttostr(ladowiska[a].pilotow));
      end;

  end;

if rysrepaintmysz then
with (sender as tpaintbox).canvas do begin
   case narzedzie.ItemIndex of
    0,1,4:begin//rysowanie
      pen.mode:=pmnot;
      brush.style:=bsclear;
      if KsztaltPedzla.ItemIndex=0 then
        Ellipse((mysz.x-trpedzel.position)*rozmiar,
                (mysz.y-trpedzel.position)*rozmiar,
                (mysz.x+1+trpedzel.position)*rozmiar,
                (mysz.y+1+trpedzel.position)*rozmiar)
      else
        rectangle((mysz.x-trpedzel.Position+1)*rozmiar,
                  (mysz.y-trpedzel.Position+1)*rozmiar,
                  (mysz.x+trpedzel.Position)*rozmiar,
                  (mysz.y+trpedzel.Position)*rozmiar);
      end;
    2:begin//dzialka
      pen.mode:=pmnot;
      brush.style:=bsclear;
      Ellipse((mysz.x)*rozmiar,
              (mysz.y)*rozmiar,
              (mysz.x+1)*rozmiar,
              (mysz.y+1)*rozmiar);
      end;
    3:begin//ladowiska
      pen.mode:=pmnot;
      brush.style:=bsclear;
      rectangle((mysz.x-UpDownLadRX.Position)*rozmiar,
                (mysz.y-UpDownLadRZ.Position)*rozmiar,
                (mysz.x+UpDownLadRX.Position)*rozmiar,
                (mysz.y+UpDownLadRZ.Position)*rozmiar);
      end;
   end;
end;

end;

procedure TForm1.trskalaChange(Sender: TObject);
begin
skala:=(sender as ttrackbar).Position/100;
rys.Repaint;
end;

procedure TForm1.FormCreate(Sender: TObject);
var a,y,b,m:integer;
begin
//ScrollBox1.DoubleBuffered:=true;
rys.ControlStyle:=[csopaque];
Randomize;
mysz.pedzel:=6;

for a:=0 to ilekol do begin
    y:=18+(ilekol-a)*25;

    k_sh[a]:=TShape.Create(Form1);
    with k_sh[a] do begin
       parent:=GroupBoxKolorowanie;
       left:=8;
       width:=169;
       top:=y;
       height:=22;
       OnMouseDown:=KolorMouseDown;
       Cursor:=crHandPoint;
    end;

    k_ed[a]:=TEdit.Create(Form1);
    with k_ed[a] do begin
       parent:=GroupBoxKolorowanie;
       left:=184;
       width:=44;
       top:=y;
       height:=21;
    end;

    k_up[a]:=TUpDown.Create(Form1);
    with k_up[a] do begin
       parent:=GroupBoxKolorowanie;
       Associate:=k_ed[a];
       min:=-700;
       max:=700;
       Position:=a*150-200;
{       left:=184;
       width:=44;
       top:=18+a*25;
       height:=21;}
    end;

end;

for a:=0 to 5 do begin
    y:=18+a*25;

    mu_lab[a]:=TLabel.Create(Form1);
    with mu_lab[a] do begin
       parent:=GroupBoxMinUpgrade;
       left:=8;
       //width:=169;
       top:=y;
       //height:=22;
       //OnMouseDown:=KolorMouseDown;
       case a of
          0:Caption:='paliwo';
          1:Caption:='rakiety';
          2:Caption:='dzialko';
          3:Caption:='sila';
          4:Caption:='chlodzenie';
          5:Caption:='ladownosc';
       end;
    end;
    mu_cb[a]:=TCombobox.Create(Form1);
    with mu_cb[a] do begin
       parent:=GroupBoxMinUpgrade;
       left:=parent.Width-90;
       width:=80;
       top:=y;
       if a in [3,4] then m:=100 else m:=1;
       style:=csDropDownList;
       for b:=0 to 9 do items.add(inttostr(1+b)+') '+inttostr(round(upgrade[a,b].ile*m)));
       itemindex:=0;
    end;

end;

trskalaChange(trskala);
Stwrzpust1Click(Stwrzpust1);
BtnDomyslneTekstyClick(BtnDomyslneTeksty);
trpedzelChange(trpedzel);
trjasnoscChange(trjasnosc);
end;

procedure TForm1.rysuj(btn:byte);
var a,x,y,j,ax,az:integer; w:real; klr,klg,klb:real;
begin
case narzedzie.itemindex of
0:begin//wysokosci
 if btn=0 then j:=700-trjasnosc.position
          else j:=0;

 if KsztaltPedzla.ItemIndex=0 then begin//kolo
     for y:=mysz.y-mysz.pedzel to mysz.y+mysz.pedzel do
         for x:=mysz.x-mysz.pedzel to mysz.x+mysz.pedzel do begin

             if (x>=0) and (y>=0) and (x<ziemia.wx) and (y<ziemia.wz) then begin
                if (x-mysz.x=0) and (y-mysz.y=0) then
                   w:=((mysz.pedzel+1) - sqrt2(sqr(1)+sqr(0)) ) / mysz.pedzel
                else
                   w:=((mysz.pedzel+1) - sqrt2(sqr(x-mysz.x)+sqr(y-mysz.y)) ) / mysz.pedzel;

                if w<0 then w:=0;

                if ChRysWygladz.Checked then
                   ziemia.pk[x,y].p:=(j*w + ziemia.pk[x,y].p*(1-w))
                else
                   if w>0 then ziemia.pk[x,y].p:=j;

             end;

         end;
 end else begin//kwadrat
     for y:=mysz.y-mysz.pedzel to mysz.y+mysz.pedzel do
         for x:=mysz.x-mysz.pedzel to mysz.x+mysz.pedzel do begin

             if (x>=0) and (y>=0) and (x<ziemia.wx) and (y<ziemia.wz) then begin
                if (x-mysz.x=0) and (y-mysz.y=0) then
                   w:=((mysz.pedzel+1) - sqrt2(sqr(1)+sqr(0)) ) / mysz.pedzel
                else begin
                   //w:=((mysz.pedzel+1) - sqrt2(sqr(x-mysz.x)+sqr(y-mysz.y)) ) / mysz.pedzel;
                   if (abs(x-mysz.x)<abs(y-mysz.y)) then w:=1-abs(mysz.y-y)/mysz.pedzel
                                      else w:=1-abs(mysz.x-x)/mysz.pedzel;
                end;

                if w<0 then w:=0;

                if ChRysWygladz.Checked then
                   ziemia.pk[x,y].p:=(j*w + ziemia.pk[x,y].p*(1-w))
                else
                   if w>0 then ziemia.pk[x,y].p:=j;

             end;

         end;

 end;

 end;

1:begin//kolorowanie
 klr:=(Kolor.Brush.Color and $000000FF)/256;
 klg:=((Kolor.Brush.Color and $0000FF00) shr 8)/256;
 klb:=((Kolor.Brush.Color and $00FF0000) shr 16)/256;
{ for y:=mysz.y-mysz.pedzel to mysz.y+mysz.pedzel do
     for x:=mysz.x-mysz.pedzel to mysz.x+mysz.pedzel do begin

         if (x>=0) and (y>=0) and (x<ziemia.wx) and (y<ziemia.wz) then begin
            w:=((mysz.pedzel+1) - sqrt2(sqr(x-mysz.x)+sqr(y-mysz.y)) ) / mysz.pedzel;
            if w<0 then w:=0;

            ziemia.pk[x,y].kr:=(klr*w + ziemia.pk[x,y].kr*(1-w));
            ziemia.pk[x,y].kg:=(klg*w + ziemia.pk[x,y].kg*(1-w));
            ziemia.pk[x,y].kb:=(klb*w + ziemia.pk[x,y].kb*(1-w));

         end;

     end;}

 if KsztaltPedzla.ItemIndex=0 then begin//kolo
     for y:=mysz.y-mysz.pedzel to mysz.y+mysz.pedzel do
         for x:=mysz.x-mysz.pedzel to mysz.x+mysz.pedzel do begin

             if (x>=0) and (y>=0) and (x<ziemia.wx) and (y<ziemia.wz) then begin
                if (x-mysz.x=0) and (y-mysz.y=0) then
                   w:=((mysz.pedzel+1) - sqrt2(sqr(1)+sqr(0)) ) / mysz.pedzel
                else
                   w:=((mysz.pedzel+1) - sqrt2(sqr(x-mysz.x)+sqr(y-mysz.y)) ) / mysz.pedzel;

                if w<0 then w:=0;

                if ChRysWygladz.Checked then begin
                   ziemia.pk[x,y].kr:=(klr*w + ziemia.pk[x,y].kr*(1-w));
                   ziemia.pk[x,y].kg:=(klg*w + ziemia.pk[x,y].kg*(1-w));
                   ziemia.pk[x,y].kb:=(klb*w + ziemia.pk[x,y].kb*(1-w));
                end else
                   if w>0 then begin
                       ziemia.pk[x,y].kr:=klr;
                       ziemia.pk[x,y].kg:=klg;
                       ziemia.pk[x,y].kb:=klb;
                   end;

             end;

         end;
 end else begin//kwadrat
     for y:=mysz.y-mysz.pedzel to mysz.y+mysz.pedzel do
         for x:=mysz.x-mysz.pedzel to mysz.x+mysz.pedzel do begin

             if (x>=0) and (y>=0) and (x<ziemia.wx) and (y<ziemia.wz) then begin
                if (x-mysz.x=0) and (y-mysz.y=0) then
                   w:=((mysz.pedzel+1) - sqrt2(sqr(1)+sqr(0)) ) / mysz.pedzel
                else begin
                   //w:=((mysz.pedzel+1) - sqrt2(sqr(x-mysz.x)+sqr(y-mysz.y)) ) / mysz.pedzel;
                   if (abs(x-mysz.x)<abs(y-mysz.y)) then w:=1-abs(mysz.y-y)/mysz.pedzel
                                      else w:=1-abs(mysz.x-x)/mysz.pedzel;
                end;

                if w<0 then w:=0;

                if ChRysWygladz.Checked then begin
                   ziemia.pk[x,y].kr:=(klr*w + ziemia.pk[x,y].kr*(1-w));
                   ziemia.pk[x,y].kg:=(klg*w + ziemia.pk[x,y].kg*(1-w));
                   ziemia.pk[x,y].kb:=(klb*w + ziemia.pk[x,y].kb*(1-w));
                end else
                   if w>0 then begin
                       ziemia.pk[x,y].kr:=klr;
                       ziemia.pk[x,y].kg:=klg;
                       ziemia.pk[x,y].kb:=klb;
                   end;

             end;

         end;

 end;


 end;

2:begin//dzialka
   case btn of
      0:begin //dodaj
           for a:=0 to high(dzialko) do begin
               if (dzialko[a].x>=(mysz.x-1)*ziemia.wlk) and
                  (dzialko[a].x<=(mysz.x+1)*ziemia.wlk) and
                  (dzialko[a].z>=(mysz.y-1)*ziemia.wlk) and
                  (dzialko[a].z<=(mysz.y+1)*ziemia.wlk) then begin
                  exit;
               end;
           end;

           setlength(dzialko,length(dzialko)+1);
           dzialko[high(dzialko)].x:=mysz.x;
           dzialko[high(dzialko)].z:=mysz.y;
           dzialko[high(dzialko)].rodzaj:=RodzajDzialka.ItemIndex;
           mysz.l:=false;
        end;
      1:begin //usun
           for a:=0 to high(dzialko) do begin
               if (dzialko[a].x>=mysz.x) and
                  (dzialko[a].x<=(mysz.x)) and
                  (dzialko[a].z>=mysz.y) and
                  (dzialko[a].z<=(mysz.y)) then begin
                  dzialko[a]:=dzialko[high(dzialko)];
                  setlength(dzialko,length(dzialko)-1);
                  break;
               end;
           end;
           mysz.l:=false;
        end;
   end;
 end;

3:begin//ladowiska
   case btn of
      0:begin //dodaj
           for a:=0 to high(ladowiska) do begin
               if (ladowiska[a].x-ladowiska[a].rx <=mysz.x+UpDownLadRX.Position ) and
                  (ladowiska[a].x+ladowiska[a].rx >=mysz.x-UpDownLadRX.Position ) and
                  (ladowiska[a].z-ladowiska[a].rz <=mysz.y+UpDownLadRZ.Position ) and
                  (ladowiska[a].z+ladowiska[a].rz >=mysz.y-UpDownLadRZ.Position )
                  then begin
                  exit;
               end;
           end;

           setlength(ladowiska,length(ladowiska)+1);
           ladowiska[high(ladowiska)].x:=mysz.x;
           ladowiska[high(ladowiska)].z:=mysz.y;
           ladowiska[high(ladowiska)].rx:=UpDownLadRX.Position;
           ladowiska[high(ladowiska)].rz:=UpDownLadRZ.Position;
           ladowiska[high(ladowiska)].pilotow:=UpDownLadPilotow.Position;
           ladowiska[high(ladowiska)].dobre:=ChLadDobre.Checked;

           if LadKoloruj.Checked then begin
              for ax:=ladowiska[high(ladowiska)].x-ladowiska[high(ladowiska)].rx  to ladowiska[high(ladowiska)].x+ ladowiska[high(ladowiska)].rx-1 do
                  for az:=ladowiska[high(ladowiska)].z-ladowiska[high(ladowiska)].rz to ladowiska[high(ladowiska)].z+ ladowiska[high(ladowiska)].rz-1 do begin
                      ziemia.pk[ax,az].kr:=(LadKolor.Brush.Color and $000000FF)/256;
                      ziemia.pk[ax,az].kg:=((LadKolor.Brush.Color and $0000FF00) shr 8)/256;
                      ziemia.pk[ax,az].kb:=((LadKolor.Brush.Color and $00FF0000) shr 16)/256;
                  end;
           end;

           mysz.l:=false;
        end;
      1:begin //usun
           for a:=0 to high(ladowiska) do begin
               if (ladowiska[a].x>=mysz.x-ladowiska[a].rx ) and
                  (ladowiska[a].x<=mysz.x+ladowiska[a].rx ) and
                  (ladowiska[a].z>=mysz.y-ladowiska[a].rz ) and
                  (ladowiska[a].z<=mysz.y+ladowiska[a].rz ) then begin
                  ladowiska[a]:=ladowiska[high(ladowiska)];
                  setlength(ladowiska,length(ladowiska)-1);
                  break;
               end;
           end;
           mysz.l:=false;
        end;
   end;
 end;

4:begin//sceneria
 if btn=0 then j:=1
          else j:=0;

 if KsztaltPedzla.ItemIndex=0 then begin//kolo
     for y:=mysz.y-mysz.pedzel to mysz.y+mysz.pedzel do
         for x:=mysz.x-mysz.pedzel to mysz.x+mysz.pedzel do begin

             if (x>=0) and (y>=0) and (x<ziemia.wx) and (y<ziemia.wz) then begin
                if (x-mysz.x=0) and (y-mysz.y=0) then
                   w:=((mysz.pedzel+1) - sqrt2(sqr(1)+sqr(0)) ) / mysz.pedzel
                else
                   w:=((mysz.pedzel+1) - sqrt2(sqr(x-mysz.x)+sqr(y-mysz.y)) ) / mysz.pedzel;

                if w>0 then begin
                   if (ChRysWygladz.Checked and (random(1000)+1<=w*100)) or
                      not ChRysWygladz.Checked then
                      ziemia.pk[x,y].scen:=boolean(j);
                end;
             end;
         end;
 end else begin//kwadrat
     for y:=mysz.y-(mysz.pedzel-1) to mysz.y+(mysz.pedzel-1) do
         for x:=mysz.x-(mysz.pedzel-1) to mysz.x+(mysz.pedzel-1) do begin

             if (x>=0) and (y>=0) and (x<ziemia.wx) and (y<ziemia.wz) then begin
//                ziemia.pk[x,y].scen:=boolean(j);

                if (x-mysz.x=0) and (y-mysz.y=0) then
                   w:=((mysz.pedzel+1) - sqrt2(sqr(1)+sqr(0)) ) / mysz.pedzel
                else begin
                   if (abs(x-mysz.x)<abs(y-mysz.y)) then w:=1-abs(mysz.y-y)/mysz.pedzel
                                      else w:=1-abs(mysz.x-x)/mysz.pedzel;
                end;

                if w<0 then w:=0;

                if (ChRysWygladz.Checked and (random(1000)+1<=w*100)) or
                   not ChRysWygladz.Checked then
                   ziemia.pk[x,y].scen:=boolean(j);

             end;
         end;
 end;

 end;


end;

end;

procedure TForm1.rysMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
rysrepaint_wokol_myszy(false);
mysz.l:=button=mbleft;
mysz.p:=button=mbright;
mysz.sr:=button=mbmiddle;
mysz.x:=x div rozmiar;
mysz.y:=y div rozmiar;
if mysz.l then rysuj(0);
if mysz.p then rysuj(1);

if mysz.sr then pobierz_spod_myszy;

rysrepaint_wokol_myszy(true);
end;

procedure TForm1.rysMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if button=mbleft then mysz.l:=false;
if button=mbright then mysz.p:=false;
if button=mbmiddle then mysz.sr:=false;

mysz.x:=x div rozmiar;
mysz.y:=y div rozmiar;
end;

procedure TForm1.pobierz_spod_myszy;
begin
   if (mysz.x>=0) and (mysz.y>=0) and (mysz.x<ziemia.wx) and (mysz.y<ziemia.wz) then begin
    case narzedzie.itemindex of
       1:begin
         Kolor.Brush.Color := trunc(ziemia.pk[mysz.x,mysz.y].kr*256)+
                              trunc(ziemia.pk[mysz.x,mysz.y].kg*256) shl 8+
                              trunc(ziemia.pk[mysz.x,mysz.y].kb*256) shl 16;
       end
       else begin
         trJasnosc.Position:=700-round(ziemia.pk[mysz.x,mysz.y].p);
         trjasnoscChange(trjasnosc);
       end;
    end;
   end;
end;

procedure TForm1.rysMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var kr,kg,kb:integer;
begin
rysrepaint_wokol_myszy(false);

mysz.x:=x div rozmiar;
mysz.y:=y div rozmiar;
if mysz.l then begin
   rysuj(0);
   if (narzedzie.ItemIndex=1) and ChRysZmianaKoloru.Checked then begin
      kr:=(Kolor.Brush.Color and $000000FF);
      kg:=((Kolor.Brush.Color and $0000FF00) shr 8);
      kb:=((Kolor.Brush.Color and $00FF0000) shr 16);

      kr:=kr+random(5)-2;
      kg:=kg+random(5)-2;
      kb:=kb+random(5)-2;
      if kr<0 then kr:=0;
      if kr>255 then kr:=255;
      if kg<0 then kg:=0;
      if kg>255 then kg:=255;
      if kb<0 then kb:=0;
      if kb>255 then kb:=255;

      Kolor.Brush.Color := kr+
                           kg shl 8+
                           kb shl 16;

   end;
end;
if mysz.p then rysuj(1);

myszx.Caption:='X:'+inttostr(mysz.x);
myszz.Caption:='Z:'+inttostr(mysz.y);
if (mysz.x>=0) and (mysz.y>=0) and (mysz.x<ziemia.wx) and (mysz.y<ziemia.wz) then
   myszy.Caption:='wys:'+inttostr(round(ziemia.pk[mysz.x,mysz.y].p))
else
   myszy.Caption:='wys: ---';

if mysz.sr then pobierz_spod_myszy;

myszx.Update;
myszz.Update;
myszy.Update;

rysrepaint_wokol_myszy(true);

end;

procedure TForm1.trrozmiarChange(Sender: TObject);
begin
rozmiar:=(sender as ttrackbar).Position;
rysRepaint((mysz.x-trpedzel.position)*rozmiar,(mysz.y-trpedzel.position)*rozmiar,
           (mysz.x+trpedzel.position)*rozmiar,(mysz.y+trpedzel.position)*rozmiar);
end;

//zapis
procedure TForm1.Button2Click(Sender: TObject);
var a,b,i:integer; f:tstream; bt:byte; r:real;
begin
if SaveDialog1.FileName='' then SaveDialog1.FileName:=trim(memonazwa.text);
if SaveDialog1.Execute then begin
    f:=nil;
    try
      try
         f:=TFileStream.Create(SaveDialog1.FileName, fmCreate);

         f.WriteBuffer(ziemia.wx,sizeof(ziemia.wx));
         f.WriteBuffer(ziemia.wz,sizeof(ziemia.wz));
         f.WriteBuffer(ziemia.wlk,sizeof(ziemia.wlk));

         //typ misji
         if RadioMisja1.Checked then bt:=0
            else bt:=1;
         f.WriteBuffer(bt,sizeof(bt));
         case bt of
            0:begin i:=UpDownMisja1.Position; f.WriteBuffer(i,sizeof(i));  end;
            1:begin i:=UpDownMisja2.Position; f.WriteBuffer(i,sizeof(i));  end;
         end;


         //poziom trudnosci
         bt:=UpDownMisjaPoziom.Position;
         f.WriteBuffer(bt,sizeof(bt));
         bt:=UpDownMisjaPoziomDo.Position-UpDownMisjaPoziom.Position+1;
         f.WriteBuffer(bt,sizeof(bt)); //* zwykly random()
         //grawitacja
         r:=UpDownMisjaGrawitacja.Position/10000;
         f.WriteBuffer(r,sizeof(r));
         r:=(UpDownMisjaGrawitacjaDo.Position/10000)-(UpDownMisjaGrawitacja.Position/10000);
         f.WriteBuffer(r,sizeof(r)); //* random * ta_wartosc
         //gestosc powietrza
         r:=(1000-UpDownMisjaGestosc.Position)/1000;
         f.WriteBuffer(r,sizeof(r));
         r:=((1000-(UpDownMisjaGestoscDo.Position-UpDownMisjaGestosc.Position))/1000);
         f.WriteBuffer(r,sizeof(r)); //* random * ta_wartosc
         //wiatr
         r:=UpDownMisjaWiatr.Position/10000;
         f.WriteBuffer(r,sizeof(r));
         r:=(UpDownMisjaWiatrDo.Position/10000)-(UpDownMisjaWiatr.Position/10000);
         f.WriteBuffer(r,sizeof(r)); //* random * ta_wartosc
         //max mysliwcow
         bt:=UpDownMaxMysliwcow.Position;
         f.WriteBuffer(bt,sizeof(bt)); //*
         bt:=UpDownMaxMysliwcowDo.Position-UpDownMaxMysliwcow.Position+1;
         f.WriteBuffer(bt,sizeof(bt)); //* zwykly random()

         //wys matki
         i:=UpDownWysMatki.Position;
         f.WriteBuffer(i,sizeof(i));
         //czas
         i:=UpDownCzasMin.Position*60+UpDownCzasSek.Position;
         f.WriteBuffer(i,sizeof(i));

         //kolor nieba
         bt:=kolornieba.Brush.color and $000000FF;
         f.WriteBuffer(bt,sizeof(bt));
         bt:=(kolornieba.Brush.color and $0000FF00) shr 8;
         f.WriteBuffer(bt,sizeof(bt));
         bt:=(kolornieba.Brush.color and $00FF0000) shr 16;
         f.WriteBuffer(bt,sizeof(bt));

         zapiszstring(f, memonazwa.Text);
         zapiszstring(f, MemoIntro.Text);
         zapiszstring(f, MemoOutroWin.Text);
         zapiszstring(f, MemoOutroLost.Text);

         for b:=0 to ziemia.wz-1 do
             for a:=0 to ziemia.wx-1 do begin
                 f.WriteBuffer(ziemia.pk[a,b].p,sizeof(ziemia.pk[a,b].p));
                 bt:=trunc(ziemia.pk[a,b].kr*256);
                 f.WriteBuffer(bt,sizeof(bt));
                 bt:=trunc(ziemia.pk[a,b].kg*256);
                 f.WriteBuffer(bt,sizeof(bt));
                 bt:=trunc(ziemia.pk[a,b].kb*256);
                 f.WriteBuffer(bt,sizeof(bt));
                 f.WriteBuffer(ziemia.pk[a,b].scen,sizeof(ziemia.pk[a,b].scen));
             end;

         b:=length(dzialko);
         f.WriteBuffer(b,sizeof(b));
         for a:=0 to high(dzialko) do begin
             f.WriteBuffer(dzialko[a].x,sizeof(dzialko[a].x));
             f.WriteBuffer(dzialko[a].z,sizeof(dzialko[a].z));
             f.WriteBuffer(dzialko[a].rodzaj,sizeof(dzialko[a].rodzaj)); //*
         end;

         b:=length(ladowiska);
         f.WriteBuffer(b,sizeof(b));
         for a:=0 to high(ladowiska) do begin
             f.WriteBuffer(ladowiska[a].x,sizeof(ladowiska[a].x));
             f.WriteBuffer(ladowiska[a].z,sizeof(ladowiska[a].z));
             f.WriteBuffer(ladowiska[a].rx,sizeof(ladowiska[a].rx));
             f.WriteBuffer(ladowiska[a].rz,sizeof(ladowiska[a].rz));
             f.WriteBuffer(ladowiska[a].pilotow,sizeof(ladowiska[a].pilotow));
             f.WriteBuffer(ladowiska[a].dobre,sizeof(ladowiska[a].dobre));
         end;

         zapiszstring(f, EditMuzyka.Text);

         f.Free;
         f:=nil;
      except
         if f<>nil then begin
            f.Free;
            f:=nil;
         end;
         MessageBox(Handle, pchar('B³¹d podczas zapisu pliku'), 'B³¹d', MB_OK+MB_TASKMODAL+MB_ICONERROR);
      end;
    finally
       if f<>nil then begin
          f.Free;
          f:=nil;
       end;
       OpenDialog1.FileName:=SaveDialog1.FileName;
    end;
end;

end;

//odczyt
procedure TForm1.Button3Click(Sender: TObject);
var a,b,i:integer; f:tstream; bt,br,bg,bb:byte; r:real;
begin
if OpenDialog1.Execute then begin
    f:=nil;
    try
      try
         f:=TFileStream.Create(OpenDialog1.FileName, fmopenread);

         f.ReadBuffer(ziemia.wx,sizeof(ziemia.wx));
         f.ReadBuffer(ziemia.wz,sizeof(ziemia.wz));
         f.ReadBuffer(ziemia.wlk,sizeof(ziemia.wlk));
         UpDownWymX.Position:=ziemia.wx;
         UpDownWymZ.Position:=ziemia.wz;
         UpDownWymWlk.Position:=ziemia.wlk;

         //typ misji
         f.ReadBuffer(bt,sizeof(bt));
         if bt=0 then RadioMisja1.Checked:=true
            else RadioMisja2.Checked:=true;
         f.ReadBuffer(i,sizeof(i));
         case bt of
            0:begin UpDownMisja1.Position:=i; end;
            1:begin UpDownMisja2.Position:=i; end;
         end;

         //poziom trudnosci
         f.ReadBuffer(bt,sizeof(bt));
         UpDownMisjaPoziom.Position:=bt;
         f.ReadBuffer(bt,sizeof(bt)); //*
         UpDownMisjaPoziomDo.Position:=UpDownMisjaPoziom.Position+bt-1;
         //grawitacja
         f.ReadBuffer(r,sizeof(r));
         UpDownMisjaGrawitacja.Position:=round(r*10000);
         f.ReadBuffer(r,sizeof(r)); //*
         UpDownMisjaGrawitacjaDo.Position:=UpDownMisjaGrawitacja.Position+round(r*10000);
         //gestosc powietrza
         f.ReadBuffer(r,sizeof(r));
         UpDownMisjaGestosc.Position:=round(1000-r*1000);
         f.ReadBuffer(r,sizeof(r)); //*
         UpDownMisjaGestoscDo.Position:=UpDownMisjaGestosc.Position+round(1000-r*1000);
         //wiatr
         f.ReadBuffer(r,sizeof(r));
         UpDownMisjaWiatr.Position:=round(r*10000);
         f.ReadBuffer(r,sizeof(r)); //*
         UpDownMisjaWiatrDo.Position:=UpDownMisjaWiatr.Position+round(r*10000);
         //poziom trudnosci
         f.ReadBuffer(bt,sizeof(bt)); //*
         UpDownMaxMysliwcow.Position:=bt;
         f.ReadBuffer(bt,sizeof(bt)); //*
         UpDownMaxMysliwcowDo.Position:=UpDownMaxMysliwcow.Position+bt-1;

         //wys matki
         f.ReadBuffer(i,sizeof(i));
         UpDownWysMatki.Position:=i;
         //czas
         f.ReadBuffer(i,sizeof(i));
         UpDownCzasMin.Position:=i div 60;
         UpDownCzasSek.Position:=i mod 60;

         //kolor nieba
         f.ReadBuffer(br,sizeof(br));
         f.ReadBuffer(bg,sizeof(bg));
         f.ReadBuffer(bb,sizeof(bb));
         kolornieba.Brush.color := br+(bg) shl 8+(bb) shl 16;

         memonazwa.Text:=wczytajstring(f);
         MemoIntro.Text:=wczytajstring(f);
         MemoOutroWin.Text:=wczytajstring(f);
         MemoOutroLost.Text:=wczytajstring(f);

         setlength(ziemia.pk,ziemia.wx);
         for a:=0 to high(ziemia.pk) do
             setlength(ziemia.pk[a],ziemia.wz);

         for b:=0 to ziemia.wz-1 do
             for a:=0 to ziemia.wx-1 do begin
                 f.ReadBuffer(ziemia.pk[a,b].p,sizeof(ziemia.pk[a,b].p));
                 f.ReadBuffer(br,sizeof(br));
                 f.ReadBuffer(bg,sizeof(bg));
                 f.ReadBuffer(bb,sizeof(bb));
                 ziemia.pk[a,b].kr:=br/256;
                 ziemia.pk[a,b].kg:=bg/256;
                 ziemia.pk[a,b].kb:=bb/256;
                 f.ReadBuffer(ziemia.pk[a,b].scen,sizeof(ziemia.pk[a,b].scen));
             end;

         f.ReadBuffer(b,sizeof(b));
         setlength(dzialko,b);
         for a:=0 to high(dzialko) do begin
             f.ReadBuffer(dzialko[a].x,sizeof(dzialko[a].x));
             f.ReadBuffer(dzialko[a].z,sizeof(dzialko[a].z));
             f.ReadBuffer(dzialko[a].rodzaj,sizeof(dzialko[a].rodzaj));
         end;

         f.ReadBuffer(b,sizeof(b));
         setlength(ladowiska,b);
         for a:=0 to high(ladowiska) do begin
             f.ReadBuffer(ladowiska[a].x,sizeof(ladowiska[a].x));
             f.ReadBuffer(ladowiska[a].z,sizeof(ladowiska[a].z));
             f.ReadBuffer(ladowiska[a].rx,sizeof(ladowiska[a].rx));
             f.ReadBuffer(ladowiska[a].rz,sizeof(ladowiska[a].rz));
             f.ReadBuffer(ladowiska[a].pilotow,sizeof(ladowiska[a].pilotow));
             f.ReadBuffer(ladowiska[a].dobre,sizeof(ladowiska[a].dobre));
         end;

         EditMuzyka.Text:=wczytajstring(f);

         f.Free;
         f:=nil;
      except
         if f<>nil then begin
            f.Free;
            f:=nil;
         end;
         MessageBox(Handle, pchar('B³¹d podczas odczytu pliku'), 'B³¹d', MB_OK+MB_TASKMODAL+MB_ICONERROR);
      end;
    finally
       if f<>nil then begin
          f.Free;
          f:=nil;
       end;
       SaveDialog1.FileName:=OpenDialog1.FileName;
    end;
end;

rysrepaintrect:=rect(0,0,ziemia.wx-1,ziemia.wz-1);
rysrepaintmysz:=true;

rys.Repaint;
end;

procedure TForm1.trpedzelChange(Sender: TObject);
begin
mysz.pedzel:=(sender as ttrackbar).Position;
rys.Repaint;
end;

procedure TForm1.btnrozmyjClick(Sender: TObject);
var a,b,n,az,ax,bx,bz:integer;
ax1,axm1, az1,azm1:integer;
begin
  for az:=0 to ziemia.wz-1 do begin
    for ax:=0 to ziemia.wx-1 do begin
        ax1:=ax+1;
        axm1:=ax-1;
        az1:=az+1;
        azm1:=az-1;
        if ax1>=ziemia.wx then dec(ax1,ziemia.wx);
        if az1>=ziemia.wz then dec(az1,ziemia.wz);
        if axm1<0 then inc(axm1,ziemia.wx);
        if azm1<0 then inc(azm1,ziemia.wz);

        ziemia.pk[ax,az].p:= (ziemia.pk[ax,az].p+
                             ziemia.pk[ax1,az].p+
                             ziemia.pk[ax,az1].p+
                             ziemia.pk[axm1,az].p+
                             ziemia.pk[ax,azm1].p)/5
    end;
  end;

  rys.Repaint;
end;

procedure TForm1.Wyjcie1Click(Sender: TObject);
begin
close;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
PageControl1.ActivePageIndex:=0;
trjasnosc.SetTick(700);
//TabUstawienia2.Free;
end;

procedure TForm1.BtnZmienWymiarClick(Sender: TObject);
var a:integer;
begin
ziemia.wx:=UpDownWymX.Position;
ziemia.wz:=UpDownWymZ.Position;

setlength(ziemia.pk,ziemia.wx);
for a:=0 to high(ziemia.pk) do
    setlength(ziemia.pk[a],ziemia.wz);

rys.Repaint;
end;

procedure TForm1.Stwrzpust1Click(Sender: TObject);
var a,b:integer;
begin
OpenDialog1.FileName:='';
SaveDialog1.FileName:='';
ziemia.wx:=UpDownWymX.Position;
ziemia.wz:=UpDownWymZ.Position;
ziemia.wlk:=UpDownWymWlk.Position;

setlength(ziemia.pk,ziemia.wx);
for a:=0 to high(ziemia.pk) do
    setlength(ziemia.pk[a],ziemia.wz);

for a:=0 to ziemia.wx-1 do
    for b:=0 to ziemia.wz-1 do begin
        ziemia.pk[a,b].p:=0;
        ziemia.pk[a,b].kr:=0.3;
        ziemia.pk[a,b].kg:=0.6;
        ziemia.pk[a,b].kb:=0.3;
        ziemia.pk[a,b].rodzaj:=0;
    end;

setlength(dzialko,0);
setlength(ladowiska,0);

rysrepaintrect:=rect(0,0,ziemia.wx-1,ziemia.wz-1);
rysrepaintmysz:=true;

rys.Repaint;
end;

procedure TForm1.KolorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if button=mbleft then begin
   ColorDialog1.Color:=(sender as tshape).brush.color;
   if ColorDialog1.Execute then (sender as tshape).brush.color:=ColorDialog1.Color;
end;
end;

procedure TForm1.PokazujClick(Sender: TObject);
begin
rys.Repaint;
end;

procedure TForm1.KolorniebaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if button=mbleft then begin
   ColorDialog1.Color:=(sender as tshape).brush.color;
   if ColorDialog1.Execute then (sender as tshape).brush.color:=ColorDialog1.Color;
end;
end;

procedure TForm1.narzedzieClick(Sender: TObject);
begin
GroupBoxLadowiska.Visible:=(sender as tradiogroup).itemindex=3;
GroupBoxDzialka.Visible:=(sender as tradiogroup).itemindex=2;
GroupBoxRysowanie.Visible:=(sender as tradiogroup).itemindex in [0,1,4];
ChRysZmianaKoloru.Enabled:=(sender as tradiogroup).itemindex in [1];
rys.Repaint;
end;

procedure TForm1.BtnMisja1Click(Sender: TObject);
var a,i:integer;
begin
i:=0;
if length(ladowiska)>0 then
   for a:=0 to high(ladowiska) do
       if ladowiska[a].dobre then inc(i,ladowiska[a].pilotow);
UpDownMisja1.Position:=i;
end;

procedure TForm1.BtnMisja2Click(Sender: TObject);
begin
UpDownMisja2.Position:=length(dzialko);
end;

procedure TForm1.tr3dChange(Sender: TObject);
begin
rys.Repaint;
end;

procedure TForm1.BtnLosujKolClick(Sender: TObject);
var a:integer; r,g,b:integer;
begin
k_sh[0].brush.color:=$00+(random(256) shl 16)+(random(256) shl 8)+(random(256));

for a:=1 to ilekol do begin
    r:= k_sh[a-1].brush.color and $000000FF;
    g:= (k_sh[a-1].brush.color and $0000FF00) shr 8;
    b:= (k_sh[a-1].brush.color and $00FF0000) shr 16;

    r:=r+random(160)-80;
    if r<0 then r:=0;
    if r>255 then r:=255;
    g:=g+random(160)-80;
    if g<0 then g:=0;
    if g>255 then g:=255;
    b:=b+random(160)-80;
    if b<0 then b:=0;
    if b>255 then b:=255;

    k_sh[a].brush.color:=$00+(b shl 16)+(g shl 8)+r;

end;

end;

procedure TForm1.BtnNalozKoloryClick(Sender: TObject);
var a,b:integer; r:real; k:tcolor;
begin
screen.Cursor:=crHourGlass;
for a:=0 to high(ziemia.pk) do begin
    for b:=0 to high(ziemia.pk[a]) do begin

        r:=ziemia.pk[a,b].p;

        if r<=k_up[0].Position-20 then k:= k_sh[0].Brush.color
        else
        if r<=k_up[0].Position+20 then k:= k_sh[0+random(2)].Brush.color
        else
        if r<=k_up[1].Position-20 then k:= k_sh[1].Brush.color
        else
        if r<=k_up[1].Position+20 then k:= k_sh[1+random(2)].Brush.color
        else
        if r<=k_up[2].Position-20 then k:= k_sh[2].Brush.color
        else
        if r<=k_up[2].Position+20 then k:= k_sh[2+random(2)].Brush.color
        else
        if r<=k_up[3].Position-20 then k:= k_sh[3].Brush.color
        else
        if r<=k_up[3].Position+20 then k:= k_sh[3+random(2)].Brush.color
        else
        if r<=k_up[4].Position-20 then k:= k_sh[4].Brush.color
        else
        if r<=k_up[4].Position+20 then k:= k_sh[4+random(2)].Brush.color
        else
            k:= k_sh[5].Brush.color;


        ziemia.pk[a,b].kr:= (k and $000000FF)/256 ;
        ziemia.pk[a,b].kg:= ((k and $0000FF00) shr 8)/256 ;
        ziemia.pk[a,b].kb:= ((k and $00FF0000) shr 16)/256 ;

    end;
end;
rys.Repaint;
screen.Cursor:=crDefault;
end;

procedure TForm1.BtnLosDzialClick(Sender: TObject);
var a,b,n,ax,az,bx,bz,proba:integer; ok:boolean;
begin
for n:=1 to UpDownLosDzial.Position do begin
    setlength(dzialko,length(dzialko)+1);
    a:=high(dzialko);
    with dzialko[a] do begin
       proba:=0;
       rodzaj:=random(2);
       repeat
         inc(proba);
         ax:=(2+random(ziemia.wx-4));
         az:=(2+random(ziemia.wz-4));
         ok:=true;
         for bx:=ax-2 to ax+2 do
             for bz:=az-2 to az+2 do begin
                 if ziemia.pk[bx,bz].rodzaj<>0 then ok:=false;
             end;

         x:=ax;
         z:=az;

         if a>=1 then
            for b:=0 to a-1 do
                if (dzialko[b].x>=x-2) and
                   (dzialko[b].x<=x+2) and
                   (dzialko[b].z>=z-2) and
                   (dzialko[b].z<=z+2) then ok:=false;

       until ok or (proba>1500);

       if proba>1500 then begin
          setlength(dzialko,length(dzialko)-1);
          rys.Repaint;
          messagebox(handle,'Nie znaleziono wolnego miejsca na dzia³ko!','Uwaga!', MB_OK or MB_TASKMODAL);
          exit;
       end;

    end;
end;
rys.Repaint;
end;

procedure TForm1.BtnLosLadClick(Sender: TObject);
var a,b,n,ax,az,bx,bz,proba:integer; ok:boolean;
begin

for n:=1 to UpDownLosLad.Position do begin
    setlength(ladowiska,length(ladowiska)+1);
    a:=high(ladowiska);
    with ladowiska[a] do begin
       proba:=0;
       dobre:=ChLadLosJakie.Checked;
       repeat
         inc(proba);

         rx:=1+random(6);
         rz:=1+random(6);

         x:=(rx div 2+random(ziemia.wx-rx-2));
         z:=(rz div 2+random(ziemia.wz-rz-2));

         pilotow:=random(20);

         if a>=1 then
            for b:=0 to a-1 do
                if (ladowiska[b].x-ladowiska[b].rx div 2<=x+rx div 2) and
                   (ladowiska[b].x+ladowiska[b].rx div 2>=x-rx div 2) and
                   (ladowiska[b].z-ladowiska[b].rz div 2<=z+rz div 2) and
                   (ladowiska[b].z+ladowiska[b].rz div 2>=z-rz div 2) then ok:=false;

       until ok or (proba>40000);

       if proba>40000 then begin
          setlength(ladowiska,length(ladowiska)-1);
          rys.Repaint;
          messagebox(handle,'Nie znaleziono wolnego miejsca na ladowisko!','Uwaga!', MB_OK or MB_TASKMODAL);
          exit;
       end;

    end;
end;
rys.Repaint;
end;

procedure TForm1.RadioMisja1Click(Sender: TObject);
begin
EditMisja1.Enabled:=(sender as TRadiobutton).checked;
UpDownMisja1.Enabled:=(sender as TRadiobutton).checked;
EditMisja2.Enabled:=not (sender as TRadiobutton).checked;
UpDownMisja2.Enabled:=not (sender as TRadiobutton).checked;
end;

procedure TForm1.RadioMisja2Click(Sender: TObject);
begin
EditMisja1.Enabled:=not (sender as TRadiobutton).checked;
UpDownMisja1.Enabled:=not (sender as TRadiobutton).checked;
EditMisja2.Enabled:=(sender as TRadiobutton).checked;
UpDownMisja2.Enabled:=(sender as TRadiobutton).checked;
end;

procedure TForm1.ChPokLadowiskaClick(Sender: TObject);
begin
rys.Repaint;
end;

procedure TForm1.ChPokDzialaClick(Sender: TObject);
begin
rys.Repaint;
end;

procedure TForm1.BtnDomyslneTekstyClick(Sender: TObject);
begin
if RadioMisja1.Checked then begin
   MemoIntro.text:='URATUJ CO NAJMNIEJ %1 LUDZI Z WSZYSTKICH %2'+#13#10+
        'ZANIM WYSADZIMY PLANETÊ. CZAS NA WYKONANIE MISJI: %5.'#13#10+
        'POWODZENIA!';
   MemoOutroWin.text:='UDA£O CI SIÊ WYKONAÆ MISJÊ!';
   MemoOutroLost.text:='NIE WYKONA£EŒ MISJI!'#13#10+
               'ZA£OGA STATKU-MATKI NIE CHCE CIÊ WIÊCEJ WIDZIEÆ'#13#10+
               'PRZEZ TO, ¯E NIE URATOWA£EŒ ICH LUDZI... PRZEZ CIEBIE'#13#10+
               'WSZYSCY POZOSTALI NA PLANECIE ZGIN¥.';
end else begin
   MemoIntro.text:='ZNISZCZ CO NAJMNIEJ %3 DZIA£ WROGA Z WSZYSTKICH %4'#13#10+
        'Z PLANETY. CZAS NA WYKONANIE MISJI: %5.'#13#10+
        'POWODZENIA!';
   MemoOutroWin.text:='UDA£O CI SIÊ WYKONAÆ MISJÊ!';
   MemoOutroLost.text:='NIE WYKONA£EŒ MISJI!'#13#10+
               'NASZA PLANETA ZOSTA£A OPANOWANA PRZEZ WROGA, BO'#13#10+
               'ZAWIOD£EŒ...';
end;

end;

procedure TForm1.Znieksztaca1Click(Sender: TObject);
var a,b,n,az,ax,bx,bz:integer;
ax1,axm1, az1,azm1:integer;
begin
  for az:=0 to ziemia.wz-1 do begin
    for ax:=0 to ziemia.wx-1 do begin
        ziemia.pk[ax,az].p:= ziemia.pk[ax,az].p+(random-0.5)*20;
        if ziemia.pk[ax,az].p<-700 then ziemia.pk[ax,az].p:=-700;
        if ziemia.pk[ax,az].p>700 then ziemia.pk[ax,az].p:=700;
    end;
  end;

  rys.Repaint;
end;

procedure TForm1.UpDownMisjaPoziomClick(Sender: TObject;
  Button: TUDBtnType);
begin
if UpDownMisjaPoziomDo.Position<UpDownMisjaPoziom.Position then
   UpDownMisjaPoziomDo.Position:=UpDownMisjaPoziom.Position;
end;

procedure TForm1.UpDownMisjaPoziomDoClick(Sender: TObject;
  Button: TUDBtnType);
begin
if UpDownMisjaPoziom.Position>UpDownMisjaPoziomDo.Position then
   UpDownMisjaPoziom.Position:=UpDownMisjaPoziomDo.Position;
end;

procedure TForm1.UpDownMisjaGrawitacjaClick(Sender: TObject;
  Button: TUDBtnType);
begin
if UpDownMisjaGrawitacjaDo.Position<UpDownMisjaGrawitacja.Position then
   UpDownMisjaGrawitacjaDo.Position:=UpDownMisjaGrawitacja.Position;
end;

procedure TForm1.UpDownMisjaGrawitacjaDoClick(Sender: TObject;
  Button: TUDBtnType);
begin
if UpDownMisjaGrawitacja.Position>UpDownMisjaGrawitacjaDo.Position then
   UpDownMisjaGrawitacja.Position:=UpDownMisjaGrawitacjaDo.Position;
end;

procedure TForm1.UpDownMisjaGestoscClick(Sender: TObject;
  Button: TUDBtnType);
begin
if UpDownMisjaGestoscDo.Position<UpDownMisjaGestosc.Position then
   UpDownMisjaGestoscDo.Position:=UpDownMisjaGestosc.Position;
end;

procedure TForm1.UpDownMisjaGestoscDoClick(Sender: TObject;
  Button: TUDBtnType);
begin
if UpDownMisjaGestosc.Position>UpDownMisjaGestoscDo.Position then
   UpDownMisjaGestosc.Position:=UpDownMisjaGestoscDo.Position;
end;

procedure TForm1.UpDownMisjaWiatrClick(Sender: TObject;
  Button: TUDBtnType);
begin
if UpDownMisjaWiatrDo.Position<UpDownMisjaWiatr.Position then
   UpDownMisjaWiatrDo.Position:=UpDownMisjaWiatr.Position;
end;

procedure TForm1.UpDownMisjaWiatrDoClick(Sender: TObject;
  Button: TUDBtnType);
begin
if UpDownMisjaWiatr.Position>UpDownMisjaWiatrDo.Position then
   UpDownMisjaWiatr.Position:=UpDownMisjaWiatrDo.Position;
end;

procedure TForm1.UpDownMaxMysliwcowClick(Sender: TObject;
  Button: TUDBtnType);
begin
if UpDownMaxMysliwcowDo.Position<UpDownMaxMysliwcow.Position then
   UpDownMaxMysliwcowDo.Position:=UpDownMaxMysliwcow.Position;
end;

procedure TForm1.UpDownMaxMysliwcowDoClick(Sender: TObject;
  Button: TUDBtnType);
begin
if UpDownMaxMysliwcow.Position>UpDownMaxMysliwcowDo.Position then
   UpDownMaxMysliwcow.Position:=UpDownMaxMysliwcowDo.Position;
end;

procedure TForm1.BtnZmienWysClick(Sender: TObject);
var a,b,n,az,ax,bx,bz:integer;
ax1,axm1, az1,azm1:integer;
begin
  for az:=0 to ziemia.wz-1 do begin
    for ax:=0 to ziemia.wx-1 do begin
        ziemia.pk[ax,az].p:= ziemia.pk[ax,az].p+UpDownZmienWys.Position;
        if ziemia.pk[ax,az].p<-700 then ziemia.pk[ax,az].p:=-700;
        if ziemia.pk[ax,az].p>700 then ziemia.pk[ax,az].p:=700;
    end;
  end;

  rys.Repaint;
end;

procedure TForm1.UpDownWymWlkClick(Sender: TObject; Button: TUDBtnType);
begin
ziemia.wlk:=UpDownWymWlk.Position;
end;

procedure TForm1.trjasnoscChange(Sender: TObject);
begin
LabJasnosc.Caption:=inttostr(700-(sender as ttrackbar).Position);
LabJasnosc.Update;
end;

procedure TForm1.Edytorepizodw1Click(Sender: TObject);
begin
FormEpizody.ShowModal;
end;

procedure TForm1.BtnSkalujWysClick(Sender: TObject);
var a,b,n,az,ax,bx,bz:integer;
ax1,axm1, az1,azm1:integer;
begin
  for az:=0 to ziemia.wz-1 do begin
    for ax:=0 to ziemia.wx-1 do begin
        ziemia.pk[ax,az].p:= ziemia.pk[ax,az].p*(UpDownSkalujWys.Position/100);
        if ziemia.pk[ax,az].p<-700 then ziemia.pk[ax,az].p:=-700;
        if ziemia.pk[ax,az].p>700 then ziemia.pk[ax,az].p:=700;
    end;
  end;

  rys.Repaint;
end;

procedure TForm1.BtnSceneriaClick(Sender: TObject);
var a,b,n,az,ax,bx,bz:integer;
ax1,axm1, az1,azm1:integer;
pr,tol:integer;
begin
  for az:=0 to ziemia.wz-1 do
    for ax:=0 to ziemia.wx-1 do
        ziemia.pk[ax][az].scen:=false;

  pr:= UpDownScenIle.Position;
  tol:= UpDownScenTolerancja.Position;

  for az:=1 to ziemia.wz-2 do
    for ax:=1 to ziemia.wx-2 do begin
        ziemia.pk[ax][az].scen := (random(100)+1)<=pr;

        if (abs(ziemia.pk[ax][az].p-ziemia.pk[ax+1][az].p)>tol) or
           (abs(ziemia.pk[ax][az].p-ziemia.pk[ax-1][az].p)>tol) or
           (abs(ziemia.pk[ax][az].p-ziemia.pk[ax][az+1].p)>tol) or
           (abs(ziemia.pk[ax][az].p-ziemia.pk[ax][az-1].p)>tol) then ziemia.pk[ax][az].scen:=false;

    end;

  rys.Repaint;
end;

procedure TForm1.rysrepaint(x0,y0, x1,y1: real; rmysz:boolean);
begin
  if x0<0 then x0:=0;
  if x0>ziemia.wx-1 then x0:=ziemia.wx-1;

  if y0<0 then y0:=0;
  if y0>ziemia.wz-1 then y0:=ziemia.wz-1;

  if x1<0 then x1:=0;
  if x1>ziemia.wx-1 then x1:=ziemia.wx-1;

  if y1<0 then y1:=0;
  if y1>ziemia.wz-1 then y1:=ziemia.wz-1;

  if tr3d.Position>0 then begin
     y0:=0;
     y1:=ziemia.wz-1;
  end;

  rysrepaintmysz:=rmysz;
  rysrepaintrect:=rect(trunc(x0),trunc(y0),trunc(x1),trunc(y1));
  rys.Repaint;
  rysrepaintrect:=rect(0,0,ziemia.wx-1,ziemia.wz-1);
  rysrepaintmysz:=true;
end;


procedure TForm1.rysrepaint_wokol_myszy(b: boolean);
begin

   case narzedzie.ItemIndex of
    0,1,4:begin//rysowanie
       rysRepaint((mysz.x-trpedzel.position),(mysz.y-trpedzel.position),
               (mysz.x+trpedzel.position),(mysz.y+trpedzel.position), b);
      end;
    2:begin//dzialka
       rysRepaint((mysz.x-1),(mysz.y-1),
               (mysz.x+1),(mysz.y+1), b);
      end;
    3:begin//ladowiska
       rysRepaint((mysz.x-UpDownLadRX.Position),(mysz.y-UpDownLadRZ.Position),
               (mysz.x+UpDownLadRX.Position),(mysz.y+UpDownLadRZ.Position), b);
      end;
   end;

end;

procedure TForm1.MemoIntroExit(Sender: TObject);
var a,b,l:integer; s:string;
begin
(sender as tmemo).Text:=AnsiUpperCase((sender as tmemo).Text);

s:=(sender as tmemo).Text;

l:=0;
a:=1;
while a<=length(s) do begin
    if s[a]=#13 then l:=0
       else inc(l);

    if l>=56 then begin
       b:=0;
       while (b<=56) and (s[a-b]<>' ') do inc(b);
       if b<56 then begin
          delete(s, a-b,1);
          insert(#13#10, s, a-b);
          a:=a-b;
       end;
       l:=0;
    end;

    inc(a);
end;

(sender as tmemo).Text:=s;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
Kolornieba.brush.color:=$00+(random(256) shl 16)+(random(256) shl 8)+(random(256));
end;

end.
