require("hammerjs");

function setupSwipesActual(elementId, swipeLeftFn, swipeRightFn) {
  console.log("setupSwipesActual", elementId, swipeLeftFn, swipeRightFn);
  const element = document.getElementById(elementId);
  const hammertime = new Hammer(element, {});
  hammertime.on("swipeleft", function() {
    console.log("left!");
    swipeLeftFn();
  });
  hammertime.on("swiperight", function() {
    console.log("right!");
    swipeRightFn();
  });
}

exports.setupSwipes = setupSwipesActual;
