function InsertDocString()
doc = matlab.desktop.editor.getActive;
text = doc.Text;
pos = regexp(text,'^function\s([^)]*))','tokenExtents','once');
funName = text(pos(1):(pos(2)+1));
doc.insertTextAtPositionInLine(ReturnDocString(funName),2,1);
end