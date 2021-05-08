//
//  MVCViewController.swift
//  TaskMVP
//
//  Created by  on 2021/3/10.
//

import UIKit

/*
 MVC構成になっています、MVP構成に変えてください

 Viewから何かを渡す、Viewが何かを受け取る　以外のことを書かない
 if, guard, forといった制御を入れない
 Presenter以外のクラスを呼ばない
 itemsといった変化するパラメータを持たない(状態を持たない)
 
 Presenterに通知を送る、Presenterから通知を受け取るのみ
*/
final class MVPSearchViewController: UIViewController {

  @IBOutlet private weak var searchTextField: UITextField!
  @IBOutlet private weak var searchButton: UIButton! {
    didSet {
      searchButton.addTarget(self, action: #selector(tapSearchButton(_sender:)), for: .touchUpInside)
    }
  }

  @IBOutlet private weak var indicator: UIActivityIndicatorView!

  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.register(UINib.init(nibName: MVPTableViewCell.className, bundle: nil), forCellReuseIdentifier: MVPTableViewCell.className)
      tableView.delegate = self
      tableView.dataSource = self
    }
  }

    /*
     private let presenter = MVPTableViewPresenter()
     にして、viewDidLoad内で
     presenter.output = self
     としても動くけど推奨じゃない理由（考察）
     
     コントローラー内でインスタンス化することによってコントローラーのテストをする際に
     コントローラーだけでなくpresenterの動作も関連してくる
     presenterでURLセッションを行なっているのでネットワークエラーのせいでテストが失敗することもあり得る
     → コントローラーとは直接関係ないところでテストが失敗してしまう
     外部でインスタンス化すればコントローラーはpresenterクラスのメソッドの中身を知る必要がないため
     コントローラー単体でテストできる
     だからinjectする書き方の方が良い
     
     ↑正解！
     + テスト用プロトコルに差し替えするのも簡単 (メンターより）
     */
    
    private var presenter: MVPTableViewPresenter!
    //presenterとvcを繋ぐメソッド
    func inject(presenter: MVPTableViewPresenter){
        self.presenter = presenter
    }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.isHidden = true
    indicator.isHidden = true
  }

  @objc func tapSearchButton(_sender: UIResponder) {
    presenter.searchText(searchWord: searchTextField.text)
  }
}

extension MVPSearchViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    presenter.didSelect(index: indexPath.row)
  }
}

extension MVPSearchViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    presenter.numberOfItems
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: MVPTableViewCell.className) as? MVPTableViewCell else {
      fatalError()
    }
    cell.configure(githubModel: presenter.item(index: indexPath.row))
    return cell
  }
}

extension MVPSearchViewController: MVPTableViewOutput{
    
    func alert(error: Error) {
        //エラーを表示する(今回はしない)
        print(error)
    }
    
    func willSearch() {
        indicator.isHidden = false
        tableView.isHidden = true
    }
    
    func didFinishSearch() {
        self.indicator.isHidden = true
        self.tableView.isHidden = false
    }
    
    func update() {
        self.tableView.reloadData()
    }
    
    func showWeb(item: GithubModel) {
        Router.shared.showWeb(from: self, githubModel: item)
    }
}
