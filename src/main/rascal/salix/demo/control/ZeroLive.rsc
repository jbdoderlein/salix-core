@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::control::ZeroLive

import salix::LiveApp;
import salix::HTML;
import salix::Index;
import salix::Core;
import IO;
import String;


SalixApp[Model] zeroApp(str id = "root") 
  = makeApp(id, init, "view", "update", "salix::demo::control::ZeroLive",
    subs = subs);

App[Model] zeroWebApp()
  = webApp(
      zeroApp(),
      |project://salix/src/main/rascal|
    );

list[Sub] subs(Model m) = [observeVSFile(
  fileChange, |project://salix-core/src/main/rascal/salix/demo/control/ZeroLive.rsc|) ];


void launching() = standaloneVSCode(|http://localhost:8080|, zeroWebApp());

alias Model = tuple[int count];

Model init() = <0>;

data Msg = inc() | dec() | fileChange(str) | setter(str);

Model update(Msg msg, Model m) {
  switch (msg) {
    case inc(): m.count += 1;
    case dec(): m.count -= 1;
    case setter(str x): m.count = toInt(x);
    //case fileChange(f): println("File <f> changed!");
  }
  return m;
}

void view(Model m) {
  html(() {
    head(() {
      script(\type("text/javascript"), src("/salix/salix.js"));
             
      script("document.addEventListener(\"DOMContentLoaded\", function() {
             '  window.$salix = new Salix(\"root\");
             '  $salix.start();
             '});");
    });
    body(() {
      h2(id("header"), "Counter plus");
      button(onClick(inc()), "+");
      //input(\type("range"), \value("<m.count>"), \min("0"), \max("10"), onChange(setter));
      //button(onClick(sinc("1")), "++");
      div(id("thecount"), "<m.count>");
      button(onClick(dec()), "-");
    });
  });
}

