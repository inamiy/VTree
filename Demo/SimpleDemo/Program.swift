import UIKit
import VTree

/// Simple `Message` type (String RawRepresentable).
public enum Msg: String, Message
{
    case increment
    case decrement
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
            guard let msg = Msg(anyMsg) else { return }
            switch msg {
                case .increment:
                    self?.onIncrement()
                case .decrement:
                    self?.onDecrement()
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
                children: children
            )
        }

        func label(_ state: Int) -> VLabel<Msg>
        {
            return VLabel(
                frame: CGRect(x: 0, y: 40, width: rootWidth, height: 80),
                backgroundColor: .clear,
                font: .systemFont(ofSize: 48),
                text: "\(state)",
                textAlignment: .center
            )
        }

        func incrementButton() -> VButton<Msg>
        {
            return VButton(
                frame: CGRect(x: rootWidth/2 + space/2, y: 150, width: buttonWidth, height: 50),
                backgroundColor: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1),
                title: "+",
                titleFont: .systemFont(ofSize: 24),
                handlers: [.touchUpInside: .increment]
            )
        }

        func decrementButton() -> VButton<Msg>
        {
            return VButton(
                frame: CGRect(x: space, y: 150, width: buttonWidth, height: 50),
                backgroundColor: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1),
                title: "-",
                titleFont: .systemFont(ofSize: 24),
                handlers: [.touchUpInside: .decrement]
            )
        }

        func testView(_ state: Int) -> VButton<Msg>
        {
            let alpha = 0.6 + 0.4 * sin(CGFloat(state) * 2 * .pi / 10)
            let fontSize = max(0, state)
            let height = CGFloat(50 + max(0, state))

            return VButton(
                frame: CGRect(x: space, y: 250, width: rootWidth-2*space, height: height),
                backgroundColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),
                alpha: alpha,
                title: "Font \(fontSize)pt",
                titleColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1).withAlphaComponent(1.2 - alpha),
                titleFont: .systemFont(ofSize: CGFloat(fontSize))
            )
        }

        return rootView([
            *label(state),
            *incrementButton(),
            *decrementButton(),
            *testView(state)
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
