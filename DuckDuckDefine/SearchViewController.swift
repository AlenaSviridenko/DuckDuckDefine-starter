/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class SearchViewController: UIViewController {
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
  
  private lazy var duckDuckGo = DuckDuckGo()
  
  private var searchTerms = [String]()
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    
    performSearch(for: searchBar.text)
  }
  
  func saveSearchTerm(_ term: String) {
    if self.searchTerms.contains(term) {
      return
    }
    
    searchTerms.insert(term, at: 0)
    tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .left)
  }
  
  func performSearch(for term: String?) {
    guard let term = term else { return }
    
    activityIndicatorView.startAnimating()
    
    duckDuckGo.performSearch(for: term) { definition in
      self.activityIndicatorView.stopAnimating()
      
      if let definition = definition {
        self.saveSearchTerm(term)
        
        self.performSegue(withIdentifier: "DefinitionSegue", sender: DefinitionSegueContext(definition: definition))
      } else {
        self.showNoDefinitionAlert(for: term)
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let context = sender as? DefinitionSegueContext,
      segue.identifier == "DefinitionSegue" {
      let vc = segue.destination as! DefinitionViewController
      vc.definition = context.definition
    }
  }
  
  func showNoDefinitionAlert(for term: String) {
    let alertController = UIAlertController(title: "Huh...", message: "No definition could be found for \(term). Try searching for something else?", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    
    present(alertController, animated: true)
  }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchTerms.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel!.text = searchTerms[indexPath.row]
    return cell
  }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSearch(for: searchTerms[indexPath.row])
  }
}
