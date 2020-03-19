// Generating random numbers w/o GameplayKit
import Foundation

let int1 = Int.random(in: 0 ... 10)
let int2 = Int.random(in: 0 ..< 10)
let double1 = Double.random(in: 1000 ... 10000)
let float1 = Float.random(in: -100 ... 100)

/// Old-fashioned randomness
print(arc4random())
print(arc4random())
print(arc4random())
print(arc4random())

print(arc4random() % 6)
print(arc4random_uniform(6))

func RandomInt(min: Int, max: Int) -> Int {
    if max < min { return min }
    return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
}

// Generating random numbers with GameplayKit: GKRandomSource
import GameplayKit

print(GKRandomSource.sharedRandom().nextInt())
print(GKRandomSource.sharedRandom().nextInt(upperBound: 6))

// Choosing a random number source: GKARC4RandomSource and other GameplayKit options
let arc4 = GKARC4RandomSource()
arc4.nextInt(upperBound: 20)

let mersenne = GKMersenneTwisterRandomSource()
mersenne.nextInt(upperBound: 20)

arc4.dropValues(1024)

// Shaping GameplayKit random numbers: GKRandomDistribution, GKShuffledDistribution and GKGaussianDistribution
let d6 = GKRandomDistribution.d6()
d6.nextInt()

let d20 = GKRandomDistribution.d20()
d20.nextInt()

let crazy = GKRandomDistribution(lowestValue: 1, highestValue: 11539)
crazy.nextInt()

/// App crash
//let distribution = GKRandomDistribution(lowestValue: 10, highestValue: 20)
//distribution.nextInt(upperBound: 9)

let rand = GKMersenneTwisterRandomSource()
let distribution = GKRandomDistribution(randomSource: rand,
                                        lowestValue: 10,
                                        highestValue: 20)
print(distribution.nextInt())

/// Generate the numbres 1 to 6 in a random order
let shuffled = GKShuffledDistribution.d6()
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())

// Shuffling an array with GameplayKit: arrayByShufflingObjects(in:)
/// Fisher-Yates array shuffle algorithm by Nate Cook
extension Array {
    mutating func shuffle() {
        for i in 0 ..< (count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swapAt(i, j)
        }
    }
}

let lotteryBalls = [Int](1 ... 49)
let shuffledBalls = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lotteryBalls)
print(shuffledBalls[0])
print(shuffledBalls[1])
print(shuffledBalls[2])
print(shuffledBalls[3])
print(shuffledBalls[4])
print(shuffledBalls[5])

let fixedLotteryBalls = [Int]( 1 ... 49)
let fixedShuffledBalls = GKMersenneTwisterRandomSource(seed: 1001).arrayByShufflingObjects(in: fixedLotteryBalls)
print(fixedLotteryBalls[0])
print(fixedLotteryBalls[1])
print(fixedLotteryBalls[2])
print(fixedLotteryBalls[3])
print(fixedLotteryBalls[4])
print(fixedLotteryBalls[5])
