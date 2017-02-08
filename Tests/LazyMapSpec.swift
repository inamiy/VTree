@testable import VTree
import Quick
import Nimble

class LazyMapSpec: QuickSpec
{
    override func spec()
    {
        #if os(iOS) || os(tvOS)
            it("no AnyVTree.map") {
                var createdMsgs = [MyMsg]()
                var updatedMsgs = [MyMsg]()

                // Handle messages sent from `VTree`.
                Messenger.shared.handler = { anyMsg in
                    guard let msg = MyMsg(anyMsg) else { return }
                    updatedMsgs.append(msg)
                }

                let tree = VButton<MyMsg>(handlers: [.touchUpInside: .msg1])

                let button = tree.createTestView { msg -> MyMsg in
                    createdMsgs.append(msg)
                    return msg
                }

                expect(createdMsgs) == [MyMsg.msg1]
                expect(updatedMsgs) == []

                button.sendActions(for: .touchUpInside)

                // NOTE: `msgMapper` in `createView()` is only invoked once.
                expect(createdMsgs) == [MyMsg.msg1]
                expect(updatedMsgs) == [MyMsg.msg1]
            }

            it("using AnyVTree.map") {
                var createdMsgs = [MyMsg2]()
                var updatedMsgs = [MyMsg2]()

                // Handle messages sent from `VTree`.
                Messenger.shared.handler = { anyMsg in
                    guard let msg = MyMsg2(anyMsg) else { return }
                    updatedMsgs.append(msg)
                }

                let tree = *VButton<MyMsg>(handlers: [.touchUpInside: .msg1])
                let tree2 = tree.map { _ in MyMsg2.test2 }

                let button = tree2.createTestView { msg -> MyMsg2 in
                    createdMsgs.append(msg)
                    return msg
                } as! UIButton

                expect(createdMsgs) == [MyMsg2.test2]
                expect(updatedMsgs) == []

                button.sendActions(for: .touchUpInside)

                expect(createdMsgs) == [MyMsg2.test2]
                expect(updatedMsgs) == [MyMsg2.test2]
            }
        #endif
    }
}
