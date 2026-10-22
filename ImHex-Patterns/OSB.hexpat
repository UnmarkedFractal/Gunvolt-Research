import std.io;
import std.mem;
import type.base;
 
struct Header 
{
    type::Hex<u32> headerSize;
    u32 unknown1;
    u32 unknown2;
    u32 unknown3;
    u32 unknown4;
    u32 unknown5;
    type::Hex<u32> unknown6;
    type::Hex<u32> spriteBlockOffset;
    u32 animationCount;
    u32 spriteCount;
    type::Hex<u32> spriteUnknownOffset;
    u32 unknown7;
    u32 unknown8;
    u32 unknown9;
    u16 unknown10_0;
    u16 unknown3Count;
    u16 unknown4Count;
    u16 totalShaderCount;
    u16 pixelShaderCount;
    u16 unknown12_1;
    u16 unknown13_0;
    u16 unknownThing4Size;
    u16 unknown14_0;
    u16 unknown14_1;
    type::Hex<u32> imageDataOffset;
    type::Hex<u32> unknown3Offset;
    type::Hex<u32> unknown4Offset;
    type::Hex<u32> shaderBlockOffset;
    type::Hex<u32> unknownBlockOffset;
    u32 unknown16;
    type::Hex<u32> imageDataOffset_Offset0;
    type::Hex<u32> imageDataOffset_Offset1;
};
 
Header header @ 0x00;

union AnimationKeyFrameValue
{
    u32 value_u32;
    float value_f32;
};

struct AnimationKeyFrame
{
    float time; // -FLT_MAX for 1st frame, FLT_MAX for last frame
    u32 unknown1;
    AnimationKeyFrameValue;
    u32 unknown3;
    u32 unknown4;
};

struct AnimationKeyFrameList
{
    u32 headerSize;
    u32 frameCount;
    u32 type;
    type::Hex<u32> unknown2;
    type::Hex<u32> unknown3;
    
    AnimationKeyFrame keyFrames[frameCount];
};

struct AnimationTrack
{
    u32 headerSize;
    type::Hex<u32> hash;
    type::Hex<u32> unknownHash;
    type::Hex<u32> unknown1;
    AnimationKeyFrameList* keyFrameList : u32;
    type::Hex<u32> unknown3;
    type::Hex<u32> unknown4;
    type::Hex<u32> unknown5;
    type::Hex<u32> unknown6;
    type::Hex<u32> unknown7;
    type::Hex<u32> unknown8;
    type::Hex<u32> unknown9;
    type::Hex<u32> unknown10;
    type::Hex<u32> unknown11;
    type::Hex<u32> unknown12;
    type::Hex<u32> unknown13;
    type::Hex<u32> unknown14;
    type::Hex<u32> unknown15;
};

struct AnimationEntry
{
    u32 headerSize;
    type::Hex<u32> hash;
    float duration;
    u32 unknown2;
    u32 unknown3;
    u32 trackCount;
    AnimationTrack* tracks[trackCount] : u32;
};

struct AnimationBlock
{
    if (header.animationCount > 0)
    {
        AnimationEntry animations[header.animationCount];
    }
} [[single_color]];
 
AnimationBlock animationBlock @ header.headerSize;
 
struct Pixel 
{
     u8 b;
     u8 g;
     u8 r;
     u8 a;
} [[static, single_color, color(std::format("{:02X}{:02X}{:02X}", r, g, b))]];
 
struct SpriteUnknown1
{
     type::Hex<u32> unknown0;
     type::Hex<u32> imageDataOffset1;
     type::Hex<u32> unknown2;
     type::Hex<u32> imageDataOffset2;
} [[single_color]];

struct ImageBlock
{
    type::Hex<u32> imageDataOffset;
    type::Hex<u32> imageDataSize;
    type::Hex<u32> hashMaybe;
    u32 width;
    u32 height;
    u32 unknown;
    
    Pixel pixels[width * height];
} [[single_color]];

struct SpriteVertex
{
    float position1[3];
    float uv1[2];
    float position2[3];
    float uv2[2];
    float position3[3];
    float uv3[2];
    float position4[3];
    float uv4[2];
} [[single_color]];

struct SpriteIndices
{
    // Using quad for this as an example, but this is probably a triangle index list
    u16 indices1[3];
    u16 indices2[3];
} [[single_color]];

u32 spriteGeoOffset = 0;
fn GetSpriteGeometryPtr(u32 offset) 
{
    return spriteGeoOffset;
};

struct Sprite
{
    // Offsets are relative to the start of the sprite
    spriteGeoOffset = $;

    u32 headerSize;
    u32 unknown2;
    SpriteVertex* vertices : u32 [[pointer_base("GetSpriteGeometryPtr")]];
    SpriteIndices* indices : u32 [[pointer_base("GetSpriteGeometryPtr")]];
    u32 vertexCount;
    u32 indexCount;
} [[single_color]];

struct SpriteBlock
{
    u32 count;
    
    Sprite spriteList[count];
    SpriteVertex spriteVertexList[count];
    SpriteIndices spriteIndexList[count];
} [[single_color]];

struct UnknownThing3
{
     type::Hex<u32> hash;
     type::Hex<u32> unknown1;
     type::Hex<u32> unknown2;
     type::Hex<u32> unknown3;
} [[single_color]];

struct UnknownThing4
{
     float unknown[header.unknownThing4Size / 4];
} [[single_color]];

fn GetShaderUnknownPtr(u32 offset) 
{
    return header.shaderBlockOffset;
};

struct ShaderSemanticName
{
    char text[];
};

struct ShaderSemantic
{
    u32 unknown0;
    u32 type; // semantic type -> [Position, BlendWeight, BlendIndices, Normal, TexCoord, Color, Tangent]
    u32 index; // semantic index
    
    ShaderSemanticName* name : u32 [[pointer_base("GetShaderUnknownPtr")]];
};

struct Shader
{
    type::Hex<u32> hash;
    type::Hex<u8> stage; // 0: VS, 1: PS
    type::Hex<u8> semanticCount;
    type::Hex<u16> unknown1;
    ShaderSemantic* semantics[semanticCount] : u32 [[pointer_base("GetShaderUnknownPtr")]];
    type::Hex<u32> unknownItemSize;
    type::Hex<u32>* unknownItem[unknownItemSize / 4] : u32 [[pointer_base("GetShaderUnknownPtr")]];
    type::Hex<u32> shaderCodeSize;
    type::Hex<u8>* shaderCode[shaderCodeSize] : u32 [[pointer_base("GetShaderUnknownPtr")]];

} [[single_color]];

struct ShaderCodeBlock
{
     Shader shaderList[header.totalShaderCount];
} [[single_color]];

fn GetUnknownBlockPtr(u32 offset) 
{
    return header.unknownBlockOffset;
};

struct UnknownThing5
{
    type::Hex<u32> hash;
    u16 entryCount;
    u16 entrySize;
  
    type::Hex<u32>* item[entryCount * (entrySize / 4)] : u32 [[pointer_base("GetUnknownBlockPtr")]];
} [[single_color]];

struct UnknownBlock
{
    UnknownThing5 entries1[header.pixelShaderCount];
} [[single_color]];

SpriteUnknown1 spriteUnknown[header.spriteCount] @ header.spriteUnknownOffset;

ImageBlock imageBlock @ header.imageDataOffset;

SpriteBlock spriteBlock @ header.spriteBlockOffset;

UnknownThing3 unknown3[header.unknown3Count] @ header.unknown3Offset;

UnknownThing4 unknown4[header.unknown4Count] @ header.unknown4Offset;

ShaderCodeBlock shaderCodeBlock @ header.shaderBlockOffset;

UnknownBlock unknownBlock @ header.unknownBlockOffset;