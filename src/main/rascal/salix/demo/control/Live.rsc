@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::control::Live

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


SalixApp[Model] liveApp(str id = "root") {
    return makeLiveApp(id, init, 
    withIndex("Counter", "root", view), 
    |project://salix-core/src/main/rascal/salix/demo/control/Live.rsc|, 
    getModuleUpdate,
    subs = subs);
}


App[Model] liveWebApp()
  = webApp(
      liveApp(),
      |project://salix/src/main/rascal|
    );

void() launching() = standaloneVSCode(|http://localhost:8080|, liveWebApp());

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

alias MyModelUpdate = Model(Msg, Model);
alias MyModelView = void(Model);

MyModelUpdate getModuleUpdate(RascalRuntime e) {
  // Better alternative is parsing Module with parseModule and extracting update function
  // but this is simpler for demo purposes

  e.eval(#void, "import salix::demo::control::Live;");
  Result[MyModelUpdate] newUpdate = e.eval(#MyModelUpdate, "update");
  switch (newUpdate) {
    case result(fn): {
      return fn;
    }
  }
  return update;
}

/*
MyModelView getModuleView(RascalRuntime e) {
  e.eval(#void, "import salix::demo::control::Live;");
  e.eval(#void, "import salix::Index;");
  Result[MyModelView] newView = e.eval(#MyModelView, "withIndex(\"Counter\", \"root\", view)");
  switch (newView) {
    case result(fn): {
      return fn;
    }
  }
  return view;
}
*/











