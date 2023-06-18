unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, PowerInputs, Buttons, directinput8, ComCtrls;

const ile_klaw=17;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    cbtrybgraf: TComboBox;
    cbbity: TComboBox;
    cbhz: TComboBox;
    GroupBox2: TGroupBox;
    cbdzwiek: TComboBox;
    btnok: TButton;
    btnanuluj: TButton;
    chfullscreen: TCheckBox;
    PowerInput1: TPowerInput;
    GroupBox3: TGroupBox;
    ButPrzywrocDomyslne: TSpeedButton;
    klawskrol: TScrollBox;
    TrVolDzw: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    TrVolMuz: TTrackBar;
    Label3: TLabel;
    TrWidocznosc: TTrackBar;
    TrJasnosc: TTrackBar;
    Label4: TLabel;
    ChKrzaki: TCheckBox;
    procedure btnanulujClick(Sender: TObject);
    procedure wczytajkfg;
    procedure zapiszkfg;
    procedure btnokClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ustawieniadomyslneklawiszy;
    procedure KlawiszClick(Sender: TObject);
    procedure ButPrzywrocDomyslneClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    klawisze_labele:array[0..ile_klaw] of TLabel;
    klawisze_zmien:array[0..ile_klaw] of TSpeedbutton;
  end;

var
  Form1: TForm1;

czest:array[0..3] of integer=(
              60,
              72,
              75,
              85);
bity:array[0..2] of integer=(
              16,
              24,
              32);
rozdz:array[0..4,0..1] of integer=(
             (320,240),
             (640,480),
             (800,600),
             (1024,768),
             (1280,1024));

nazwyklawiszy:array[0..ile_klaw] of string=(
         'Skrêcanie w lewo (prawa dysza)',
         'Skrêcanie w prawo (lewa dysza)',
         'Do góry (dolne dysze)',
         'Dolne dysze - podwójna moc',
         'W dó³ (górna dysza)',
         'Do przodu (tylna dysza)',
         'Strza³ rakiet¹',
         'Strza³ z dzia³a maszynowego',
         'Zakoñczenie misji (na statku-matce)',
         'Kamera 1 (zza l¹downika blisko)',
         'Kamera 2 (zza l¹downika do góry)',
         'Kamera 3 (ruchoma zza l¹downika w dó³)',
         'Kamera 4 (z przodu l¹downika)',
         'Kamera 5 (zza l¹downika dalej)',
         'Kamera 6 (nad l¹downikiem pionowo w dó³)',
         'Kamera 7 (z najbli¿szego l¹dowiska)',
         'Kamera 8 (ze œrodka)',
         'Wyjœcie pilota z pok³adu'
         );

klawisze:array[0..49] of byte;

implementation

uses Unit2;

{$R *.dfm}

procedure TForm1.ustawieniadomyslneklawiszy;
begin
klawisze[ 0]:=dik_left;
klawisze[ 1]:=dik_right;
klawisze[ 2]:=dik_z;
klawisze[ 3]:=dik_x;
klawisze[ 4]:=dik_q;
klawisze[ 5]:=dik_a;
klawisze[ 6]:=dik_s;
klawisze[ 7]:=dik_d;
klawisze[ 8]:=dik_w;
klawisze[ 9]:=dik_1;
klawisze[10]:=dik_2;
klawisze[11]:=dik_3;
klawisze[12]:=dik_4;
klawisze[13]:=dik_5;
klawisze[14]:=dik_6;
klawisze[15]:=dik_7;
klawisze[16]:=dik_8;
klawisze[17]:=dik_r;
end;

procedure TForm1.btnanulujClick(Sender: TObject);
begin
close;
end;

procedure tform1.wczytajkfg;
var f:tstream; a,x,y:integer;b:boolean;
begin
f:=nil;
try
  try
     f:=TFileStream.Create('Retrofire.kfg', fmopenread);
     f.ReadBuffer(x,sizeof(x));
     f.ReadBuffer(y,sizeof(y));
     for a:=0 to high(rozdz) do
         if (x=rozdz[a,0]) and (y=rozdz[a,1]) then cbtrybgraf.itemindex:=a;

     f.ReadBuffer(x,sizeof(x));
     for a:=0 to high(bity) do
         if (x=bity[a]) then cbbity.itemindex:=a;

     f.ReadBuffer(x,sizeof(x));
     for a:=0 to high(czest) do
         if (x=czest[a]) then cbhz.itemindex:=a;

     f.ReadBuffer(b,sizeof(b));
     chfullscreen.checked:=b;

     f.ReadBuffer(a,sizeof(a));
     cbdzwiek.itemindex:=a;

     for a:=0 to 49 do f.ReadBuffer(klawisze[a],sizeof(klawisze[a]));

     f.ReadBuffer(a,sizeof(a));
     TrVolDzw.Position:=a div 10;
     f.ReadBuffer(a,sizeof(a));
     TrVolMuz.Position:=a div 10;

     f.ReadBuffer(a,sizeof(a));
     TrWidocznosc.Position:=a div 10;

     f.ReadBuffer(a,sizeof(a));
     TrJasnosc.Position:=a;

     f.ReadBuffer(a,sizeof(a));
     ChKrzaki.Checked:=boolean(a);

  except
     if f<>nil then begin
        f.Free;
        f:=nil;
     end;
     //MessageBox(Handle, pchar('B³¹d podczas odczytu pliku'), 'B³¹d', MB_OK+MB_TASKMODAL+MB_ICONERROR);
  end;
finally
   if f<>nil then begin
      f.Free;
      f:=nil;
   end;
end;

end;

procedure tform1.zapiszkfg;
var f:tstream;a:integer;b:boolean;
begin
f:=nil;
try
  try
     f:=TFileStream.Create('Retrofire.kfg', fmCreate);
     a:=rozdz[cbtrybgraf.itemindex,0];  f.WriteBuffer(a,sizeof(a));
     a:=rozdz[cbtrybgraf.itemindex,1];  f.WriteBuffer(a,sizeof(a));
     a:=bity[cbbity.itemindex];  f.WriteBuffer(a,sizeof(a));
     a:=czest[cbhz.itemindex];  f.WriteBuffer(a,sizeof(a));

     b:=chfullscreen.checked;  f.WriteBuffer(b,sizeof(b));

     a:=cbdzwiek.itemindex;  f.WriteBuffer(a,sizeof(a));

     for a:=0 to 49 do f.WriteBuffer(klawisze[a],sizeof(klawisze[a]));

     a:=TrVolDzw.Position*10;  f.WriteBuffer(a,sizeof(a));
     a:=TrVolMuz.Position*10;  f.WriteBuffer(a,sizeof(a));

     a:=TrWidocznosc.Position*10; f.WriteBuffer(a,sizeof(a));
     a:=TrJasnosc.Position; f.WriteBuffer(a,sizeof(a));

     a:=ord(ChKrzaki.checked); f.WriteBuffer(a,sizeof(a));

     f.Free;
     f:=nil;
  except
     if f<>nil then begin
        f.Free;
        f:=nil;
     end;
     MessageBox(Handle, pchar('B³¹d podczas zapisu pliku konfiguracji!'), 'B³¹d', MB_OK+MB_TASKMODAL+MB_ICONERROR);
  end;
finally
   if f<>nil then begin
      f.Free;
      f:=nil;
   end;
end;

end;

procedure TForm1.btnokClick(Sender: TObject);
begin
zapiszkfg;
close;
end;

procedure TForm1.FormCreate(Sender: TObject);
const odstep=20;
var a:integer;
begin
ChDir(ExtractFilePath(Application.ExeName));

ustawieniadomyslneklawiszy;

wczytajkfg;

for a:=0 to ile_klaw do begin
    klawisze_labele[a]:=TLabel.create(form1);
    with klawisze_labele[a] do begin
       parent:=klawskrol;
       visible:=true;
       left:=10;
       top:=5+a*odstep;
       caption:=nazwyklawiszy[a];
    end;
    klawisze_zmien[a]:=TSpeedButton.create(form1);
    with klawisze_zmien[a] do begin
       parent:=klawskrol;
       visible:=true;
       left:=parent.width-120;
       width:=90;
       height:=20;
       top:=5+a*odstep;
       caption:=form1.PowerInput1.KeyName[klawisze[a]];
       font.Style:=[fsbold];
       flat:=true;
       tag:=a;
       OnClick:=klawiszclick;
    end;
end;
PowerInput1.Initialize();

end;


procedure TForm1.KlawiszClick(Sender: TObject);
begin
 form2.ktoryklawisz:=(sender as tspeedbutton).Tag;
 form2.PowerTimer1.MayProcess:=true;
 form2.Showmodal;
end;

procedure TForm1.ButPrzywrocDomyslneClick(Sender: TObject);
var a:integer;
begin
ustawieniadomyslneklawiszy;
for a:=0 to ile_klaw do begin
    klawisze_zmien[a].caption:=form1.PowerInput1.KeyName[klawisze[a]];
end;

end;


end.
