import Testing

@testable import NBT

// TODO: these tests need to be adapted

/*
@Test func parseNamedNBTPrimitives() async throws {
    try NBT.named(from: [1, 0, 1, 65, 255])
}

@Test func parseNamelessNBTPrimitives() async throws {
    try NBT.unnamed(from: [1, 0])
    try NBT.unnamed(from: [1, 1])
}

@Test func parseNamedNBTCompound() async throws {
    try NBT.named(from: [
        10, // Comp
        0, 1, 65, // name
        1, 0, 1, 66, 1, // byte "B": 1
        8, 0, 1, 67, 0, 1, 68, // string "C": "D"
        10, 0, 1, 97, // comp "a"
            2, 0, 1, 98, 255, 255, // short "b" = 65535
            0, // comp end
        0 // comp end
    ])
}

@Test func parseNamedNBTList() async throws {
    try NBT.named(from: [
        9, // list
        0, 1, 65, // name
        1, // items: byte
        0, 0, 0, 3, // length
        0, 1, 255 // byte: 1
    ])

    try NBT.named(from: [
        9, // list
        0, 1, 65, // name
        2, // items: short
        0, 0, 0, 1, // length
        0, 1 // short: 1
    ])

    try NBT.named(from: [
        9, // list
        0, 1, 65, // name
        3, // items: int32
        0, 0, 0, 1, // length
        0, 0, 0, 1 // int32: 1
    ])

    try NBT.named(from: [
        9, // list
        0, 1, 65, // name
        4, // items: int64
        0, 0, 0, 1, // length
        0, 0, 0, 0, 0, 0, 0, 1 // int64: 1
    ].makeIterator())
}
*/
