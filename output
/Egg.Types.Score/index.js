// Generated by purs version 0.13.5
"use strict";
var Data_Eq = require("../Data.Eq/index.js");
var Data_Ord = require("../Data.Ord/index.js");
var Data_Semiring = require("../Data.Semiring/index.js");
var Data_Show = require("../Data.Show/index.js");
var Score = function (x) {
    return x;
};
var showScore = Data_Show.showInt;
var semiringScore = Data_Semiring.semiringInt;
var ordScore = Data_Ord.ordInt;
var eqScore = Data_Eq.eqInt;
module.exports = {
    Score: Score,
    showScore: showScore,
    eqScore: eqScore,
    ordScore: ordScore,
    semiringScore: semiringScore
};
