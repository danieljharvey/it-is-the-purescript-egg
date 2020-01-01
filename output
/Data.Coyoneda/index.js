// Generated by purs version 0.13.5
"use strict";
var Control_Alt = require("../Control.Alt/index.js");
var Control_Alternative = require("../Control.Alternative/index.js");
var Control_Applicative = require("../Control.Applicative/index.js");
var Control_Apply = require("../Control.Apply/index.js");
var Control_Bind = require("../Control.Bind/index.js");
var Control_Category = require("../Control.Category/index.js");
var Control_Comonad = require("../Control.Comonad/index.js");
var Control_Extend = require("../Control.Extend/index.js");
var Control_Monad = require("../Control.Monad/index.js");
var Control_Monad_Trans_Class = require("../Control.Monad.Trans.Class/index.js");
var Control_MonadPlus = require("../Control.MonadPlus/index.js");
var Control_MonadZero = require("../Control.MonadZero/index.js");
var Control_Plus = require("../Control.Plus/index.js");
var Data_Distributive = require("../Data.Distributive/index.js");
var Data_Eq = require("../Data.Eq/index.js");
var Data_Exists = require("../Data.Exists/index.js");
var Data_Foldable = require("../Data.Foldable/index.js");
var Data_Functor = require("../Data.Functor/index.js");
var Data_Functor_Invariant = require("../Data.Functor.Invariant/index.js");
var Data_Ord = require("../Data.Ord/index.js");
var Data_Semigroup_Foldable = require("../Data.Semigroup.Foldable/index.js");
var Data_Semigroup_Traversable = require("../Data.Semigroup.Traversable/index.js");
var Data_Traversable = require("../Data.Traversable/index.js");
var CoyonedaF = (function () {
    function CoyonedaF(value0, value1) {
        this.value0 = value0;
        this.value1 = value1;
    };
    CoyonedaF.create = function (value0) {
        return function (value1) {
            return new CoyonedaF(value0, value1);
        };
    };
    return CoyonedaF;
})();
var Coyoneda = function (x) {
    return x;
};
var unCoyoneda = function (f) {
    return function (v) {
        return Data_Exists.runExists(function (v1) {
            return f(v1.value0)(v1.value1);
        })(v);
    };
};
var lowerCoyoneda = function (dictFunctor) {
    return unCoyoneda(Data_Functor.map(dictFunctor));
};
var foldableCoyoneda = function (dictFoldable) {
    return new Data_Foldable.Foldable(function (dictMonoid) {
        return function (f) {
            return unCoyoneda(function (k) {
                return Data_Foldable.foldMap(dictFoldable)(dictMonoid)(function ($80) {
                    return f(k($80));
                });
            });
        };
    }, function (f) {
        return function (z) {
            return unCoyoneda(function (k) {
                return Data_Foldable.foldl(dictFoldable)(function (x) {
                    var $81 = f(x);
                    return function ($82) {
                        return $81(k($82));
                    };
                })(z);
            });
        };
    }, function (f) {
        return function (z) {
            return unCoyoneda(function (k) {
                return Data_Foldable.foldr(dictFoldable)(function ($83) {
                    return f(k($83));
                })(z);
            });
        };
    });
};
var foldable1Coyoneda = function (dictFoldable1) {
    return new Data_Semigroup_Foldable.Foldable1(function () {
        return foldableCoyoneda(dictFoldable1.Foldable0());
    }, function (dictSemigroup) {
        return unCoyoneda(function (k) {
            return Data_Semigroup_Foldable.foldMap1(dictFoldable1)(dictSemigroup)(k);
        });
    }, function (dictSemigroup) {
        return function (f) {
            return unCoyoneda(function (k) {
                return Data_Semigroup_Foldable.foldMap1(dictFoldable1)(dictSemigroup)(function ($84) {
                    return f(k($84));
                });
            });
        };
    });
};
var eqCoyoneda = function (dictFunctor) {
    return function (dictEq1) {
        return function (dictEq) {
            return new Data_Eq.Eq(function (x) {
                return function (y) {
                    return Data_Eq.eq1(dictEq1)(dictEq)(lowerCoyoneda(dictFunctor)(x))(lowerCoyoneda(dictFunctor)(y));
                };
            });
        };
    };
};
var ordCoyoneda = function (dictFunctor) {
    return function (dictOrd1) {
        return function (dictOrd) {
            return new Data_Ord.Ord(function () {
                return eqCoyoneda(dictFunctor)(dictOrd1.Eq10())(dictOrd.Eq0());
            }, function (x) {
                return function (y) {
                    return Data_Ord.compare1(dictOrd1)(dictOrd)(lowerCoyoneda(dictFunctor)(x))(lowerCoyoneda(dictFunctor)(y));
                };
            });
        };
    };
};
var eq1Coyoneda = function (dictFunctor) {
    return function (dictEq1) {
        return new Data_Eq.Eq1(function (dictEq) {
            return Data_Eq.eq(eqCoyoneda(dictFunctor)(dictEq1)(dictEq));
        });
    };
};
var ord1Coyoneda = function (dictFunctor) {
    return function (dictOrd1) {
        return new Data_Ord.Ord1(function () {
            return eq1Coyoneda(dictFunctor)(dictOrd1.Eq10());
        }, function (dictOrd) {
            return Data_Ord.compare(ordCoyoneda(dictFunctor)(dictOrd1)(dictOrd));
        });
    };
};
var coyoneda = function (k) {
    return function (fi) {
        return Coyoneda(Data_Exists.mkExists(new CoyonedaF(k, fi)));
    };
};
var functorCoyoneda = new Data_Functor.Functor(function (f) {
    return function (v) {
        return Data_Exists.runExists(function (v1) {
            return coyoneda(function ($85) {
                return f(v1.value0($85));
            })(v1.value1);
        })(v);
    };
});
var invatiantCoyoneda = new Data_Functor_Invariant.Invariant(Data_Functor_Invariant.imapF(functorCoyoneda));
var hoistCoyoneda = function (nat) {
    return function (v) {
        return Data_Exists.runExists(function (v1) {
            return coyoneda(v1.value0)(nat(v1.value1));
        })(v);
    };
};
var liftCoyoneda = coyoneda(Control_Category.identity(Control_Category.categoryFn));
var distributiveCoyoneda = function (dictDistributive) {
    return new Data_Distributive.Distributive(function () {
        return functorCoyoneda;
    }, function (dictFunctor) {
        return function (f) {
            var $86 = Data_Distributive.collect(dictDistributive)(dictFunctor)((function () {
                var $88 = lowerCoyoneda(dictDistributive.Functor0());
                return function ($89) {
                    return $88(f($89));
                };
            })());
            return function ($87) {
                return liftCoyoneda($86($87));
            };
        };
    }, function (dictFunctor) {
        var $90 = Data_Distributive.collect(dictDistributive)(dictFunctor)(lowerCoyoneda(dictDistributive.Functor0()));
        return function ($91) {
            return liftCoyoneda($90($91));
        };
    });
};
var extendCoyoneda = function (dictExtend) {
    return new Control_Extend.Extend(function () {
        return functorCoyoneda;
    }, function (f) {
        return function (v) {
            return Data_Exists.runExists(function (v1) {
                return liftCoyoneda(Control_Extend.extend(dictExtend)((function () {
                    var $92 = coyoneda(v1.value0);
                    return function ($93) {
                        return f($92($93));
                    };
                })())(v1.value1));
            })(v);
        };
    });
};
var monadTransCoyoneda = new Control_Monad_Trans_Class.MonadTrans(function (dictMonad) {
    return liftCoyoneda;
});
var traversableCoyoneda = function (dictTraversable) {
    return new Data_Traversable.Traversable(function () {
        return foldableCoyoneda(dictTraversable.Foldable1());
    }, function () {
        return functorCoyoneda;
    }, function (dictApplicative) {
        return unCoyoneda(function (k) {
            var $94 = Data_Functor.map((dictApplicative.Apply0()).Functor0())(liftCoyoneda);
            var $95 = Data_Traversable.traverse(dictTraversable)(dictApplicative)(k);
            return function ($96) {
                return $94($95($96));
            };
        });
    }, function (dictApplicative) {
        return function (f) {
            return unCoyoneda(function (k) {
                var $97 = Data_Functor.map((dictApplicative.Apply0()).Functor0())(liftCoyoneda);
                var $98 = Data_Traversable.traverse(dictTraversable)(dictApplicative)(function ($100) {
                    return f(k($100));
                });
                return function ($99) {
                    return $97($98($99));
                };
            });
        };
    });
};
var traversable1Coyoneda = function (dictTraversable1) {
    return new Data_Semigroup_Traversable.Traversable1(function () {
        return foldable1Coyoneda(dictTraversable1.Foldable10());
    }, function () {
        return traversableCoyoneda(dictTraversable1.Traversable1());
    }, function (dictApply) {
        return unCoyoneda(function (k) {
            var $101 = Data_Functor.map(dictApply.Functor0())(liftCoyoneda);
            var $102 = Data_Semigroup_Traversable.sequence1(dictTraversable1)(dictApply);
            var $103 = Data_Functor.map((dictTraversable1.Traversable1()).Functor0())(k);
            return function ($104) {
                return $101($102($103($104)));
            };
        });
    }, function (dictApply) {
        return function (f) {
            return unCoyoneda(function (k) {
                var $105 = Data_Functor.map(dictApply.Functor0())(liftCoyoneda);
                var $106 = Data_Semigroup_Traversable.traverse1(dictTraversable1)(dictApply)(function ($108) {
                    return f(k($108));
                });
                return function ($107) {
                    return $105($106($107));
                };
            });
        };
    });
};
var comonadCoyoneda = function (dictComonad) {
    return new Control_Comonad.Comonad(function () {
        return extendCoyoneda(dictComonad.Extend0());
    }, function (v) {
        return Data_Exists.runExists(function (v1) {
            return v1.value0(Control_Comonad.extract(dictComonad)(v1.value1));
        })(v);
    });
};
var applyCoyoneda = function (dictApply) {
    return new Control_Apply.Apply(function () {
        return functorCoyoneda;
    }, function (f) {
        return function (g) {
            return liftCoyoneda(Control_Apply.apply(dictApply)(lowerCoyoneda(dictApply.Functor0())(f))(lowerCoyoneda(dictApply.Functor0())(g)));
        };
    });
};
var bindCoyoneda = function (dictBind) {
    return new Control_Bind.Bind(function () {
        return applyCoyoneda(dictBind.Apply0());
    }, function (v) {
        return function (f) {
            return liftCoyoneda(Data_Exists.runExists(function (v1) {
                return Control_Bind.bindFlipped(dictBind)((function () {
                    var $109 = lowerCoyoneda((dictBind.Apply0()).Functor0());
                    return function ($110) {
                        return $109(f(v1.value0($110)));
                    };
                })())(v1.value1);
            })(v));
        };
    });
};
var applicativeCoyoneda = function (dictApplicative) {
    return new Control_Applicative.Applicative(function () {
        return applyCoyoneda(dictApplicative.Apply0());
    }, (function () {
        var $111 = Control_Applicative.pure(dictApplicative);
        return function ($112) {
            return liftCoyoneda($111($112));
        };
    })());
};
var monadCoyoneda = function (dictMonad) {
    return new Control_Monad.Monad(function () {
        return applicativeCoyoneda(dictMonad.Applicative0());
    }, function () {
        return bindCoyoneda(dictMonad.Bind1());
    });
};
var altCoyoneda = function (dictAlt) {
    return new Control_Alt.Alt(function () {
        return functorCoyoneda;
    }, function (x) {
        return function (y) {
            return liftCoyoneda(Control_Alt.alt(dictAlt)(lowerCoyoneda(dictAlt.Functor0())(x))(lowerCoyoneda(dictAlt.Functor0())(y)));
        };
    });
};
var plusCoyoneda = function (dictPlus) {
    return new Control_Plus.Plus(function () {
        return altCoyoneda(dictPlus.Alt0());
    }, liftCoyoneda(Control_Plus.empty(dictPlus)));
};
var alternativeCoyoneda = function (dictAlternative) {
    return new Control_Alternative.Alternative(function () {
        return applicativeCoyoneda(dictAlternative.Applicative0());
    }, function () {
        return plusCoyoneda(dictAlternative.Plus1());
    });
};
var monadZeroCoyoneda = function (dictMonadZero) {
    return new Control_MonadZero.MonadZero(function () {
        return alternativeCoyoneda(dictMonadZero.Alternative1());
    }, function () {
        return monadCoyoneda(dictMonadZero.Monad0());
    });
};
var monadPlusCoyoneda = function (dictMonadPlus) {
    return new Control_MonadPlus.MonadPlus(function () {
        return monadZeroCoyoneda(dictMonadPlus.MonadZero0());
    });
};
module.exports = {
    Coyoneda: Coyoneda,
    coyoneda: coyoneda,
    unCoyoneda: unCoyoneda,
    liftCoyoneda: liftCoyoneda,
    lowerCoyoneda: lowerCoyoneda,
    hoistCoyoneda: hoistCoyoneda,
    eqCoyoneda: eqCoyoneda,
    eq1Coyoneda: eq1Coyoneda,
    ordCoyoneda: ordCoyoneda,
    ord1Coyoneda: ord1Coyoneda,
    functorCoyoneda: functorCoyoneda,
    invatiantCoyoneda: invatiantCoyoneda,
    applyCoyoneda: applyCoyoneda,
    applicativeCoyoneda: applicativeCoyoneda,
    altCoyoneda: altCoyoneda,
    plusCoyoneda: plusCoyoneda,
    alternativeCoyoneda: alternativeCoyoneda,
    bindCoyoneda: bindCoyoneda,
    monadCoyoneda: monadCoyoneda,
    monadTransCoyoneda: monadTransCoyoneda,
    monadZeroCoyoneda: monadZeroCoyoneda,
    monadPlusCoyoneda: monadPlusCoyoneda,
    extendCoyoneda: extendCoyoneda,
    comonadCoyoneda: comonadCoyoneda,
    foldableCoyoneda: foldableCoyoneda,
    traversableCoyoneda: traversableCoyoneda,
    foldable1Coyoneda: foldable1Coyoneda,
    traversable1Coyoneda: traversable1Coyoneda,
    distributiveCoyoneda: distributiveCoyoneda
};
