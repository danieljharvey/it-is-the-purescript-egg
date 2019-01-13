/* tslint:disable: only-arrow-functions */

import { Coords } from "../../objects/Coords";
import * as path from "../PathFinder";

import { fromJS } from "immutable";
import { Maybe } from "tsmonad";

test("Map size", function() {
  const map = [[1, 2, 5], [3, 4, 8]];
  const mapSize = path.getMapSize(map);
  expect(mapSize).toEqual({ width: 2, height: 3 });
});

test("Wraps width under", function() {
  const map = [[1, 2], [3, 4]];
  const point = new Coords({
    x: -1,
    y: 4
  });

  const expected = new Coords({
    x: 1,
    y: 0
  });

  const actual = path.wrapValue(map)(point.x, point.y);
  expect(actual).toEqual(expected);
});

test("Returns a valid map point", function() {
  const map = [[1, 2], [3, 4]];

  const value1 = path.findAdjacent(map)({ x: 0, y: 0 });
  expect(value1).toEqual(Maybe.just(1));

  const value2 = path.findAdjacent(map)({ x: 0, y: 1 });
  expect(value2).toEqual(Maybe.just(2));

  const value3 = path.findAdjacent(map)({ x: 1, y: 0 });
  expect(value3).toEqual(Maybe.just(3));

  const value4 = path.findAdjacent(map)({ x: 1, y: 1 });
  expect(value4).toEqual(Maybe.just(4));
});

test("Returns wrapped value for invalid map point", function() {
  const map = [[1, 2], [3, 4]];

  const valueFalse = path.findAdjacent(map)({ x: -1, y: 0 });
  expect(valueFalse).toEqual(Maybe.just(3));
});

test("Finds a previously used point", function() {
  const map = [[0, 0, 0], [0, 1, 0], [0, 0, 0]];

  const list = [{ x: 1, y: 0 }, { x: 0, y: 0 }];

  const point = { x: 0, y: 0 };

  const expected = [{ x: 0, y: 0 }, { x: 1, y: 0 }, { x: 0, y: 0 }];

  const actual = path.addAdjacent(map)(list)(point);

  expect(actual).toEqual(expected);
});

test("Finds an unavailable point", function() {
  const map = [[0, 1, 0], [0, 1, 0], [0, 0, 0]];

  const list = [{ x: 0, y: 0 }];

  const point = { x: 0, y: 1 };

  const expected = [];

  const actual = path.addAdjacent(map)(list)(point);

  expect(actual).toEqual(expected);
});

test("Gets rid of those duplicates", function() {
  const list = [{ x: 0, y: 1 }, { x: 0, y: 0 }, { x: 0, y: 1 }];

  const expected = false;

  const actual = path.filterDuplicates(list);

  expect(actual).toEqual(expected);
});

test("Leaves those non-duplicates", function() {
  const list = [{ x: 0, y: 1 }, { x: 0, y: 0 }, { x: 0, y: 2 }];

  const expected = true;

  const actual = path.filterDuplicates(list);

  expect(actual).toEqual(expected);
});

test("Adds to empty list", function() {
  const list = [];

  const point = { x: 1, y: 0 };

  const expected = [{ x: 1, y: 0 }];

  const actual = path.addToList(list, point);

  expect(actual).toEqual(expected);
});

test("Adds to small list", function() {
  const list = [{ x: 1, y: 0 }, { x: 0, y: 0 }];

  const point = { x: 1, y: 1 };

  const expected = [{ x: 1, y: 1 }, { x: 1, y: 0 }, { x: 0, y: 0 }];

  const actual = path.addToList(list, point);

  expect(actual).toEqual(expected);
});

test("Finds them all", function() {
  const map = [[1, 1, 1], [1, 1, 1], [1, 1, 1]];

  const point = new Coords({ x: 0, y: 0 });

  const expected = [
    new Coords({ x: 2, y: 0 }),
    new Coords({ x: 1, y: 0 }),
    new Coords({ x: 0, y: 2 }),
    new Coords({ x: 0, y: 1 })
  ];

  const actual = path.squaresAround(map)(point);

  expect(expected).toEqual(actual);
});

test("Finds one that is", function() {
  const point = { x: 0, y: 0 };

  const list = [{ x: 0, y: 0 }, { x: 1, y: 0 }];

  const found = path.isInList(list, point);

  expect(found).toEqual(true);
});

test("Finds one that isn't", function() {
  const point = { x: 4, y: 0 };

  const list = [{ x: 0, y: 0 }, { x: 1, y: 0 }];

  const found = path.isInList(list, point);

  expect(found).toEqual(false);
});

test("Finds only option from starting point", function() {
  const map = [
    [0, 1, 0, 0, 1],
    [0, 1, 1, 1, 1],
    [0, 1, 0, 0, 1],
    [0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1]
  ];

  const list = [new Coords({ x: 0, y: 0 })];

  const expected = [[new Coords({ x: 1, y: 0 }), new Coords({ x: 0, y: 0 })]];

  const actual = path.getMoveOptions(map)(list);

  expect(actual).toEqual(expected);
});

test("Doesn't go back on itself", function() {
  const map = [
    [0, 1, 0, 0, 1],
    [0, 1, 1, 1, 1],
    [0, 1, 0, 0, 1],
    [0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1]
  ];

  const list = [new Coords({ x: 1, y: 0 }), new Coords({ x: 0, y: 0 })];

  const expected = [
    [
      new Coords({ x: 2, y: 0 }),
      new Coords({ x: 1, y: 0 }),
      new Coords({ x: 0, y: 0 })
    ]
  ];

  const actual = path.getMoveOptions(map)(list);

  expect(actual).toEqual(expected);
});

test("Returns multiple options", function() {
  const map = [[false, true], [false, true], [false, true]];

  const list = [new Coords({ x: 1, y: 0 })];

  const expected = [
    [new Coords({ x: 0, y: 0 }), new Coords({ x: 1, y: 0 })],
    [new Coords({ x: 2, y: 0 }), new Coords({ x: 1, y: 0 })]
  ];

  const actual = path.getMoveOptions(map)(list);

  expect(actual).toEqual(expected);
});

it("Finds one", function() {
  const target = { x: 2, y: 2 };

  const list = [
    [{ x: 1, y: 2 }, { x: 3, y: 4 }],
    [{ x: 2, y: 1 }, { x: 3, y: 4 }],
    [{ x: 1, y: 2 }, { x: 3, y: 4 }],
    [{ x: 2, y: 2 }, { x: 3, y: 4 }]
  ];

  const expected = Maybe.just([{ x: 2, y: 2 }, { x: 3, y: 4 }]);

  const actual = path.findAnswerInList(target)(list);

  expect(actual).toEqual(expected);
});

it("Finds nothing", function() {
  const target = { x: 7, y: 9 };

  const list = [
    [{ x: 1, y: 2 }, { x: 3, y: 4 }],
    [{ x: 2, y: 1 }, { x: 3, y: 4 }],
    [{ x: 1, y: 2 }, { x: 3, y: 4 }],
    [{ x: 2, y: 2 }, { x: 3, y: 4 }]
  ];

  const expected = Maybe.nothing();

  const actual = path.findAnswerInList(target)(list);

  expect(actual).toEqual(expected);
});

it("Very quickly fails", function() {
  const map = [
    [0, 1, 0, 0, 1],
    [1, 1, 1, 1, 1],
    [0, 1, 0, 0, 1],
    [0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1]
  ];

  const start = { x: 0, y: 0 };

  const end = { x: 2, y: 2 };

  const expected = Maybe.nothing();

  const startList = [[start]];

  const actual = path.processMoveList(map)(startList)(end);

  expect(actual).toEqual(expected);
});

it("Very quickly wins", function() {
  const map = [[false, true, true], [false, true, true], [true, true, true]];

  const start = new Coords({ x: 0, y: 0 });

  const end = new Coords({ x: 1, y: 0 });

  const expected = Maybe.just([
    new Coords({ x: 0, y: 0 }),
    new Coords({ x: 1, y: 0 })
  ]);

  const startList = [[start]];

  const actual = path.processMoveList(map)(startList)(end);

  expect(actual).toEqual(expected);
});

it("Wins I suppose", function() {
  const map = [
    [0, 0, 0, 0, 1],
    [0, 1, 1, 1, 1],
    [0, 1, 0, 0, 1],
    [0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1]
  ];

  const start = new Coords({ x: 0, y: 0 });

  const end = new Coords({ x: 2, y: 2 });

  const expected = Maybe.just([
    new Coords({ x: 0, y: 0 }),
    new Coords({ x: 1, y: 0 }),
    new Coords({ x: 2, y: 0 }),
    new Coords({ x: 3, y: 0 }),
    new Coords({ x: 3, y: 1 }),
    new Coords({ x: 3, y: 2 }),
    new Coords({ x: 2, y: 2 })
  ]);

  const startList = [[start]];

  const actual = path.processMoveList(map)(startList)(end);

  expect(actual).toEqual(expected);
});

it("Wins another map", function() {
  const map = [[0, 0, 0, 1], [1, 1, 0, 1], [0, 0, 0, 1], [1, 1, 1, 1]];

  const start = new Coords({ x: 2, y: 0 });

  const end = new Coords({ x: 0, y: 0 });

  const expected = Maybe.just([
    new Coords({ x: 2, y: 0 }),
    new Coords({ x: 2, y: 1 }),
    new Coords({ x: 2, y: 2 }),
    new Coords({ x: 1, y: 2 }),
    new Coords({ x: 0, y: 2 }),
    new Coords({ x: 0, y: 1 }),
    new Coords({ x: 0, y: 0 })
  ]);

  const startList = [[start]];

  const actual = path.processMoveList(map)(startList)(end);

  expect(actual).toEqual(expected);
});

it("Wins a silly map", function() {
  const map = [
    [0, 0, 0, 1],
    [1, 1, 0, 1],
    [0, 0, 0, 1],
    [0, 1, 1, 1],
    [0, 0, 0, 1],
    [1, 1, 0, 1],
    [0, 0, 0, 1],
    [0, 1, 1, 1],
    [0, 1, 0, 1],
    [0, 0, 0, 1],
    [0, 1, 0, 1],
    [1, 1, 0, 0],
    [1, 1, 1, 1]
  ];

  const start = new Coords({ x: 0, y: 0 });

  const end = new Coords({ x: 11, y: 3 });

  const expectedLength = 23;

  const startList = [[start]];

  const actual = path.processMoveList(map)(startList)(end);

  const value = actual.caseOf({
    just: val => val,
    nothing: () => []
  });

  expect(value.length).toEqual(expectedLength);
});

it("Finds the easier path", function() {
  const map = [
    [true, true, true, true, true, true, true],
    [true, false, false, false, false, false, true],
    [true, true, true, true, true, true, true]
  ];

  const start = new Coords({ x: 2, y: 1 });

  const ends = fromJS([
    new Coords({ x: 5, y: 1 }),
    new Coords({ x: 1, y: 1 }), // closer
    new Coords({ x: 2, y: 1 }) // need to ignore this one
  ]);

  const expected = [new Coords({ x: 2, y: 1 }), new Coords({ x: 1, y: 1 })];

  const actual = path.findClosestPath(map)(start)(ends);

  const value = actual.caseOf({
    just: val => val,
    nothing: () => []
  });

  expect(value).toEqual(expected);
});

it("Takes path and works out next move", function() {
  const pointList = [
    new Coords({ x: 2, y: 2 }),
    new Coords({ x: 3, y: 2 }),
    new Coords({ x: 4, y: 2 })
  ];

  const expected = new Coords({ x: 1, y: 0 });

  const actual = path.findNextDirection(pointList);

  expect(actual).toEqual(expected);
});

it("Takes path and works out X-axis move across edges", function() {
  // this is jump from right to left
  const pointList = [new Coords({ x: 4, y: 2 }), new Coords({ x: 0, y: 2 })];

  const expected = new Coords({ x: 1, y: 0 });

  const actual = path.findNextDirection(pointList);

  expect(actual).toEqual(expected);
});

it("Takes path and works out Y-axis move across edges", function() {
  // this is jump from bottom to top
  const pointList = [new Coords({ x: 3, y: 0 }), new Coords({ x: 3, y: 4 })];

  const expected = new Coords({ x: 0, y: -1 });

  const actual = path.findNextDirection(pointList);

  expect(actual).toEqual(expected);
});

it("Don't bother looking for itself", function() {
  const map = [
    [true, true, true, true],
    [true, false, false, true],
    [true, true, true, true]
  ];

  const start = new Coords({ x: 1, y: 1 });

  const target = new Coords({ x: 1, y: 1 });

  const expected = Maybe.nothing();

  const actual = path.findPath(map)(start)(target);

  expect(actual).toEqual(expected);
});

it("Deals with stuff from actual game", function() {
  const map = [
    [
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false
    ],
    [
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      true
    ],
    [
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      false,
      false
    ],
    [
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      true,
      true,
      true
    ],
    [
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      false,
      false,
      false,
      false
    ],
    [
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      true,
      true,
      true,
      true,
      true
    ],
    [
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    [
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true
    ],
    [
      false,
      true,
      false,
      true,
      false,
      true,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    [
      false,
      true,
      false,
      true,
      false,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true
    ],
    [
      false,
      true,
      false,
      true,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    [
      false,
      true,
      false,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true
    ],
    [
      false,
      true,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    [
      false,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ]
  ];
  const start = new Coords({ x: 0, y: 12, offsetX: 0, offsetY: 0 });
  const targets = fromJS([
    new Coords({ x: 0, y: 12, offsetX: 0, offsetY: 0 }),
    new Coords({ x: 7, y: 0, offsetX: 0, offsetY: 0 })
  ]);

  const actual = path.findClosestPath(map)(start)(targets);

  const value = actual.caseOf({
    just: val => val,
    nothing: () => false
  });

  expect(value.length).toEqual(11);
});

it("Uses a really big map and doesn't timeout", function(done) {
  const map = [
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    [
      false,
      true,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    [
      false,
      true,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      true,
      false,
      false,
      false,
      false,
      false,
      false,
      true,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      true,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      true,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      true,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      true,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      true,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      true,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      true,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      true,
      false,
      false,
      false,
      false
    ],
    [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      true,
      false,
      false,
      false,
      false
    ]
  ];

  const start = new Coords({ x: 2, y: 2 });

  const targets = fromJS([new Coords({ x: 9, y: 6 })]);

  const actual = path.findClosestPath(map)(start)(targets);

  const value = actual.caseOf({
    just: val => {
      return val;
    },
    nothing: () => false
  });

  expect(value.length).toEqual(12);

  done();
});
