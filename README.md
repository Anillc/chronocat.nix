# chronocat.nix

使用前需要将 bstar.js 0.5.8 加入到 nix store 中，请自行下载后添加

```bash
nix-store --add-fixed sha256 bstar.js
```

如果你不想用默认参数：

```nix
lib.x86_64-linux.buildChronocat {
  sandbox.dns = "223.5.5.5"; # sandbox 中的 dns
  sandbox.display = 114; # 使用的 display
  sandbox.port = 5900; # vnc 的端口，注意并没有设置密码，请自行解决防火墙的问题
}
```
