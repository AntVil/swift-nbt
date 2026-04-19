import Foundation


// MARK: NBT Array

public extension NBTByteArray {
    func encode(to encoder: any Encoder) throws {
        fatalError("TODO")
    }

    init(from decoder: any Decoder) throws {
        if let decoder = decoder as? NBTNamedContainerDecoder {
            guard case .namedByteArray(_, let values) = decoder.nbt else {
                throw DecodingError.typeMismatch(Self.self, .init(codingPath: decoder.codingPath, debugDescription: "Tried to decode \(Self.self), but found a \(decoder.nbt)"))
            }
            self.values = values
            return
        }
        if let decoder = decoder as? NBTNamelessContainerDecoder {
            guard case .byteArray(let values) = decoder.nbt else {
                throw DecodingError.typeMismatch(Self.self, .init(codingPath: decoder.codingPath, debugDescription: "Tried to decode \(Self.self), but found a \(decoder.nbt)"))
            }
            self.values = values
            return
        }

        // default implementation outside of nbt
        self.values = try .init(from: decoder)
    }
}

public extension NBTInt32Array {
    func encode(to encoder: any Encoder) throws {
        fatalError("TODO")
    }

    init(from decoder: any Decoder) throws {
        if let decoder = decoder as? NBTNamedContainerDecoder {
            guard case .namedInt32Array(_, let values) = decoder.nbt else {
                throw DecodingError.typeMismatch(Self.self, .init(codingPath: decoder.codingPath, debugDescription: "Tried to decode \(Self.self), but found a \(decoder.nbt)"))
            }
            self.values = values
            return
        }
        if let decoder = decoder as? NBTNamelessContainerDecoder {
            guard case .int32Array(let values) = decoder.nbt else {
                throw DecodingError.typeMismatch(Self.self, .init(codingPath: decoder.codingPath, debugDescription: "Tried to decode \(Self.self), but found a \(decoder.nbt)"))
            }
            self.values = values
            return
        }

        // default implementation outside of nbt
        self.values = try .init(from: decoder)
    }
}

public extension NBTInt64Array {
    func encode(to encoder: any Encoder) throws {
        fatalError("TODO")
    }

    init(from decoder: any Decoder) throws {
        if let decoder = decoder as? NBTNamedContainerDecoder {
            guard case .namedInt64Array(_, let values) = decoder.nbt else {
                throw DecodingError.typeMismatch(Self.self, .init(codingPath: decoder.codingPath, debugDescription: "Tried to decode \(Self.self), but found a \(decoder.nbt)"))
            }
            self.values = values
            return
        }
        if let decoder = decoder as? NBTNamelessContainerDecoder {
            guard case .int64Array(let values) = decoder.nbt else {
                throw DecodingError.typeMismatch(Self.self, .init(codingPath: decoder.codingPath, debugDescription: "Tried to decode \(Self.self), but found a \(decoder.nbt)"))
            }
            self.values = values
            return
        }

        // default implementation outside of nbt
        self.values = try .init(from: decoder)
    }
}

// MARK: Decoder

public struct NBTDecoder {
    public init() {}

    public func decodeNamed<T: Decodable>(_: T.Type, from data: [UInt8]) throws -> T {
        var iterator = data.makeIterator()
        let nbt = try NBT.named(from: &iterator)
        let decoder = NBTNamedContainerDecoder(codingPath: [], userInfo: [:], nbt: nbt)

        return try T.init(from: decoder)
    }

    public func decodeNameless<T: Decodable>(_: T.Type, from data: [UInt8]) throws -> T {
        var iterator = data.makeIterator()
        let nbt = try NBT.unnamed(from: &iterator)
        let decoder = NBTNamelessContainerDecoder(codingPath: [], userInfo: [:], nbt: nbt)

        return try T.init(from: decoder)
    }

    public func decodeNamed_<T: Decodable, D: Sequence>(_: T.Type, from data: D) throws -> T where D.Iterator == IndexingIterator<[UInt8]> {
        var iterator = data.makeIterator()
        let nbt = try NBT.named(from: &iterator)
        let decoder = NBTNamedContainerDecoder(codingPath: [], userInfo: [:], nbt: nbt)

        return try T.init(from: decoder)
    }

    public func decodeNameless_<T: Decodable, D: Sequence>(_: T.Type, from data: D) throws -> T where D.Iterator == IndexingIterator<[UInt8]> {
        var iterator = data.makeIterator()
        let nbt = try NBT.unnamed(from: &iterator)
        let decoder = NBTNamelessContainerDecoder(codingPath: [], userInfo: [:], nbt: nbt)

        return try T.init(from: decoder)
    }
}

import NIOCore

extension NBTDecoder {
    public func decodeNamed<T: Decodable>(_: T.Type, from data: ByteBuffer) throws -> T {
        var iterator = data.readableBytesView.makeIterator()
        let nbt = try NBT.named(from: &iterator)
        let decoder = NBTNamedContainerDecoder(codingPath: [], userInfo: [:], nbt: nbt)

        return try T.init(from: decoder)
    }

    public func decodeNameless<T: Decodable>(_: T.Type, from data: ByteBuffer) throws -> T {
        var iterator = data.readableBytesView.makeIterator()
        let nbt = try NBT.unnamed(from: &iterator)
        let decoder = NBTNamelessContainerDecoder(codingPath: [], userInfo: [:], nbt: nbt)

        return try T.init(from: decoder)
    }
}

fileprivate class NBTNamedContainerDecoder: Decoder {
    let nbt: NBT
    let codingPath: [any CodingKey]

    let userInfoSendable: [CodingUserInfoKey: Sendable]
    var userInfo: [CodingUserInfoKey: Any] { self.userInfoSendable }

    init(codingPath: [any CodingKey], userInfo userInfoSendable: [CodingUserInfoKey: Sendable], nbt: NBT) {
        self.codingPath = codingPath
        self.userInfoSendable = userInfoSendable
        self.nbt = nbt
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard case .namedCompound(_, let values) = self.nbt else {
            throw DecodingError.typeMismatch([String:Any].self, .init(codingPath: self.codingPath, debugDescription: "Decoded value was not a container, but a \(self.nbt)"))
        }
        return try KeyedDecodingContainer(NBTContainer<Key>(values: values, decoder: self))
    }

    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        guard case .namedList(_, let value) = self.nbt else {
            throw DecodingError.typeMismatch([Any].self, .init(codingPath: self.codingPath, debugDescription: "Decoded value was not an array, but a \(self.nbt)"))
        }
        return NBTListDecodingContainer(items: value, decoder: self)
    }

    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        return NBTNamedSingleValueDecodingContainer(decoder: self, codingPath: self.codingPath)
    }
}

fileprivate class NBTNamelessContainerDecoder: Decoder {
    let codingPath: [any CodingKey]

    let userInfoSendable: [CodingUserInfoKey: Sendable]
    var userInfo: [CodingUserInfoKey: Any] { self.userInfoSendable }
    let nbt: NBT

    init(codingPath: [any CodingKey], userInfo userInfoSendable: [CodingUserInfoKey: Sendable], nbt: NBT) {
        self.codingPath = codingPath
        self.userInfoSendable = userInfoSendable
        self.nbt = nbt
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard case .compound(let values) = self.nbt else {
            throw DecodingError.typeMismatch([String:Any].self, .init(codingPath: self.codingPath, debugDescription: "Decoded value was not a container, but a \(self.nbt)"))
        }
        return try KeyedDecodingContainer(NBTContainer<Key>(values: values, decoder: self))
    }

    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        guard case .list(let value) = self.nbt else {
            throw DecodingError.typeMismatch([Any].self, .init(codingPath: self.codingPath, debugDescription: "Decoded value was not an array, but a \(self.nbt)"))
        }
        return NBTListDecodingContainer(items: value, decoder: self)
    }

    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        return NBTNamelessSingleValueDecodingContainer(decoder: self, codingPath: self.codingPath)
    }
}

fileprivate struct NBTContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    let decoder: Decoder
    let values: [NBT]

    init(values: [NBT], decoder: Decoder) throws {
        self.decoder = decoder
        self.values = values
    }

    let codingPath: [any CodingKey] = []
    var allKeys: [Key] {
        self.values.compactMap {
            let name: String
            switch $0 {
            case .namedByte(let name_, _):
                name = name_
            case .namedShort(let name_, _):
                name = name_
            case .namedInt32(let name_, _):
                name = name_
            case .namedInt64(let name_, _):
                name = name_
            case .namedFloat(let name_, _):
                name = name_
            case .namedDouble(let name_, _):
                name = name_
            case .namedByteArray(let name_, _):
                name = name_
            case .namedString(let name_, _):
                name = name_
            case .namedList(let name_, _):
                name = name_
            case .namedCompound(let name_, _):
                name = name_
            case .namedInt32Array(let name_, _):
                name = name_
            case .namedInt64Array(let name_, _):
                name = name_
            case .byte, .short, .int32, .int64, .float, .double, .byteArray, .string, .list, .compound, .int32Array, .int64Array:
                fatalError("This shouldn't happen.")
            }

            return Key(stringValue: name)
        }
    }

    func decode(_: Bool.Type, forKey key: Key) throws -> Bool {
        for value in self.values {
            guard
                case .namedByte(let name, let value) = value,
                name == key.stringValue
            else {
                continue
            }

            switch value {
            case 0: return false
            case 1: return true
            default: throw DecodingError.typeMismatch(Bool.self, .init(codingPath: self.codingPath, debugDescription: "Decoding failed, underlying value was \(value)."))
            }
        }

        if self.contains(key) {
            throw DecodingError.typeMismatch(Bool.self, .init(codingPath: self.codingPath, debugDescription: "The value for \(key) was not a boolean / byte"))
        } else {
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "The key \(key) was not found"))
        }
    }

    func decode(_: Int.Type, forKey key: Key) throws -> Int {
        throw DecodingError.typeMismatch(Int.self, .init(codingPath: self.codingPath, debugDescription: "The type Int is not supported by NBT, use either Int32 or Int64"))
    }

    func decode(_: Int64.Type, forKey key: Key) throws -> Int64 {
        for value in self.values {
            guard
                case .namedInt64(let name, let value) = value,
                name == key.stringValue
            else {
                continue
            }

            return .init(bitPattern: value)
        }

        if self.contains(key) {
            throw DecodingError.typeMismatch(Int64.self, .init(codingPath: self.codingPath, debugDescription: "The value for \(key) was not a int64"))
        } else {
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "The key \(key) was not found"))
        }
    }

    func decode(_: Int32.Type, forKey key: Key) throws -> Int32 {
        for value in self.values {
            guard
                case .namedInt32(let name, let value) = value,
                name == key.stringValue
            else {
                continue
            }

            return .init(bitPattern: value)
        }

        if self.contains(key) {
            throw DecodingError.typeMismatch(Int32.self, .init(codingPath: self.codingPath, debugDescription: "The value for \(key) was not a int32"))
        } else {
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "The key \(key) was not found"))
        }
    }

    func decode(_: Int16.Type, forKey key: Key) throws -> Int16 {
        for value in self.values {
            guard
                case .namedShort(let name, let value) = value,
                name == key.stringValue
            else {
                continue
            }

            return .init(bitPattern: value)
        }

        if self.contains(key) {
            throw DecodingError.typeMismatch(Int16.self, .init(codingPath: self.codingPath, debugDescription: "The value for \(key) was not a int16"))
        } else {
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "The key \(key) was not found"))
        }
    }

    func decode(_: Int8.Type, forKey key: Key) throws -> Int8 {
        for value in self.values {
            guard
                case .namedByte(let name, let value) = value,
                name == key.stringValue
            else {
                continue
            }

            return .init(bitPattern: value)
        }

        if self.contains(key) {
            throw DecodingError.typeMismatch(Int8.self, .init(codingPath: self.codingPath, debugDescription: "The value for \(key) was not a byte"))
        } else {
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "The key \(key) was not found"))
        }
    }

    func decode(_: UInt.Type, forKey key: Key) throws -> UInt {
        throw DecodingError.typeMismatch(UInt.self, .init(codingPath: self.codingPath, debugDescription: "The type UInt is not supported by NBT, use either UInt32 or UInt64"))
    }

    func decode(_: UInt64.Type, forKey key: Key) throws -> UInt64 {
        for value in self.values {
            guard
                case .namedInt64(let name, let value) = value,
                name == key.stringValue
            else {
                continue
            }

            return value
        }

        if self.contains(key) {
            throw DecodingError.typeMismatch(UInt64.self, .init(codingPath: self.codingPath, debugDescription: "The value for \(key) was not a uint64"))
        } else {
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "The key \(key) was not found"))
        }
    }

    func decode(_: UInt32.Type, forKey key: Key) throws -> UInt32 {
        for value in self.values {
            guard
                case .namedInt32(let name, let value) = value,
                name == key.stringValue
            else {
                continue
            }

            return value
        }

        if self.contains(key) {
            throw DecodingError.typeMismatch(UInt32.self, .init(codingPath: self.codingPath, debugDescription: "The value for \(key) was not a uint32"))
        } else {
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "The key \(key) was not found"))
        }
    }

    func decode(_: UInt16.Type, forKey key: Key) throws -> UInt16 {
        for value in self.values {
            guard
                case .namedShort(let name, let value) = value,
                name == key.stringValue
            else {
                continue
            }

            return value
        }

        if self.contains(key) {
            throw DecodingError.typeMismatch(UInt16.self, .init(codingPath: self.codingPath, debugDescription: "The value for \(key) was not a uint16"))
        } else {
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "The key \(key) was not found"))
        }
    }

    func decode(_: UInt8.Type, forKey key: Key) throws -> UInt8 {
        for value in self.values {
            guard
                case .namedByte(let name, let value) = value,
                name == key.stringValue
            else {
                continue
            }

            return value
        }

        if self.contains(key) {
            throw DecodingError.typeMismatch(UInt8.self, .init(codingPath: self.codingPath, debugDescription: "The value for \(key) was not a byte"))
        } else {
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "The key \(key) was not found"))
        }
    }

    func decode(_: String.Type, forKey key: Key) throws -> String {
        for value in self.values {
            guard
                case .namedString(let name, let value) = value,
                name == key.stringValue
            else {
                continue
            }

            return value
        }

        if self.contains(key) {
            throw DecodingError.typeMismatch(String.self, .init(codingPath: self.codingPath, debugDescription: "The value for \(key) was not a string"))
        } else {
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "The key \(key) was not found"))
        }
    }

    func decode(_: Float.Type, forKey key: Key) throws -> Float {
        for value in self.values {
            guard
                case .namedFloat(let name, let value) = value,
                name == key.stringValue
            else {
                continue
            }

            return value
        }

        if self.contains(key) {
            throw DecodingError.typeMismatch(Float.self, .init(codingPath: self.codingPath, debugDescription: "The value for \(key) was not a float"))
        } else {
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "The key \(key) was not found"))
        }
    }

    func decode(_: Double.Type, forKey key: Key) throws -> Double {
        for value in self.values {
            guard
                case .namedDouble(let name, let value) = value,
                name == key.stringValue
            else {
                continue
            }

            return value
        }

        if self.contains(key) {
            throw DecodingError.typeMismatch(Double.self, .init(codingPath: self.codingPath, debugDescription: "The value for \(key) was not a double"))
        } else {
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "The key \(key) was not found"))
        }
    }

    func contains(_ key: Key) -> Bool {
        for value in self.values {
            let name: String
            switch value {
            case .namedByte(let name_, _):
                name = name_
            case .namedShort(let name_, _):
                name = name_
            case .namedInt32(let name_, _):
                name = name_
            case .namedInt64(let name_, _):
                name = name_
            case .namedFloat(let name_, _):
                name = name_
            case .namedDouble(let name_, _):
                name = name_
            case .namedByteArray(let name_, _):
                name = name_
            case .namedString(let name_, _):
                name = name_
            case .namedList(let name_, _):
                name = name_
            case .namedCompound(let name_, _):
                name = name_
            case .namedInt32Array(let name_, _):
                name = name_
            case .namedInt64Array(let name_, _):
                name = name_
            case .byte, .short, .int32, .int64, .float, .double, .byteArray, .string, .list, .compound, .int32Array, .int64Array:
                fatalError("This shouldn't happen.")
            }

            guard name == key.stringValue else {
                continue
            }
            return true
        }
        return false
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        return !contains(key)
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        return try T.init(from: self.decoder)
    }

    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        for value in self.values {
            guard
                case .namedCompound(let name, let values) = value,
                name == key.stringValue
            else {
                continue
            }

            let decoder = NBTNamedContainerDecoder(codingPath: [], userInfo: [:], nbt: value)
            return try KeyedDecodingContainer(NBTContainer<NestedKey>(values: values, decoder: decoder))
        }

        if self.contains(key) {
            throw DecodingError.typeMismatch([String:Any].self, .init(codingPath: self.codingPath, debugDescription: "The value for \(key) was not a compound"))
        } else {
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "The key \(key) was not found"))
        }
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        for value in self.values {
            guard
                case .namedList(let name, let value) = value,
                name == key.stringValue
            else {
                continue
            }

            return NBTListDecodingContainer(items: value, decoder: self.decoder)
        }

        if self.contains(key) {
            throw DecodingError.typeMismatch([Any].self, .init(codingPath: self.codingPath, debugDescription: "The value for \(key) was not a list"))
        } else {
            throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "The key \(key) was not found"))
        }
    }

    func superDecoder() throws -> Decoder {
        return self.decoder
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        guard key.stringValue == "super" && key.intValue == 0 else {
            fatalError("TODO")
        }

        fatalError("TODO")
    }
}

fileprivate struct NBTListDecodingContainer: UnkeyedDecodingContainer {
    var currentIndex: Int = 0
    let decoder: Decoder
    let items: [NBT]

    var codingPath: [any CodingKey] { fatalError("TODO") }
    var count: Int? { self.items.count }
    var isAtEnd: Bool { self.currentIndex >= self.items.count }

    init(items: [NBT], decoder: Decoder) {
        self.items = items
        self.decoder = decoder
    }

    fileprivate struct NBTArrayIndex: CodingKey {
        let intValue: Int?
        let stringValue: String

        init(intValue: Int) {
            self.intValue = intValue
            self.stringValue = "\(intValue)"
        }

        @available(*, deprecated, message: "Only present for protocol conformance")
        init(stringValue: String) {
            self.intValue = nil
            self.stringValue = stringValue
        }
    }

    mutating func decodeNil() throws -> Bool {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Bool.self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        return false
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Bool.self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        guard case .byte(let value) = self.items[self.currentIndex] else {
            throw DecodingError.typeMismatch(Bool.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a boolean / byte"))
        }
        switch value {
        case 0:
            self.currentIndex += 1
            return false
        case 1:
            self.currentIndex += 1
            return true
        default: throw DecodingError.typeMismatch(Bool.self, .init(codingPath: self.codingPath, debugDescription: "Decoding failed, underlying value was \(value)."))
        }
    }

    mutating func decode(_ type: String.Type) throws -> String {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(String.self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        guard case .string(let value) = self.items[self.currentIndex] else {
            throw DecodingError.typeMismatch(String.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a string"))
        }
        self.currentIndex += 1
        return value
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Float.self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        guard case .float(let value) = self.items[self.currentIndex] else {
            throw DecodingError.typeMismatch(Float.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a float"))
        }
        self.currentIndex += 1
        return value
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Double.self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        guard case .double(let value) = self.items[self.currentIndex] else {
            throw DecodingError.typeMismatch(Double.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a double"))
        }
        self.currentIndex += 1
        return value
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        throw DecodingError.typeMismatch(Int.self, .init(codingPath: self.codingPath, debugDescription: "The type Int is not supported by NBT, use either Int32 or Int64"))
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Int64.self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        guard case .int64(let value) = self.items[self.currentIndex] else {
            throw DecodingError.typeMismatch(Int64.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a int64"))
        }
        self.currentIndex += 1
        return .init(bitPattern: value)
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Int32.self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        guard case .int32(let value) = self.items[self.currentIndex] else {
            throw DecodingError.typeMismatch(Int32.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a int32"))
        }
        self.currentIndex += 1
        return .init(bitPattern: value)
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Int16.self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        guard case .short(let value) = self.items[self.currentIndex] else {
            throw DecodingError.typeMismatch(Int16.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a int16"))
        }
        self.currentIndex += 1
        return .init(bitPattern: value)
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Int8.self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        guard case .byte(let value) = self.items[self.currentIndex] else {
            throw DecodingError.typeMismatch(Int8.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a byte"))
        }
        self.currentIndex += 1
        return .init(bitPattern: value)
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        throw DecodingError.typeMismatch(UInt.self, .init(codingPath: self.codingPath, debugDescription: "The type UInt is not supported by NBT, use either UInt32 or UInt64"))
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(UInt64.self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        guard case .int64(let value) = self.items[self.currentIndex] else {
            throw DecodingError.typeMismatch(UInt64.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a uint64"))
        }
        self.currentIndex += 1
        return value
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(UInt32.self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        guard case .int32(let value) = self.items[self.currentIndex] else {
            throw DecodingError.typeMismatch(UInt32.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a uint32"))
        }
        self.currentIndex += 1
        return value
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(UInt16.self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        guard case .short(let value) = self.items[self.currentIndex] else {
            throw DecodingError.typeMismatch(UInt16.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a uint16"))
        }
        self.currentIndex += 1
        return value
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(UInt8.self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        guard case .byte(let value) = self.items[self.currentIndex] else {
            throw DecodingError.typeMismatch(UInt8.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a byte"))
        }
        self.currentIndex += 1
        return value
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(T.self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        let decoder = NBTNamelessContainerDecoder(codingPath: [], userInfo: [:], nbt: self.items[self.currentIndex])
        let result = try T(from: decoder)
        self.currentIndex += 1
        return result
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound([String:Any].self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        guard case .compound(let values) = self.items[self.currentIndex] else {
            throw DecodingError.typeMismatch([String:Any].self, .init(codingPath: self.codingPath, debugDescription: "The value was not a compound"))
        }

        self.currentIndex += 1

        let decoder = NBTNamedContainerDecoder(codingPath: [], userInfo: [:], nbt: self.items[self.currentIndex])
        return try KeyedDecodingContainer(NBTContainer<NestedKey>(values: values, decoder: decoder))
    }

    mutating func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound([Any].self, .init(codingPath: self.codingPath, debugDescription: "Value does not exist"))
        }
        guard case .list(let items) = self.items[self.currentIndex] else {
            throw DecodingError.typeMismatch([Any].self, .init(codingPath: self.codingPath, debugDescription: "The value was not an array"))
        }

        self.currentIndex += 1

        return NBTListDecodingContainer(items: items, decoder: self.decoder)
    }

    func superDecoder() throws -> Decoder {
        return self.decoder
    }
}

fileprivate struct NBTNamedSingleValueDecodingContainer: SingleValueDecodingContainer {
    let decoder: NBTNamedContainerDecoder
    let codingPath: [any CodingKey]

    init(decoder: NBTNamedContainerDecoder, codingPath: [any CodingKey]) {
        self.decoder = decoder
        self.codingPath = codingPath
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try T.init(from: self.decoder)
    }

    func decodeNil() -> Bool {
        return false
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        guard case .namedByte(_, let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(Bool.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a boolean / byte"))
        }
        switch value {
        case 0: return false
        case 1: return true
        default: throw DecodingError.typeMismatch(Bool.self, .init(codingPath: self.codingPath, debugDescription: "Decoding failed, underlying value was \(value)."))
        }
    }

    func decode(_ type: Float.Type) throws -> Float {
        guard case .namedFloat(_, let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(Float.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a float"))
        }
        return value
    }

    func decode(_ type: Double.Type) throws -> Double {
        guard case .namedDouble(_, let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(Double.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a double"))
        }
        return value
    }

    func decode(_ type: Int.Type) throws -> Int {
        throw DecodingError.typeMismatch(Int.self, .init(codingPath: self.codingPath, debugDescription: "The type Int is not supported by NBT, use either Int32 or Int64"))
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        guard case .namedInt64(_, let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(Int64.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a int64"))
        }
        return .init(bitPattern: value)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        guard case .namedInt32(_, let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(Int32.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a int32"))
        }
        return .init(bitPattern: value)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        guard case .namedShort(_, let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(Int16.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a int16"))
        }
        return .init(bitPattern: value)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        guard case .namedByte(_, let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(Int8.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a byte"))
        }
        return .init(bitPattern: value)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        throw DecodingError.typeMismatch(UInt.self, .init(codingPath: self.codingPath, debugDescription: "The type UInt is not supported by NBT, use either UInt32 or UInt64"))
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard case .namedInt64(_, let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(UInt64.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a uint64"))
        }
        return value
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard case .namedInt32(_, let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(UInt32.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a uint32"))
        }
        return value
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard case .namedShort(_, let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(UInt16.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a uint16"))
        }
        return value
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard case .namedByte(_, let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(UInt8.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a byte"))
        }
        return value
    }

    func decode(_ type: String.Type) throws -> String {
        guard case .namedString(_, let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(String.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a string"))
        }
        return value
    }
}

fileprivate struct NBTNamelessSingleValueDecodingContainer: SingleValueDecodingContainer {
    let decoder: NBTNamelessContainerDecoder
    let codingPath: [any CodingKey]

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try T.init(from: self.decoder)
    }

    func decodeNil() -> Bool {
        return false
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        guard case .byte(let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(Bool.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a boolean / byte"))
        }
        switch value {
        case 0: return false
        case 1: return true
        default: throw DecodingError.typeMismatch(Bool.self, .init(codingPath: self.codingPath, debugDescription: "Decoding failed, underlying value was \(value)."))
        }
    }

    func decode(_ type: Float.Type) throws -> Float {
        guard case .float(let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(Float.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a float"))
        }
        return value
    }

    func decode(_ type: Double.Type) throws -> Double {
        guard case .double(let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(Double.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a double"))
        }
        return value
    }

    func decode(_ type: Int.Type) throws -> Int {
        throw DecodingError.typeMismatch(Int.self, .init(codingPath: self.codingPath, debugDescription: "The type Int is not supported by NBT, use either Int32 or Int64"))
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        guard case .int64(let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(Int64.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a int64"))
        }
        return .init(bitPattern: value)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        guard case .int32(let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(Int32.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a int32"))
        }
        return .init(bitPattern: value)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        guard case .short(let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(Int16.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a int16"))
        }
        return .init(bitPattern: value)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        guard case .byte(let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(Int8.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a byte"))
        }
        return .init(bitPattern: value)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        throw DecodingError.typeMismatch(UInt.self, .init(codingPath: self.codingPath, debugDescription: "The type UInt is not supported by NBT, use either UInt32 or UInt64"))
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard case .int64(let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(UInt64.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a uint64"))
        }
        return value
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard case .int32(let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(UInt32.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a uint32"))
        }
        return value
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard case .short(let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(UInt16.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a uint16"))
        }
        return value
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard case .byte(let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(UInt8.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a byte"))
        }
        return value
    }

    func decode(_ type: String.Type) throws -> String {
        guard case .string(let value) = self.decoder.nbt else {
            throw DecodingError.typeMismatch(String.self, .init(codingPath: self.codingPath, debugDescription: "The value was not a string"))
        }
        return value
    }
}
