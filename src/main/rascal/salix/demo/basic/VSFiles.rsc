module salix::demo::basic::VSFiles

import salix::App;
import salix::HTML;
import salix::Index;
import salix::Core;

import util::Maybe;
import IO;

SalixApp[Model] filesApp(str id = "root") 
  = makeApp(id, init, withIndex("Files", id, view), update, subs = subs);

App[Model] filesWebApp()
  = webApp(filesApp(),|project://salix-core/src/main/rascal|);



void launching() = startVSSalix(|http://localhost:8080|, filesWebApp());

list[Sub] subs(Model m) = [observeVSFile(
  fileChange, |cwd://salix-core/src/main/rascal/salix/demo/basic/VSFiles.rsc|) ];

alias Model = str;

Model init() = "";

data Msg 
    = fileChange(str)
    ;



Model update(Msg msg, Model m) {
  switch (msg) {
    case fileChange(str fileContent): m = fileContent;
  }
  return m;
}

void view(Model m) {
  h2("File content viewer");
  div("Current file content: <m>");
}