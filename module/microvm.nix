{config, ...}: {
  microvm.hypervisor = "qemu";
  microvm.mem = config.opencode-sandbox.mem;
  microvm.vcpu = config.opencode-sandbox.vcpu;

  microvm.forwardPorts =
    map (
      port: {
        from = "guest";
        guest.address = "10.0.2.10";
        guest.port = 8888;
        host.address = "127.0.0.1";
        host.port = 8888;
      }
    )
    config.opencode-sandbox.forwardPorts;

  microvm.interfaces = [
    {
      type = "user";
      id = "sandbox-a1";
      mac = "02:00:00:00:00:01";
    }
  ];

  microvm.shares = [
    {
      tag = "work";
      source = "./.";
      mountPoint = "/home/user/work";
    }
  ];

  microvm.writableStoreOverlay = "/nix/.rw-store";
  microvm.volumes = [
    {
      image = "${config.opencode-sandbox.volumeName}.img";
      mountPoint = config.microvm.writableStoreOverlay;
      size = config.opencode-sandbox.storeSize;
    }
  ];
}
