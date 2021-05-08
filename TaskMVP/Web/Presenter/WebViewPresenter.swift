//
//  WebViewPresenter.swift
//  TaskMVP
//
//  Created by 肥沼英里 on 2021/05/08.
//

import Foundation

protocol WebViewInput {
    func viewDidLoaded()
}

protocol WebViewOutput: AnyObject {
    func load(url: URL)
}

final class WebViewPresenter {
    private var input: WebViewInput!
    private weak var output: WebViewOutput?
    private var githubModel: GithubModel?
    
    init(output: WebViewOutput, githubModel: GithubModel){
        self.output = output
        self.githubModel = githubModel
    }
}

extension WebViewPresenter: WebViewInput {
    func viewDidLoaded() {
        guard
          let githubModel = githubModel,
          let url = URL(string: githubModel.urlStr) else {
          return
        }
        output?.load(url: url)
    }
}
