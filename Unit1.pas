unit Unit1;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Objects

  {$IFDEF ANDROID}
    ,
    Androidapi.JNI.GraphicsContentViewText,
    Androidapi.JNI.JavaTypes,
    Androidapi.Helpers,
    Androidapi.JNI.Net,
    FMX.Surfaces,
    System.IOUtils,
    xPlat.OpenPDF,
    FMX.Helpers.Android
  {$ENDIF}
  ;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    Button1: TButton;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
  private
   {$IFDEF ANDROID}
      function FileNameToURI(const Filename: string): Jnet_Uri;
      function CMToPixel(const ACentimeter: Double): Double;
    {$ENDIF}
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation


{$R *.fmx}

{$IFDEF ANDROID}
function TForm1.FileNameToURI(const Filename: string): Jnet_Uri;
var
  JavaFile : JFile;
begin
  JavaFile := TJFile.JavaClass.init(StringToJString(FileName));
  Result   := TJnet_Uri.JavaClass.fromFile(JavaFile);
end;

function TForm1.CMToPixel(const ACentimeter: Double): Double;
var
  iPPI : Double;
begin
  iPPI   := TDeviceDisplayMetrics.Default.PixelsPerInch / 2.54;
  Result := Round(iPPI * ACentimeter);
end;
{$ENDIF}


procedure TForm1.Button1Click(Sender: TObject);
{$IFDEF ANDROID}
var
  Documento        : JPdfDocument;
  PageInfo         : JPdfDocument_PageInfo;
  Page             : JPdfDocument_Page;
  Canvas           : JCanvas;
  Paint            : JPaint;
  Recto            : JRect;
  Rect             : JRect;
  Filename         : string;
  OutputStream     : JFileOutputStream;
  Intent           : JIntent;
  NativeBitmap     : JBitmap;
  sBitmap          : TBitmapSurface;
begin
  Documento      := TJPdfDocument.JavaClass.init;
  try
    //Página 1
    PageInfo    := TJPageInfo_Builder.JavaClass.init(595, 842, 1).Create;
    Page        := Documento.startPage(PageInfo);

    Canvas       := Page.getCanvas;
    Paint        := TJPaint.JavaClass.init;

    Paint.setARGB($FF, 0, 0, $FF);

    Canvas.drawText(StringToJString('Texto 1') , CMToPixel(2), CMToPixel(2), Paint);
    Canvas.drawText(StringToJString('Texto 2') , CMToPixel(3), CMToPixel(3), Paint);
    Canvas.drawText(StringToJString('Texto 3') , CMToPixel(4), CMToPixel(4), Paint);
    Canvas.drawText(StringToJString('Texto 4'), CMToPixel(10), CMToPixel(10), Paint);

    Documento.finishPage(Page);

    //Página 2
    PageInfo    := TJPageInfo_Builder.JavaClass.init(595, 842, 2).Create;
    Page        := Documento.startPage(PageInfo);

    Canvas       := Page.getCanvas;
    Paint        := TJPaint.JavaClass.init;

    //Linha 1
    Paint.setARGB($FF, $FF, 0, 0);
    Canvas.drawLine(10, 10, 90, 10, Paint);

    //Linha 2
    Paint.setStrokeWidth(1);
    Paint.setARGB($FF, 0, $FF, 0);
    Canvas.drawLine(10, 20, 90, 20, Paint);

    Paint.setStrokeWidth(2);
    Paint.setARGB($FF, 0, 0, $FF);
    Canvas.drawLine(10, 30, 90, 30, Paint);

    Paint.setARGB($FF, $FF, $FF, 0);
    Canvas.drawRect(10, 40, 90, 60, Paint);

    Rect := TJRect.JavaClass.init;
    Rect.&set(15, 50, 65, 100);
    Recto := TJRect.JavaClass.init;
    Recto.&set(0, 0, Image1.Bitmap.Width, Image1.Bitmap.Height);
    Paint.setARGB($FF, $FF, 0, $FF);

    NativeBitmap := TJBitmap.JavaClass.createBitmap(Image1.Bitmap.Width,
      Image1.Bitmap.Height, TJBitmap_Config.JavaClass.ARGB_8888);

    sBitMap := TBitmapSurface.create;
    sBitMap.Assign(Image1.Bitmap);

    SurfaceToJBitmap(sBitMap, NativeBitmap);

    Canvas.drawBitmap(NativeBitmap, Recto, Rect, Paint);

    Documento.finishPage(Page);

    Filename     := TPath.Combine(TPath.GetSharedDocumentsPath, 'Demo.pdf');
    OutputStream := TJFileOutputStream.JavaClass.init(StringToJString(Filename));

    try
      Documento.writeTo(OutputStream);

    finally
      OutputStream.close;
    end;
  finally
    Documento.close;
  end;

  Intent := TJIntent.JavaClass.init;
  Intent.setAction(TJIntent.JavaClass.ACTION_VIEW);
  Intent.setDataAndType(FileNameToUri(FileName), StringToJString('application/pdf'));
  Intent.setFlags(TJIntent.JavaClass.FLAG_ACTIVITY_NO_HISTORY or TJIntent.JavaClass.FLAG_ACTIVITY_CLEAR_TOP);
  SharedActivity.StartActivity(Intent);

{$ELSE}
  ShowMessage('Função funciona somente em Android');
{$ENDIF}

end;

end.
