module salix::demo::basic::VSFiles

import salix::App;
import salix::HTML;
import salix::Index;
import salix::Core;

import util::Maybe;
import IO;
import String;
import List;
import util::Random;
import util::Math;

SalixApp[Model] filesApp(str id = "root") 
  = makeApp(id, init, withIndex("Files", id, view), update, subs = subs);

App[Model] filesWebApp()
  = webApp(filesApp(),|project://salix-core/src/main/rascal|);



void launching() = standaloneVSCode(|http://localhost:8080|, filesWebApp());

list[Sub] subs(Model m) = [observeVSFile(
  fileChange, |cwd://salix-core/src/main/rascal/salix/demo/basic/VSFiles.rsc|) ];

alias Model = str;

Model init() = "";

data Msg =  useless() | fileChange(str);

Model update(Msg msg, Model m) {
  switch (msg) {
    case fileChange(str fileContent): {
      println("File changed, new content:\n<fileContent>");
      m = fileContent;
      int rdline = abs(randomValue(#int)) % (size(split("\n",m)));
      // This sad but we need to have JS convertor for Rascal loc
      do(highlightLine(useless(), "file:///home/jbdod/CWI/salix-core/src/main/rascal/salix/demo/basic/VSFiles.rsc", rdline));
    }
  }
  return m;
}

void view(Model m) {
  h2(id("main"), "File content viewer");
  div("Current file content : <m>");
}