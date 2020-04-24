//
//  Created by Luis Ascorbe on 23/04/2020.
//  Copyright © 2020 Luis Ascorbe. All rights reserved.
//

import SwiftUI

struct MasterView<T: MasterPresenting>: View {
    @ObservedObject private var presenter: T
    
    init(presenter: T) {
        self.presenter = presenter
    }

    var body: some View {
        Content(presenter: presenter)
            .navigationBarTitle(Text("Master"))
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(
                    action: {
                        withAnimation {
                            self.presenter.add()
                        }
                }
                ) {
                    Image(systemName: "plus")
                }
            )
    }
}

private struct Content<T: MasterPresenting>: View {
    @ObservedObject var presenter: T
    
    var body: some View {
        List {
            ForEach(presenter.viewModel.dates, id: \.self) { date in
                Row(presenter: self.presenter, date: date)
            }.onDelete { indices in
                indices.forEach { self.presenter.remove(at: $0) }
            }
        }
    }
}

struct ProductFamilyRowStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .colorMultiply(configuration.isPressed ?
                Color.white.opacity(0.5) : Color.white)
    }
}

// This view needs to be a separate struct from Content, otherwise NavigationLink gets mad
private struct Row<T: MasterPresenting>: View {
    @ObservedObject var presenter: T
    
    var date: Date
    
    @State private var selection: Int? = 0 // using selection instead of isActive on this view to show how to put several buttons on the same row
    private let buttonTag1 = 1
    private let buttonTag2 = 2
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.selection = self.buttonTag1
                }) {
                    Text("\(date, formatter: dateFormatter)")
                        .background(
                            self.presenter.dateSelected(date: date, tag: buttonTag1, selection: $selection)
                    )
                }
                .foregroundColor(Color.red)
                
                Button(action: {
                    self.selection = self.buttonTag2
                }) {
                    Text("Go Red")
                        .background(
                            self.presenter.anotherSelected(date: date, tag: buttonTag2, selection: $selection)
                    )
                }
                .foregroundColor(Color.blue)
            }
            Button(action: {
                self.selection = self.buttonTag2
            }) {
                Text("Go Red")
                    .background(
                        self.presenter.anotherSelected(date: date, tag: buttonTag2, selection: $selection)
                )
            }
            .foregroundColor(Color.blue)
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(ProductFamilyRowStyle())
    }
}

struct MasterView_Previews: PreviewProvider {
    private static var dates: [Date] = {
        var dates = [Date]()
        dates.insert(Date(), at: 0)
        dates.insert(Date(), at: 0)
        dates.insert(Date(), at: 0)
        dates.insert(Date(), at: 0)
        dates.insert(Date(), at: 0)
        return dates
    }()
    
    static var previews: some View {
        let presenter = MasterPresenter(viewModel: MasterViewModel(dates: dates), detailCoordinator: DetailCoordinator(), detailRedCoordinator: DetailRedCoordinator())
        return MasterView(presenter: presenter)
    }
}
