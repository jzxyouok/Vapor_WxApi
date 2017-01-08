

// TPL means Template Language tag mark based on HTML procal translation
// TPL 为英文单词Template(模板)的计算机机器码简称 不用全称要用3个英文字母 这是搞技术的通病：喜欢偷懒。。。
// pointer to bar 一定要写 ptr2bar 这样装逼更接地气

// 经过我观察 Swift语言 依然需要MVC来驾驭他 才能做大项目 - 如何让100个代码风格截然不同的人 协同推进呢？ MVC的重要性就出来了
// Controller: 经过简单的封装 在一个自然类Class中防止一个数组容器[闭包]  存放所有的 闭包 [ { request ,response in  ... } ] 就可以进行最简单的 controller控制器架构
// Model: 的架构 比较复杂 需要编写 Fluent数据映射框架 最终的效果是  model.save()函数 可以进行 一对多的数据库插入 model一条同时插入 MySQL 和 PostgreSQL + Sqlite3 三种数据库 read()函数 也是直接从本地/远程数据库中读取 通讯协议为TCPIP(由数据库供应商实现) 我们本身只用较为简单的HTTP协议 构建API  你放我我的API 我才有权限访问总数据库
// View: 设计人员只交HTML纯文本 不可编程 后端人员交 #{} 模板语言标签 先制作静态网页 然后交给后台 插入 tag标签 转换为 动态数据 每次请求 从缓存铺pull 缓存每个一个时间周期 从总数据库 进行一次数据同步 刷新HTML页/app推送Json数据源
// 哲学：还是 MVC

import Foundation
import Vapor
import HTTP

import PostgreSQL

public typealias RouteClosureIMP = (Request) throws -> ResponseRepresentable

final class TplIMPController {
    /// 路由器字典
    fileprivate var routingRegisterIMP :[String:(RouteClosureIMP)] {
        get{
            return realBlockDictionary
        }
        
        set{
            realBlockDictionary = newValue
        }
    }
    
    private var realBlockDictionary:[String:RouteClosureIMP] = [String:RouteClosureIMP]() {
        didSet{
            print("授权初始化 block字典 每一个进来的HTTP路由 都必须提前授权才能初始化")
            print("生产阶段 我会用TCPIP传递一个 SHA1(tokenString)才能初始化注册表字典")
        }
        
        willSet{
            print("it works! it fucking worked !!!!!!")
        }
    }
    
    init(code:String) {
        
        let version_code = "API测试: 基准JSon返回"
        
        if code == "dk..." {
            // API测试: 基准JSon返回
            routingRegisterIMP["api_v1_json"] = { (req:Request) -> Response in ///标准闭包语法
                print(version_code)
                
                let node = try JSON.init(node : [
                    "Json字典测试" : "This is a un-official Json implementation",
                    "Json数组测试--": [1,2,4,45,19024],
                    "基本字符串测试--": "Vapor is awsome"])
                return try Response.init(status: .ok, json: node)
            }
            
            // API测试: 404页面
            routingRegisterIMP["api_v1_404"] = { req in
                return try drop.view.make("welcome", [
                    "message": drop.localization[req.lang, "welcome", "title"]
                    ])
            }
            
            // API测试: 多路路由模拟传参
            routingRegisterIMP["api_v1_param"] = { /// 匿名闭包语法
                let parameter :String = $0.data["sword"]?.string ?? "用户没有get传参数过来..."

                return try JSON.init(node : [
                    "Xiaoxi Canshu" : "\(parameter) is passing via website......"
                    ])
            }
            
            // API测试: Datalize 购物车测试
            routingRegisterIMP["model"] = {
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
            
            // API测试 POST协议方法
            routingRegisterIMP["post"] = { request in
                guard let name = request.data["data"]?.string else {
                    throw Abort.badRequest
                }
                print("user said : /// ....[\(name)]")
                
                return try JSON.init(node : [
                    "message" : name
                    ])
            }
            
            // API测试 cURL抓取淘宝网首页
            routingRegisterIMP["curl"] = { req in
                return try drop.view.make("index.html")
            }
            
            // API测试(重要) 连接阿里云PostgreSQL数据库大后端
            routingRegisterIMP["postgreSQL"] = { req in
                let dbName :String = req.data["dbname"]?.string ?? "milist"
                /// HTTP get收参
                let psql = PostgreSQL.Database(dbname: "postgres", user: "postgres", password: "dingkang3")
                let resultSet :[[String:Node]] = try psql.execute("SELECT * FROM \(dbName);")
                var temp = [Node]()
                for item in resultSet {
                    temp += [try item.makeNode()]
                    print(item)
                }
                return try temp.makeJSON()
            }
            
            routingRegisterIMP["leaf"] = { request in
                let pgsql = PostgreSQL.Database(dbname: "postgres", user: "postgres", password: "dingkang3")
                let rs :[[String:Node]] = try pgsql.execute("SELECT * FROM yz_employ;")
                
                var temp = [Node]()
                for row in 0 ..< rs.count {
                    temp.append(try rs[row].makeNode())
                }
                
                print(JSON.init(temp[0].makeNode()))
                
                return try drop.view.make("base", [
                    "d1": JSON.init(temp[3].makeNode()),
                    "d2": JSON.init(temp[4].makeNode())
                ])
            }
        }else {
            fatalError("没有授权码 跑出一个致命错误")
        }
        
    }
}

let drop = Droplet()
let 注册表 = TplIMPController.init(code: "dk...")

drop.get("api_v1_404", handler: 注册表.routingRegisterIMP["api_v1_404"]!)
drop.get("api_v1_json", handler: 注册表.routingRegisterIMP["api_v1_json"]!)
drop.get("api_v1_param", handler: 注册表.routingRegisterIMP["api_v1_param"]!)
drop.get("model", handler: 注册表.routingRegisterIMP["model"]!)
drop.post("post", handler: 注册表.routingRegisterIMP["post"]!)
drop.post("curl", handler: 注册表.routingRegisterIMP["curl"]!)
drop.get("postgreSQL", handler: 注册表.routingRegisterIMP["postgreSQL"]!)
drop.get("leaf", handler: 注册表.routingRegisterIMP["leaf"]!)

drop.resource("posts", PostController())
drop.run()
