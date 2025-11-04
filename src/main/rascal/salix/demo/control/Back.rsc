@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::control::Back

import salix::App;
import salix::HTML;
import salix::Index;

import List;


SalixApp[Model] backApp(str id = "root") 
  = makeApp(id, init, withIndex("Counter", id, view), update);

App[Model] backWebApp()
  = webApp(
      backApp(),
      |project://salix/src/main/rascal|
    );


alias Model = tuple[int current, list[int] prev];

Model init() = <0, [0]>;

data Msg = inc() | dec() | back() | step();

Model update(Msg msg, Model m) {
  switch (msg) {
    case inc(): {
        m.prev = m.prev + [m.prev[m.current] + 1];
        m.current = size(m.prev) - 1;
    }
    case dec(): {
        m.prev = m.prev + [m.prev[m.current] - 1];
        m.current = size(m.prev) - 1;
    }
    case back(): {
        if (m.current> 0) {
          m.current -=1; 
        }
    }
    case step(): {
        if (m.current < size(m.prev) - 1) {
          m.current +=1; 
        }
    }
  }
  return m;
}

void view(Model m) {
    h2(id("header"), "My first counter app in Rascal");
    div(class("row"), () {
        div(class("col-lg-8"), () {
        button(onClick(inc()), "+");
        div(id("thecount"), "<m.prev[m.current]>");
        button(onClick(dec()), "-");
        });

        div(class("col-lg-4"), () {
            h3("History");
            button(onClick(back()), "\<-");
            button(onClick(step()), "-\>");
            ul(style(<"all", "unset">), () {
            for (int i <- [0..size(m.prev)]) {
                li(style(("padding": "0 0" ,"font-size": "small", "border-bottom": "none")), () {
                div(style(("font-weight": "bold" | i == m.current)), "<m.prev[i]>");      
                });
            }
            });
        });
    });
}

