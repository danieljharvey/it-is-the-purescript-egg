// Generated by purs version 0.13.5
"use strict";
var Control_Applicative = require("../Control.Applicative/index.js");
var Control_Monad_Writer_Trans = require("../Control.Monad.Writer.Trans/index.js");
var Data_Identity = require("../Data.Identity/index.js");
var Data_Newtype = require("../Data.Newtype/index.js");
var Data_Tuple = require("../Data.Tuple/index.js");
var writer = (function () {
    var $0 = Control_Applicative.pure(Data_Identity.applicativeIdentity);
    return function ($1) {
        return Control_Monad_Writer_Trans.WriterT($0($1));
    };
})();
var runWriter = (function () {
    var $2 = Data_Newtype.unwrap(Data_Identity.newtypeIdentity);
    return function ($3) {
        return $2(Control_Monad_Writer_Trans.runWriterT($3));
    };
})();
var mapWriter = function (f) {
    return Control_Monad_Writer_Trans.mapWriterT((function () {
        var $4 = Data_Newtype.unwrap(Data_Identity.newtypeIdentity);
        return function ($5) {
            return Data_Identity.Identity(f($4($5)));
        };
    })());
};
var execWriter = function (m) {
    return Data_Tuple.snd(runWriter(m));
};
module.exports = {
    writer: writer,
    runWriter: runWriter,
    execWriter: execWriter,
    mapWriter: mapWriter
};
