//
//  Bag.swift
//  hello-vapor
//
//  Created by 沙罗双树 on 2017/1/6.
//
//  HTTP后端服务器组件 Vapor 1.0 + 中间件Jay(Linux版Json框架)

import Foundation

public struct Bag <Element : Hashable> {
    public var name :String = "购物车"
    fileprivate var contents:[Element :Int] = [:]
    public var uniqueCount :Int {
        return contents.count
    }
    public var totalCount :Int {
        return contents.values.reduce(0, {
            $0 + $1
        })
    }
    public mutating func add(_ member : Element , occurences : Int = 1) {
        precondition(occurences > 0 ,"一次只能添加一个正整数[\(name)]元素")
        
        if let currentIndex = contents[member] {
            /// 宜家铁锅 : 3个 ---> 宜家铁锅 : 4个 (+1) 集合类会保证内存中始终不会用重复元素
            contents[member] = currentIndex + occurences
        }else {
            contents[member] = occurences
        }
    }
    public mutating func remove(_ member: Element, occurrences: Int = 1) {
        guard let currentCount = contents[member], currentCount >= occurrences else {
            preconditionFailure("这个元素已经被移除 请不要重复移除")
        }
        precondition(occurrences > 0, "只能移除正整数个的[\(name)]元素")
        if currentCount > occurrences {
            contents[member] = currentCount - occurrences
        } else {
            contents.removeValue(forKey: member)
        }
    }
}
extension Bag {
    var description :String {
        return String.init(describing: contents)
    }
}
