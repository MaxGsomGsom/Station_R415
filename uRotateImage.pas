unit uRotateImage;

interface
uses
  Math,
  Windows,
  Graphics,
  SysUtils,
  Variants,
  Classes,
  ExtCtrls,
  StdCtrls;

type
  TRotateImage = class
    public
    function RotateImage(Const BitmapOriginal: TBitmap;
      Const iRotationAxis, jRotationAxis: Integer;
      Const AngleOfRotation: Double): TBitmap;
  end;

implementation

  FUNCTION TRotateImage.RotateImage(Const BitmapOriginal: TBitmap;
                     Const iRotationAxis, jRotationAxis: Integer;
                     Const AngleOfRotation: Double): TBitmap;
CONST
  MaxPixelCount = 32768;

TYPE
  TRGBTripleArray = ARRAY[0..MaxPixelCount-1] OF TRGBTriple;
  pRGBTripleArray = ^TRGBTripleArray;
VAR
    cosTheta   : EXTENDED;
    i          : INTEGER;
    iOriginal  : INTEGER;
    iPrime     : INTEGER;
    j          : INTEGER;
    jOriginal  : INTEGER;
    jPrime     : INTEGER;
    RowOriginal: pRGBTripleArray;
    RowRotated : pRGBTRipleArray;
    sinTheta   : EXTENDED;
    ug         : REAL;
begin
   ug := AngleOfRotation / 360*2*pi;
   RESULT := TBitmap.Create;
   RESULT.Width := BitmapOriginal.Width;
   RESULT.Height := BitmapOriginal.Height;
   RESULT.PixelFormat := pf24bit;
   sinTheta := SIN(ug);
   cosTheta := COS(ug);
   FOR j := RESULT.Height-1 DOWNTO 0 DO
   BEGIN
     RowRotated := RESULT.Scanline[j];
     jPrime := j - jRotationAxis;
     FOR i := RESULT.Width-1 DOWNTO 0 DO
     BEGIN
      iPrime := i - iRotationAxis;
      iOriginal := iRotationAxis + ROUND(iPrime * CosTheta - jPrime * sinTheta);
      jOriginal := jRotationAxis + ROUND(iPrime * sinTheta + jPrime * cosTheta);
      IF (iOriginal >=0) AND (iOriginal <=BitmapOriginal.Width-1) AND
          (jOriginal >=0) AND (jOriginal <=BitmapOriginal.Height-1)
      THEN BEGIN
        RowOriginal := BitmapOriginal.Scanline[jOriginal];
        RowRotated[i] := RowOriginal[iOriginal]
      END
      ELSE BEGIN
        RowRotated[i].rgbtBlue := 0;
        RowRotated[i].rgbtGreen := 0;
        RowRotated[i].rgbtRed := 0
     END
   END
  END;
END;
end.
