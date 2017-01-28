@testable import VTree
import Quick
import Nimble

class FuncBoxSpec: QuickSpec
{
    override func spec()
    {
        describe("FuncBox") {

            it("Basic") {
                let f1 = { $0 + 1 }
                let fbox1 = FuncBox(f1)

                expect(fbox1.impl(0)) == 1
                expect(fbox1.impl(1)) == 2
                expect(fbox1.impl(2)) == 3

                expect(fbox1) == fbox1

                let fbox1b = FuncBox(f1)

                expect(fbox1b) == fbox1

                let f2 = f1
                let fbox2 = FuncBox(f2)

                expect(fbox2) == fbox1

                let f3 = { $0 + 1 }     // new closure
                let fbox3 = FuncBox(f3)

                expect(fbox3) != fbox1  // NOTE: `f` and `f3` aren't same func pointer
            }

            it("Equatable works inside Array") {
                let f1 = { $0 + 1 }
                let f2 = { $0 + 1 } // new closure
                let fbox1 = FuncBox(f1)
                let fbox1b = FuncBox(f1)
                let fbox2 = FuncBox(f2)
                let arr1 = [fbox1, fbox1, fbox1b, fbox2]

                expect(arr1[0]) == arr1[0]
                expect(arr1[1]) == arr1[0]
                expect(arr1[2]) == arr1[0]
                expect(arr1[3]) != arr1[0]

                // NOTE:
                // Using raw closure inside collection will fail `_peekFunc`'s equality check.
                // For example:
                //
                // let arr2 = [f1, f1]
                // expect(_peekFunc(arr2[0]) == _peekFunc(arr2[1])).to(beFalse())
            }

            it("FuncBox.map") {
                let f1 = { $0 + 1 }
                let map1 = { $0 * 2 }
                let fbox1 = FuncBox(f1).map(map1)

                expect(fbox1.impl(0)) == 2
                expect(fbox1.impl(1)) == 4
                expect(fbox1.impl(2)) == 6

                expect(fbox1) == fbox1

                let fbox1b = FuncBox(f1).map(map1)

                expect(fbox1b) == fbox1

                let fbox1c = FuncBox(f1).map { $0 * 2 }     // new closure

                expect(fbox1c) != fbox1

                let fbox1d = FuncBox { $0 + 1 }.map(map1)  // new closure

                expect(fbox1d) != fbox1
            }

            it("FuncBox.compose") {
                let f1 = { $0 + 1 }
                let f2 = { $0 * 2 }
                let fbox1 = FuncBox(f1).compose(FuncBox(f2))

                expect(fbox1.impl(0)) == 2
                expect(fbox1.impl(1)) == 4
                expect(fbox1.impl(2)) == 6

                expect(fbox1) == fbox1

                let fbox1b = FuncBox(f1).compose(FuncBox(f2))

                expect(fbox1b) == fbox1

                let fbox1c = FuncBox(f1).compose(FuncBox { $0 * 2 })    // new closure

                expect(fbox1c) != fbox1

                let fbox1d = FuncBox { $0 + 1 }.compose(FuncBox(f2))    // new closure

                expect(fbox1d) != fbox1
            }

            describe("Hashable") {
                let f1 = { $0 + 1 }
                let f2 = { $0 * 2 }

                it("FuncBox Set should not increase when inserting existing element") {
                    var set = Set(arrayLiteral: FuncBox(f1), FuncBox(f2))
                    expect(set.count) == 2

                    set.insert(FuncBox(f1))
                    expect(set.count) == 2
                }

                it("FuncBox Sets should be equal when elements are swapped") {
                    let set = Set(arrayLiteral: FuncBox(f1), FuncBox(f2))
                    let set2 = Set(arrayLiteral: FuncBox(f2), FuncBox(f1))
                    expect(set) == set2
                }

                it("FuncBox Arrays should not be equal when elements are swapped") {
                    let array = [FuncBox(f1), FuncBox(f2)]
                    let array2 = [FuncBox(f2), FuncBox(f1)]
                    expect(array) != array2
                }
            }

        }
    }
}
