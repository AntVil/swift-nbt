import Testing

@testable import NBT


@Test func decodeNamedNBTPrimitives() throws {
    let decoder = NBTDecoder()

    #expect(try decoder.decodeNamed(Bool.self, from: [1, 0, 0, 0]) == false)
    #expect(try decoder.decodeNamed(Bool.self, from: [1, 0, 0, 1]) == true)
    #expect(try decoder.decodeNamed(Bool.self, from: [1, 0, 1, 65, 0]) == false)
    #expect(try decoder.decodeNamed(Bool.self, from: [1, 0, 1, 65, 1]) == true)

    #expect(try decoder.decodeNamed(UInt8.self, from: [1, 0, 0, 0]) == 0)
    #expect(try decoder.decodeNamed(UInt8.self, from: [1, 0, 0, 255]) == 255)
    #expect(try decoder.decodeNamed(UInt8.self, from: [1, 0, 1, 65, 0]) == 0)
    #expect(try decoder.decodeNamed(UInt8.self, from: [1, 0, 1, 65, 255]) == 255)

    #expect(try decoder.decodeNamed(Int8.self, from: [1, 0, 0, 0]) == 0)
    #expect(try decoder.decodeNamed(Int8.self, from: [1, 0, 0, 255]) == -1)
    #expect(try decoder.decodeNamed(Int8.self, from: [1, 0, 1, 65, 0]) == 0)
    #expect(try decoder.decodeNamed(Int8.self, from: [1, 0, 1, 65, 255]) == -1)

    #expect(try decoder.decodeNamed(String.self, from: [8, 0, 0, 0, 0]) == "")
    #expect(try decoder.decodeNamed(String.self, from: [8, 0, 0, 0, 1, 65]) == "A")
    #expect(try decoder.decodeNamed(String.self, from: [8, 0, 1, 65, 0, 0]) == "")
    #expect(try decoder.decodeNamed(String.self, from: [8, 0, 1, 65, 0, 1, 65]) == "A")

}

@Test func decodeNamelessNBTPrimitives() throws {
    let decoder = NBTDecoder()

    #expect(try decoder.decodeNameless(Bool.self, from: [1, 0]) == false)
    #expect(try decoder.decodeNameless(Bool.self, from: [1, 1]) == true)

    #expect(try decoder.decodeNameless(UInt8.self, from: [1, 0]) == 0)
    #expect(try decoder.decodeNameless(UInt8.self, from: [1, 255]) == 255)

    #expect(try decoder.decodeNameless(Int8.self, from: [1, 0]) == 0)
    #expect(try decoder.decodeNameless(Int8.self, from: [1, 255]) == -1)

    #expect(try decoder.decodeNameless(String.self, from: [8, 0, 0]) == "")
    #expect(try decoder.decodeNameless(String.self, from: [8, 0, 1, 65]) == "A")

}

@Test func decodeNamedNBTCompound() throws {
    let decoder = NBTDecoder()

    #expect(try decoder.decodeNamed(CompoundBool.self, from: [10, 0, 0, 0]) == CompoundBool(a: nil))
    #expect(try decoder.decodeNamed(CompoundBool.self, from: [10, 0, 0, 1, 0, 1, 65, 0, 0]) == CompoundBool(a: false))
    #expect(try decoder.decodeNamed(CompoundBool.self, from: [10, 0, 0, 1, 0, 1, 65, 1, 0]) == CompoundBool(a: true))

    #expect(try decoder.decodeNamed(CompoundBool.self, from: [10, 0, 1, 65, 0]) == CompoundBool(a: nil))
    #expect(try decoder.decodeNamed(CompoundBool.self, from: [10, 0, 1, 65, 1, 0, 1, 65, 0, 0]) == CompoundBool(a: false))
    #expect(try decoder.decodeNamed(CompoundBool.self, from: [10, 0, 1, 65, 1, 0, 1, 65, 1, 0]) == CompoundBool(a: true))

}

@Test func decodeNamelessNBTCompound() throws {
    let decoder = NBTDecoder()

    #expect(try decoder.decodeNameless(CompoundBool.self, from: [10, 0]) == CompoundBool(a: nil))
    #expect(try decoder.decodeNameless(CompoundBool.self, from: [10, 1, 0, 1, 65, 0, 0]) == CompoundBool(a: false))
    #expect(try decoder.decodeNameless(CompoundBool.self, from: [10, 1, 0, 1, 65, 1, 0]) == CompoundBool(a: true))
    #expect(try decoder.decodeNameless(CompoundBool.self, from: [10, 1, 0, 1, 66, 1, 0]) == CompoundBool(a: nil))

}

@Test func decodeNamedNBTArray() throws {
    let decoder = NBTDecoder()

    #expect(try decoder.decodeNameless(NBTByteArray.self, from: [7, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless(NBTByteArray.self, from: [7, 0, 0, 0, 3, 0, 1, 255]) == [0, 1, 255])

    #expect(try decoder.decodeNameless(NBTInt32Array.self, from: [11, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless(NBTInt32Array.self, from: [11, 0, 0, 0, 3, 0, 0, 0, 0, 255, 0, 0, 0, 255, 255, 255, 255]) == [0, 255 << (3 * 8), .max])

    #expect(try decoder.decodeNameless(NBTInt64Array.self, from: [12, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless(NBTInt64Array.self, from: [12, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255]) == [0, 255 << (7 * 8), .max])
}

@Test func decodeNamedNBTList() throws {
    let decoder = NBTDecoder()

    #expect(try decoder.decodeNamed([Bool].self, from: [9, 0, 0, 1, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNamed([Bool].self, from: [9, 0, 0, 1, 0, 0, 0, 1, 1]) == [true])
    #expect(try decoder.decodeNamed([Bool].self, from: [9, 0, 0, 1, 0, 0, 0, 2, 1, 0]) == [true, false])
    #expect(try decoder.decodeNamed([Bool].self, from: [9, 0, 1, 65, 1, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNamed([Bool].self, from: [9, 0, 1, 65, 1, 0, 0, 0, 1, 1]) == [true])
    #expect(try decoder.decodeNamed([Bool].self, from: [9, 0, 1, 65, 1, 0, 0, 0, 2, 1, 0]) == [true, false])

}

@Test func decodeNamelessNBTList() throws {
    let decoder = NBTDecoder()

    #expect(try decoder.decodeNameless([Bool].self, from: [9, 1, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless([Bool].self, from: [9, 1, 0, 0, 0, 1, 1]) == [true])
    #expect(try decoder.decodeNameless([Bool].self, from: [9, 1, 0, 0, 0, 2, 1, 0]) == [true, false])

    #expect(try decoder.decodeNameless([UInt8].self, from: [9, 1, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless([UInt8].self, from: [9, 1, 0, 0, 0, 1, 255]) == [.max])
    #expect(try decoder.decodeNameless([UInt8].self, from: [9, 1, 0, 0, 0, 2, 255, 0]) == [.max, 0])

    #expect(try decoder.decodeNameless([UInt16].self, from: [9, 2, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless([UInt16].self, from: [9, 2, 0, 0, 0, 1, 255, 255]) == [.max])
    #expect(try decoder.decodeNameless([UInt16].self, from: [9, 2, 0, 0, 0, 3, 255, 255, 255, 0, 0, 0]) == [.max, 255 << 8, 0])

    #expect(try decoder.decodeNameless([UInt32].self, from: [9, 3, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless([UInt32].self, from: [9, 3, 0, 0, 0, 1, 255, 255, 255, 255]) == [.max])
    #expect(try decoder.decodeNameless([UInt32].self, from: [9, 3, 0, 0, 0, 3, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0]) == [.max, 255 << (3 * 8), 0])

    #expect(try decoder.decodeNameless([UInt64].self, from: [9, 4, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless([UInt64].self, from: [9, 4, 0, 0, 0, 1, 255, 255, 255, 255, 255, 255, 255, 255]) == [.max])
    #expect(try decoder.decodeNameless([UInt64].self, from: [9, 4, 0, 0, 0, 3, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) == [.max, 255 << (7 * 8), 0])

    #expect(try decoder.decodeNameless([Int8].self, from: [9, 1, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless([Int8].self, from: [9, 1, 0, 0, 0, 1, 127]) == [.max])
    #expect(try decoder.decodeNameless([Int8].self, from: [9, 1, 0, 0, 0, 2, 127, 0]) == [.max, 0])

    #expect(try decoder.decodeNameless([Int16].self, from: [9, 2, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless([Int16].self, from: [9, 2, 0, 0, 0, 1, 127, 255]) == [.max])
    #expect(try decoder.decodeNameless([Int16].self, from: [9, 2, 0, 0, 0, 3, 127, 255, 127, 0, 0, 0]) == [.max, 127 << 8, 0])

    #expect(try decoder.decodeNameless([Int32].self, from: [9, 3, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless([Int32].self, from: [9, 3, 0, 0, 0, 1, 127, 255, 255, 255]) == [.max])
    #expect(try decoder.decodeNameless([Int32].self, from: [9, 3, 0, 0, 0, 3, 127, 255, 255, 255, 127, 0, 0, 0, 0, 0, 0, 0]) == [.max, 127 << (3 * 8), 0])

    #expect(try decoder.decodeNameless([Int64].self, from: [9, 4, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless([Int64].self, from: [9, 4, 0, 0, 0, 1, 127, 255, 255, 255, 255, 255, 255, 255]) == [.max])
    #expect(try decoder.decodeNameless([Int64].self, from: [9, 4, 0, 0, 0, 3, 127, 255, 255, 255, 255, 255, 255, 255, 127, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]) == [.max, 127 << (7 * 8), 0])

    #expect(try decoder.decodeNameless([String].self, from: [9, 8, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless([String].self, from: [9, 8, 0, 0, 0, 1, 0, 0]) == [""])
    #expect(try decoder.decodeNameless([String].self, from: [9, 8, 0, 0, 0, 3, 0, 0, 0, 1, 65, 0, 2, 65, 66]) == ["", "A", "AB"])

    #expect(try decoder.decodeNameless([CompoundBool].self, from: [9, 10, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless([CompoundBool].self, from: [9, 10, 0, 0, 0, 3, 1, 0, 1, 65, 1, 0, 1, 0, 1, 65, 0, 0, 0]) == [.init(a: true), .init(a: false), .init(a: nil)])

    #expect(try decoder.decodeNameless([NBTByteArray].self, from: [9, 7, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless([NBTByteArray].self, from: [9, 7, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 2, 255, 0]) == [[], [1], [255, 0]])

    #expect(try decoder.decodeNameless([NBTInt32Array].self, from: [9, 11, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless([NBTInt32Array].self, from: [9, 11, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 255, 0, 0, 0, 0]) == [[], [1], [255, 0]])

    #expect(try decoder.decodeNameless([NBTInt64Array].self, from: [9, 12, 0, 0, 0, 0]) == [])
    #expect(try decoder.decodeNameless([NBTInt64Array].self, from: [9, 12, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0]) == [[], [1], [255, 0]])

}

struct CompoundBool: Decodable, Equatable {
    let a: Bool?

    enum CodingKeys: String, CodingKey {
        case a = "A"
    }
}
