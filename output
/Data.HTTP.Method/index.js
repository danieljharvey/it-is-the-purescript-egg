// Generated by purs version 0.13.5
"use strict";
var Data_Either = require("../Data.Either/index.js");
var Data_Eq = require("../Data.Eq/index.js");
var Data_Ord = require("../Data.Ord/index.js");
var Data_Ordering = require("../Data.Ordering/index.js");
var Data_Show = require("../Data.Show/index.js");
var Data_String_Common = require("../Data.String.Common/index.js");
var OPTIONS = (function () {
    function OPTIONS() {

    };
    OPTIONS.value = new OPTIONS();
    return OPTIONS;
})();
var GET = (function () {
    function GET() {

    };
    GET.value = new GET();
    return GET;
})();
var HEAD = (function () {
    function HEAD() {

    };
    HEAD.value = new HEAD();
    return HEAD;
})();
var POST = (function () {
    function POST() {

    };
    POST.value = new POST();
    return POST;
})();
var PUT = (function () {
    function PUT() {

    };
    PUT.value = new PUT();
    return PUT;
})();
var DELETE = (function () {
    function DELETE() {

    };
    DELETE.value = new DELETE();
    return DELETE;
})();
var TRACE = (function () {
    function TRACE() {

    };
    TRACE.value = new TRACE();
    return TRACE;
})();
var CONNECT = (function () {
    function CONNECT() {

    };
    CONNECT.value = new CONNECT();
    return CONNECT;
})();
var PROPFIND = (function () {
    function PROPFIND() {

    };
    PROPFIND.value = new PROPFIND();
    return PROPFIND;
})();
var PROPPATCH = (function () {
    function PROPPATCH() {

    };
    PROPPATCH.value = new PROPPATCH();
    return PROPPATCH;
})();
var MKCOL = (function () {
    function MKCOL() {

    };
    MKCOL.value = new MKCOL();
    return MKCOL;
})();
var COPY = (function () {
    function COPY() {

    };
    COPY.value = new COPY();
    return COPY;
})();
var MOVE = (function () {
    function MOVE() {

    };
    MOVE.value = new MOVE();
    return MOVE;
})();
var LOCK = (function () {
    function LOCK() {

    };
    LOCK.value = new LOCK();
    return LOCK;
})();
var UNLOCK = (function () {
    function UNLOCK() {

    };
    UNLOCK.value = new UNLOCK();
    return UNLOCK;
})();
var PATCH = (function () {
    function PATCH() {

    };
    PATCH.value = new PATCH();
    return PATCH;
})();
var CustomMethod = function (x) {
    return x;
};
var unCustomMethod = function (v) {
    return v;
};
var showMethod = new Data_Show.Show(function (v) {
    if (v instanceof OPTIONS) {
        return "OPTIONS";
    };
    if (v instanceof GET) {
        return "GET";
    };
    if (v instanceof HEAD) {
        return "HEAD";
    };
    if (v instanceof POST) {
        return "POST";
    };
    if (v instanceof PUT) {
        return "PUT";
    };
    if (v instanceof DELETE) {
        return "DELETE";
    };
    if (v instanceof TRACE) {
        return "TRACE";
    };
    if (v instanceof CONNECT) {
        return "CONNECT";
    };
    if (v instanceof PROPFIND) {
        return "PROPFIND";
    };
    if (v instanceof PROPPATCH) {
        return "PROPPATCH";
    };
    if (v instanceof MKCOL) {
        return "MKCOL";
    };
    if (v instanceof COPY) {
        return "COPY";
    };
    if (v instanceof MOVE) {
        return "MOVE";
    };
    if (v instanceof LOCK) {
        return "LOCK";
    };
    if (v instanceof UNLOCK) {
        return "UNLOCK";
    };
    if (v instanceof PATCH) {
        return "PATCH";
    };
    throw new Error("Failed pattern match at Data.HTTP.Method (line 40, column 1 - line 56, column 23): " + [ v.constructor.name ]);
});
var showCustomMethod = new Data_Show.Show(function (v) {
    return "(CustomMethod " + (Data_Show.show(Data_Show.showString)(v) + ")");
});
var print = Data_Either.either(Data_Show.show(showMethod))(unCustomMethod);
var fromString = function (s) {
    var v = Data_String_Common.toUpper(s);
    if (v === "OPTIONS") {
        return new Data_Either.Left(OPTIONS.value);
    };
    if (v === "GET") {
        return new Data_Either.Left(GET.value);
    };
    if (v === "HEAD") {
        return new Data_Either.Left(HEAD.value);
    };
    if (v === "POST") {
        return new Data_Either.Left(POST.value);
    };
    if (v === "PUT") {
        return new Data_Either.Left(PUT.value);
    };
    if (v === "DELETE") {
        return new Data_Either.Left(DELETE.value);
    };
    if (v === "TRACE") {
        return new Data_Either.Left(TRACE.value);
    };
    if (v === "CONNECT") {
        return new Data_Either.Left(CONNECT.value);
    };
    if (v === "PROPFIND") {
        return new Data_Either.Left(PROPFIND.value);
    };
    if (v === "PROPPATCH") {
        return new Data_Either.Left(PROPPATCH.value);
    };
    if (v === "MKCOL") {
        return new Data_Either.Left(MKCOL.value);
    };
    if (v === "COPY") {
        return new Data_Either.Left(COPY.value);
    };
    if (v === "MOVE") {
        return new Data_Either.Left(MOVE.value);
    };
    if (v === "LOCK") {
        return new Data_Either.Left(LOCK.value);
    };
    if (v === "UNLOCK") {
        return new Data_Either.Left(UNLOCK.value);
    };
    if (v === "PATCH") {
        return new Data_Either.Left(PATCH.value);
    };
    return new Data_Either.Right(v);
};
var eqMethod = new Data_Eq.Eq(function (x) {
    return function (y) {
        if (x instanceof OPTIONS && y instanceof OPTIONS) {
            return true;
        };
        if (x instanceof GET && y instanceof GET) {
            return true;
        };
        if (x instanceof HEAD && y instanceof HEAD) {
            return true;
        };
        if (x instanceof POST && y instanceof POST) {
            return true;
        };
        if (x instanceof PUT && y instanceof PUT) {
            return true;
        };
        if (x instanceof DELETE && y instanceof DELETE) {
            return true;
        };
        if (x instanceof TRACE && y instanceof TRACE) {
            return true;
        };
        if (x instanceof CONNECT && y instanceof CONNECT) {
            return true;
        };
        if (x instanceof PROPFIND && y instanceof PROPFIND) {
            return true;
        };
        if (x instanceof PROPPATCH && y instanceof PROPPATCH) {
            return true;
        };
        if (x instanceof MKCOL && y instanceof MKCOL) {
            return true;
        };
        if (x instanceof COPY && y instanceof COPY) {
            return true;
        };
        if (x instanceof MOVE && y instanceof MOVE) {
            return true;
        };
        if (x instanceof LOCK && y instanceof LOCK) {
            return true;
        };
        if (x instanceof UNLOCK && y instanceof UNLOCK) {
            return true;
        };
        if (x instanceof PATCH && y instanceof PATCH) {
            return true;
        };
        return false;
    };
});
var ordMethod = new Data_Ord.Ord(function () {
    return eqMethod;
}, function (x) {
    return function (y) {
        if (x instanceof OPTIONS && y instanceof OPTIONS) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof OPTIONS) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof OPTIONS) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof GET && y instanceof GET) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof GET) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof GET) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof HEAD && y instanceof HEAD) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof HEAD) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof HEAD) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof POST && y instanceof POST) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof POST) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof POST) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof PUT && y instanceof PUT) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof PUT) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof PUT) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof DELETE && y instanceof DELETE) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof DELETE) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof DELETE) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof TRACE && y instanceof TRACE) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof TRACE) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof TRACE) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof CONNECT && y instanceof CONNECT) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof CONNECT) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof CONNECT) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof PROPFIND && y instanceof PROPFIND) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof PROPFIND) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof PROPFIND) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof PROPPATCH && y instanceof PROPPATCH) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof PROPPATCH) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof PROPPATCH) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof MKCOL && y instanceof MKCOL) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof MKCOL) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof MKCOL) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof COPY && y instanceof COPY) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof COPY) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof COPY) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof MOVE && y instanceof MOVE) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof MOVE) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof MOVE) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof LOCK && y instanceof LOCK) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof LOCK) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof LOCK) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof UNLOCK && y instanceof UNLOCK) {
            return Data_Ordering.EQ.value;
        };
        if (x instanceof UNLOCK) {
            return Data_Ordering.LT.value;
        };
        if (y instanceof UNLOCK) {
            return Data_Ordering.GT.value;
        };
        if (x instanceof PATCH && y instanceof PATCH) {
            return Data_Ordering.EQ.value;
        };
        throw new Error("Failed pattern match at Data.HTTP.Method (line 38, column 1 - line 38, column 40): " + [ x.constructor.name, y.constructor.name ]);
    };
});
var eqCustomMethod = new Data_Eq.Eq(function (x) {
    return function (y) {
        return x === y;
    };
});
var ordCustomMethod = new Data_Ord.Ord(function () {
    return eqCustomMethod;
}, function (x) {
    return function (y) {
        return Data_Ord.compare(Data_Ord.ordString)(x)(y);
    };
});
module.exports = {
    OPTIONS: OPTIONS,
    GET: GET,
    HEAD: HEAD,
    POST: POST,
    PUT: PUT,
    DELETE: DELETE,
    TRACE: TRACE,
    CONNECT: CONNECT,
    PROPFIND: PROPFIND,
    PROPPATCH: PROPPATCH,
    MKCOL: MKCOL,
    COPY: COPY,
    MOVE: MOVE,
    LOCK: LOCK,
    UNLOCK: UNLOCK,
    PATCH: PATCH,
    unCustomMethod: unCustomMethod,
    fromString: fromString,
    print: print,
    eqMethod: eqMethod,
    ordMethod: ordMethod,
    showMethod: showMethod,
    eqCustomMethod: eqCustomMethod,
    ordCustomMethod: ordCustomMethod,
    showCustomMethod: showCustomMethod
};
