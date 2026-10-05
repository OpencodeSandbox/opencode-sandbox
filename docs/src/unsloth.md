# Connecting to unsloth desktop

> [!TIP]
> An example of how to set up Opencode to connect to a locally running [Unsloth Desktop] session
> can be found under [`examples/unsloth-desktop`]

## Sandbox

Opencode Sandbox supports connecting to local API providers via [host port forwarding]. Add the
following to your `flake.nix`:

```nix
sandbox = opencode-sandbox.packages.${system}.sandbox.override {
  opencode-sandbox = {
    git.remote.url = "https://github.com/OpencodeSandbox/opencode-sandbox.git";
  
    # Required to access the unsloth server running on the host
    # By default Unsloth server and Unsloth desktop expose their API on port 8888
    forwardPorts = [8888];
  };
};
```

Then, from your local Unsloth desktop UI, head over to `Settings -> API -> Create token`. Make sure
to save the resulting key and add it to your `.env`:

```bash
UNSLOTH_API_KEY=skl-unsloth-123
```


## Opencode

Additionally, Opencode has to be configured to use whichever model you are running locally. Add the
following to your root-level `opencode.jsonc`.

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "unsloth-studio": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Unsloth Studio",
      "options": {
        // 10.0.2.10 is the default address used for port forwarding
        // inside of the sandbox
        "baseURL": "http://10.0.2.10:8888/v1",
        "apiKey": "{env:UNSLOTH_API_KEY}"
      },
      "models": {
        // Replace this with the name of the model you are running
        // You can find the full name of a model by heading to the
        // model hub and clicking the "copy" icon next to its name
        "unsloth/Qwen3.8-27B-GGUF:UD-Q8_K_XL": {
          "name": "Qwen3.8 27B (local)"
        }
      }
    }
  },
  // Replace this with the name of the model you are running
  "model": "unsloth-studio/unsloth/Qwen3.8-27B-GGUF:UD-Q8_K_XL",
}
```

[`examples/unsloth-desktop`]: https://github.com/OpencodeSandbox/opencode-sandbox/tree/7433ac4c2953f350dcd8cd8a217bc1e2545d62b4/examples/unsloth-desktop
[Unsloth Desktop]: https://unsloth.ai/docs/desktop
[host port forwarding]: ./options.md#forwardports
