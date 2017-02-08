import UIKit
import PlaygroundSupport
import VTree
import Flexbox

struct Model
{
    let rootSize = CGSize(width: 320, height: 480)
    let message: String
}

func update(_ model: Model, _ msg: Msg) -> Model
{
    print(msg)  // Warning: impure logging

    let argsString = msg.rawValue.arguments.map { "\($0)" }.joined(separator: "\n")
    return Model(message: "\(msg.rawValue.funcName)\n\(argsString)")
}

func view(model: Model) -> VView<Msg>
{
    let rootWidth = model.rootSize.width
    let rootHeight = model.rootSize.height

    func rootView(_ children: [AnyVTree<Msg>]) -> VView<Msg>
    {
        return VView(
            frame: CGRect(x: 0, y: 0, width: rootWidth, height: rootHeight),
            backgroundColor: .white,
            gestures: [.tap(^Msg.tap), .pan(^Msg.pan), .longPress(^Msg.longPress), .swipe(^Msg.swipe), .pinch(^Msg.pinch), .rotation(^Msg.rotation)],
            children: children
        )
    }

    func label(_ message: String) -> VLabel<Msg>
    {
        return VLabel(
            frame: CGRect(x: 0, y: 40, width: rootWidth, height: 300),
            backgroundColor: .clear,
            text: message,
            textAlignment: .center,
            font: .systemFont(ofSize: 24)
        )
    }

    func noteLabel() -> VLabel<Msg>
    {
        return VLabel(
            frame: CGRect(x: 0, y: 350, width: rootWidth, height: 80),
            backgroundColor: .clear,
            text: "Tap anywhere to test gesture.",
            textAlignment: .center,
            font: .systemFont(ofSize: 20)
        )
    }

    return rootView([
        *label(model.message),
        *noteLabel()
    ])
}

let model = Model(message: "Initial")

let program = Program(model: model, update: update, view: view, debug: false)

PlaygroundPage.current.liveView = program.rootView
