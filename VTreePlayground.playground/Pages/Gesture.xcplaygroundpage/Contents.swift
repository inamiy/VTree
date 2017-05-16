import UIKit
import PlaygroundSupport
import VTree
import VTreeDebugger
import Flexbox
import DemoFramework

struct Model: DebuggableModel
{
    let rootSize = CGSize(width: 320, height: 480)
    let message: String
    let cursor: Cursor?

    var description: String
    {
        return message
    }

    struct Cursor
    {
        let frame: CGRect
        let backgroundColor: UIColor
    }
}

extension Model.Cursor
{
    init?(msg: Msg)
    {
        switch msg {
            case let .tap(context):
                let frame = CGRect(origin: context.location, size: .zero)
                    .insetBy(dx: -20, dy: -20)
                self = Model.Cursor(frame: frame, backgroundColor: .orange)
            case let .pan(context) where context.state == .changed:
                let frame = CGRect(origin: context.location, size: .zero)
                    .insetBy(dx: -20, dy: -20)
                self = Model.Cursor(frame: frame, backgroundColor: .green)
            default:
                return nil
        }
    }
}

func update(_ model: Model, _ msg: Msg) -> Model?
{
    print(msg)  // Warning: impure logging

    let argsString = msg.rawMessage.arguments.map { "\($0)" }.joined(separator: "\n")
    let cursor = Model.Cursor(msg: msg)

    return Model(
        message: "\(msg.rawMessage.funcName)\n\(argsString)",
        cursor: cursor
    )
}

func view(model: Model) -> VView<Msg>
{
    let rootWidth = model.rootSize.width
    let rootHeight = model.rootSize.height

    func rootView(_ children: [AnyVTree<Msg>?]) -> VView<Msg>
    {
        return VView(
            styles: .init {
                $0.frame = CGRect(x: 0, y: 0, width: rootWidth, height: rootHeight)
                $0.backgroundColor = .white
            },
            gestures: [.tap(^Msg.tap), .pan(^Msg.pan), .longPress(^Msg.longPress), .swipe(^Msg.swipe), .pinch(^Msg.pinch), .rotation(^Msg.rotation)],
            children: children.flatMap { $0 }
        )
    }

    func label(_ message: String) -> VLabel<Msg>
    {
        return VLabel(
            key: key("label"),
            text: .text(message),
            styles: .init {
                $0.frame = CGRect(x: 0, y: 40, width: rootWidth, height: 300)
                $0.backgroundColor = .clear
                $0.textAlignment = .center
                $0.font = .systemFont(ofSize: 24)
            }
        )
    }

    func noteLabel() -> VLabel<Msg>
    {
        return VLabel(
            key: key("noteLabel"),
            text: "Tap anywhere to test gesture.",
            styles: .init {
                $0.frame = CGRect(x: 0, y: 350, width: rootWidth, height: 80)
                $0.backgroundColor = .clear
                $0.textAlignment = .center
                $0.font = .systemFont(ofSize: 20)
            }
        )
    }

    func cursorView(_ cursor: Model.Cursor) -> VView<Msg>
    {
        return VView(
            key: key("cursor"),
            styles: .init {
                $0.frame = cursor.frame
                $0.backgroundColor = cursor.backgroundColor
            }
        )
    }

    return rootView([
        *label(model.message),
        *noteLabel(),
        model.cursor.map(cursorView).map(*)
    ])
}

// MARK: Main

let initial = Model(message: "Initial", cursor: nil)

//let program = Program(model: initial, update: update, view: view)
let program = Program(
    model: DebugModel(initial),
    update: debugUpdate(update),
    view: debugView(view)
)

PlaygroundPage.current.liveView = program.rootView
