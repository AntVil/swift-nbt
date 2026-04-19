import Foundation
import NIOCore

indirect enum NBT {
    case namedByte(name: String, value: UInt8)
    case namedShort(name: String, value: UInt16)
    case namedInt32(name: String, value: UInt32)
    case namedInt64(name: String, value: UInt64)
    case namedFloat(name: String, value: Float)
    case namedDouble(name: String, value: Double)
    case namedByteArray(name: String, value: [UInt8])
    case namedString(name: String, value: String)
    case namedList(name: String, value: [NBT])
    case namedCompound(name: String, value: [NBT])
    case namedInt32Array(name: String, value: [UInt32])
    case namedInt64Array(name: String, value: [UInt64])
    case byte(value: UInt8)
    case short(value: UInt16)
    case int32(value: UInt32)
    case int64(value: UInt64)
    case float(value: Float)
    case double(value: Double)
    case byteArray(value: [UInt8])
    case string(value: String)
    case list(value: [NBT])
    case compound(value: [NBT])
    case int32Array(value: [UInt32])
    case int64Array(value: [UInt64])

    public static func named<T>(from data: inout IndexingIterator<T>) throws -> Self where T.Element == UInt8 {
        let result = try Self.named(&data)

        guard data.next() == nil else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The parsed data wasn't fully consumed"))
        }
        return result
    }

    public static func unnamed<T>(from data: inout IndexingIterator<T>) throws -> Self where T.Element == UInt8 {
        let result = try Self.unnamed(&data)

        guard data.next() == nil else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The parsed data wasn't fully consumed"))
        }
        return result
    }

    static func string<T, Length: FixedWidthInteger>(_ data: inout IndexingIterator<T>, length: Length) throws -> String where T.Element == UInt8 {
        let bytes = try (0 ..< length).map { _ in
            guard let byte = data.next() else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse string of length \(length)."))
            }

            return byte
        }

        guard let result = String(data: Data(bytes), encoding: .utf8) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "A invalid string with the length \(length) was found"))
        }

        return result
    }

    static func named<T>(_ data: inout IndexingIterator<T>) throws -> Self where T.Element == UInt8 {
        guard let type = data.next() else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse type."))
        }
        return try Self.named(&data, type: type)
    }

    static func named<T>(_ data: inout IndexingIterator<T>, type: UInt8) throws -> Self where T.Element == UInt8 {
        guard let nameLength = Self.short(from: &data) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse name of type \(type)."))
        }

        let name = try string(&data, length: nameLength)

        switch type {
        case 1:
            guard let result = Self.byte(from: &data) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse byte named \(name)."))
            }
            return .namedByte(name: name, value: result)
        case 2:
            guard let result = Self.short(from: &data) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse short named \(name)."))
            }
            return .namedShort(name: name, value: result)
        case 3:
            guard let result = Self.int32(from: &data) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse int32 named \(name)."))
            }
            return .namedInt32(name: name, value: result)
        case 4:
            guard let result = Self.int64(from: &data) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse int64 named \(name)."))
            }
            return .namedInt64(name: name, value: result)
        case 5:
            guard let result = Self.float(from: &data) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse float named \(name)."))
            }
            return .namedFloat(name: name, value: result)
        case 6:
            guard let result = Self.double(from: &data) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse double named \(name)."))
            }
            return .namedDouble(name: name, value: result)
        case 7:
            let result = try Self.byteArray(from: &data)
            return .namedByteArray(name: name, value: result)
        case 8:
            let result = try Self.string(from: &data)
            return .namedString(name: name, value: result)
        case 9:
            let result = try Self.listItems(from: &data)
            return .namedList(name: name, value: result)
        case 10:
            let result = try Self.compound(from: &data)
            return .namedCompound(name: name, value: result)
        case 11:
            let result = try Self.int32Array(from: &data)
            return .namedInt32Array(name: name, value: result)
        case 12:
            let result = try Self.int64Array(from: &data)
            return .namedInt64Array(name: name, value: result)
        default:
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "A invalid nbt type tag \(type) was found"))
        }
    }

    static func byte<T>(from data: inout IndexingIterator<T>) -> UInt8? where T.Element == UInt8 {
        return data.next()
    }

    static func short<T>(from data: inout IndexingIterator<T>) -> UInt16? where T.Element == UInt8 {
        guard
            let byte1 = data.next(),
            let byte2 = data.next()
        else {
            return nil
        }

        return (UInt16(byte1) << 8) | UInt16(byte2)
    }

    static func int32<T>(from data: inout IndexingIterator<T>) -> UInt32? where T.Element == UInt8 {
        guard
            let byte1 = data.next(),
            let byte2 = data.next(),
            let byte3 = data.next(),
            let byte4 = data.next()
        else {
            return nil
        }

        return (UInt32(byte1) << 24) | (UInt32(byte2) << 16) | (UInt32(byte3) << 8) | UInt32(byte4)
    }

    static func int64<T>(from data: inout IndexingIterator<T>) -> UInt64? where T.Element == UInt8 {
        guard
            let byte1 = data.next(),
            let byte2 = data.next(),
            let byte3 = data.next(),
            let byte4 = data.next(),
            let byte5 = data.next(),
            let byte6 = data.next(),
            let byte7 = data.next(),
            let byte8 = data.next()
        else {
            return nil
        }

        return (UInt64(byte1) << 56) | (UInt64(byte2) << 48) | (UInt64(byte3) << 40) | (UInt64(byte4) << 32) | (UInt64(byte5) << 24) | (UInt64(byte6) << 16) | (UInt64(byte7) << 8) | UInt64(byte8)
    }

    static func float<T>(from data: inout IndexingIterator<T>) -> Float? where T.Element == UInt8 {
        guard let raw = Self.int32(from: &data) else {
            return nil
        }
        return .init(bitPattern: raw)
    }

    static func double<T>(from data: inout IndexingIterator<T>) -> Double? where T.Element == UInt8 {
        guard let raw = Self.int64(from: &data) else {
            return nil
        }
        return .init(bitPattern: raw)
    }

    static func string<T>(from data: inout IndexingIterator<T>) throws -> String where T.Element == UInt8 {
        guard let length = Self.short(from: &data) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse string length."))
        }

        return try Self.string(&data, length: length)
    }

    static func byteArray<T>(from data: inout IndexingIterator<T>) throws -> [UInt8] where T.Element == UInt8 {
        guard let length = Self.int32(from: &data).flatMap({ Int($0) }) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse byte array length."))
        }

        return try byteValues(from: &data, length: length)
    }

    static func byteValues<T>(from data: inout IndexingIterator<T>, length: Int) throws -> [UInt8] where T.Element == UInt8 {
        return try (0 ..< length).map { _ in
            guard let byte = data.next() else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse byte array of legnth \(length)."))
            }

            return byte
        }
    }

    static func shortValues<T>(from data: inout IndexingIterator<T>, length: Int) throws -> [UInt16] where T.Element == UInt8 {
        return try (0 ..< MemoryLayout<UInt16>.size * length)
            .map { _ in
                guard let byte = data.next() else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse int32 array item."))
                }

                return byte
            }
            .withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
                return (0 ..< length).map { (index: Int) in
                    return buffer.loadUnaligned(fromByteOffset: index * MemoryLayout<UInt16>.size, as: UInt16.self).bigEndian
                }
            }
    }

    static func int32Array<T>(from data: inout IndexingIterator<T>) throws -> [UInt32] where T.Element == UInt8 {
        guard let length = Self.int32(from: &data).flatMap({ Int($0) }) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse int32 array length."))
        }

        return try int32Values(from: &data, length: length)
    }

    static func int32Values<T>(from data: inout IndexingIterator<T>, length: Int) throws -> [UInt32] where T.Element == UInt8 {
        return try (0 ..< MemoryLayout<UInt32>.size * length)
            .map { _ in
                guard let byte = data.next() else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse int32 array item."))
                }

                return byte
            }
            .withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
                return (0 ..< length).map { (index: Int) in
                    return buffer.loadUnaligned(fromByteOffset: index * MemoryLayout<UInt32>.size, as: UInt32.self).bigEndian
                }
            }
    }

    static func int64Array<T>(from data: inout IndexingIterator<T>) throws -> [UInt64] where T.Element == UInt8 {
        guard let length = Self.int32(from: &data).flatMap({ Int($0) }) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse int64 array length."))
        }

        return try Self.int64Values(from: &data, length: length)
    }

    static func int64Values<T>(from data: inout IndexingIterator<T>, length: Int) throws -> [UInt64] where T.Element == UInt8 {
        return try (0 ..< MemoryLayout<UInt64>.size * length)
            .map { _ in
                guard let byte = data.next() else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse int64 values item."))
                }

                return byte
            }
            .withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
                return (0 ..< length).map { (index: Int) in
                    return buffer.loadUnaligned(fromByteOffset: index * MemoryLayout<UInt64>.size, as: UInt64.self).bigEndian
                }
            }
    }

    static func listItems<T>(from data: inout IndexingIterator<T>) throws -> [Self] where T.Element == UInt8 {
        guard let itemType = data.next() else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse list item type"))
        }
        guard let length = Self.int32(from: &data).flatMap({ Int($0) }) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse list length"))
        }

        switch itemType {
        case 1:
            return try Self.byteValues(from: &data, length: length).map {
                return Self.byte(value: $0)
            }
        case 2:
            return try Self.shortValues(from: &data, length: length).map {
                return Self.short(value: $0)
            }
        case 3:
            return try Self.int32Values(from: &data, length: length).map {
                return Self.int32(value: $0)
            }
        case 4:
            return try Self.int64Values(from: &data, length: length).map {
                return Self.int64(value: $0)
            }
        case 5:
            return try (0 ..< length).map { _ in
                guard let value = Self.float(from: &data) else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse list float item"))
                }
                return Self.float(value: value)
            }
        case 6:
            return try (0 ..< length).map { _ in
                guard let value = Self.double(from: &data) else {
                    throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse list double item"))
                }
                return Self.double(value: value)
            }
        case 7:
            var items = [NBT]()
            for _ in 0 ..< length {
                let result = try Self.byteArray(from: &data)
                items.append(Self.byteArray(value: result))
            }
            return items
        case 8:
            var items = [NBT]()
            for _ in 0 ..< length {
                let result = try Self.string(from: &data)
                items.append(Self.string(value: result))
            }
            return items
        case 9:
            var items = [NBT]()
            for _ in 0 ..< length {
                let item = try Self.listItems(from: &data)
                items.append(Self.list(value: item))
            }
            return items
        case 10:
            var items = [NBT]()
            for _ in 0 ..< length {
                let result = try Self.compound(from: &data)
                items.append(Self.compound(value: result))
            }
            return items
        case 11:
            var items = [NBT]()
            for _ in 0 ..< length {
                let result = try Self.int32Array(from: &data)
                items.append(Self.int32Array(value: result))
            }
            return items
        case 12:
            var items = [NBT]()
            for _ in 0 ..< length {
                let result = try Self.int64Array(from: &data)
                items.append(Self.int64Array(value: result))
            }
            return items
        default:
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "A invalid nbt type tag \(itemType) in a list was found"))
        }
    }

    static func compound<T>(from data: inout IndexingIterator<T>) throws -> [Self] where T.Element == UInt8 {
        var byte: UInt8

        guard let byte_ = data.next() else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse compound."))
        }
        byte = byte_

        var items = [Self]()

        while byte != 0 {
            let item = try Self.named(&data, type: byte)

            items.append(item)

            guard let byte_ = data.next() else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse compound."))
            }
            byte = byte_
        }

        return items
    }

    static func unnamed<T>(_ data: inout IndexingIterator<T>) throws -> Self where T.Element == UInt8 {
        guard let type = data.next() else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse type."))
        }

        switch type {
        case 1:
            guard let result = Self.byte(from: &data) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse byte."))
            }
            return .byte(value: result)
        case 2:
            guard let result = Self.short(from: &data) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse short."))
            }
            return .short(value: result)
        case 3:
            guard let result = Self.int32(from: &data) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse int32."))
            }
            return .int32(value: result)
        case 4:
            guard let result = Self.int64(from: &data) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse int64."))
            }
            return .int64(value: result)
        case 5:
            guard let result = Self.float(from: &data) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse float."))
            }
            return .float(value: result)
        case 6:
            guard let result = Self.double(from: &data) else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data for parsing ended prematurely, could not parse double."))
            }
            return .double(value: result)
        case 7:
            let result = try Self.byteArray(from: &data)
            return .byteArray(value: result)
        case 8:
            let result = try Self.string(from: &data)
            return .string(value: result)
        case 9:
            let result = try Self.listItems(from: &data)
            return .list(value: result)
        case 10:
            let result = try Self.compound(from: &data)
            return .compound(value: result)
        case 11:
            let result = try Self.int32Array(from: &data)
            return .int32Array(value: result)
        case 12:
            let result = try Self.int64Array(from: &data)
            return .int64Array(value: result)
        default:
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "A invalid nbt type tag \(type) was found"))
        }
    }
}
