// Generated by purs version 0.13.5
"use strict";
var Control_Bind = require("../Control.Bind/index.js");
var Data_Array = require("../Data.Array/index.js");
var Data_Functor = require("../Data.Functor/index.js");
var Data_Map_Internal = require("../Data.Map.Internal/index.js");
var Data_Maybe = require("../Data.Maybe/index.js");
var Egg_Data_PlayerTypes = require("../Egg.Data.PlayerTypes/index.js");
var Egg_Types_Coord = require("../Egg.Types.Coord/index.js");
var Egg_Types_CurrentFrame = require("../Egg.Types.CurrentFrame/index.js");
var Egg_Types_PlayerType = require("../Egg.Types.PlayerType/index.js");
var Matrix = require("../Matrix/index.js");
var getPlayerTypeByKind = function (playerKind) {
    return Data_Map_Internal.lookup(Egg_Types_PlayerType.ordPlayerKind)(playerKind)(Egg_Data_PlayerTypes.playerTypes);
};
var createPlayer = function (i) {
    return function (coord) {
        return function (playerType) {
            return {
                playerType: playerType,
                coords: coord,
                direction: Egg_Types_Coord.createCoord(1)(0),
                oldDirection: Egg_Types_Coord.createCoord(0)(0),
                currentFrame: Egg_Types_CurrentFrame.createCurrentFrame(playerType.frames),
                id: i,
                falling: false,
                stop: false,
                lastAction: Data_Maybe.Nothing.value,
                moved: false
            };
        };
    };
};
var createPlayerFromTile = function (i) {
    return function (renderItem) {
        var playerType = Control_Bind.bind(Data_Maybe.bindMaybe)(renderItem.value.createPlayer)(getPlayerTypeByKind);
        var coord = Egg_Types_Coord.createCoord(renderItem.x)(renderItem.y);
        return Data_Functor.map(Data_Maybe.functorMaybe)(createPlayer(i)(coord))(playerType);
    };
};
var getPlayersFromBoard = function (board) {
    var tiles = Matrix.toIndexedArray(board);
    return Data_Array.catMaybes(Data_Array.mapWithIndex(createPlayerFromTile)(tiles));
};
var changePlayerKind = function (player) {
    return function (playerKind) {
        var newPlayer = Data_Functor.map(Data_Maybe.functorMaybe)(function (playerType$prime) {
            return {
                playerType: playerType$prime,
                coords: player.coords,
                currentFrame: player.currentFrame,
                direction: player.direction,
                falling: player.falling,
                id: player.id,
                lastAction: player.lastAction,
                moved: player.moved,
                oldDirection: player.oldDirection,
                stop: player.stop
            };
        })(getPlayerTypeByKind(playerKind));
        return Data_Maybe.fromMaybe(player)(newPlayer);
    };
};
module.exports = {
    getPlayersFromBoard: getPlayersFromBoard,
    getPlayerTypeByKind: getPlayerTypeByKind,
    createPlayerFromTile: createPlayerFromTile,
    changePlayerKind: changePlayerKind,
    createPlayer: createPlayer
};
