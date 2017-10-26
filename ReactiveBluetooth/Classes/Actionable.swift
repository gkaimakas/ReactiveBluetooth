//
//  NonBlocking.swift
//  ReactiveBluetooth
//
//  Created by George Kaimakas on 26/10/2017.
//

public protocol ActionableProvider: class {}

extension ActionableProvider {
	/// A proxy which hosts non blocking extensions for `self`.
	public var action: Actionable<Self> {
		return Actionable(self)
	}
}

/// A proxy which hosts non blocking extensions of `Base`.
public struct Actionable<Base> {
	/// The `Base` instance the extensions would be invoked with.
	public let base: Base

	/// Construct a proxy
	///
	/// - parameters:
	///   - base: The object to be proxied.
	fileprivate init(_ base: Base) {
		self.base = base
	}
}

