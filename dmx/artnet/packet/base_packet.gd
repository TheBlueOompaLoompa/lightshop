@abstract class_name ArtBasePacket extends RefCounted

static var base := PackedByteArray([
    65, 114, 116, 45, 78, 101, 116, 0, # Art-Net\0
    0, 0, # Dummy OpCode (8, 9)
    0, 14 # Protocol Version (10, 11)
])

@export var data := PackedByteArray(base)


func encode_op(code: OpCode):
    data.encode_u8(8, code & 0xff)
    data.encode_u8(9, code >> 8)


## Legal OpCodes for Art-Net Packets
enum OpCode {
    POLL = 0x2000, ## This is an ArtPoll packet, no other data is contained in this UDP packet.
    POLL_REPLY = 0x2100, ## This is an ArtPollReply Packet. It contains device status information.
    DIAG_DATA = 0x2300,
    COMMAND = 0x2400,
    DATA_REQUEST = 0x2700,
    DATA_REPLY = 0x2800,
    OUTPUT = 0x5000,
    NZS = 0x5100,
    SYNC = 0x5200,
    ADDRESS = 0x6000,
    INPUT = 0x7000,
    TOD_REQUEST = 0x8000,
    TOD_DATA = 0x8100,
    TOD_CONTROL = 0x8200,
    RDM = 0x8300,
    RDM_SUB = 0x8400,
    VIDEO_SETUP = 0xa010,
    VIDEO_PALETTE = 0xa20,
    VIDEO_DATA = 0xa040,
    MAC_HOST = 0xf000,
    MAC_CLIENT = 0xf100,
    FIRMWARE_MASTER = 0xf200,
    FIRMWARE_REPLY = 0xf300,
    FILE_TN_MASTER = 0xf400,
    FILE_FN_MASTER = 0xf500,
    FILE_FN_REPLY = 0xf600,
    IP_PROG = 0xf800,
    IP_PROG_REPLY = 0xf900,
    MEDIA = 0x9000,
    MEDIA_PATCH = 0x9100,
    MEDIA_CONTROL = 0x9200,
    MEDIA_CONTROL_REPLY = 0x9300,
    TIME_CODE = 0x9700,
    TIME_SYNC = 0x9800,
    TRIGGER = 0x9900,
    DIRECTORY = 0x9a00,
    DIRECTORY_REPLY = 0x9b00,
}
