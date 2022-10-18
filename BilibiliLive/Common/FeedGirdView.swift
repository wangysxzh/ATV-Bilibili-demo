//
//  FeedGirdView.swift
//  BilibiliLive
//
//  Created by yicheng on 2022/10/18.
//

import SwiftUI
import Kingfisher

struct FeedGirdView: View {
    struct FeedDisplayData:DisplayData,Hashable {
        var title: String
        var owner: String
        var pic: URL?
    }
    @EnvironmentObject var model: FeedGirdViewModel
    
    private var grids = [GridItem(.flexible()),GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    func width(for size: CGSize) -> CGFloat {
        return size.width / 4 - 20
    }
    
    var body: some View {
        GeometryReader {
            proxy in
            LazyVGrid(columns: grids) {
                ForEach(Array(model.displayData.enumerated()), id: \.offset) {
                    index, item in
                    Button {
                        model.didSelect?(index)
                    } label: {
                        VStack(alignment: .leading, spacing:2) {
                            KFImage(item.pic)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 225)
                                .clipped()
                            Text(item.title).font(.headline).padding(.leading)
                                .lineLimit(2)
                            Text(item.owner).font(.footnote).foregroundColor(Color(UIColor.label))
                                .padding(.leading)
                        }.frame(width: width(for: proxy.size))
                    }
                    .buttonStyle(.card)
                }
            }
        }
        
    }
}

class FeedGirdViewModel: ObservableObject {
    @Published var displayData:[FeedGirdView.FeedDisplayData] = []
    var didSelect:((Int)->Void)?
}

class FeedGirdViewController: UIHostingController<AnyView> {
    
    let model = FeedGirdViewModel()
    
    var displayData:[DisplayData] = [] {
        didSet {
            model.displayData = displayData.map{FeedGirdView.FeedDisplayData(title: $0.title, owner: $0.owner,pic: $0.pic)}
        }
    }
    
    var didSelect: ((IndexPath)->Void)? = nil
    
    
    init() {
        super.init(rootView: AnyView(FeedGirdView().environmentObject(model)))
        model.didSelect = { [weak self] in
            self?.didSelect?(IndexPath(item: $0, section: 0))
        }
    }
    
    func show(in vc: UIViewController) {
        vc.addChild(self)
        vc.view.addSubview(view)
        view.makeConstraintsToBindToSuperview()
        didMove(toParent: vc)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct FeedGirdView_Previews: PreviewProvider {
    static var previews: some View {
        FeedGirdView()
    }
}
