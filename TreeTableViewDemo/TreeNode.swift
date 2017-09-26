//
//  TreeModel.swift
//  TreeTableViewDemo
//
//  Created by zhuxuhong on 2017/9/25.
//  Copyright © 2017年 zhuxuhong. All rights reserved.
//

import UIKit


class TreeNode: NSObject {
	var name = ""
	var isOpen = false
	var subNodes = [TreeNode]()
	var levelString = ""
	
	var level: Int{
		return levelString.components(separatedBy: ".").count
	}
	var isLeaf: Bool{
		return subNodes.isEmpty
	}
	
	override var description: String{
		return "levelString: \(levelString) name: \(name)"
	}
}


extension TreeNode{	
	override func setValue(_ value: Any?, forUndefinedKey key: String) {
		if key == "subs", let subs = value as? [[String: Any]]{
			for i in 0..<subs.count {
				let tree = TreeNode.modelWithDictionary(subs[i], levelString: i,parent: levelString)
				subNodes.append(tree)
			}
		}
	}
	
	public static func modelWithDictionary(_ dict: [String: Any], levelString index: Int, parent levelString: String?) -> TreeNode{
		let model = TreeNode()
		model.levelString = levelString != nil ? (levelString! + ".\(index + 1)") : "\(index + 1)"
		model.setValuesForKeys(dict)
		return model
	}
}


extension TreeNode{
	var needsDisplayNodes: [TreeNode]{
		return needsDisplayNodesOf(ancestor: self)
	}
	
	// 应该显示的
	private func needsDisplayNodesOf(ancestor: TreeNode) -> [TreeNode]{
		var nodes = [TreeNode]()
		for node in ancestor.subNodes {
			nodes.append(node)
			if node.isOpen {
				nodes.append(contentsOf: needsDisplayNodesOf(ancestor: node))
			}
		}
		return nodes.sorted{ $0.levelString < $1.levelString }
	}
}


extension TreeNode{
	public static func mockData() -> [TreeNode]{
		var trees = [TreeNode]()
		do{
			let data = try Data(contentsOf: Bundle.main.url(forResource: "tree.json", withExtension: nil)!)
			guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [[String: Any]] else{
				return trees
			}
			for i in 0..<jsonArray.count{
				let tree = TreeNode.modelWithDictionary(jsonArray[i], levelString: i, parent: nil)
				trees.append(tree)
			}
		}catch{
			fatalError("JSON数据解析失败")
		}
		return trees
	}
}
