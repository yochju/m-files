function CreateTemplate()
% http://blogs.mathworks.com/desktop/2011/05/16/matlab-editor-api-examples/
% http://blogs.mathworks.com/desktop/2011/05/09/r2011a-matlab-editor-api/
Template = sprintf( 'function out = NewFunction( in )\n\nend');
doc = matlab.desktop.editor.newDocument(Template);
doc.insertTextAtPositionInLine(ReturnDocString('out = NewFunction( in )'),2,1);
end