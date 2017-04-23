import UIKit
import VTree
import VTreeDebugger

/// Naive VTree renderer & event handler.
/// - SeeAlso: https://github.com/inamiy/SwiftElm for more elegant solution.
public final class Program<Model, Msg: Message>
{
    public private(set) var rootView: View?

    private var _rootTree: AnyVTree<Msg>?

    private var _model: Model
    private let _view: (Model) -> AnyVTree<Msg>

    /// Flag for border-color & logging.
    private let _debug: Bool

    public init<T: VTree>(debug: Bool = false, model: Model, update: @escaping (Model, Msg) -> Model?, view: @escaping (Model) -> T)
        where T.MsgType == Msg
    {
        self._model = model
        self._view = { *view($0) }

        let initialTree = self._view(model)
        let initialView = initialTree.createView()

        self._rootTree = initialTree
        self.rootView = initialView

        if debug {
            Debug.addBorderColorsRecursively(initialView)
            Debug.printRecursiveDescription(initialView)
        }
        self._debug = debug

        // Handle messages sent from `VTree`.
        Messenger.shared.handler = { [weak self] anyMsg in
            guard let self_ = self, let msg = Msg(anyMsg),
                let newModel = update(self_._model, msg) else { return }

            self_._model = newModel
            self_._rerender()
        }
    }

    /// Diff & Apply.
    private func _rerender()
    {
        if self._debug {
            print(#function, "model = \(_model)")
        }

        let oldTree = self._rootTree!

        // createTree: State -> VTree
        let newTree = self._view(_model)

        // diff: VTree -> VTree -> Patch
        let patch = diff(old: oldTree, new: newTree)
        if self._debug {
            print("patch =", patch)
        }

        // apply: Patch -> View -> IO View
        let newView = apply(patch: patch, to: self.rootView!)

        self.rootView = newView
        self._rootTree = newTree

        if let newView = newView, self._debug == true {
            Debug.addBorderColorsRecursively(newView)
            Debug.printRecursiveDescription(newView)
        }
    }
}

/// Time-travelling `Program` with `VTreeDebugger`.
///
/// ## Usage
/// ```
/// // let program = Program(model: .initial, update: update, view: view)
/// let program = debugProgram(debug: false, model: .initial, update: update, view: view)
/// ```
public func debugProgram<Model: VTreeDebugger.DebuggableModel, Msg: Message>(
    debug: Bool = false,    // Flag for border-color & logging.
    model: Model,
    update: @escaping (Model, Msg) -> Model?,
    view: @escaping (Model) -> VView<Msg>
    ) -> Program<DebugModel<Model, Msg>, DebugMsg<Msg>>
{
    return Program(debug: debug, model: DebugModel(model), update: debugUpdate(update), view: debugView(view))
}
