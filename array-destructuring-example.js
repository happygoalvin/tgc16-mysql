function fruitBar() {
    return ['mangosteen', 'pears', 'oranges', 'kiwi']
}

let fruits = ['apples', 'bananas', 'durians', 'pineapples']

// without array destructuring
let f1 = fruits[0];
let f2 = fruits[1];
let f3 = fruits[2];

// with array destructuring
let [g1, g2, g3] = fruits;
console.log(g1, g2, g3)

let [m1, m2] = fruitBar();
console.log(m1, m2)