//
//  MVPTableViewPresenter.swift
//  TaskMVP
//
//  Created by 肥沼英里 on 2021/05/07.
//

import Foundation

protocol MVPTableViewInput{
    func searchText(searchWord: String?)
    func item(index: Int) -> GithubModel
    var numberOfItems: Int { get }
    func didSelect(index: Int)
}

protocol MVPTableViewOutput: AnyObject{
    func willSearch()
    func didFinishSearch()
    func update()
    func showWeb(item: GithubModel)
    func alert(error: Error)
}

final class MVPTableViewPresenter{
    
    private weak var output: MVPTableViewOutput!
    private var items: [GithubModel] = []
    private var githubAPI: GithubAPIProtocol = GithubAPI.shared
    
    init(output: MVPTableViewOutput){
        self.output = output
        self.githubAPI = GithubAPI.shared
    }
}

extension MVPTableViewPresenter: MVPTableViewInput{
    
    func didSelect(index: Int) {
        self.output.showWeb(item: self.items[index])
    }
    
    var numberOfItems: Int {
        items.count
    }
    
    func item(index: Int) -> GithubModel {
        return items[index]
    }

    func searchText(searchWord: String?) {
        guard let searchWord = searchWord, !searchWord.isEmpty else { return }
        output.willSearch()
        githubAPI.get(searchWord: searchWord) { result in
          DispatchQueue.main.async {
            self.output.didFinishSearch()
            switch result {
            case .failure(let error):
                //アラート機能をつける場合などのためにコントローラーに渡す
                self.output.alert(error: error)
            case .success(let items):
              self.items = items
                self.output.update()
            }
          }
        }
    }
}
