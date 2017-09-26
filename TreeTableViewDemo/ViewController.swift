//
//  ViewController.swift
//  TreeTableViewDemo
//
//  Created by zhuxuhong on 2017/9/25.
//  Copyright © 2017年 zhuxuhong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!

	var dataSource = TreeNode.mockData()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.automaticallyAdjustsScrollViewInsets = false
		
		tableView.tableFooterView = UIView()
				
		tableView.register(TreeNodeCell.self, forCellReuseIdentifier: "TreeNodeCell")
		tableView.register(TreeLeafCell.self, forCellReuseIdentifier: "TreeLeafCell")
	}
}

extension ViewController: UITableViewDelegate{
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	tableView.deselectRow(at: indexPath, animated: true)
	
	let node = dataSource[indexPath.row]
	let subs = node.subNodes
	if subs.isEmpty {
		return
	}
	
	node.isOpen = !node.isOpen
	let insertIndex = dataSource.index(of: node)! + 1
	if node.isOpen {
		dataSource.insert(contentsOf: subs, at: insertIndex)
		tableView.insertRows(at: subs.map{
			IndexPath(row: dataSource.index(of: $0)!, section: 0)
		}, with: .top)
	}
	else{
		for subNode in node.descendantNodes {
			guard let index = dataSource.index(of: subNode) else {
				continue
			}
			subNode.isOpen = false
			dataSource.remove(at: index)
			tableView.deleteRows(at: 
				[IndexPath(row: index, section: 0)]
			, with: .bottom)
		}
	}
	tableView.reloadRows(at: [indexPath], with: .none)
}
}

extension ViewController: UITableViewDataSource{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource.count 
	}
	
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	let node = dataSource[indexPath.row]
	let subs = node.subNodes
	let flagText = !subs.isEmpty ? (node.isOpen ? "-" : "+") : ""
	
	var cell: UITableViewCell!
	if subs.isEmpty {
		cell = tableView.dequeueReusableCell(withIdentifier: "TreeLeafCell", for: indexPath) as! TreeLeafCell
	}
	else{
		cell = tableView.dequeueReusableCell(withIdentifier: "TreeNodeCell", for: indexPath) as! TreeNodeCell
	}
	
	cell.textLabel?.text = String(repeating: "    ", count: node.level) + "\(flagText)  " + node.name
	
	return cell
}
}

