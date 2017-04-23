import Foundation
import VTree
import Flexbox

internal func debugSlider<Msg: Message>(text: String?, ratio: CGFloat, rootSize: CGSize) -> AnyVTree<DebugMsg<Msg>>
{
    let sliderHeight: CGFloat = 100
    let labelHeight: CGFloat = 30

    func hairline<Msg: Message>() -> AnyVTree<DebugMsg<Msg>>
    {
        return *VView(
            backgroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
            flexbox: Flexbox.Node(
                size: CGSize(width: rootSize.width - 40, height: 1),
                maxSize: CGSize(width: rootSize.width - 40, height: sliderHeight),
                flexGrow: 1
            )
        )
    }

    func slideHandle<Msg: Message>(ratio: CGFloat) -> AnyVTree<DebugMsg<Msg>>
    {
        let handleWidth: CGFloat = 40

        func labelWrapper<Msg: Message>(text: String?, ratio: CGFloat) -> AnyVTree<DebugMsg<Msg>>
        {
            let labelWrapperWidth: CGFloat = rootSize.width

            func label<Msg: Message>(text: String?, ratio: CGFloat) -> AnyVTree<DebugMsg<Msg>>
            {
                return *VLabel<DebugMsg<Msg>>(
                    backgroundColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.5),
                    isHidden: text == nil,
                    text: text,
                    textColor: .white,
                    textAlignment: .center,
                    font: .systemFont(ofSize: 24),
                    flexbox: Flexbox.Node(
                        padding: Edges(uniform: 4)
                    )
                )
            }

            // labelWrapper
            return *VView<DebugMsg<Msg>>(
                isHidden: text == nil,
                flexbox: Flexbox.Node(
                    size: CGSize(width: labelWrapperWidth, height: labelHeight),
                    flexDirection: .columnReverse,
                    alignItems: .center,
                    positionType: .absolute,
                    position: Edges(
                        left: -labelWrapperWidth/2 + handleWidth/2,
                        top: -40
                    )
                ),
                children: [
                    label(text: text, ratio: ratio)
                ]
            )
        }

        // slideHandle
        return *VView(
            backgroundColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),
            cornerRadius: handleWidth/2,
            flexbox: Flexbox.Node(
                size: CGSize(width: handleWidth, height: handleWidth),
                positionType: .absolute,
                position: Edges(
                    left: max(0, min(rootSize.width - handleWidth, rootSize.width * ratio - handleWidth/2)),
                    top: (sliderHeight - handleWidth)/2
                )
            ),
            children: [
                *labelWrapper(text: text, ratio: 0)
            ]
        )
    }

    func slider() -> AnyVTree<DebugMsg<Msg>>
    {
        return *VView(
            flexbox: Flexbox.Node(
                size: CGSize(width: rootSize.width, height: sliderHeight),
                flexDirection: .row,
                justifyContent: .center,
                alignItems: .center
            ),
            children: [
                hairline(),
                slideHandle(ratio: ratio)
            ]
        )
    }

    // debugSlider
    return *VView(
        frame: CGRect(x: 0, y: rootSize.height - sliderHeight, width: rootSize.width, height: sliderHeight),
        flexbox: Flexbox.Node(
            flexDirection: .column,
            alignItems: .center
        ),
        gestures: [.pan(^DebugMsg<Msg>.slider)],
        children: [
            slider(),
        ]
    )
}
