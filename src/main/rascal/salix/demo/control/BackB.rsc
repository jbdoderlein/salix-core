@license{
  Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
  All rights reserved.
  This file is licensed under the BSD 2-Clause License, which accompanies this project
  and is available under https://opensource.org/licenses/BSD-2-Clause.
}
@contributor{Tijs van der Storm - storm@cwi.nl - CWI}

module salix::demo::control::BackB

import salix::App;
import salix::HTML;
import salix::Index;

import List;


SalixApp[Model] backbApp(str id = "root") 
  = makeApp(id, init, withIndex("Counter", id, view, css = ["/salix/demo/control/index.css"], scripts = ["/salix/demo/control/index.js"]), update);

App[Model] backbWebApp()
  = webApp(
      backbApp(),
      |project://salix/src/main/rascal|
    );


alias Model = tuple[int current, list[tuple[int v,int p]] hist];
  
Model init() = <0, [<0, 0>]>;

data Msg = inc() | dec() | back() | step();

Model update(Msg msg, Model m) {
  switch (msg) {
    case inc(): {
        m.hist = m.hist + [<m.hist[m.current][0] + 1, m.current>];
        m.current = size(m.hist) - 1;
    }
    case dec(): {
        m.hist = m.hist + [<m.hist[m.current][0] - 1, m.current>];
        m.current = size(m.hist) - 1;
    }
    case back(): {
        if (m.current> 0) {
          if (m.hist[m.current][1] != m.current){
            m.current = m.hist[m.current][1]; 
          }
        }
    }
    case step(): {
        if (m.current < size(m.hist) - 1) {
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
        div(id("thecount"), "<m.hist[m.current][0]>");
        button(onClick(dec()), "-");
        });

        div(class("col-lg-4"), () {
            h3("History");
            
            div("\<button(onClick(() { sendMessageToParent(\"Hello from BackB!\"); }), \"Send Message to Parent\")\>");
            button(onClick(back()), "\<-");
            button(onClick(step()), "-\>");
            ul(style(<"all", "unset">), () {
            for (int i <- [0..size(m.hist)]) {
                li(style(("padding": "0 0" ,"font-size": "small", "border-bottom": "none")), () {
                div(style(("font-weight": "bold" | i == m.current)), "[<i>] <m.hist[i][0]> (from <m.hist[i][1]>)");      
                });
            }
            });
        });
    });
}

