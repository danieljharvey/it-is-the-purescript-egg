// Generated by purs version 0.13.5
"use strict";
var Data_Array = require("../Data.Array/index.js");
var Data_Foldable = require("../Data.Foldable/index.js");
var Data_Functor = require("../Data.Functor/index.js");
var Data_Maybe = require("../Data.Maybe/index.js");
var Egg_Logic_Action = require("../Egg.Logic.Action/index.js");
var Egg_Logic_Board = require("../Egg.Logic.Board/index.js");
var Egg_Logic_Collisions = require("../Egg.Logic.Collisions/index.js");
var Egg_Logic_CreatePlayers = require("../Egg.Logic.CreatePlayers/index.js");
var Egg_Logic_Map = require("../Egg.Logic.Map/index.js");
var Egg_Logic_Movement = require("../Egg.Logic.Movement/index.js");
var Egg_Types_Action = require("../Egg.Types.Action/index.js");
var Egg_Types_Clockwise = require("../Egg.Types.Clockwise/index.js");
var Egg_Types_InputEvent = require("../Egg.Types.InputEvent/index.js");
var Egg_Types_Outcome = require("../Egg.Types.Outcome/index.js");
var Egg_Types_PlayerType = require("../Egg.Types.PlayerType/index.js");
var Egg_Types_ScreenSize = require("../Egg.Types.ScreenSize/index.js");
var Egg_Types_TileAction = require("../Egg.Types.TileAction/index.js");
var Matrix = require("../Matrix/index.js");
var toCollectableScore = function (tile) {
    if (tile.action instanceof Egg_Types_TileAction.Collectable) {
        return tile.action.value0;
    };
    return 0;
};
var spinSpeed = 3;
var setAction = function (action) {
    return function (old) {
        return {
            players: old.players,
            board: old.board,
            score: old.score,
            rotations: old.rotations,
            rotateAngle: old.rotateAngle,
            renderAngle: old.renderAngle,
            outcome: old.outcome,
            turns: old.turns,
            current: action,
            screenSize: old.screenSize
        };
    };
};
var resizeBoard = function (width) {
    return function (height) {
        return function (oldAction) {
            return function (gs) {
                return {
                    players: gs.players,
                    board: gs.board,
                    score: gs.score,
                    rotations: gs.rotations,
                    rotateAngle: gs.rotateAngle,
                    renderAngle: gs.renderAngle,
                    outcome: gs.outcome,
                    turns: gs.turns,
                    current: oldAction,
                    screenSize: Egg_Types_ScreenSize.screenSize(width)(height)
                };
            };
        };
    };
};
var resetOutcome = function (gs) {
    return {
        players: gs.players,
        board: gs.board,
        score: gs.score,
        rotations: gs.rotations,
        rotateAngle: gs.rotateAngle,
        renderAngle: gs.renderAngle,
        outcome: Egg_Types_Outcome.KeepPlaying.value,
        turns: gs.turns,
        current: gs.current,
        screenSize: gs.screenSize
    };
};
var isPlayableEgg = function (a) {
    return Egg_Types_PlayerType.playerValue(a.playerType.type_) > 0;
};
var incrementTurnCount = function (gameState) {
    var next = gameState.turns + 1 | 0;
    return {
        players: gameState.players,
        board: gameState.board,
        score: gameState.score,
        rotations: gameState.rotations,
        rotateAngle: gameState.rotateAngle,
        renderAngle: gameState.renderAngle,
        outcome: gameState.outcome,
        turns: next,
        current: gameState.current,
        screenSize: gameState.screenSize
    };
};
var doTurn = function (clockwise) {
    return function (angle) {
        return function (gs) {
            var next = new Egg_Types_Action.Turning(clockwise, angle + spinSpeed | 0);
            if (clockwise instanceof Egg_Types_Clockwise.Clockwise) {
                return {
                    players: gs.players,
                    board: gs.board,
                    score: gs.score,
                    rotations: gs.rotations,
                    rotateAngle: gs.rotateAngle,
                    renderAngle: angle,
                    outcome: gs.outcome,
                    turns: gs.turns,
                    current: next,
                    screenSize: gs.screenSize
                };
            };
            if (clockwise instanceof Egg_Types_Clockwise.AntiClockwise) {
                return {
                    players: gs.players,
                    board: gs.board,
                    score: gs.score,
                    rotations: gs.rotations,
                    rotateAngle: gs.rotateAngle,
                    renderAngle: (-1 | 0) * angle | 0,
                    outcome: gs.outcome,
                    turns: gs.turns,
                    current: next,
                    screenSize: gs.screenSize
                };
            };
            throw new Error("Failed pattern match at Egg.Logic.TakeTurn (line 96, column 29 - line 106, column 8): " + [ clockwise.constructor.name ]);
        };
    };
};
var doRotate = function (gameState) {
    return function (clockwise) {
        var boardSize = Egg_Logic_Board.boardSizeFromBoard(gameState.board);
        return {
            players: Data_Functor.map(Data_Functor.functorArray)(Egg_Logic_Map.rotatePlayer(boardSize)(clockwise))(gameState.players),
            board: Egg_Logic_Map.rotateBoard(clockwise)(gameState.board),
            score: gameState.score,
            rotations: gameState.rotations + 1 | 0,
            rotateAngle: Egg_Logic_Map.changeRenderAngle(gameState.rotateAngle)(clockwise),
            renderAngle: 0,
            outcome: gameState.outcome,
            turns: gameState.turns,
            current: Egg_Types_Action.Playing.value,
            screenSize: gameState.screenSize
        };
    };
};
var doPlayerMove = function (i) {
    return function (old) {
        var newPlayers = Egg_Logic_Movement.movePlayers(old.board)(i)(old.players);
        return {
            players: newPlayers,
            board: old.board,
            score: old.score,
            rotations: old.rotations,
            rotateAngle: old.rotateAngle,
            renderAngle: old.renderAngle,
            outcome: old.outcome,
            turns: old.turns,
            current: old.current,
            screenSize: old.screenSize
        };
    };
};
var countPlayers = (function () {
    var $42 = Data_Array.filter(isPlayableEgg);
    return function ($43) {
        return Data_Array.length($42($43));
    };
})();
var countCollectables = function (board) {
    return Data_Foldable.foldr(Data_Foldable.foldableArray)(function (a) {
        return function (total) {
            return total + toCollectableScore(a.value) | 0;
        };
    })(0)(Matrix.toIndexedArray(board));
};
var isLevelDone = function (gameState) {
    return countPlayers(gameState.players) < 2 && countCollectables(gameState.board) < 1;
};
var checkIfWeveCompletedTheLevel = function (gs) {
    if (gs.outcome instanceof Egg_Types_Outcome.KeepPlaying) {
        return new Data_Maybe.Just(gs);
    };
    if (gs.outcome instanceof Egg_Types_Outcome.BackAtTheEggCup) {
        var $18 = isLevelDone(gs);
        if ($18) {
            return Data_Maybe.Nothing.value;
        };
        return new Data_Maybe.Just(gs);
    };
    throw new Error("Failed pattern match at Egg.Logic.TakeTurn (line 132, column 35 - line 138, column 14): " + [ gs.outcome.constructor.name ]);
};
var checkCollisions = function (old) {
    return {
        players: Egg_Logic_Collisions.checkAllCollisions(old.players),
        board: old.board,
        score: old.score,
        rotations: old.rotations,
        rotateAngle: old.rotateAngle,
        renderAngle: old.renderAngle,
        outcome: old.outcome,
        turns: old.turns,
        current: old.current,
        screenSize: old.screenSize
    };
};
var changeToRainbowEgg = function (player) {
    var $19 = isPlayableEgg(player);
    if ($19) {
        return Egg_Logic_CreatePlayers.changePlayerKind(player)(Egg_Types_PlayerType.RainbowEgg.value);
    };
    return player;
};
var checkNearlyFinished = function (gameState) {
    var $20 = isLevelDone(gameState);
    if ($20) {
        return {
            players: Data_Functor.map(Data_Functor.functorArray)(changeToRainbowEgg)(gameState.players),
            board: gameState.board,
            score: gameState.score,
            rotations: gameState.rotations,
            rotateAngle: gameState.rotateAngle,
            renderAngle: gameState.renderAngle,
            outcome: gameState.outcome,
            turns: gameState.turns,
            current: gameState.current,
            screenSize: gameState.screenSize
        };
    };
    return gameState;
};
var doGameMove = function (i) {
    var $44 = doPlayerMove(i);
    return function ($45) {
        return checkIfWeveCompletedTheLevel(Egg_Logic_Action.checkAllActions(checkNearlyFinished($44(checkCollisions(incrementTurnCount(resetOutcome($45)))))));
    };
};
var doAction = function (old) {
    return function (v) {
        return function (v1) {
            if (v instanceof Egg_Types_Action.Paused) {
                return new Data_Maybe.Just(old);
            };
            if (v instanceof Egg_Types_Action.Playing && v1 >= 1) {
                return doGameMove(v1)(old);
            };
            if (v instanceof Egg_Types_Action.Playing) {
                return new Data_Maybe.Just(old);
            };
            if (v instanceof Egg_Types_Action.Turning && v.value1 >= 90) {
                return Data_Maybe.Just.create(doRotate(old)(v.value0));
            };
            if (v instanceof Egg_Types_Action.Turning) {
                return Data_Maybe.Just.create(doTurn(v.value0)(v.value1)(old));
            };
            if (v instanceof Egg_Types_Action.Resize) {
                return Data_Maybe.Just.create(resizeBoard(v.value0)(v.value1)(v.value2)(old));
            };
            throw new Error("Failed pattern match at Egg.Logic.TakeTurn (line 52, column 1 - line 52, column 58): " + [ old.constructor.name, v.constructor.name, v1.constructor.name ]);
        };
    };
};
var calcNextAction = function (v) {
    return function (v1) {
        if (v instanceof Egg_Types_Action.Turning) {
            return new Egg_Types_Action.Turning(v.value0, v.value1);
        };
        if (v instanceof Egg_Types_Action.Playing && (v1 instanceof Data_Maybe.Just && v1.value0 instanceof Egg_Types_InputEvent.Pause)) {
            return Egg_Types_Action.Paused.value;
        };
        if (v instanceof Egg_Types_Action.Paused && (v1 instanceof Data_Maybe.Just && v1.value0 instanceof Egg_Types_InputEvent.Pause)) {
            return Egg_Types_Action.Playing.value;
        };
        if (v instanceof Egg_Types_Action.Playing && (v1 instanceof Data_Maybe.Just && v1.value0 instanceof Egg_Types_InputEvent.LeftArrow)) {
            return new Egg_Types_Action.Turning(Egg_Types_Clockwise.AntiClockwise.value, 0);
        };
        if (v instanceof Egg_Types_Action.Playing && (v1 instanceof Data_Maybe.Just && v1.value0 instanceof Egg_Types_InputEvent.RightArrow)) {
            return new Egg_Types_Action.Turning(Egg_Types_Clockwise.Clockwise.value, 0);
        };
        if (v1 instanceof Data_Maybe.Just && v1.value0 instanceof Egg_Types_InputEvent.ResizeWindow) {
            return new Egg_Types_Action.Resize(v1.value0.value0, v1.value0.value1, v);
        };
        return v;
    };
};
var go = function (i) {
    return function (input) {
        return function (gs) {
            var nextAction = calcNextAction(gs.current)(input);
            var gameState = setAction(nextAction)(gs);
            return doAction(gameState)(nextAction)(i);
        };
    };
};
module.exports = {
    spinSpeed: spinSpeed,
    go: go,
    calcNextAction: calcNextAction,
    doAction: doAction,
    resizeBoard: resizeBoard,
    incrementTurnCount: incrementTurnCount,
    doGameMove: doGameMove,
    checkCollisions: checkCollisions,
    setAction: setAction,
    doTurn: doTurn,
    doPlayerMove: doPlayerMove,
    doRotate: doRotate,
    resetOutcome: resetOutcome,
    checkIfWeveCompletedTheLevel: checkIfWeveCompletedTheLevel,
    checkNearlyFinished: checkNearlyFinished,
    changeToRainbowEgg: changeToRainbowEgg,
    isLevelDone: isLevelDone,
    isPlayableEgg: isPlayableEgg,
    countPlayers: countPlayers,
    countCollectables: countCollectables,
    toCollectableScore: toCollectableScore
};
