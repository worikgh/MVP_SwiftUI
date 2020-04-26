//
//  Created by Luis Ascorbe on 23/04/2020.
//  Copyright © 2020 Luis Ascorbe. All rights reserved.
//

import SwiftUI

protocol MasterBaseCoordinator: BaseCoordinator {}

extension MasterBaseCoordinator {
    func presentDetailView(viewModel: DetailViewModel, isPresented: Binding<Bool>) -> some View {
        let coordinator = DetailCoordinator<Self>(viewModel: viewModel, isPresented: isPresented)
        return coordinate(to: coordinator)
    }
    
    func presentDetailRedView(viewModel: DetailRedViewModel, isPresented: Binding<Bool>) -> some View {
        let coordinator = DetailRedCoordinator<Self>(viewModel: viewModel, isPresented: isPresented)
        return coordinate(to: coordinator)
    }
    
    func presentDetailRedViewInModal(viewModel: DetailRedViewModel, isPresented: Binding<Bool>) -> some View {
        let coordinator = DetailRedModalCoordinator<Self>(viewModel: viewModel, isPresented: isPresented)
        return coordinate(to: coordinator)
    }
}

final class MasterRootCoordinator<P: BaseCoordinator>: MasterBaseCoordinator {
    weak var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    @discardableResult
    func start() -> some View {
        let view = MasterFactory.make(with: MasterViewModel(dates: [Date()]), coordinator: self)
        let navigation = NavigationView { view }
        // Looks like using StackNavigationViewStyle on the root view controller
        // doesn't work as expected on iPad 🤷🏻‍♂️
//            .navigationViewStyle(StackNavigationViewStyle())
        let hosting = UIHostingController(rootView: navigation)
        window?.rootViewController = hosting
        window?.makeKeyAndVisible()
        return EmptyReturnWrapper(destination: EmptyView()) // we have to return something
    }
}

final class MasterCoordinator<P: BaseCoordinator>: MasterBaseCoordinator {
    private let viewModel: MasterViewModel?
    private var isPresented: Binding<Bool>
    
    init(viewModel: MasterViewModel?, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self.isPresented = isPresented
    }
    
    @discardableResult
    func start() -> some View {
        // Is there a better way to do this if?
        if let viewModel = viewModel {
            let view = MasterFactory.make(with: viewModel, coordinator: self)
            return NavigationLink(destination: view, isActive: isPresented) {
                EmptyView()
            }
        } else {
            let view = MasterFactory.make(coordinator: self)
            return NavigationLink(destination: view, isActive: isPresented) {
                EmptyView()
            }
        }
    }
}
