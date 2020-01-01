// Generated by purs version 0.13.5
"use strict";
var Control_Bind = require("../Control.Bind/index.js");
var Control_Category = require("../Control.Category/index.js");
var Data_Boolean = require("../Data.Boolean/index.js");
var Data_Eq = require("../Data.Eq/index.js");
var Data_Function = require("../Data.Function/index.js");
var Data_Functor = require("../Data.Functor/index.js");
var Data_FunctorWithIndex = require("../Data.FunctorWithIndex/index.js");
var Data_List = require("../Data.List/index.js");
var Data_List_Types = require("../Data.List.Types/index.js");
var Data_Maybe = require("../Data.Maybe/index.js");
var Data_NonEmpty = require("../Data.NonEmpty/index.js");
var Data_Ord = require("../Data.Ord/index.js");
var Data_Semigroup = require("../Data.Semigroup/index.js");
var Data_Semigroup_Traversable = require("../Data.Semigroup.Traversable/index.js");
var Data_Tuple = require("../Data.Tuple/index.js");
var Data_Unfoldable = require("../Data.Unfoldable/index.js");
var Partial_Unsafe = require("../Partial.Unsafe/index.js");
var zipWith = function (f) {
    return function (v) {
        return function (v1) {
            return new Data_NonEmpty.NonEmpty(f(v.value0)(v1.value0), Data_List.zipWith(f)(v.value1)(v1.value1));
        };
    };
};
var zipWithA = function (dictApplicative) {
    return function (f) {
        return function (xs) {
            return function (ys) {
                return Data_Semigroup_Traversable.sequence1(Data_List_Types.traversable1NonEmptyList)(dictApplicative.Apply0())(zipWith(f)(xs)(ys));
            };
        };
    };
};
var zip = zipWith(Data_Tuple.Tuple.create);
var wrappedOperation2 = function (name) {
    return function (f) {
        return function (v) {
            return function (v1) {
                var v2 = f(new Data_List_Types.Cons(v.value0, v.value1))(new Data_List_Types.Cons(v1.value0, v1.value1));
                if (v2 instanceof Data_List_Types.Cons) {
                    return new Data_NonEmpty.NonEmpty(v2.value0, v2.value1);
                };
                if (v2 instanceof Data_List_Types.Nil) {
                    return Partial_Unsafe.unsafeCrashWith("Impossible: empty list in NonEmptyList " + name);
                };
                throw new Error("Failed pattern match at Data.List.NonEmpty (line 104, column 3 - line 106, column 81): " + [ v2.constructor.name ]);
            };
        };
    };
};
var wrappedOperation = function (name) {
    return function (f) {
        return function (v) {
            var v1 = f(new Data_List_Types.Cons(v.value0, v.value1));
            if (v1 instanceof Data_List_Types.Cons) {
                return new Data_NonEmpty.NonEmpty(v1.value0, v1.value1);
            };
            if (v1 instanceof Data_List_Types.Nil) {
                return Partial_Unsafe.unsafeCrashWith("Impossible: empty list in NonEmptyList " + name);
            };
            throw new Error("Failed pattern match at Data.List.NonEmpty (line 91, column 3 - line 93, column 81): " + [ v1.constructor.name ]);
        };
    };
};
var updateAt = function (i) {
    return function (a) {
        return function (v) {
            if (i === 0) {
                return new Data_Maybe.Just(new Data_NonEmpty.NonEmpty(a, v.value1));
            };
            if (Data_Boolean.otherwise) {
                return Data_Functor.map(Data_Maybe.functorMaybe)(function ($161) {
                    return Data_List_Types.NonEmptyList((function (v1) {
                        return new Data_NonEmpty.NonEmpty(v.value0, v1);
                    })($161));
                })(Data_List.updateAt(i - 1 | 0)(a)(v.value1));
            };
            throw new Error("Failed pattern match at Data.List.NonEmpty (line 197, column 1 - line 197, column 75): " + [ i.constructor.name, a.constructor.name, v.constructor.name ]);
        };
    };
};
var unzip = function (ts) {
    return new Data_Tuple.Tuple(Data_Functor.map(Data_List_Types.functorNonEmptyList)(Data_Tuple.fst)(ts), Data_Functor.map(Data_List_Types.functorNonEmptyList)(Data_Tuple.snd)(ts));
};
var unsnoc = function (v) {
    var v1 = Data_List.unsnoc(v.value1);
    if (v1 instanceof Data_Maybe.Nothing) {
        return {
            init: Data_List_Types.Nil.value,
            last: v.value0
        };
    };
    if (v1 instanceof Data_Maybe.Just) {
        return {
            init: new Data_List_Types.Cons(v.value0, v1.value0.init),
            last: v1.value0.last
        };
    };
    throw new Error("Failed pattern match at Data.List.NonEmpty (line 159, column 35 - line 161, column 50): " + [ v1.constructor.name ]);
};
var unionBy = (function () {
    var $162 = wrappedOperation2("unionBy");
    return function ($163) {
        return $162(Data_List.unionBy($163));
    };
})();
var union = function (dictEq) {
    return wrappedOperation2("union")(Data_List.union(dictEq));
};
var uncons = function (v) {
    return {
        head: v.value0,
        tail: v.value1
    };
};
var toList = function (v) {
    return new Data_List_Types.Cons(v.value0, v.value1);
};
var toUnfoldable = function (dictUnfoldable) {
    var $164 = Data_Unfoldable.unfoldr(dictUnfoldable)(function (xs) {
        return Data_Functor.map(Data_Maybe.functorMaybe)(function (rec) {
            return new Data_Tuple.Tuple(rec.head, rec.tail);
        })(Data_List.uncons(xs));
    });
    return function ($165) {
        return $164(toList($165));
    };
};
var tail = function (v) {
    return v.value1;
};
var sortBy = (function () {
    var $166 = wrappedOperation("sortBy");
    return function ($167) {
        return $166(Data_List.sortBy($167));
    };
})();
var sort = function (dictOrd) {
    return function (xs) {
        return sortBy(Data_Ord.compare(dictOrd))(xs);
    };
};
var snoc = function (v) {
    return function (y) {
        return new Data_NonEmpty.NonEmpty(v.value0, Data_List.snoc(v.value1)(y));
    };
};
var singleton = (function () {
    var $168 = Data_NonEmpty.singleton(Data_List_Types.plusList);
    return function ($169) {
        return Data_List_Types.NonEmptyList($168($169));
    };
})();
var snoc$prime = function (v) {
    return function (y) {
        if (v instanceof Data_List_Types.Cons) {
            return new Data_NonEmpty.NonEmpty(v.value0, Data_List.snoc(v.value1)(y));
        };
        if (v instanceof Data_List_Types.Nil) {
            return singleton(y);
        };
        throw new Error("Failed pattern match at Data.List.NonEmpty (line 139, column 1 - line 139, column 51): " + [ v.constructor.name, y.constructor.name ]);
    };
};
var reverse = wrappedOperation("reverse")(Data_List.reverse);
var nubBy = (function () {
    var $170 = wrappedOperation("nubBy");
    return function ($171) {
        return $170(Data_List.nubBy($171));
    };
})();
var nub = function (dictEq) {
    return wrappedOperation("nub")(Data_List.nub(dictEq));
};
var modifyAt = function (i) {
    return function (f) {
        return function (v) {
            if (i === 0) {
                return new Data_Maybe.Just(new Data_NonEmpty.NonEmpty(f(v.value0), v.value1));
            };
            if (Data_Boolean.otherwise) {
                return Data_Functor.map(Data_Maybe.functorMaybe)(function ($172) {
                    return Data_List_Types.NonEmptyList((function (v1) {
                        return new Data_NonEmpty.NonEmpty(v.value0, v1);
                    })($172));
                })(Data_List.modifyAt(i - 1 | 0)(f)(v.value1));
            };
            throw new Error("Failed pattern match at Data.List.NonEmpty (line 202, column 1 - line 202, column 82): " + [ i.constructor.name, f.constructor.name, v.constructor.name ]);
        };
    };
};
var mapWithIndex = Data_FunctorWithIndex.mapWithIndex(Data_List_Types.functorWithIndexNonEmptyList);
var lift = function (f) {
    return function (v) {
        return f(new Data_List_Types.Cons(v.value0, v.value1));
    };
};
var mapMaybe = function ($173) {
    return lift(Data_List.mapMaybe($173));
};
var partition = function ($174) {
    return lift(Data_List.partition($174));
};
var span = function ($175) {
    return lift(Data_List.span($175));
};
var take = function ($176) {
    return lift(Data_List.take($176));
};
var takeWhile = function ($177) {
    return lift(Data_List.takeWhile($177));
};
var length = function (v) {
    return 1 + Data_List.length(v.value1) | 0;
};
var last = function (v) {
    return Data_Maybe.fromMaybe(v.value0)(Data_List.last(v.value1));
};
var intersectBy = (function () {
    var $178 = wrappedOperation2("intersectBy");
    return function ($179) {
        return $178(Data_List.intersectBy($179));
    };
})();
var intersect = function (dictEq) {
    return wrappedOperation2("intersect")(Data_List.intersect(dictEq));
};
var insertAt = function (i) {
    return function (a) {
        return function (v) {
            if (i === 0) {
                return new Data_Maybe.Just(new Data_NonEmpty.NonEmpty(a, new Data_List_Types.Cons(v.value0, v.value1)));
            };
            if (Data_Boolean.otherwise) {
                return Data_Functor.map(Data_Maybe.functorMaybe)(function ($180) {
                    return Data_List_Types.NonEmptyList((function (v1) {
                        return new Data_NonEmpty.NonEmpty(v.value0, v1);
                    })($180));
                })(Data_List.insertAt(i - 1 | 0)(a)(v.value1));
            };
            throw new Error("Failed pattern match at Data.List.NonEmpty (line 192, column 1 - line 192, column 75): " + [ i.constructor.name, a.constructor.name, v.constructor.name ]);
        };
    };
};
var init = function (v) {
    return Data_Maybe.maybe(Data_List_Types.Nil.value)(function (v1) {
        return new Data_List_Types.Cons(v.value0, v1);
    })(Data_List.init(v.value1));
};
var index = function (v) {
    return function (i) {
        if (i === 0) {
            return new Data_Maybe.Just(v.value0);
        };
        if (Data_Boolean.otherwise) {
            return Data_List.index(v.value1)(i - 1 | 0);
        };
        throw new Error("Failed pattern match at Data.List.NonEmpty (line 166, column 1 - line 166, column 52): " + [ v.constructor.name, i.constructor.name ]);
    };
};
var head = function (v) {
    return v.value0;
};
var groupBy = (function () {
    var $181 = wrappedOperation("groupBy");
    return function ($182) {
        return $181(Data_List.groupBy($182));
    };
})();
var group$prime = function (dictOrd) {
    return wrappedOperation("group'")(Data_List["group'"](dictOrd));
};
var group = function (dictEq) {
    return wrappedOperation("group")(Data_List.group(dictEq));
};
var fromList = function (v) {
    if (v instanceof Data_List_Types.Nil) {
        return Data_Maybe.Nothing.value;
    };
    if (v instanceof Data_List_Types.Cons) {
        return new Data_Maybe.Just(new Data_NonEmpty.NonEmpty(v.value0, v.value1));
    };
    throw new Error("Failed pattern match at Data.List.NonEmpty (line 120, column 1 - line 120, column 57): " + [ v.constructor.name ]);
};
var fromFoldable = function (dictFoldable) {
    var $183 = Data_List.fromFoldable(dictFoldable);
    return function ($184) {
        return fromList($183($184));
    };
};
var foldM = function (dictMonad) {
    return function (f) {
        return function (a) {
            return function (v) {
                return Control_Bind.bind(dictMonad.Bind1())(f(a)(v.value0))(function (a$prime) {
                    return Data_List.foldM(dictMonad)(f)(a$prime)(v.value1);
                });
            };
        };
    };
};
var findLastIndex = function (f) {
    return function (v) {
        var v1 = Data_List.findLastIndex(f)(v.value1);
        if (v1 instanceof Data_Maybe.Just) {
            return new Data_Maybe.Just(v1.value0 + 1 | 0);
        };
        if (v1 instanceof Data_Maybe.Nothing) {
            if (f(v.value0)) {
                return new Data_Maybe.Just(0);
            };
            if (Data_Boolean.otherwise) {
                return Data_Maybe.Nothing.value;
            };
        };
        throw new Error("Failed pattern match at Data.List.NonEmpty (line 186, column 3 - line 190, column 29): " + [ v1.constructor.name ]);
    };
};
var findIndex = function (f) {
    return function (v) {
        if (f(v.value0)) {
            return new Data_Maybe.Just(0);
        };
        if (Data_Boolean.otherwise) {
            return Data_Functor.map(Data_Maybe.functorMaybe)(function (v1) {
                return v1 + 1 | 0;
            })(Data_List.findIndex(f)(v.value1));
        };
        throw new Error("Failed pattern match at Data.List.NonEmpty (line 179, column 1 - line 179, column 69): " + [ f.constructor.name, v.constructor.name ]);
    };
};
var filterM = function (dictMonad) {
    var $185 = Data_List.filterM(dictMonad);
    return function ($186) {
        return lift($185($186));
    };
};
var filter = function ($187) {
    return lift(Data_List.filter($187));
};
var elemLastIndex = function (dictEq) {
    return function (x) {
        return findLastIndex(function (v) {
            return Data_Eq.eq(dictEq)(v)(x);
        });
    };
};
var elemIndex = function (dictEq) {
    return function (x) {
        return findIndex(function (v) {
            return Data_Eq.eq(dictEq)(v)(x);
        });
    };
};
var dropWhile = function ($188) {
    return lift(Data_List.dropWhile($188));
};
var drop = function ($189) {
    return lift(Data_List.drop($189));
};
var cons$prime = function (x) {
    return function (xs) {
        return new Data_NonEmpty.NonEmpty(x, xs);
    };
};
var cons = function (y) {
    return function (v) {
        return new Data_NonEmpty.NonEmpty(y, new Data_List_Types.Cons(v.value0, v.value1));
    };
};
var concatMap = Data_Function.flip(Control_Bind.bind(Data_List_Types.bindNonEmptyList));
var concat = function (v) {
    return Control_Bind.bind(Data_List_Types.bindNonEmptyList)(v)(Control_Category.identity(Control_Category.categoryFn));
};
var catMaybes = lift(Data_List.catMaybes);
var appendFoldable = function (dictFoldable) {
    return function (v) {
        return function (ys) {
            return new Data_NonEmpty.NonEmpty(v.value0, Data_Semigroup.append(Data_List_Types.semigroupList)(v.value1)(Data_List.fromFoldable(dictFoldable)(ys)));
        };
    };
};
module.exports = {
    toUnfoldable: toUnfoldable,
    fromFoldable: fromFoldable,
    fromList: fromList,
    toList: toList,
    singleton: singleton,
    length: length,
    cons: cons,
    "cons'": cons$prime,
    snoc: snoc,
    "snoc'": snoc$prime,
    head: head,
    last: last,
    tail: tail,
    init: init,
    uncons: uncons,
    unsnoc: unsnoc,
    index: index,
    elemIndex: elemIndex,
    elemLastIndex: elemLastIndex,
    findIndex: findIndex,
    findLastIndex: findLastIndex,
    insertAt: insertAt,
    updateAt: updateAt,
    modifyAt: modifyAt,
    reverse: reverse,
    concat: concat,
    concatMap: concatMap,
    filter: filter,
    filterM: filterM,
    mapMaybe: mapMaybe,
    catMaybes: catMaybes,
    appendFoldable: appendFoldable,
    mapWithIndex: mapWithIndex,
    sort: sort,
    sortBy: sortBy,
    take: take,
    takeWhile: takeWhile,
    drop: drop,
    dropWhile: dropWhile,
    span: span,
    group: group,
    "group'": group$prime,
    groupBy: groupBy,
    partition: partition,
    nub: nub,
    nubBy: nubBy,
    union: union,
    unionBy: unionBy,
    intersect: intersect,
    intersectBy: intersectBy,
    zipWith: zipWith,
    zipWithA: zipWithA,
    zip: zip,
    unzip: unzip,
    foldM: foldM
};
