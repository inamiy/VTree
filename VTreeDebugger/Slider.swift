import Foundation
import VTree
import Flexbox

internal func debugSlider<Msg: Message>(text: Text?, ratio: CGFloat, rootSize: CGSize) -> AnyVTree<DebugMsg<Msg>>
{
    let sliderHeight: CGFloat = 100
    let labelHeight: CGFloat = 30

    func hairline<Msg: Message>() -> AnyVTree<DebugMsg<Msg>>
    {
        return *VView(
            styles: .init {
                $0.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                $0.flexbox = Flexbox.Node(
                    size: CGSize(width: rootSize.width - 40, height: 1),
                    maxSize: CGSize(width: rootSize.width - 40, height: sliderHeight),
                    flexGrow: 1
                )
            }
        )
    }

    func slideHandle<Msg: Message>(ratio: CGFloat) -> AnyVTree<DebugMsg<Msg>>
    {
        let handleWidth: CGFloat = 40

        func labelWrapper<Msg: Message>(text: Text?, ratio: CGFloat) -> AnyVTree<DebugMsg<Msg>>
        {
            let labelWrapperWidth: CGFloat = rootSize.width

            func label<Msg: Message>(text: Text?, ratio: CGFloat) -> AnyVTree<DebugMsg<Msg>>
            {
                return *VLabel<DebugMsg<Msg>>(
                    text: text,
                    styles: .init {
                        $0.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.5)
                        $0.isHidden = text == nil
                        $0.textColor = .white
                        $0.textAlignment = .center
                        $0.font = .systemFont(ofSize: 24)
                        $0.flexbox = Flexbox.Node(
                            padding: Edges(uniform: 4)
                        )
                    }
                )
            }

            // labelWrapper
            return *VView<DebugMsg<Msg>>(
                styles: .init {
                    $0.isHidden = text == nil
                    $0.flexbox = Flexbox.Node(
                        size: CGSize(width: labelWrapperWidth, height: labelHeight),
                        flexDirection: .columnReverse,
                        alignItems: .center,
                        positionType: .absolute,
                        position: Edges(
                            left: -labelWrapperWidth/2 + handleWidth/2,
                            top: -40
                        )
                    )
                },
                children: [
                    label(text: text, ratio: ratio)
                ]
            )
        }

        // slideHandle
        return *VView(
            styles: .init {
                $0.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                $0.cornerRadius = handleWidth/2
                $0.flexbox = Flexbox.Node(
                    size: CGSize(width: handleWidth, height: handleWidth),
                    positionType: .absolute,
                    position: Edges(
                        left: max(0, min(rootSize.width - handleWidth, rootSize.width * ratio - handleWidth/2)),
                        top: (sliderHeight - handleWidth)/2
                    )
                )
            },
            children: [
                *labelWrapper(text: text, ratio: 0)
            ]
        )
    }

    func slider() -> AnyVTree<DebugMsg<Msg>>
    {
        return *VView(
            styles: .init {
                $0.flexbox = Flexbox.Node(
                    size: CGSize(width: rootSize.width, height: sliderHeight),
                    flexDirection: .row,
                    justifyContent: .center,
                    alignItems: .center
                )
                return
            },
            children: [
                hairline(),
                slideHandle(ratio: ratio)
            ]
        )
    }

    // debugSlider
    return *VView(
        styles: .init {
            $0.frame = CGRect(x: 0, y: rootSize.height - sliderHeight, width: rootSize.width, height: sliderHeight)
            $0.flexbox = Flexbox.Node(
                flexDirection: .column,
                alignItems: .center
            )
        },
        gestures: [.pan(^DebugMsg<Msg>.slider)],
        children: [
            slider(),
        ]
    )
}
