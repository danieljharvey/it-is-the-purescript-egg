// Generated by purs version 0.13.5
"use strict";
var $foreign = require("./foreign.js");
var Data_Eq = require("../Data.Eq/index.js");
var Data_Function = require("../Data.Function/index.js");
var Data_Maybe = require("../Data.Maybe/index.js");
var Data_Ord = require("../Data.Ord/index.js");
var Data_Ordering = require("../Data.Ordering/index.js");
var Foreign_Object = require("../Foreign.Object/index.js");
var verbJsonType = function (def) {
    return function (f) {
        return function (g) {
            return g(def)(f);
        };
    };
};
var toJsonType = verbJsonType(Data_Maybe.Nothing.value)(Data_Maybe.Just.create);
var jsonZero = $foreign.fromNumber(0.0);
var jsonTrue = $foreign.fromBoolean(true);
var jsonSingletonObject = function (key) {
    return function (val) {
        return $foreign.fromObject(Foreign_Object.singleton(key)(val));
    };
};
var jsonSingletonArray = function (j) {
    return $foreign.fromArray([ j ]);
};
var jsonFalse = $foreign.fromBoolean(false);
var jsonEmptyString = $foreign.fromString("");
var jsonEmptyObject = $foreign.fromObject(Foreign_Object.empty);
var jsonEmptyArray = $foreign.fromArray([  ]);
var isJsonType = verbJsonType(false)(Data_Function["const"](true));
var ordJson = new Data_Ord.Ord(function () {
    return eqJson;
}, function (a) {
    return function (b) {
        return $foreign["_compare"](Data_Ordering.EQ.value, Data_Ordering.GT.value, Data_Ordering.LT.value, a, b);
    };
});
var eqJson = new Data_Eq.Eq(function (j1) {
    return function (j2) {
        return Data_Eq.eq(Data_Ordering.eqOrdering)(Data_Ord.compare(ordJson)(j1)(j2))(Data_Ordering.EQ.value);
    };
});
var eqJNull = new Data_Eq.Eq(function (v) {
    return function (v1) {
        return true;
    };
});
var ordJNull = new Data_Ord.Ord(function () {
    return eqJNull;
}, function (v) {
    return function (v1) {
        return Data_Ordering.EQ.value;
    };
});
var caseJsonString = function (d) {
    return function (f) {
        return function (j) {
            return $foreign["_caseJson"](Data_Function["const"](d), Data_Function["const"](d), Data_Function["const"](d), f, Data_Function["const"](d), Data_Function["const"](d), j);
        };
    };
};
var isString = isJsonType(caseJsonString);
var toString = toJsonType(caseJsonString);
var caseJsonObject = function (d) {
    return function (f) {
        return function (j) {
            return $foreign["_caseJson"](Data_Function["const"](d), Data_Function["const"](d), Data_Function["const"](d), Data_Function["const"](d), Data_Function["const"](d), f, j);
        };
    };
};
var isObject = isJsonType(caseJsonObject);
var toObject = toJsonType(caseJsonObject);
var caseJsonNumber = function (d) {
    return function (f) {
        return function (j) {
            return $foreign["_caseJson"](Data_Function["const"](d), Data_Function["const"](d), f, Data_Function["const"](d), Data_Function["const"](d), Data_Function["const"](d), j);
        };
    };
};
var isNumber = isJsonType(caseJsonNumber);
var toNumber = toJsonType(caseJsonNumber);
var caseJsonNull = function (d) {
    return function (f) {
        return function (j) {
            return $foreign["_caseJson"](f, Data_Function["const"](d), Data_Function["const"](d), Data_Function["const"](d), Data_Function["const"](d), Data_Function["const"](d), j);
        };
    };
};
var isNull = isJsonType(caseJsonNull);
var toNull = toJsonType(caseJsonNull);
var caseJsonBoolean = function (d) {
    return function (f) {
        return function (j) {
            return $foreign["_caseJson"](Data_Function["const"](d), f, Data_Function["const"](d), Data_Function["const"](d), Data_Function["const"](d), Data_Function["const"](d), j);
        };
    };
};
var isBoolean = isJsonType(caseJsonBoolean);
var toBoolean = toJsonType(caseJsonBoolean);
var caseJsonArray = function (d) {
    return function (f) {
        return function (j) {
            return $foreign["_caseJson"](Data_Function["const"](d), Data_Function["const"](d), Data_Function["const"](d), Data_Function["const"](d), f, Data_Function["const"](d), j);
        };
    };
};
var isArray = isJsonType(caseJsonArray);
var toArray = toJsonType(caseJsonArray);
var caseJson = function (a) {
    return function (b) {
        return function (c) {
            return function (d) {
                return function (e) {
                    return function (f) {
                        return function (json) {
                            return $foreign["_caseJson"](a, b, c, d, e, f, json);
                        };
                    };
                };
            };
        };
    };
};
module.exports = {
    caseJson: caseJson,
    caseJsonNull: caseJsonNull,
    caseJsonBoolean: caseJsonBoolean,
    caseJsonNumber: caseJsonNumber,
    caseJsonString: caseJsonString,
    caseJsonArray: caseJsonArray,
    caseJsonObject: caseJsonObject,
    isNull: isNull,
    isBoolean: isBoolean,
    isNumber: isNumber,
    isString: isString,
    isArray: isArray,
    isObject: isObject,
    toNull: toNull,
    toBoolean: toBoolean,
    toNumber: toNumber,
    toString: toString,
    toArray: toArray,
    toObject: toObject,
    jsonTrue: jsonTrue,
    jsonFalse: jsonFalse,
    jsonZero: jsonZero,
    jsonEmptyString: jsonEmptyString,
    jsonEmptyArray: jsonEmptyArray,
    jsonSingletonArray: jsonSingletonArray,
    jsonEmptyObject: jsonEmptyObject,
    jsonSingletonObject: jsonSingletonObject,
    eqJson: eqJson,
    ordJson: ordJson,
    fromBoolean: $foreign.fromBoolean,
    fromNumber: $foreign.fromNumber,
    fromString: $foreign.fromString,
    fromArray: $foreign.fromArray,
    fromObject: $foreign.fromObject,
    jsonNull: $foreign.jsonNull,
    stringify: $foreign.stringify
};
