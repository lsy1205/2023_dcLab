#!/usr/bin/env python
from sys import argv, stdin, stdout
from struct import unpack, pack

KEY_W = 512

def mul_naive(a, b, n):
    ret = 0
    for i in range(KEY_W-1, -1, -1):
        ret <<= 1
        if ret >= n:
            ret -= n
        if b & (1 << i):
            ret += a
            if ret >= n:
                ret -= n
    return ret


def power_naive(a, b, n):
    a2 = a + 0
    ret = 1
    for i in range(KEY_W):
        if b & (1 << i):
            ret = mul_naive(ret, a2, n)
        a2 = mul_naive(a2, a2, n)
    return ret


def mont_preprocess(a, n):
    """return a*2^(256) % n"""
    # for i in range(KEY_W):
    #     a <<= 1
    #     if a >= n:
    #         a -= n
    # or, equivalent to this
    return (a<<KEY_W)%n


def mul_mont(a, b, n):
    """return a*b*2^(-256) % n"""
    ret = 0  # Note: ret must has 257b [0,2n)
    for i in range(KEY_W):
        if b & (1 << i):
            ret += a
        if ret & 1:
            ret += n
        ret >>= 1
    return ret if ret < n else ret-n  # [0,n) now


def power_mont(a, b, n):
    a2 = mont_preprocess(a+0, n)
    ret = 1
    # print hex(ret)
    for i in range(KEY_W):
        if b & (1 << i):
            ret = mul_mont(ret, a2, n)
        a2 = mul_mont(a2, a2, n)
    return ret


if __name__ == '__main__':
    # # 2048
    # val_n = 0xd556b6a73228f03499967d8e69b33391251b2c6cf0ffb7704d8a0c79fb261f5e7b55039d1bd6718fe24590daebc44a63f91ac21c1059c38b39bba12337f53c5b1bd98bf7e3875a02283e69f03b295e9e234e13448e942e5ccdadb4a4bfc44c3ab12bc37f4a0775315bff0d13c369f9adf64a10be9efcb4fc7af591472e5bf1d1f0efe9b201619c2bbd99b0af1236d38b5d9b2006ca8cdf64eafc9be188dc9c82b3582fcec2f5f7a991a6c5012678e8600c90b8f72bc09d7447dfb3d5af44549421ac8201cfb6a6fe5f97a1a883ad754412fc6b6e01534b9c0a59edbe2603af80712d0bede2522946542295b50bf67b77cbf6922d0e78e0cfa55089f5c36b35f5
    # val_e = 0x010001
    # val_d = 0x56cf8e4bc2d17dcd29a25f3d102de791ec737e44665ce81c3eb12a1a88e41e67a7f014245e2b88d26fd4b6f91e6f258640db6e9954ddf2003961ec5414752a3638c2f17dd18c46481270335399ff5f8d21f8a746826e31df79a2719b889d2c17c5f874f8dafae5e94bf2213425947e1117e353a4fdb4ff40ae183721abefa61a759e83e791a6afd16552fffa0c5745d8fcca3886a4b0a5dbef570966216c9e15dfb13939b114d1861fec7bdd7f0d926e7c4db8bfdd415e7d0ee0ccb235df61c79469e59ce41a6f89e9c753b116f5a6bd9185508a4a626a96b31b0f069478370f26605ec21da3f404cbebefc738502a3d262e924ed6ceab1c14d5b62fe7b10481
    # # 1024
    # val_n = 0xca13c00da260fe3e374e9e82c4cc548a31eafbd31ea4d1729416814f42facd0393f9518ef67968e3d9e1b388369bb326ae6e571ad127f8ecb4a4b5db80c1ce95b77c1423757d11fd73f409153931cbab91228efa9a76a7ee3e90da74b139af118e621b015c1b906bcc9ae7ab48fe4cd2a6bb99e47ec54b361b6d08051e2cd29b
    # val_e = 0x010001
    # val_d = 0xc17c9db4b058ccb787bf6878efb471f20c8fe1e5a8fec9693b303d4a4668dc2a63e2225c8fd57a4048dc1a49ff779fd716c7a1f194790098acf2d50a42c3cf67c9c30d95e8bf1af691f501600a9381aa76138472220245ee555a0d23c5755c5f83b5cad294110a2841134053dae13fe1e4bb8f4de292e9bdfe16862321445f01
    # 512
    val_n = 0x6d2222eaa6a74f3fb3fddf38aab211200a020756787947070ee72550a27acbe475d0d553ca718516f7dec617aa9eedd3b7849845263e9b17894b4f4a10c8b50b
    val_e = 0x010001
    val_d = 0x1f2af9a7e472b21a727055f91c1f00ef128ca3c5d960619dad6eec644c131ff9bc96c695506af918483291044a7f453817ac41f367721cfd4d7e1eb71a8a9781

    assert len(argv) == 4, "Usage: {} <e|d> <input file> <output file>".format(argv[0])
    if argv[1] == 'e':
        exponentiation = val_e
        r_chunk_size = KEY_W//8 - 1
        w_chunk_size = KEY_W//8
    else:
        exponentiation = val_d
        r_chunk_size = KEY_W//8
        w_chunk_size = KEY_W//8 - 1

    file_in = open(argv[2], 'rb')
    file_out = open(argv[3], 'wb')

    message = file_in.read(r_chunk_size)
    while message:
        chunk = message
        n_read = len(chunk)
        # print message
        assert n_read == r_chunk_size, "Expect {} bytes, but receive {} bytes".format(r_chunk_size, n_read)

        vals = unpack("{}B".format(r_chunk_size), chunk)
        msg = 0
        for val in vals:
            msg = (msg << 8) | val
        
        msg_new = power_mont(msg, exponentiation, val_n)
        vals_new = map(lambda shamt: (msg_new >> shamt) & 0xff, range((w_chunk_size-1)*8, -8, -8))
        vals_new = pack("{}B".format(w_chunk_size), *vals_new)
        file_out.write(vals_new)
        message = file_in.read(r_chunk_size)
