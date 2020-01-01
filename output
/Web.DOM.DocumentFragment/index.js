// Generated by purs version 0.13.5
"use strict";
var Unsafe_Coerce = require("../Unsafe.Coerce/index.js");
var Web_Internal_FFI = require("../Web.Internal.FFI/index.js");
var toParentNode = Unsafe_Coerce.unsafeCoerce;
var toNonElementParentNode = Unsafe_Coerce.unsafeCoerce;
var toNode = Unsafe_Coerce.unsafeCoerce;
var toEventTarget = Unsafe_Coerce.unsafeCoerce;
var toChildNode = Unsafe_Coerce.unsafeCoerce;
var fromParentNode = Web_Internal_FFI.unsafeReadProtoTagged("DocumentFragment");
var fromNonElementParentNode = Web_Internal_FFI.unsafeReadProtoTagged("DocumentFragment");
var fromNode = Web_Internal_FFI.unsafeReadProtoTagged("DocumentFragment");
var fromEventTarget = Web_Internal_FFI.unsafeReadProtoTagged("DocumentFragment");
var fromChildNode = Web_Internal_FFI.unsafeReadProtoTagged("DocumentFragment");
module.exports = {
    fromNode: fromNode,
    fromChildNode: fromChildNode,
    fromParentNode: fromParentNode,
    fromNonElementParentNode: fromNonElementParentNode,
    fromEventTarget: fromEventTarget,
    toNode: toNode,
    toChildNode: toChildNode,
    toParentNode: toParentNode,
    toNonElementParentNode: toNonElementParentNode,
    toEventTarget: toEventTarget
};
