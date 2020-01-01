// Generated by purs version 0.13.5
"use strict";
var Control_Apply = require("../Control.Apply/index.js");
var Data_Boolean = require("../Data.Boolean/index.js");
var Data_Enum = require("../Data.Enum/index.js");
var Data_Eq = require("../Data.Eq/index.js");
var Data_Functor = require("../Data.Functor/index.js");
var Data_Int = require("../Data.Int/index.js");
var Data_Maybe = require("../Data.Maybe/index.js");
var Data_Ord = require("../Data.Ord/index.js");
var Data_Semigroup = require("../Data.Semigroup/index.js");
var Data_Semiring = require("../Data.Semiring/index.js");
var Data_Show = require("../Data.Show/index.js");
var Data_String_CodePoints = require("../Data.String.CodePoints/index.js");
var Data_String_CodeUnits = require("../Data.String.CodeUnits/index.js");
var Data_String_Common = require("../Data.String.Common/index.js");
var Global = require("../Global/index.js");
var Perm = function (x) {
    return x;
};
var Perms = function (x) {
    return x;
};
var write = {
    r: false,
    w: true,
    x: false
};
var semiringPerm = new Data_Semiring.Semiring(function (v) {
    return function (v1) {
        return {
            r: v.r || v1.r,
            w: v.w || v1.w,
            x: v.x || v1.x
        };
    };
}, function (v) {
    return function (v1) {
        return {
            r: v.r && v1.r,
            w: v.w && v1.w,
            x: v.x && v1.x
        };
    };
}, {
    r: true,
    w: true,
    x: true
}, {
    r: false,
    w: false,
    x: false
});
var read = {
    r: true,
    w: false,
    x: false
};
var permToInt = function (v) {
    return ((function () {
        if (v.r) {
            return 4;
        };
        return 0;
    })() + (function () {
        if (v.w) {
            return 2;
        };
        return 0;
    })() | 0) + (function () {
        if (v.x) {
            return 1;
        };
        return 0;
    })() | 0;
};
var permToString = (function () {
    var $97 = Data_Show.show(Data_Show.showInt);
    return function ($98) {
        return $97(permToInt($98));
    };
})();
var permsToString = function (v) {
    return "0" + (permToString(v.u) + (permToString(v.g) + permToString(v.o)));
};
var permsToInt = (function (dictPartial) {
    var $99 = Data_Maybe.fromJust();
    var $100 = Global.readInt(8);
    return function ($101) {
        return $99(Data_Int.fromNumber($100(permsToString($101))));
    };
})();
var none = Data_Semiring.zero(semiringPerm);
var mkPerms = function (u) {
    return function (g) {
        return function (o) {
            return {
                u: u,
                g: g,
                o: o
            };
        };
    };
};
var mkPerm = function (r) {
    return function (w) {
        return function (x) {
            return {
                r: r,
                w: w,
                x: x
            };
        };
    };
};
var execute = {
    r: false,
    w: false,
    x: true
};
var permFromChar = function (c) {
    if (c === "0") {
        return Data_Maybe.Just.create(none);
    };
    if (c === "1") {
        return Data_Maybe.Just.create(execute);
    };
    if (c === "2") {
        return Data_Maybe.Just.create(write);
    };
    if (c === "3") {
        return Data_Maybe.Just.create(Data_Semiring.add(semiringPerm)(write)(execute));
    };
    if (c === "4") {
        return Data_Maybe.Just.create(read);
    };
    if (c === "5") {
        return Data_Maybe.Just.create(Data_Semiring.add(semiringPerm)(read)(execute));
    };
    if (c === "6") {
        return Data_Maybe.Just.create(Data_Semiring.add(semiringPerm)(read)(write));
    };
    if (c === "7") {
        return Data_Maybe.Just.create(Data_Semiring.add(semiringPerm)(Data_Semiring.add(semiringPerm)(read)(write))(execute));
    };
    return Data_Maybe.Nothing.value;
};
var permsFromString = (function () {
    var zeroChar = Data_Maybe.fromJust()(Data_Enum.toEnum(Data_Enum.boundedEnumChar)(48));
    var dropPrefix = function (x) {
        return function (xs) {
            if (Data_Eq.eq(Data_Maybe.eqMaybe(Data_Eq.eqChar))(Data_String_CodeUnits.charAt(0)(xs))(new Data_Maybe.Just(x))) {
                return Data_String_CodePoints.drop(1)(xs);
            };
            if (Data_Boolean.otherwise) {
                return xs;
            };
            throw new Error("Failed pattern match at Node.FS.Perms (line 126, column 5 - line 128, column 35): " + [ x.constructor.name, xs.constructor.name ]);
        };
    };
    var _perms = function (v) {
        if (v.length === 3) {
            return Control_Apply.apply(Data_Maybe.applyMaybe)(Control_Apply.apply(Data_Maybe.applyMaybe)(Data_Functor.map(Data_Maybe.functorMaybe)(mkPerms)(permFromChar(v[0])))(permFromChar(v[1])))(permFromChar(v[2]));
        };
        return Data_Maybe.Nothing.value;
    };
    var $102 = dropPrefix(zeroChar);
    return function ($103) {
        return _perms(Data_String_CodeUnits.toCharArray($102($103)));
    };
})();
var eqPerm = new Data_Eq.Eq(function (v) {
    return function (v1) {
        return v.r === v1.r && (v.w === v1.w && v.x === v1.x);
    };
});
var eqPerms = new Data_Eq.Eq(function (v) {
    return function (v1) {
        return Data_Eq.eq(eqPerm)(v.u)(v1.u) && (Data_Eq.eq(eqPerm)(v.g)(v1.g) && Data_Eq.eq(eqPerm)(v.o)(v1.o));
    };
});
var ordPerm = new Data_Ord.Ord(function () {
    return eqPerm;
}, function (v) {
    return function (v1) {
        return Data_Ord.compare(Data_Ord.ordArray(Data_Ord.ordBoolean))([ v.r, v.w, v.x ])([ v1.r, v1.w, v1.x ]);
    };
});
var ordPerms = new Data_Ord.Ord(function () {
    return eqPerms;
}, function (v) {
    return function (v1) {
        return Data_Ord.compare(Data_Ord.ordArray(ordPerm))([ v.u, v.g, v.o ])([ v1.u, v1.g, v1.o ]);
    };
});
var all = Data_Semiring.one(semiringPerm);
var showPerm = new Data_Show.Show(function (v) {
    if (Data_Eq.eq(eqPerm)(v)(none)) {
        return "none";
    };
    if (Data_Eq.eq(eqPerm)(v)(all)) {
        return "all";
    };
    var ps = Data_Semigroup.append(Data_Semigroup.semigroupArray)((function () {
        if (v.r) {
            return [ "read" ];
        };
        return [  ];
    })())(Data_Semigroup.append(Data_Semigroup.semigroupArray)((function () {
        if (v.w) {
            return [ "write" ];
        };
        return [  ];
    })())((function () {
        if (v.x) {
            return [ "execute" ];
        };
        return [  ];
    })()));
    return Data_String_Common.joinWith(" + ")(ps);
});
var showPerms = new Data_Show.Show(function (v) {
    var f = function (perm) {
        var str = Data_Show.show(showPerm)(perm);
        var $93 = Data_Maybe.isNothing(Data_String_CodePoints.indexOf(" ")(str));
        if ($93) {
            return str;
        };
        return "(" + (str + ")");
    };
    return "mkPerms " + Data_String_Common.joinWith(" ")(Data_Functor.map(Data_Functor.functorArray)(f)([ v.u, v.g, v.o ]));
});
module.exports = {
    none: none,
    read: read,
    write: write,
    execute: execute,
    all: all,
    mkPerms: mkPerms,
    permsFromString: permsFromString,
    permsToString: permsToString,
    permsToInt: permsToInt,
    eqPerm: eqPerm,
    ordPerm: ordPerm,
    showPerm: showPerm,
    semiringPerm: semiringPerm,
    eqPerms: eqPerms,
    ordPerms: ordPerms,
    showPerms: showPerms
};
