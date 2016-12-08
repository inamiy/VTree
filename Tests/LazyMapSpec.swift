@testable import VTree
import Quick
import Nimble

fileprivate enum _MyMsg2: String, Message
{
    case test1, test2
}

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

                let tree = VButton<MyMsg>(handlers: [.touchUpInside : .msg1])

                let button = tree.createView { msg -> MyMsg in
                    createdMsgs.append(msg)
                    return msg
                }

                expect(createdMsgs) == [MyMsg.msg1]
                expect(updatedMsgs) == []

                button.sendActions(for: .touchUpInside)

                // NOTE: `msgMapper` in `createView()` is only invoked once.
                expect(createdMsgs) == [MyMsg.msg1]
                expect(createdMsgs) == [MyMsg.msg1]
            }

            it("using AnyVTree.map") {
                var createdMsgs = [_MyMsg2]()
                var updatedMsgs = [_MyMsg2]()

                // Handle messages sent from `VTree`.
                Messenger.shared.handler = { anyMsg in
                    guard let msg = _MyMsg2(anyMsg) else { return }
                    updatedMsgs.append(msg)
                }

                let tree = *VButton<MyMsg>(handlers: [.touchUpInside : .msg1])
                let tree2 = tree.map { _ in _MyMsg2.test2 }

                let button = tree2.createView { msg -> _MyMsg2 in
                    createdMsgs.append(msg)
                    return msg
                } as! UIButton

                expect(createdMsgs) == [_MyMsg2.test2]
                expect(updatedMsgs) == []

                button.sendActions(for: .touchUpInside)

                expect(createdMsgs) == [_MyMsg2.test2]
                expect(createdMsgs) == [_MyMsg2.test2]
            }
        #endif
    }
}
