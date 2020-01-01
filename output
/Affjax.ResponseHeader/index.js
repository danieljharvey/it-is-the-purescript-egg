// Generated by purs version 0.13.5
"use strict";
var Data_Eq = require("../Data.Eq/index.js");
var Data_Ord = require("../Data.Ord/index.js");
var Data_Ordering = require("../Data.Ordering/index.js");
var Data_Show = require("../Data.Show/index.js");
var ResponseHeader = (function () {
    function ResponseHeader(value0, value1) {
        this.value0 = value0;
        this.value1 = value1;
    };
    ResponseHeader.create = function (value0) {
        return function (value1) {
            return new ResponseHeader(value0, value1);
        };
    };
    return ResponseHeader;
})();
var value = function (v) {
    return v.value1;
};
var showResponseHeader = new Data_Show.Show(function (v) {
    return "(ResponseHeader " + (Data_Show.show(Data_Show.showString)(v.value0) + (" " + (Data_Show.show(Data_Show.showString)(v.value1) + ")")));
});
var name = function (v) {
    return v.value0;
};
var eqResponseHeader = new Data_Eq.Eq(function (x) {
    return function (y) {
        return x.value0 === y.value0 && x.value1 === y.value1;
    };
});
var ordResponseHeader = new Data_Ord.Ord(function () {
    return eqResponseHeader;
}, function (x) {
    return function (y) {
        var v = Data_Ord.compare(Data_Ord.ordString)(x.value0)(y.value0);
        if (v instanceof Data_Ordering.LT) {
            return Data_Ordering.LT.value;
        };
        if (v instanceof Data_Ordering.GT) {
            return Data_Ordering.GT.value;
        };
        return Data_Ord.compare(Data_Ord.ordString)(x.value1)(y.value1);
    };
});
module.exports = {
    ResponseHeader: ResponseHeader,
    name: name,
    value: value,
    eqResponseHeader: eqResponseHeader,
    ordResponseHeader: ordResponseHeader,
    showResponseHeader: showResponseHeader
};
