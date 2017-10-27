//
//  SyncCollection.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 27/10/2017.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import Result

public protocol SyncCollectionProtocol {
	associatedtype T
	func append(_ newElement: T)
}

public class SyncCollection<Element>: NSObject, SyncCollectionProtocol {
	public typealias T = Element

	public enum Event<Element> {
		case insert(element: Element, at: Int)
		case update(element: Element, at: Int)
		case remove(element: Element, at: Int)
	}

	fileprivate var store: [Element]
	fileprivate let queue: DispatchQueue
	fileprivate let eventsObserver: Signal<Event<Element>, NoError>.Observer

	public let events: Signal<Event<Element>, NoError>

	public var startIndex: Int { return 0 }
	public var endIndex: Int { return count }
	public func index(after i: Int) -> Int {
		var index: Int = 0
		queue.sync {
			precondition(i < endIndex)
			index = i+1
		}
		return index
	}

	public var count: Int { return size() }

	public override init() {
		self.store = []
		self.queue = DispatchQueue(label: "com.gkaimakas.ReactiveBluetooth.SyncCollection", attributes: .concurrent)
		(events, eventsObserver) = Signal.pipe()

		super.init()
	}

	public func append(_ newElement: Element) {
		queue.async(flags: .barrier) {
			self.store.append(newElement)
			self.eventsObserver.send(value: .insert(element: newElement, at: self.store.count-1))
		}
	}

	public func insert(_ newElement: Element, at index: Int) {
		queue.async(flags: .barrier) {
			self.store.insert(newElement, at: index)
			self.eventsObserver.send(value: .insert(element: newElement, at: index))
		}
	}

	public func remove(at index: Int) -> Element {
		var element: Element!
		queue.async(flags: .barrier) {
			element = self.store.remove(at: index)
			self.eventsObserver.send(value: .remove(element: element, at: index))
		}
		return element
	}

	public subscript(position: Int) -> Element {
		set {
			queue.async(flags: .barrier) {
				self.store[position] = newValue
				self.eventsObserver.send(value: .update(element: newValue, at: position))
			}
		}

		get {
			var element: Element!
			queue.sync {
				element = self.store[position]
			}
			return element
		}
	}

	public func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
		var result: Bool!
		try queue.sync {
			result = try self.store.contains(where: predicate)
		}
		return result
	}

	private func size() -> Int {
		var result: Int = 0
		queue.sync {
			result = store.count
		}
		return result
	}
}

extension Reactive where Base: SyncCollection<DiscoveredPeripheral> {
	public var sync: BindingTarget<DiscoveredPeripheral> {
		return makeBindingTarget { (collection, element) in
			if collection.contains(where: { $0 == element }) == false {
				collection.append(element)
			}
		}
	}
}

//extension Reactive where Base: SyncCollectionProtocol {
//	var add: BindingTarget<SyncCollection> {
//		return makeBindingTarget {  }
//	}
//}

//extension SyncCollection: Collection {
//	public var startIndex: Int { return 0 }
//	public var endIndex: Int { return store.count }
//	public func index(after i: Int) -> Int {
//		precondition(i < endIndex)
//		return i+1
//	}
//	public subscript(position: Int) -> Element {
//		precondition((0 ..< endIndex).contains(position), "Index out of bounds")
//		return store[position]
//	}
//}
//
//extension SyncCollection: ExpressibleByArrayLiteral {
//	public init(arrayLiteral elements: Element ...) {
//		self.init(elements)
//	}
//}


