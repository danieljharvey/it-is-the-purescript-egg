// Generated by purs version 0.13.5
"use strict";
var Control_Category = require("../Control.Category/index.js");
var Data_Functor = require("../Data.Functor/index.js");
var Data_Identity = require("../Data.Identity/index.js");
var Data_Newtype = require("../Data.Newtype/index.js");
var Distributive = function (Functor0, collect, distribute) {
    this.Functor0 = Functor0;
    this.collect = collect;
    this.distribute = distribute;
};
var distributiveIdentity = new Distributive(function () {
    return Data_Identity.functorIdentity;
}, function (dictFunctor) {
    return function (f) {
        var $11 = Data_Functor.map(dictFunctor)((function () {
            var $13 = Data_Newtype.unwrap(Data_Identity.newtypeIdentity);
            return function ($14) {
                return $13(f($14));
            };
        })());
        return function ($12) {
            return Data_Identity.Identity($11($12));
        };
    };
}, function (dictFunctor) {
    var $15 = Data_Functor.map(dictFunctor)(Data_Newtype.unwrap(Data_Identity.newtypeIdentity));
    return function ($16) {
        return Data_Identity.Identity($15($16));
    };
});
var distribute = function (dict) {
    return dict.distribute;
};
var distributiveFunction = new Distributive(function () {
    return Data_Functor.functorFn;
}, function (dictFunctor) {
    return function (f) {
        var $17 = distribute(distributiveFunction)(dictFunctor);
        var $18 = Data_Functor.map(dictFunctor)(f);
        return function ($19) {
            return $17($18($19));
        };
    };
}, function (dictFunctor) {
    return function (a) {
        return function (e) {
            return Data_Functor.map(dictFunctor)(function (v) {
                return v(e);
            })(a);
        };
    };
});
var cotraverse = function (dictDistributive) {
    return function (dictFunctor) {
        return function (f) {
            var $20 = Data_Functor.map(dictDistributive.Functor0())(f);
            var $21 = distribute(dictDistributive)(dictFunctor);
            return function ($22) {
                return $20($21($22));
            };
        };
    };
};
var collectDefault = function (dictDistributive) {
    return function (dictFunctor) {
        return function (f) {
            var $23 = distribute(dictDistributive)(dictFunctor);
            var $24 = Data_Functor.map(dictFunctor)(f);
            return function ($25) {
                return $23($24($25));
            };
        };
    };
};
var collect = function (dict) {
    return dict.collect;
};
var distributeDefault = function (dictDistributive) {
    return function (dictFunctor) {
        return collect(dictDistributive)(dictFunctor)(Control_Category.identity(Control_Category.categoryFn));
    };
};
module.exports = {
    collect: collect,
    distribute: distribute,
    Distributive: Distributive,
    distributeDefault: distributeDefault,
    collectDefault: collectDefault,
    cotraverse: cotraverse,
    distributiveIdentity: distributiveIdentity,
    distributiveFunction: distributiveFunction
};
