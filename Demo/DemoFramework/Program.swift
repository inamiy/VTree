import UIKit
import VTree

/// Naive VTree renderer & event handler.
/// - SeeAlso: https://github.com/inamiy/SwiftElm for more elegant solution.
public final class Program<Model, Msg: Message>
{
    public private(set) var rootView: View?

    private var _rootTree: VView<Msg>?

    private var _model: Model
    private let _view: (Model) -> VView<Msg>

    private let _debug: Bool

    public init(model: Model, update: @escaping (Model, Msg) -> (Model), view: @escaping (Model) -> VView<Msg>, debug: Bool = true)
    {
        self._model = model
        self._view = view

        let initialTree = view(model)
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
            guard let self_ = self, let msg = Msg(anyMsg) else { return }

            self_._model = update(self_._model, msg)
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
