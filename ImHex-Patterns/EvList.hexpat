import std.io;
import std.mem;
import type.base;

struct Header
{
    u8 signature[4];
    u8 version;
    u8 unknown1[3];
    u32 unknown2;
    u32 entryCount;
};

struct Entry
{
    type::Hex<u32> unknown1;
    u32 unknown2;
    char name[];
    u32 unknown3;
    u16 unknown4;
    type::Hex<u16> unknown5;
    u8 unknown6[3];
} [[single_color]];

Header header @ 0x00;
Entry entries[header.entryCount] @ 0x10;