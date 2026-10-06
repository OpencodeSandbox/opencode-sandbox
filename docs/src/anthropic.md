# Connecting to Anthropic

> [!TIP]
> An example of how to set up Opencode to use Anthropic models can be found under
> [`examples/anthropic`].

## Setting up Claude

Anthropic does not support re-using your existing subscription to call their inference API. To use
Anthropic in Opencode you will first have to create a [Claude console] account which will prompt you
to buy some tokens instead.

Once you have access to the console, create a new API key using the "Get API key" button. Make sure
to save the resulting key and add it to your `.env`:

```bash
ANTHROPIC_API_KEY="sk-ant-user-xxx"
```

## Setting up Opencode

Since Opencode Sandbox does not persist any changes between sessions, you will need to save your
Anthropic configuration as part of your root-level `opencode.jsonc`.

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "anthropic": {
      "options": {
        "apiKey": "{env:ANTHROPIC_API_KEY}"
      }
    }
  },
  "model": "anthropic/claude-sonnet-5"
}
```

[`examples/anthropic`]: https://github.com/OpencodeSandbox/opencode-sandbox/tree/main/examples/anthropic
[Claude console]: https://platform.claude.com/
