{
        File: zip.pas
        License: GPLv2
        This unit is part of Free Manga Downloader
}

unit zip;

{$mode delphi}

interface

uses
  Classes, FileUtil, Zipper, baseunit, SysUtils, img2pdf;

type
  TCompress = class
  protected
    list: TStringList;
    procedure   OnFileFound(FileIterator: TFileIterator);
  public
    ext,
    Path              : String;
    CompressionQuality: Cardinal;
    procedure   DoZipCbz;
    procedure   DoPdf;
    procedure   Execute;
  end;

implementation

uses
  lazutf8classes;

procedure   TCompress.OnFileFound(FileIterator: TFileIterator);
begin
  list.Add(FileIterator.Filename);
end;

procedure   TCompress.DoZipCbz;
var
  s,
  fPath   : String;
  searcher: TFileSearcher;
  Zip     : TZipper;
  i       : Cardinal;
  fstream : TFileStreamUTF8;
begin
  try
   // Path:= FixPath(Path);
    fPath:= FixLastDir(Path);
    RenameFileUTF8(Path, fPath);
    list:= TStringList.Create;
    searcher:= TFileSearcher.Create;
    searcher.OnFileFound:= OnFileFound;
    searcher.Search(fPath, '*.jpg;*.jpeg;*.png;*.gif', FALSE, FALSE);

    if list.Count <> 0 then
    begin
      // norm the list
      //for i:= 0 to list.Count-1 do
      //  list.Strings[i]:= ExtractFileName(list.Strings[i]);
      Zip:= TZipper.Create;
      Zip.FileName:= fPath+ext;
      //SetCurrentDirUTF8(ExtractFileDir(Path+'.zip'));
      for i:= 0 to list.Count-1 do
      begin
        {$IFDEF WINDOWS}
        s:= StringReplace(list.Strings[i], '/', '\', [rfReplaceAll]);
        {$ELSE}
        s:= list.Strings[i];
        {$ENDIF}
        Zip.Entries.AddFileEntry(s, Format('%.3d%s', [i+1, ExtractFileExt(list.Strings[i])]));
      end;

      fstream:= TFileStreamUTF8.Create(fPath+ext, fmCreate);
     // Zip.ZipAllFiles;
      Zip.SaveToStream(fstream);
      fstream.Free;
      Zip.Free;
      //SetCurrentDirUTF8(oldDir);
      for i:= 0 to list.Count-1 do
        DeleteFileUTF8(list.Strings[i]);
      RemoveDirUTF8(fPath);
      if fPath[Length(fPath)] = '/' then
        Delete(fPath, Length(fPath), 1);
      RenameFileUTF8(fPath+ext, Path+ext);
    end;
  finally
    searcher.Free;
    list.Free;
  end;
end;

procedure   TCompress.DoPdf;
var
  s,
  fPath   : String;
  searcher: TFileSearcher;
  pdf     : TImg2Pdf;
  i       : Cardinal;
  fstream : TFileStreamUTF8;
begin
  try
   // Path:= FixPath(Path);
    fPath:= FixLastDir(Path);
    RenameFileUTF8(Path, fPath);
    list:= TStringList.Create;
    searcher:= TFileSearcher.Create;
    searcher.OnFileFound:= OnFileFound;
    searcher.Search(fPath, '*.jpg;*.jpeg;*.png;*.gif', FALSE, FALSE);

    if list.Count <> 0 then
    begin
      pdf:= TImg2Pdf.Create;
      pdf.CompressionQuality:= CompressionQuality;
      pdf.Title:= GetLastDir(Path);
     // pdf.FileName:= fPath+ext;
      for i:= 0 to list.Count-1 do
      begin
        {$IFDEF WINDOWS}
        s:= StringReplace(list.Strings[i], '/', '\', [rfReplaceAll]);
        {$ELSE}
        s:= list.Strings[i];
        {$ENDIF}

        // add image to PDF
        pdf.AddImage(s);
       // pdf.Image(s, 100, 100, 200, 200);
       // pdf.Entries.AddFileEntry(s, Format('%.3d%s', [i+1, ExtractFileExt(list.Strings[i])]));
      end;

      fstream:= TFileStreamUTF8.Create(fPath+ext, fmCreate);
      pdf.SaveToStream(fstream);
      fstream.Free;
      pdf.Free;
      for i:= 0 to list.Count-1 do
        DeleteFileUTF8(list.Strings[i]);
      RemoveDirUTF8(fPath);
      if fPath[Length(fPath)] = '/' then
        Delete(fPath, Length(fPath), 1);
      RenameFileUTF8(fPath+ext, Path+ext);
    end;
  finally
    searcher.Free;
    list.Free;
  end;
end;

procedure   TCompress.Execute;
begin
  if (ext='.zip') OR (ext='.cbz') then
  begin
    DoZipCbz;
  end
  else
    DoPdf;
end;

end.

