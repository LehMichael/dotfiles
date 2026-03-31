#!/usr/bin/env python3
import subprocess, sys, os, threading, re

CLANGD = r"/mnt/c/clang+llvm-22.1.1-x86_64-pc-windows-msvc/bin/clangd.exe"
WSL   = "file:///mnt/c/"
WIN   = "file:///C:/"

def translate(data: bytes, src: str, dst: str) -> bytes:
    return data.replace(src.encode(), dst.encode())

def read_message(stream) -> bytes | None:
    header = b""
    while not header.endswith(b"\r\n\r\n"):
        ch = stream.read(1)
        if not ch:
            return None
        header += ch
    length = int(re.search(rb"Content-Length: (\d+)", header).group(1))
    return header + stream.read(length)

def pipe(src, dst, wsl_to_win: bool):
    while True:
        msg = read_message(src)
        if msg is None:
            break
        if wsl_to_win:
            msg = translate(msg, WSL, WIN)
        else:
            msg = translate(msg, WIN, WSL)
        # fix Content-Length after translation (length may have changed)
        header, body = msg.split(b"\r\n\r\n", 1)
        header = re.sub(rb"Content-Length: \d+",
                        f"Content-Length: {len(body)}".encode(), header)
        dst.write(header + b"\r\n\r\n" + body)
        dst.flush()

args = [CLANGD] + sys.argv[1:]
proc = subprocess.Popen(args, stdin=subprocess.PIPE, stdout=subprocess.PIPE)

t = threading.Thread(target=pipe, args=(sys.stdin.buffer, proc.stdin, True))
t.daemon = True
t.start()

pipe(proc.stdout, sys.stdout.buffer, False)
