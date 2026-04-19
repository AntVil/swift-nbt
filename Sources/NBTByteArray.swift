fileprivate protocol NBTArray: MutableCollection, BidirectionalCollection, RandomAccessCollection, ExpressibleByArrayLiteral, Codable, Equatable where Index == [Element].Index, SubSequence == [Element].SubSequence, Iterator == [Element].Iterator {
    var values: [Element] { get set }
}

extension NBTArray {
    public subscript(_ index: Self.Index) -> Self.Element {
        get {
            self.values[index]
        }
        set {
            self.values[index] = newValue
        }
    }

    public subscript(_ range: Range<Self.Index>) -> Self.SubSequence {
        get {
            self.values[range]
        }
        set {
            self.values[range] = newValue
        }
    }

    public func makeIterator() -> Self.Iterator {
        return self.values.makeIterator()
    }

    public var startIndex: Self.Index { self.values.startIndex }
    public var endIndex: Self.Index { self.values.endIndex }

    public func index(after i: Self.Index) -> Self.Index {
        self.values.index(after: i)
    }

    public func index(before i: Self.Index) -> Self.Index {
        self.values.index(before: i)
    }
}

/// A NBT-Byte-Array. It can be used just like a regular Swift-Byte-Array, with the exception that encoding and decoding behaves slightly differently when using a `NBTDecoder` or `NBTEncoder`
public struct NBTByteArray: NBTArray {
    public init(arrayLiteral: Self.Element...) {
        self.values = arrayLiteral
    }

    public typealias Element = UInt8
    public typealias SubSequence = [Element].SubSequence
    public typealias Iterator = [Element].Iterator

    var values: [Element]
}

/// A NBT-UInt32-Array. It can be used just like a regular Swift-UInt32-Array, with the exception that encoding and decoding behaves slightly differently when using a `NBTDecoder` or `NBTEncoder`
public struct NBTInt32Array: NBTArray {
    public init(arrayLiteral: Element...) {
        self.values = arrayLiteral
    }

    public typealias Element = UInt32
    public typealias SubSequence = [Element].SubSequence
    public typealias Iterator = [Element].Iterator

    var values: [Element]
}

/// A NBT-UInt64-Array. It can be used just like a regular Swift-UInt64-Array, with the exception that encoding and decoding behaves slightly differently when using a `NBTDecoder` or `NBTEncoder`
public struct NBTInt64Array: NBTArray {
    public init(arrayLiteral: Element...) {
        self.values = arrayLiteral
    }

    public typealias Element = UInt64
    public typealias SubSequence = [Element].SubSequence
    public typealias Iterator = [Element].Iterator

    var values: [Element]
}
