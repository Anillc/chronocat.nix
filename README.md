# chronocat.nix

如果你不想用默认参数：

```nix
lib.x86_64-linux.buildChronocat {
  sandbox.dns = "223.5.5.5"; # sandbox 中的 dns
  sandbox.display = 114; # 使用的 display
  sandbox.port = 5900; # vnc 的端口，注意并没有设置密码，请自行解决防火墙的问题
}
```
