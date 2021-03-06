function GetEsMangaHereImageURL: Boolean;
  var
    i: Cardinal;
    l: TStringList;
  begin
    l:= TStringList.Create;
    if workCounter > 0 then
      Result:= GetPage(TObject(l),
                       WebsiteRoots[ESMANGAHERE_ID,1] + URL + IntToStr(workCounter+1)+'.html',
                       manager.container.manager.retryConnect)
    else
      Result:= GetPage(TObject(l),
                       WebsiteRoots[ESMANGAHERE_ID,1] + URL,
                       manager.container.manager.retryConnect);
    parse:= TStringList.Create;

    Parser:= TjsFastHTMLParser.Create(PChar(l.Text));
    Parser.OnFoundTag := OnTag;
    Parser.OnFoundText:= OnText;
    Parser.Exec;
    Parser.Free;
    if parse.Count>0 then
    begin
      for i:= 0 to parse.Count-1 do
        if (Pos('class="read_img"', parse.Strings[i])<>0) then
        begin
          manager.container.pageLinks.Strings[workCounter]:= GetAttributeValue(GetTagAttribute(parse.Strings[i+6], 'src='));
          parse.Free;
          l.Free;
          exit;
        end;
    end;
    parse.Free;
    l.Free;
  end;
  