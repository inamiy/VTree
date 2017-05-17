import Foundation
import VTree
import Flexbox

/// A protocol that `VTreeDebugger` requires `rootSize` for layouting additional UI components.
public protocol DebuggableModel: CustomStringConvertible
{
    var rootSize: CGSize { get }
}

/// Wrapper of `Model` with storing `histories` for time-travelling.
public struct DebugModel<Model: DebuggableModel, Msg: Message>
{
    fileprivate let original: Model
    fileprivate let histories: [DebugHistory<Model, Msg>]

    fileprivate let slideRatio: Double
    fileprivate let historyIndex: Int?

    public init(_ model: Model)
    {
        self.original = model
        self.histories = [DebugHistory<Model, Msg>(model: model)]
        self.slideRatio = 1
        self.historyIndex = nil
    }

    fileprivate init(_ model: Model, histories: [DebugHistory<Model, Msg>], slideRatio: Double = 1, historyIndex: Int? = nil)
    {
        self.original = model
        self.histories = histories
        self.slideRatio = slideRatio
        self.historyIndex = historyIndex
    }
}

/// Wrapper of `Msg`.
public enum DebugMsg<Msg: Message>: AutoMessage
{
    // sourcery: MessageContext
    case original(Msg)

    case slider(PanGestureContext)
}

/// Wrapper of `update`.
public func debugUpdate<Model: DebuggableModel, Msg: Message>(_ update: @escaping (Model, Msg) -> Model?) -> (DebugModel<Model, Msg>, DebugMsg<Msg>) -> DebugModel<Model, Msg>?
{
    return { debugModel, debugMsg in
        let histories = debugModel.histories

        switch debugMsg {
        case let .original(msg):
            return update(debugModel.original, msg)
                .map { DebugModel<Model, Msg>($0, histories: histories + [DebugHistory(msg: msg, model: $0)]) }
        case let .slider(panContext):

            let slideRatio = max(0, min(1, panContext.location.x / debugModel.original.rootSize.width))

            let index = Int(round(CGFloat(histories.count - 1) * slideRatio))
            let history = histories[index]

            return DebugModel(
                history.model,
                histories: histories,
                slideRatio: Double(slideRatio),
                historyIndex: index
            )
        }
    }
}

/// Wrapper of `view`.
public func debugView<Model: DebuggableModel, Msg: Message, T: VTree>(_ view: @escaping (Model) -> T) -> (DebugModel<Model, Msg>) -> AnyVTree<DebugMsg<Msg>>
    where T.MsgType == Msg
{
    return { debugModel in
        let model = debugModel.original
        let originalTree = (*view(model)).map(DebugMsg.original)

        return *VView(
            styles: .init {
                $0.frame = CGRect(origin: .zero, size: model.rootSize)
                return
            },
            children: {
                let text = debugModel.historyIndex
                    .map { index -> Text in
                        let history = debugModel.histories[index]
                        let msgName = history.msg?.rawMessage.funcName ?? "Initial"
                        return .text("[\(index)] \(msgName), \(history.model.description)")
                    }

                return [
                    originalTree,
                    debugSlider(
                        text: text,
                        ratio: CGFloat(debugModel.slideRatio),
                        rootSize: model.rootSize
                    )
                ]
            }()
        )
    }
}

// MARK: Private

fileprivate struct DebugHistory<Model: DebuggableModel, Msg: Message>
{
    fileprivate let msg: Msg?
    fileprivate let model: Model

    fileprivate init(msg: Msg, model: Model)
    {
        self.msg = msg
        self.model = model
    }

    fileprivate init(model: Model)
    {
        self.msg = nil
        self.model = model
    }
}
