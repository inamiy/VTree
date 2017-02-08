import UIKit
import PlaygroundSupport
import VTree
import Flexbox

struct Model
{
    let rootSize = CGSize(width: 320, height: 800)
    let count: Int
}

func update(_ model: Model, _ msg: Msg) -> Model
{
    switch msg {
        case .increment:
            return Model(count: model.count + 1)
        case .decrement:
            return Model(count: model.count - 1)
    }
}

func view(model: Model) -> VView<Msg>
{
    let rootWidth = model.rootSize.width
    let rootHeight = model.rootSize.height

    let space: CGFloat = 20
    let buttonWidth = (rootWidth - space*3)/2

    func rootView(_ children: [AnyVTree<Msg>] = []) -> VView<Msg>
    {
        return VView(
            frame: CGRect(x: 0, y: 0, width: rootWidth, height: rootHeight),
            backgroundColor: .white,
            children: children
        )
    }

    func label(_ count: Int) -> VLabel<Msg>
    {
        return VLabel(
            frame: CGRect(x: 0, y: 40, width: rootWidth, height: 80),
            backgroundColor: .clear,
            text: "\(count)",
            textAlignment: .center,
            font: .systemFont(ofSize: 48)
        )
    }

    func spellOutLabel(_ count: Int) -> VLabel<Msg>
    {
        return VLabel(
            backgroundColor: .clear,
            text: spellOut(count),
            textAlignment: .center,
            font: .systemFont(ofSize: 48),
            flexbox: Flexbox.Node(
                maxSize: CGSize(width: rootWidth - space*2, height: CGFloat.nan)
            )
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

    func testView(_ count: Int) -> VButton<Msg>
    {
        let alpha = 0.6 + 0.4 * sin(CGFloat(count) * 2 * .pi / 10)
        let fontSize = max(0, count)
        let height = testViewHeight(count)

        return VButton(
            frame: CGRect(x: space, y: 230, width: rootWidth-2*space, height: height),
            backgroundColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),
            alpha: alpha,
            title: "Font \(fontSize)pt",
            titleColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1).withAlphaComponent(1.2 - alpha),
            font: .systemFont(ofSize: CGFloat(fontSize))
        )
    }

    func testViewHeight(_ count: Int) -> CGFloat
    {
        let height = CGFloat(50 + max(0, count))
        return height
    }
    
    func flexRootView(_ count: Int, _ children: [AnyVTree<Msg>] = []) -> VView<Msg>
    {
        return VView(
            backgroundColor: .lightGray,
            flexbox: Node(
                size: CGSize(width: rootWidth-2*space, height: rootWidth-2*space),
                flexDirection: count % 2 == 0 ? .column : .row,
                justifyContent: .spaceAround,
                alignItems: .center,
                position: Edges(left: space, top: 230 + testViewHeight(count) + 20)
            ),
            children: children
        )
    }

    func flex1View(_ count: Int, _ children: [AnyVTree<Msg>] = []) -> VView<Msg>
    {
        return VView(
            backgroundColor: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1),
            flexbox: Node(
                size: CGSize(width: 40, height: 40),
                margin: Edges(uniform: 10)
            ),
            children: children
        )
    }

    func flex2View(_ count: Int, _ children: [AnyVTree<Msg>] = []) -> VView<Msg>
    {
        return VView(
            backgroundColor: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1),
            flexbox: Node(
                size: CGSize(width: 20, height: 20),
                margin: Edges(uniform: 10),
                padding: Edges(uniform: 10)
            ),
            children: children
        )
    }

    func flex3View(_ count: Int, _ children: [AnyVTree<Msg>] = []) -> VView<Msg>
    {
        return VView(
            backgroundColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1),
            flexbox: Node(
                size: CGSize(width: 40 + CGFloat(count) * 2, height: 40 + CGFloat(count) * 2),
                margin: Edges(uniform: 10)
            ),
            children: children
        )
    }

    let count = model.count

    return rootView([
        *label(count),
        *spellOutLabel(count),
        *incrementButton(),
        *decrementButton(),
        *testView(count),
        *flexRootView(count, count % 2 == 0 ? [
            *flex1View(count),
            *flex2View(count),
            *flex3View(count)
        ] : [
            *flex1View(count),
            *flex3View(count)
        ])
])
}

let model = Model(count: 0)

let program = Program(model: model, update: update, view: view, debug: true)

PlaygroundPage.current.liveView = program.rootView
