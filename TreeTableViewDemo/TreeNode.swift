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
	var level = 0
	var descendantNodes: [TreeNode]{
		return descendantNodesOf(ancestor: self)
	}
	
	// 计算所有的后代节点
	private func descendantNodesOf(ancestor: TreeNode) -> [TreeNode]{
		var nodes = [TreeNode]()
		nodes.append(contentsOf: ancestor.subNodes)
		for node in ancestor.subNodes {
			nodes.append(contentsOf: descendantNodesOf(ancestor: node))
		}
		return nodes
	}
	
	override func setValue(_ value: Any?, forUndefinedKey key: String) {
		if key == "subs", let subs = value as? [[String: Any]]{
			for dict in subs {
				let tree = TreeNode.modelWithDictionary(dict, parent: level)
				subNodes.append(tree)
			}
		}
	}
	
	public static func modelWithDictionary(_ dict: [String: Any], parent level: Int) -> TreeNode{
		let model = TreeNode()
		model.level = level + 1
		model.setValuesForKeys(dict)
		return model
	}
}


extension TreeNode{
	public static func mockData() -> [TreeNode]{
		var trees = [TreeNode]()
		do{
			let data = try Data(contentsOf: Bundle.main.url(forResource: "tree.json", withExtension: nil)!)
			guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [[String: Any]] else{
				return trees
			}
			for dict in json {
				let tree = TreeNode.modelWithDictionary(dict, parent: 0)
				trees.append(tree)
			}
		}catch{
			fatalError("JSON数据解析失败")
		}
		return trees
	}
}
