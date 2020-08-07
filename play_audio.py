import socketserver
import sys
import random

PORT = 1977

OPCODES = {
    'tick': 0x00,
    'notick_page1': 0x08,
    'notick_page2': 0x10,
    'exit': 0x18,
    'slowpath': 0x28
}

def serve(stream: bytes):
    cnt = 0
    state = False
    page = 0
    cycles = 0

    direction = 100
    # TODO: synchronize to VBL
    # TODO: tick now has space to also flip a soft-switch
    # - i.e. we have 4 variants
    # can make sure we always flip at start/end of line
    for b in stream:
        for i in range(8):
            bit = (b >> i) & 0x1
            cycles += 13
            if bit != state:
                state = not state
                yield OPCODES['tick']
            else:
                # 18270
                if (cycles % 18800) < (13):
                    yield OPCODES['notick_page1']
                else:
                    yield OPCODES['notick_page2']
                page += 1
            cnt += 1
            if (cnt % 2048) == 2047:
                yield OPCODES['slowpath']
                cnt += 1
                cycles += 12*13
    # make sure we send enough data to fill player's receive buffer one last
    # time, so it doesn't loop forever
    for i in range(cnt % 2048, 2048):
        yield OPCODES['exit']


def main(argv):
    serve_file = argv[1]

    def handler():
        class ChunkHandler(socketserver.BaseRequestHandler):
            def handle(self):
                with open(serve_file, "rb") as f:
                    print("Sending...")
                    for b in serve(f.read()):
                        self.request.send(bytes([b]))

        return ChunkHandler

    with socketserver.TCPServer(
            ("0.0.0.0", PORT), handler(),
            bind_and_activate=False) as server:
        server.allow_reuse_address = True
        server.server_bind()
        server.server_activate()
        server.serve_forever()


if __name__ == "__main__":
    main(sys.argv)
