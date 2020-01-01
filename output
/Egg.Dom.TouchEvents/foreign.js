require("hammerjs");

function setupSwipesActual(elementId, swipeLeftFn, swipeRightFn) {
  const element = document.getElementById(elementId);
  const hammertime = new Hammer(element, {});
  hammertime.on("swipeleft", function () {
    swipeLeftFn();
  });
  hammertime.on("swiperight", function () {
    swipeRightFn();
  });
}

exports.setupSwipes = setupSwipesActual;
