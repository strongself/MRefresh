import UIKit
import MRefresh

class MyCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .orange
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ViewController: UIViewController {

    lazy var tableView: UITableView = {
        let table = UITableView()
        self.view.addSubview(table, constraints: [
            equal(\.leadingAnchor, of: view),
            equal(\.trailingAnchor, of: view),
            equal(\.bottomAnchor, of: view),
            equalSafeArea(\.topAnchor, of: view),
        ])
        table.register(MyCell.self, forCellReuseIdentifier: "MyCell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.reloadData()
        let connectedPath = makeConnectedPath(size: CGSize(width: 50.0, height: 50.0))
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: 50.0, height: 50.0))
        let animatableView = PathDrawingAnimatableView(path: connectedPath, frame: frame)
        tableView.addPullToRefresh(animatable: animatableView, handler: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.tableView.stopAnimating()
            }
        })
    }
}

func makeConnectedPath(size: CGSize) -> SVGConnectedPath {
    let svg1 = """
    M103.3 344.3c-6.5-14.2-6.9-18.3 7.4-23.1 25.6-8 8 9.2 43.2 49.2h.3v-93.9c1.2-50.2 44-92.2 97.7-92.2 53.9 0 97.7 43.5 97.7 96.8 0 63.4-60.8 113.2-128.5
    93.3-10.5-4.2-2.1-31.7 8.5-28.6 53 0 89.4-10.1 89.4-64.4 0-61-77.1-89.6-116.9-44.6-23.5 26.4-17.6 42.1-17.6 157.6 50.7 31 118.3 22 160.4-20.1 24.8-24.8 38.5-58
    38.5-93 0-35.2-13.8-68.2-38.8-93.3-24.8-24.8-57.8-38.5-93.3-38.5s-68.8 13.8-93.5 38.5c-.3.3-16 16.5-21.2 23.9l-.5.6c-3.3 4.7-6.3 9.1-20.1
    6.1-6.9-1.7-14.3-5.8-14.3-11.8V20c0-5 3.9-10.5 10.5-10.5h241.3c8.3 0 8.3 11.6 8.3 15.1 0 3.9 0 15.1-8.3 15.1H130.3v132.9h.3c104.2-109.8 282.8-36 282.8 108.9
    0 178.1-244.8 220.3-310.1 62.8zm63.3-260.8c-.5 4.2 4.6 24.5 14.6 20.6C306 56.6 384 144.5 390.6 144.5c4.8 0 22.8-15.3 14.3-22.8-93.2-89-234.5-57-238.3-38.2z
    """
    let svg2 = """
    M213.6 306.6c0 4 4.3 7.3 5.5 8.5 3 3 6.1 4.4 8.5 4.4 3.8 0 2.6.2 22.3-19.5 19.6 19.3 19.1 19.5 22.3 19.5 5.4 0 18.5-10.4 10.7-18.2
    L265.6 284l18.2-18.2c6.3-6.8-10.1-21.8-16.2-15.7L249.7 268c-18.6-18.8-18.4-19.5-21.5-19.5-5 0-18 11.7-12.4 17.3L234 284c-18.1 17.9-20.4 19.2-20.4 22.6z
    """
    let svg3 = "M393 414.7C283 524.6 94 475.5 61 310.5c0-12.2-30.4-7.4-28.9 3.3 24 173.4 246 256.9 381.6 121.3 6.9-7.8-12.6-28.4-20.7-20.4z"
    var configuration = SVGConnectedPathConfiguration(size: size)
    configuration.add(svg: svg1, startProportion: 0.0, depth: 2)
    configuration.add(svg: svg2, startProportion: 0.3, depth: 2)
    configuration.add(svg: svg3, startProportion: 0.4, depth: 2)

    return try! SVGConnectedPathFactory.default.make(pathConfiguration: configuration)
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! MyCell
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
}
