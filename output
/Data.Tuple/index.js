// Generated by purs version 0.13.5
"use strict";
var Control_Applicative = require("../Control.Applicative/index.js");
var Control_Apply = require("../Control.Apply/index.js");
var Control_Biapplicative = require("../Control.Biapplicative/index.js");
var Control_Biapply = require("../Control.Biapply/index.js");
var Control_Bind = require("../Control.Bind/index.js");
var Control_Comonad = require("../Control.Comonad/index.js");
var Control_Extend = require("../Control.Extend/index.js");
var Control_Lazy = require("../Control.Lazy/index.js");
var Control_Monad = require("../Control.Monad/index.js");
var Control_Semigroupoid = require("../Control.Semigroupoid/index.js");
var Data_Bifoldable = require("../Data.Bifoldable/index.js");
var Data_Bifunctor = require("../Data.Bifunctor/index.js");
var Data_Bitraversable = require("../Data.Bitraversable/index.js");
var Data_BooleanAlgebra = require("../Data.BooleanAlgebra/index.js");
var Data_Bounded = require("../Data.Bounded/index.js");
var Data_CommutativeRing = require("../Data.CommutativeRing/index.js");
var Data_Distributive = require("../Data.Distributive/index.js");
var Data_Eq = require("../Data.Eq/index.js");
var Data_Foldable = require("../Data.Foldable/index.js");
var Data_FoldableWithIndex = require("../Data.FoldableWithIndex/index.js");
var Data_Functor = require("../Data.Functor/index.js");
var Data_Functor_Invariant = require("../Data.Functor.Invariant/index.js");
var Data_FunctorWithIndex = require("../Data.FunctorWithIndex/index.js");
var Data_HeytingAlgebra = require("../Data.HeytingAlgebra/index.js");
var Data_Maybe = require("../Data.Maybe/index.js");
var Data_Maybe_First = require("../Data.Maybe.First/index.js");
var Data_Monoid = require("../Data.Monoid/index.js");
var Data_Newtype = require("../Data.Newtype/index.js");
var Data_Ord = require("../Data.Ord/index.js");
var Data_Ordering = require("../Data.Ordering/index.js");
var Data_Ring = require("../Data.Ring/index.js");
var Data_Semigroup = require("../Data.Semigroup/index.js");
var Data_Semigroup_Foldable = require("../Data.Semigroup.Foldable/index.js");
var Data_Semigroup_Traversable = require("../Data.Semigroup.Traversable/index.js");
var Data_Semiring = require("../Data.Semiring/index.js");
var Data_Show = require("../Data.Show/index.js");
var Data_Traversable = require("../Data.Traversable/index.js");
var Data_TraversableWithIndex = require("../Data.TraversableWithIndex/index.js");
var Data_Unit = require("../Data.Unit/index.js");
var Type_Equality = require("../Type.Equality/index.js");
var Tuple = (function () {
    function Tuple(value0, value1) {
        this.value0 = value0;
        this.value1 = value1;
    };
    Tuple.create = function (value0) {
        return function (value1) {
            return new Tuple(value0, value1);
        };
    };
    return Tuple;
})();
var uncurry = function (f) {
    return function (v) {
        return f(v.value0)(v.value1);
    };
};
var swap = function (v) {
    return new Tuple(v.value1, v.value0);
};
var snd = function (v) {
    return v.value1;
};
var showTuple = function (dictShow) {
    return function (dictShow1) {
        return new Data_Show.Show(function (v) {
            return "(Tuple " + (Data_Show.show(dictShow)(v.value0) + (" " + (Data_Show.show(dictShow1)(v.value1) + ")")));
        });
    };
};
var semiringTuple = function (dictSemiring) {
    return function (dictSemiring1) {
        return new Data_Semiring.Semiring(function (v) {
            return function (v1) {
                return new Tuple(Data_Semiring.add(dictSemiring)(v.value0)(v1.value0), Data_Semiring.add(dictSemiring1)(v.value1)(v1.value1));
            };
        }, function (v) {
            return function (v1) {
                return new Tuple(Data_Semiring.mul(dictSemiring)(v.value0)(v1.value0), Data_Semiring.mul(dictSemiring1)(v.value1)(v1.value1));
            };
        }, new Tuple(Data_Semiring.one(dictSemiring), Data_Semiring.one(dictSemiring1)), new Tuple(Data_Semiring.zero(dictSemiring), Data_Semiring.zero(dictSemiring1)));
    };
};
var semigroupoidTuple = new Control_Semigroupoid.Semigroupoid(function (v) {
    return function (v1) {
        return new Tuple(v1.value0, v.value1);
    };
});
var semigroupTuple = function (dictSemigroup) {
    return function (dictSemigroup1) {
        return new Data_Semigroup.Semigroup(function (v) {
            return function (v1) {
                return new Tuple(Data_Semigroup.append(dictSemigroup)(v.value0)(v1.value0), Data_Semigroup.append(dictSemigroup1)(v.value1)(v1.value1));
            };
        });
    };
};
var ringTuple = function (dictRing) {
    return function (dictRing1) {
        return new Data_Ring.Ring(function () {
            return semiringTuple(dictRing.Semiring0())(dictRing1.Semiring0());
        }, function (v) {
            return function (v1) {
                return new Tuple(Data_Ring.sub(dictRing)(v.value0)(v1.value0), Data_Ring.sub(dictRing1)(v.value1)(v1.value1));
            };
        });
    };
};
var monoidTuple = function (dictMonoid) {
    return function (dictMonoid1) {
        return new Data_Monoid.Monoid(function () {
            return semigroupTuple(dictMonoid.Semigroup0())(dictMonoid1.Semigroup0());
        }, new Tuple(Data_Monoid.mempty(dictMonoid), Data_Monoid.mempty(dictMonoid1)));
    };
};
var lookup = function (dictFoldable) {
    return function (dictEq) {
        return function (a) {
            var $312 = Data_Newtype.unwrap(Data_Maybe_First.newtypeFirst);
            var $313 = Data_Foldable.foldMap(dictFoldable)(Data_Maybe_First.monoidFirst)(function (v) {
                var $163 = Data_Eq.eq(dictEq)(a)(v.value0);
                if ($163) {
                    return new Data_Maybe.Just(v.value1);
                };
                return Data_Maybe.Nothing.value;
            });
            return function ($314) {
                return $312($313($314));
            };
        };
    };
};
var heytingAlgebraTuple = function (dictHeytingAlgebra) {
    return function (dictHeytingAlgebra1) {
        return new Data_HeytingAlgebra.HeytingAlgebra(function (v) {
            return function (v1) {
                return new Tuple(Data_HeytingAlgebra.conj(dictHeytingAlgebra)(v.value0)(v1.value0), Data_HeytingAlgebra.conj(dictHeytingAlgebra1)(v.value1)(v1.value1));
            };
        }, function (v) {
            return function (v1) {
                return new Tuple(Data_HeytingAlgebra.disj(dictHeytingAlgebra)(v.value0)(v1.value0), Data_HeytingAlgebra.disj(dictHeytingAlgebra1)(v.value1)(v1.value1));
            };
        }, new Tuple(Data_HeytingAlgebra.ff(dictHeytingAlgebra), Data_HeytingAlgebra.ff(dictHeytingAlgebra1)), function (v) {
            return function (v1) {
                return new Tuple(Data_HeytingAlgebra.implies(dictHeytingAlgebra)(v.value0)(v1.value0), Data_HeytingAlgebra.implies(dictHeytingAlgebra1)(v.value1)(v1.value1));
            };
        }, function (v) {
            return new Tuple(Data_HeytingAlgebra.not(dictHeytingAlgebra)(v.value0), Data_HeytingAlgebra.not(dictHeytingAlgebra1)(v.value1));
        }, new Tuple(Data_HeytingAlgebra.tt(dictHeytingAlgebra), Data_HeytingAlgebra.tt(dictHeytingAlgebra1)));
    };
};
var functorTuple = new Data_Functor.Functor(function (f) {
    return function (m) {
        return new Tuple(m.value0, f(m.value1));
    };
});
var functorWithIndexTuple = new Data_FunctorWithIndex.FunctorWithIndex(function () {
    return functorTuple;
}, function (f) {
    return Data_Functor.map(functorTuple)(f(Data_Unit.unit));
});
var invariantTuple = new Data_Functor_Invariant.Invariant(Data_Functor_Invariant.imapF(functorTuple));
var fst = function (v) {
    return v.value0;
};
var lazyTuple = function (dictLazy) {
    return function (dictLazy1) {
        return new Control_Lazy.Lazy(function (f) {
            return new Tuple(Control_Lazy.defer(dictLazy)(function (v) {
                return fst(f(Data_Unit.unit));
            }), Control_Lazy.defer(dictLazy1)(function (v) {
                return snd(f(Data_Unit.unit));
            }));
        });
    };
};
var foldableTuple = new Data_Foldable.Foldable(function (dictMonoid) {
    return function (f) {
        return function (v) {
            return f(v.value1);
        };
    };
}, function (f) {
    return function (z) {
        return function (v) {
            return f(z)(v.value1);
        };
    };
}, function (f) {
    return function (z) {
        return function (v) {
            return f(v.value1)(z);
        };
    };
});
var foldableWithIndexTuple = new Data_FoldableWithIndex.FoldableWithIndex(function () {
    return foldableTuple;
}, function (dictMonoid) {
    return function (f) {
        return function (v) {
            return f(Data_Unit.unit)(v.value1);
        };
    };
}, function (f) {
    return function (z) {
        return function (v) {
            return f(Data_Unit.unit)(z)(v.value1);
        };
    };
}, function (f) {
    return function (z) {
        return function (v) {
            return f(Data_Unit.unit)(v.value1)(z);
        };
    };
});
var traversableTuple = new Data_Traversable.Traversable(function () {
    return foldableTuple;
}, function () {
    return functorTuple;
}, function (dictApplicative) {
    return function (v) {
        return Data_Functor.map((dictApplicative.Apply0()).Functor0())(Tuple.create(v.value0))(v.value1);
    };
}, function (dictApplicative) {
    return function (f) {
        return function (v) {
            return Data_Functor.map((dictApplicative.Apply0()).Functor0())(Tuple.create(v.value0))(f(v.value1));
        };
    };
});
var traversableWithIndexTuple = new Data_TraversableWithIndex.TraversableWithIndex(function () {
    return foldableWithIndexTuple;
}, function () {
    return functorWithIndexTuple;
}, function () {
    return traversableTuple;
}, function (dictApplicative) {
    return function (f) {
        return function (v) {
            return Data_Functor.map((dictApplicative.Apply0()).Functor0())(Tuple.create(v.value0))(f(Data_Unit.unit)(v.value1));
        };
    };
});
var foldable1Tuple = new Data_Semigroup_Foldable.Foldable1(function () {
    return foldableTuple;
}, function (dictSemigroup) {
    return function (v) {
        return v.value1;
    };
}, function (dictSemigroup) {
    return function (f) {
        return function (v) {
            return f(v.value1);
        };
    };
});
var traversable1Tuple = new Data_Semigroup_Traversable.Traversable1(function () {
    return foldable1Tuple;
}, function () {
    return traversableTuple;
}, function (dictApply) {
    return function (v) {
        return Data_Functor.map(dictApply.Functor0())(Tuple.create(v.value0))(v.value1);
    };
}, function (dictApply) {
    return function (f) {
        return function (v) {
            return Data_Functor.map(dictApply.Functor0())(Tuple.create(v.value0))(f(v.value1));
        };
    };
});
var extendTuple = new Control_Extend.Extend(function () {
    return functorTuple;
}, function (f) {
    return function (v) {
        return new Tuple(v.value0, f(v));
    };
});
var eqTuple = function (dictEq) {
    return function (dictEq1) {
        return new Data_Eq.Eq(function (x) {
            return function (y) {
                return Data_Eq.eq(dictEq)(x.value0)(y.value0) && Data_Eq.eq(dictEq1)(x.value1)(y.value1);
            };
        });
    };
};
var ordTuple = function (dictOrd) {
    return function (dictOrd1) {
        return new Data_Ord.Ord(function () {
            return eqTuple(dictOrd.Eq0())(dictOrd1.Eq0());
        }, function (x) {
            return function (y) {
                var v = Data_Ord.compare(dictOrd)(x.value0)(y.value0);
                if (v instanceof Data_Ordering.LT) {
                    return Data_Ordering.LT.value;
                };
                if (v instanceof Data_Ordering.GT) {
                    return Data_Ordering.GT.value;
                };
                return Data_Ord.compare(dictOrd1)(x.value1)(y.value1);
            };
        });
    };
};
var eq1Tuple = function (dictEq) {
    return new Data_Eq.Eq1(function (dictEq1) {
        return Data_Eq.eq(eqTuple(dictEq)(dictEq1));
    });
};
var ord1Tuple = function (dictOrd) {
    return new Data_Ord.Ord1(function () {
        return eq1Tuple(dictOrd.Eq0());
    }, function (dictOrd1) {
        return Data_Ord.compare(ordTuple(dictOrd)(dictOrd1));
    });
};
var distributiveTuple = function (dictTypeEquals) {
    return new Data_Distributive.Distributive(function () {
        return functorTuple;
    }, function (dictFunctor) {
        return Data_Distributive.collectDefault(distributiveTuple(dictTypeEquals))(dictFunctor);
    }, function (dictFunctor) {
        var $315 = Tuple.create(Type_Equality.from(dictTypeEquals)(Data_Unit.unit));
        var $316 = Data_Functor.map(dictFunctor)(snd);
        return function ($317) {
            return $315($316($317));
        };
    });
};
var curry = function (f) {
    return function (a) {
        return function (b) {
            return f(new Tuple(a, b));
        };
    };
};
var comonadTuple = new Control_Comonad.Comonad(function () {
    return extendTuple;
}, snd);
var commutativeRingTuple = function (dictCommutativeRing) {
    return function (dictCommutativeRing1) {
        return new Data_CommutativeRing.CommutativeRing(function () {
            return ringTuple(dictCommutativeRing.Ring0())(dictCommutativeRing1.Ring0());
        });
    };
};
var boundedTuple = function (dictBounded) {
    return function (dictBounded1) {
        return new Data_Bounded.Bounded(function () {
            return ordTuple(dictBounded.Ord0())(dictBounded1.Ord0());
        }, new Tuple(Data_Bounded.bottom(dictBounded), Data_Bounded.bottom(dictBounded1)), new Tuple(Data_Bounded.top(dictBounded), Data_Bounded.top(dictBounded1)));
    };
};
var booleanAlgebraTuple = function (dictBooleanAlgebra) {
    return function (dictBooleanAlgebra1) {
        return new Data_BooleanAlgebra.BooleanAlgebra(function () {
            return heytingAlgebraTuple(dictBooleanAlgebra.HeytingAlgebra0())(dictBooleanAlgebra1.HeytingAlgebra0());
        });
    };
};
var bifunctorTuple = new Data_Bifunctor.Bifunctor(function (f) {
    return function (g) {
        return function (v) {
            return new Tuple(f(v.value0), g(v.value1));
        };
    };
});
var bifoldableTuple = new Data_Bifoldable.Bifoldable(function (dictMonoid) {
    return function (f) {
        return function (g) {
            return function (v) {
                return Data_Semigroup.append(dictMonoid.Semigroup0())(f(v.value0))(g(v.value1));
            };
        };
    };
}, function (f) {
    return function (g) {
        return function (z) {
            return function (v) {
                return g(f(z)(v.value0))(v.value1);
            };
        };
    };
}, function (f) {
    return function (g) {
        return function (z) {
            return function (v) {
                return f(v.value0)(g(v.value1)(z));
            };
        };
    };
});
var bitraversableTuple = new Data_Bitraversable.Bitraversable(function () {
    return bifoldableTuple;
}, function () {
    return bifunctorTuple;
}, function (dictApplicative) {
    return function (v) {
        return Control_Apply.apply(dictApplicative.Apply0())(Data_Functor.map((dictApplicative.Apply0()).Functor0())(Tuple.create)(v.value0))(v.value1);
    };
}, function (dictApplicative) {
    return function (f) {
        return function (g) {
            return function (v) {
                return Control_Apply.apply(dictApplicative.Apply0())(Data_Functor.map((dictApplicative.Apply0()).Functor0())(Tuple.create)(f(v.value0)))(g(v.value1));
            };
        };
    };
});
var biapplyTuple = new Control_Biapply.Biapply(function () {
    return bifunctorTuple;
}, function (v) {
    return function (v1) {
        return new Tuple(v.value0(v1.value0), v.value1(v1.value1));
    };
});
var biapplicativeTuple = new Control_Biapplicative.Biapplicative(function () {
    return biapplyTuple;
}, Tuple.create);
var applyTuple = function (dictSemigroup) {
    return new Control_Apply.Apply(function () {
        return functorTuple;
    }, function (v) {
        return function (v1) {
            return new Tuple(Data_Semigroup.append(dictSemigroup)(v.value0)(v1.value0), v.value1(v1.value1));
        };
    });
};
var bindTuple = function (dictSemigroup) {
    return new Control_Bind.Bind(function () {
        return applyTuple(dictSemigroup);
    }, function (v) {
        return function (f) {
            var v1 = f(v.value1);
            return new Tuple(Data_Semigroup.append(dictSemigroup)(v.value0)(v1.value0), v1.value1);
        };
    });
};
var applicativeTuple = function (dictMonoid) {
    return new Control_Applicative.Applicative(function () {
        return applyTuple(dictMonoid.Semigroup0());
    }, Tuple.create(Data_Monoid.mempty(dictMonoid)));
};
var monadTuple = function (dictMonoid) {
    return new Control_Monad.Monad(function () {
        return applicativeTuple(dictMonoid);
    }, function () {
        return bindTuple(dictMonoid.Semigroup0());
    });
};
module.exports = {
    Tuple: Tuple,
    fst: fst,
    snd: snd,
    curry: curry,
    uncurry: uncurry,
    swap: swap,
    lookup: lookup,
    showTuple: showTuple,
    eqTuple: eqTuple,
    eq1Tuple: eq1Tuple,
    ordTuple: ordTuple,
    ord1Tuple: ord1Tuple,
    boundedTuple: boundedTuple,
    semigroupoidTuple: semigroupoidTuple,
    semigroupTuple: semigroupTuple,
    monoidTuple: monoidTuple,
    semiringTuple: semiringTuple,
    ringTuple: ringTuple,
    commutativeRingTuple: commutativeRingTuple,
    heytingAlgebraTuple: heytingAlgebraTuple,
    booleanAlgebraTuple: booleanAlgebraTuple,
    functorTuple: functorTuple,
    functorWithIndexTuple: functorWithIndexTuple,
    invariantTuple: invariantTuple,
    bifunctorTuple: bifunctorTuple,
    applyTuple: applyTuple,
    biapplyTuple: biapplyTuple,
    applicativeTuple: applicativeTuple,
    biapplicativeTuple: biapplicativeTuple,
    bindTuple: bindTuple,
    monadTuple: monadTuple,
    extendTuple: extendTuple,
    comonadTuple: comonadTuple,
    lazyTuple: lazyTuple,
    foldableTuple: foldableTuple,
    foldable1Tuple: foldable1Tuple,
    foldableWithIndexTuple: foldableWithIndexTuple,
    bifoldableTuple: bifoldableTuple,
    traversableTuple: traversableTuple,
    traversable1Tuple: traversable1Tuple,
    traversableWithIndexTuple: traversableWithIndexTuple,
    bitraversableTuple: bitraversableTuple,
    distributiveTuple: distributiveTuple
};
