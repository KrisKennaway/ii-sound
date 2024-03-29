#!/usr/bin/env python3
#
# Simple server to stream an .a2s file for playback from Apple II

import socketserver
import sys

PORT = 1977


def main(argv):
    serve_file = argv[1]

    def handler():
        class ChunkHandler(socketserver.BaseRequestHandler):
            def handle(self):
                with open(serve_file, "rb") as f:
                    print("Sending...")
                    self.request.sendall(f.read())

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
