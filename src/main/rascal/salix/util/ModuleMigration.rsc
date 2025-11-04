module salix::util::ModuleMigration


extend Type;
import String;
import util::Math;
import List;
import IO;

alias Model1 = tuple[int count, int flag];

alias Model2 = tuple[int count, bool flag, str name];

alias Model3 = tuple[int count, int flag];

/*
&S(&T) makeMigration(type[&T] oldModelType, type[&S] newModelType) {

}

*/

// Maybe do this in java ?

@synopsis{Provide Migration for (some) Atomic Types (for now int, bool, str, real) }
&S(&T) defaultMigration1(type[&T] t, type[&S] s) {
    tuple[Symbol, Symbol] types = <t.symbol, s.symbol>;
    switch (types) {
        // Identity
        case <x, x>: return &S(&T y){return y;};
        // int <-> bool
        case <\int(), \bool()>: return bool(int x){return x!=0;};
        case <\bool(), \int()>: return int(bool x){return x?1:0;};
        // int <-> str
        case <\int(), \str()>: return str(int x){return "<0>";};
        case <\str(), \int()>: return int(str x){return toInt(x);};
        // int <-> real (not correct)
        case <\int(), \real()>: return real(int x){return x;};
        case <\real(), \int()>: return int(real x){return x;};
        // bool <-> str
        case <\bool(), \str()>: return str(bool x){return x?"true":"false";};
        case <\str(), \bool()>: return bool(str x){return x=="true" || x=="1";};
        // bool <-> real
        case <\bool(), \real()>: return real(bool x){return x?1.0:0.0;};
        case <\real(), \bool()>: return bool(real x){return x!=0.0;};
        // str <-> real
        case <\real(), \str()>: return str(real x){return "<x>";};
        case <\str(), \real()>: return real(str x){return toReal(x);};

    };
    // Default case that will make a function that crash at runtime
    // maybe throw something ? (i just put it here so the type checker don't complain)
    return &S(&T x){return x;}; 
}

// int -> *
bool(int) migrate(Symbol::\int(), Symbol::\bool()) = bool(int x){return x!=0;};
int(bool) migrate(Symbol::\bool(), Symbol::\int()) = int(bool x){return x?1:0;};
str(int) migrate(Symbol::\int(), Symbol::\str()) = str(int x){return "<x>";};
int(str) migrate(Symbol::\str(), Symbol::\int()) = int(str x){return toInt(x);};
real(int) migrate(Symbol::\int(), Symbol::\real()) = real(int x){return toReal(x);};
int(real) migrate(Symbol::\real(), Symbol::\int()) = int(real x){return toInt(x);};

// bool -> *
str(bool) migrate(Symbol::\bool(), Symbol::\str()) = str(bool x){return x?"true":"false";};
bool(str) migrate(Symbol::\str(), Symbol::\bool()) = bool(str x){return x=="true" || x=="1";};
real(bool) migrate(Symbol::\bool(), Symbol::\real()) = real(bool x){return x?1.0:0.0;};
bool(real) migrate(Symbol::\real(), Symbol::\bool()) = bool(real x){return x!=0.0;};

// str -> *
str(real) migrate(Symbol::\real(), Symbol::\str()) = str(real x){return "<x>";};
real(str) migrate(Symbol::\str(), Symbol::\real()) = real(str x){return toReal(x);};

value(value) migrate(type[&T] t, type[&S] s, Symbol::\tuple(list[Symbol] ls1), Symbol::\tuple(list[Symbol] ls2)) = &S(&T x){
  tuple[int] res = <0>;
  for (int i <- [0..size(ls1)]) {
    res += migrate(ls1[i], ls2[i])(x[i]);
  }
  return res;
};




&T(&T) migrate(Symbol _, Symbol _) = &T(&T x){return x;}; // identity for same type

tuple[&T] testtype(tuple[&T] x) = x;

@synopsis{Provide Migration for (some) Composite Types }
&S(&T) defaultMigration2(type[&T] t, type[&S] s) {
  tuple[Symbol, Symbol] types = <t.symbol, s.symbol>;
  switch (types) {
    case <x, x>: return &S(&T y){return y;};
    case <\tuple(list[Symbol] ls1), \tuple(list[Symbol] ls2)>: return &S(&T y){
      // here we need to get symbol of each field and call migration on them
      // and if possible use matching on field names (so we will have add,delete, modify or reorder)
      return y;
    };
  };
  return &S(&T x){return x;}; 
}