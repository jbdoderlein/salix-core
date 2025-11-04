@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::control::Liver

import salix::App;
import salix::HTML;
import salix::Index;
import salix::Core;

import List;
import String;
// For Meta
import ValueIO;
import IO;
import Location;
import util::Eval;
import util::Reflective;
import lang::rascal::\syntax::Rascal;
import Node;
import List;
import ParseTree;




SalixApp[Model] liveApp(str id = "root") {
    return makeApp(id, init, 
    withIndex("Counter", "root", view), 
    update,
    subs = subs);
}


App[Model] liveWebApp()
  = webApp(
      liveApp(),
      |project://salix/src/main/rascal|
    );

void() launching() = startVSSalix(|http://localhost:8080|, liveWebApp());

alias Model = tuple[int current, list[tuple[int count, str code]] hist];

Model init() = <0, [<0, "">]>;


list[Sub] subs(Model m) = [observeVSFile(
  fileChange, |project://salix-core/src/main/rascal/salix/demo/control/Live.rsc|) ];


data Msg = incr() | decr() | fileChange(str)| pick(str);

Model update(Msg msg, Model m) {
  switch (msg) {
    case incr(): {
      current_count = m.hist[m.current].count;
      current_code = m.hist[size(m.hist) - 1].code;
      m.hist = m.hist + [<current_count+1, current_code>];
      m.current = size(m.hist) - 1;
    }
    case decr(): {
      current_count = m.hist[m.current].count;
      current_code = m.hist[size(m.hist) - 1].code;
      m.hist = m.hist + [<current_count-1, current_code>];
      m.current = size(m.hist) - 1;
    }
    case fileChange(str content): {
      current = m.hist[m.current];
      m.hist = m.hist + [<current.count, content>];
      m.current = size(m.hist) - 1;
    }
    case pick(str idx): {
      int iidx = toInt(idx);
      if (0 <= iidx && iidx < size(m.hist)) {
        m.current = iidx;
      }
    }
  }
  return m;
}

void view(Model m) {
    h2(id("header"), "My first counter app in Rascal");
    div(class("row"), () {
        div(class("col-lg-8"), () {
        button(onClick(incr()), "+");
        div(id("thecount"), "<m.hist[m.current].count>");
        button(onClick(decr()), "-");
        });

        div(class("col-lg-4"), () {
            h3("Historyy");
            input(\type("range"), min("0"), max("<size(m.hist) -1>"),\value("<m.current>"), onInput(pick));
            ul(style(<"all", "unset">), () {
            for (int i <- [0..size(m.hist)]) {
                li(style(("padding": "0 0" ,"font-size": "small", "border-bottom": "none")), () {
                div(style(("font-weight": "bold" | i == m.current)), "[<i>]<m.hist[i].count>");
                });
            }
            });
        });
    });
}

//loc currentModuleLoc = |project://salix-core/src/main/rascal/salix/demo/control/Live.rsc|;

alias MyModelUpdate = Model(Msg, Model);
alias MyModelView = void(Model);

tuple[MyModelUpdate, MyModelView] reloadUpdateView(loc moduleLocation) {
  Module m = parseModule(moduleLocation);
  MyModelUpdate updateFunc;
  MyModelView viewFunc;
  visit(m) {
    case FunctionDeclaration fd: {
      switch (fd) {
        case FunctionDeclaration::\default(_,_,\noThrows(_, _, Name name, _), _): {
          if (unparse(name) == "update") {
            iprint(unparse(fd));
            updateFunc = readTextValueString(unparse(fd)); // Problem here in parsing
          }
          else if (unparse(name) == "view") {
            viewFunc = readTextValueString(unparse(fd)); // Problem here in parsing
          }
        }
      }
    }
  }
  return <updateFunc, viewFunc>;
}







