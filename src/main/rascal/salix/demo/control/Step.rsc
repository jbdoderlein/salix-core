@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::control::Step

import salix::App;
import salix::HTML;
import salix::Index;

import List;


SalixApp[Model] stepApp(str id = "root") 
  = makeApp(id, init, withIndex("Counter", id, view), update);

App[Model] stepWebApp()
  = webApp(
      stepApp(),
      |project://salix/src/main/rascal|
    );


alias Model = tuple[int count, list[int] prev];

Model init() = <0, []>;

data Msg = inc() | dec();

Model update(Msg msg, Model m) {
  switch (msg) {
    case inc(): {
        m.prev = m.prev + [m.count];
        m.count += 1;
    }
    case dec(): {
        m.prev = m.prev + [m.count];
        m.count -= 1;
    }
  }
  return m;
}

void view(Model m) {
    h2(id("header"), "My first counter app in Rascal");
    div(class("row"), () {
        div(class("col-lg-8"), () {
        button(onClick(inc()), "+");
        div(id("thecount"), "<m.count>");
        button(onClick(dec()), "-");
        });

        div(class("col-lg-4"), () {
            h3("History");
            ul(style(<"all", "unset">), () {
            for (int i <- [0..size(m.prev)]) {
                li(style(("padding": "0 0" ,"font-size": "small", "border-bottom": "none")), () {
                div(style(("font-weight": "bold" | i == m.count)), "<m.prev[i]>");      
                });
            }
            });
        });
    });
}

