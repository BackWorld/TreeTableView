# TreeTableView
A tree structure view demo based on UITableView.
> 本例提供了一种“最简单”的利用UITableView实现树状结构的方法和思路，适用于OC和Swift。

![最终效果](http://upload-images.jianshu.io/upload_images/1334681-154215d6e145a63c.gif?imageMogr2/auto-orient/strip)

### 思路
- 定义数据模型TreeNode，里边有控制展开/关闭的属性`isOpen`，以及它的儿子节点`subNodes`；
- 定义tableView的数据源`dataSource = [TreeNode]()`；
- 点击cell的时候，操作数据源dataSource插入或移除`node.subNodes`；
- 点击cell的时候，设置`node.isOpen = !node.isOpen`；
- 点击cell的时候，根据`isOpen`来选择插入`insert`cells还是移除`remove`cells；
- 针对不同的cell`TreeNodeCell`或`TreeLeafCell`处理cell的显示；

- **定义JSON数据模型为如下结构：**

```
[
    {
        "name": "1",
        "subs": [
            {
                "name": "1.1",
                "subs": [
                    {
                        "name": "1.1.1",
                        "subs": []
                    }
                ]
            }
        ]
    }
]
```
- **定义数据源模型为如下结构**：
```
class TreeNode: NSObject {
	var name = ""
	var isOpen = false
	var subNodes = [TreeNode]()
	var level = 0
	var descendantNodes: [TreeNode]{
		// TODO
	}
}
```
### 实现
- **点击cell的处理逻辑**
```
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	tableView.deselectRow(at: indexPath, animated: true)
	
	let node = dataSource[indexPath.row]
	let subs = node.subNodes
//1. 点击叶子节点，不再展开/插入
	if subs.isEmpty {
		return
	}
	
	node.isOpen = !node.isOpen
	let insertIndex = dataSource.index(of: node)! + 1
	if node.isOpen {
//2. 插入subNodes - 展开
		dataSource.insert(contentsOf: subs, at: insertIndex)
		tableView.insertRows(at: subs.map{
			IndexPath(row: dataSource.index(of: $0)!, section: 0)
		}, with: .top)
	}
	else{
//3. 移除所有的subNodes - 收起
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
//4. 刷新当前cell的状态 - 卷/展icon
	tableView.reloadRows(at: [indexPath], with: .none)
}
```
- **cell显示处理逻辑**
```
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	let node = dataSource[indexPath.row]
	let subs = node.subNodes
	let flagText = !subs.isEmpty ? (node.isOpen ? "-" : "+") : ""
	
	var cell: UITableViewCell!
	if subs.isEmpty {
//1. 叶子节点cell
		cell = tableView.dequeueReusableCell(withIdentifier: "TreeLeafCell", for: indexPath) as! TreeLeafCell
	}
	else{
//2. 正常节点cell
		cell = tableView.dequeueReusableCell(withIdentifier: "TreeNodeCell", for: indexPath) as! TreeNodeCell
	}
	
	cell.textLabel?.text = String(repeating: "    ", count: node.level) + "\(flagText)  " + node.name
	
	return cell
}
```
- **TreeNode数据模型**
```
class TreeNode: NSObject {
// 所有的后代节点
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
```

- **模拟JSON数据解析逻辑**
```
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
```
### 优缺点
- **优点**
> 思路清晰，逻辑简单，代码实现容易；
代码执行效率高；
- **缺点**
> 暂不支持所有节点上次卷展状态的重现；
代码对Data Model的依赖性较强；
没有实现封装；

### 简书
> http://www.jianshu.com/p/f0a84a960115
> 如果对你有帮助，别忘了点个❤️并关注下我哦。
