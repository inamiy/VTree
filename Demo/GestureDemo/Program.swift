import UIKit
import VTree

/// Complex `Message` type that has associated values.
/// - Important: See `VTree.Message` comment documentation for more detail.
public enum Msg: AutoMessage
{
    case increment
    case decrement
    case tap(GestureContext)
    case pan(PanGestureContext)
    case longPress(GestureContext)
    case swipe(GestureContext)
    case pinch(PinchGestureContext)
    case rotation(RotationGestureContext)

    case dummy(DummyContext)
}

/// Custom `MessageContext` that is recognizable in Sourcery.
public struct DummyContext: AutoMessageContext
{
}

/// Naive VTree renderer & event handler.
public final class Program
{
    public private(set) var count: Int = 0
    public private(set) var rootView: View?

    private var rootTree: VView<Msg>?

    public init()
    {
        let initialTree = self.createTree(state: count)
        let initialView = initialTree.createView()

        self.rootTree = initialTree
        self.rootView = initialView

        // Handle messages sent from `VTree`.
        Messenger.shared.handler = { [weak self] anyMsg in
            guard let msg = Msg(anyMsg) else {
                print("Failed to convert anyMsg = \(anyMsg)")
                return
            }
            switch msg {
                case .increment:
                    self?.onIncrement()
                case .decrement:
                    self?.onDecrement()
                default:
                    print("gesture = \(msg)")
            }
        }
    }

    // MARK: VTree

    private func createTree(state: Int) -> VView<Msg>
    {
        let rootWidth = UIScreen.main.bounds.width
        let rootHeight = UIScreen.main.bounds.height

        let space: CGFloat = 20
        let buttonWidth = (rootWidth - space*3)/2

        func rootView(_ children: [AnyVTree<Msg>]) -> VView<Msg>
        {
            return VView(
                frame: CGRect(x: 0, y: 0, width: rootWidth, height: rootHeight),
                backgroundColor: .white,
                gestures: [.tap(^Msg.tap), .pan(^Msg.pan), .longPress(^Msg.longPress), .swipe(^Msg.swipe), .pinch(^Msg.pinch), .rotation(^Msg.rotation)],
                children: children
            )
        }

        func label(_ state: Int) -> VLabel<Msg>
        {
            return VLabel(
                frame: CGRect(x: 0, y: 40, width: rootWidth, height: 80),
                backgroundColor: .clear,
                text: "\(state)",
                textAlignment: .center,
                font: .systemFont(ofSize: 48)
            )
        }

        func incrementButton() -> VButton<Msg>
        {
            return VButton(
                frame: CGRect(x: rootWidth/2 + space/2, y: 150, width: buttonWidth, height: 50),
                backgroundColor: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1),
                title: "+",
                font: .systemFont(ofSize: 24),
                handlers: [.touchUpInside: .increment]
            )
        }

        func decrementButton() -> VButton<Msg>
        {
            return VButton(
                frame: CGRect(x: space, y: 150, width: buttonWidth, height: 50),
                backgroundColor: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1),
                title: "-",
                font: .systemFont(ofSize: 24),
                handlers: [.touchUpInside: .decrement]
            )
        }

        func noteLabel() -> VLabel<Msg>
        {
            return VLabel(
                frame: CGRect(x: 0, y: 200, width: rootWidth, height: 80),
                backgroundColor: .clear,
                text: "Tap anywhere to test gesture.",
                textAlignment: .center,
                font: .systemFont(ofSize: 24)
            )
        }

        return rootView([
            *label(state),
            *incrementButton(),
            *decrementButton(),
            *noteLabel()
        ])
    }

    // MARK: Event handling

    private func onDecrement()
    {
        print("-1")
        self.count -= 1
        self.rerender()
    }

    private func onIncrement()
    {
        print("+1")
        self.count += 1
        self.rerender()
    }

    // MARK: Re-render

    private func rerender()
    {
        print(#function, "count = \(count)")

        let oldTree = self.rootTree!

        // createTree: State -> VTree
        let newTree = self.createTree(state: count)

        // diff: VTree -> VTree -> Patch
        let patch = diff(old: oldTree, new: newTree)
        print("patch =", patch)

        // apply: Patch -> View -> IO View
        let newView = apply(patch: patch, to: self.rootView!)

        self.rootView = newView
        self.rootTree = newTree
    }
}
