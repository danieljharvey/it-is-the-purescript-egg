// Generated by purs version 0.13.5
"use strict";
var Data_Eq = require("../Data.Eq/index.js");
var Data_Maybe = require("../Data.Maybe/index.js");
var Data_Ord = require("../Data.Ord/index.js");
var Data_Ordering = require("../Data.Ordering/index.js");
var Data_Show = require("../Data.Show/index.js");
var Unspecified = (function () {
    function Unspecified() {

    };
    Unspecified.value = new Unspecified();
    return Unspecified;
})();
var Maybe = (function () {
    function Maybe() {

    };
    Maybe.value = new Maybe();
    return Maybe;
})();
var Probably = (function () {
    function Probably() {

    };
    Probably.value = new Probably();
    return Probably;
})();
var showCanPlayType = new Data_Show.Show(function (v) {
    if (v instanceof Unspecified) {
        return "Unspecified";
    };
    if (v instanceof Maybe) {
        return "Maybe";
    };
    if (v instanceof Probably) {
        return "Probably";
    };
    throw new Error("Failed pattern match at Web.HTML.HTMLMediaElement.CanPlayType (line 16, column 10 - line 19, column 27): " + [ v.constructor.name ]);
});
var print = function (v) {
    if (v instanceof Unspecified) {
        return "";
    };
    if (v instanceof Maybe) {
        return "maybe";
    };
    if (v instanceof Probably) {
        return "probably";
    };
    throw new Error("Failed pattern match at Web.HTML.HTMLMediaElement.CanPlayType (line 29, column 9 - line 32, column 25): " + [ v.constructor.name ]);
};
var parse = function (v) {
    if (v === "") {
        return new Data_Maybe.Just(Unspecified.value);
    };
    if (v === "maybe") {
        return new Data_Maybe.Just(Maybe.value);
    };
    if (v === "probably") {
        return new Data_Maybe.Just(Probably.value);
    };
    return Data_Maybe.Nothing.value;
};
var eqCanPlayType = new Data_Eq.Eq(function (x) {
    return function (y) {
        if (x instanceof Unspecified && y instanceof Unspecified) {
            return true;
        };
        if (x instanceof Maybe && y instanceof Maybe) {
            return true;
        };
        if (x instanceof Probably && y instanceof Probably) {
            return true;
        };
        return false;
    };
});
var ordCanPlayType = new Data_Ord.Ord(function () {
    return eqCanPlayType;
}, function (x) {
    return function (y) {
        if (x instanceof Unspecified && y instanceof Unspecified) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof Unspecified) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof Unspecified) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof Maybe && y instanceof Maybe) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof Maybe) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof Maybe) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof Probably && y instanceof Probably) {
            return Data_Ordering.EQ.value;
        };
        throw new Error("Failed pattern match at Web.HTML.HTMLMediaElement.CanPlayType (line 13, column 1 - line 13, column 50): " + [ x.constructor.name, y.constructor.name ]);
    };
});
module.exports = {
    Unspecified: Unspecified,
    Maybe: Maybe,
    Probably: Probably,
    parse: parse,
    print: print,
    eqCanPlayType: eqCanPlayType,
    ordCanPlayType: ordCanPlayType,
    showCanPlayType: showCanPlayType
};
