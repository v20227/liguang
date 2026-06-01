#!/usr/bin/env python3
"""
诸葛 · HTTPS 服务启动器
为 film-camera.html 提供 HTTPS 服务，iOS 可访问
"""

import http.server
import ssl
import os
import sys
import socket

PORT = 8443
DIR = "/Users/mima0000/Desktop/羊的草料"

class CORSHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIR, **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-cache, no-store")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

os.chdir(DIR)
httpd = http.server.HTTPServer(("0.0.0.0", PORT), CORSHandler)

context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain("/tmp/cert.pem", "/tmp/key.pem")
httpd.socket = context.wrap_socket(httpd.socket, server_side=True)

# 获取局域网 IP
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    local_ip = s.getsockname()[0]
    s.close()
except:
    local_ip = "127.0.0.1"

print(f"\n{'='*50}")
print(f"  诸葛 HTTPS 服务已启动")
print(f"  URL: https://{local_ip}:{PORT}/film-camera.html")
print(f"  {'='*50}")
print(f"\n  在 iPhone 上打开 Safari 访问以上地址")
print(f"  首次访问会提示「证书不受信任」")
print(f"  点击「显示详细信息」→「访问此网站」即可")
print(f"\n  按 Ctrl+C 停止服务\n")

httpd.serve_forever()
