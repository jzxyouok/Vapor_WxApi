
import Vapor
import HTTP

func getUserInfo (_ req :Request) ->Void {
    let info = (req.body,req.peerAddress)

    print("printing ...user info ...[\(info)]")
}

let drop = Droplet()

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}
drop.resource("posts", PostController())

drop.get("getJson") { req in
    // return an basic json string on website
    return try JSON.init(node : [
        "Json字典测试" : "This is a un-official Json implementation",
        "Json数组测试--": [1,2,4,45,19024],
        "基本字符串测试--": "Vapor is awsome"
    ])
}

drop.get("param1","param2" ) { req in
    return try JSON.init(node : [
        "message":"i am tired of saying hello"
    ])
}

// param1 ... 2 ... 3 

drop.get("sword", Int.self) { req , sword in
    return try JSON.init(node : [
        "Xiaoxi Canshu" : "\(sword - 1) is passing via website......"
    ])
}

/// demo 4 post HTTP
drop.post("post", handler: {
    guard let name = $0.data["data"]?.string else {
        throw Abort.badRequest
    }

    print("user said : /// ....[\(name)]")
    getUserInfo($0)
    
    return try JSON.init(node : [
        "message" : name
    ])
})

drop.get("curl") {
    req in
    
    var shoppingList :Bag = Bag<String>()
    shoppingList.add("小米净水器")
    shoppingList.add("小米白色LED台灯")
    shoppingList.add("ZMI小米联名移动电源")
    shoppingList.add("星巴克白色 正品2017 - 不锈钢304 500ML毫升咖啡杯 主题:城市主题[成都]")
    shoppingList.add("宜家铁锅", occurences: 3)
    
    return try JSON.init(node :[
        "购物车容器-->":shoppingList.description,
        "购物车宗类-->":shoppingList.uniqueCount,
        "购物车数量-->":shoppingList.totalCount
    ])
}

drop.get("抓取", handler: { request in
    return try drop.view.make("index.html")
})

import PostgreSQL
drop.get("Jay") { //尾随闭包语法
    request in
    let psql = PostgreSQL.Database(
        dbname :"postgres",
        user   :"postgres",
        password:"dingkang3"
    )
    let resultSet :[[String:Node]] = try psql.execute("SELECT * FROM milist;")
    for dict in resultSet {
        print(dict)
    }
    /// 渲染到 模板引擎....
    let tpl = try drop.view.make("base.leaf", ["var": resultSet[0]["mycommendofpro"]?.string ?? "没有数据" ])
    return tpl
}

drop.run()
