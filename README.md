# Github-Codespace-OnVNC

Turn a **GitHub Codespace** into a full Linux desktop you can use from your browser — no local VM, no extra cloud bill. This repo installs a lightweight **XFCE** desktop, serves it over **TigerVNC**, and bridges that to the browser with **noVNC**, all wired up through VS Code's built-in port forwarding.

## How it works

```
 Browser (vnc.html) <--HTTP/WebSocket--> noVNC proxy <--VNC--> TigerVNC server <--X11--> XFCE desktop
                          (port 6080)                    (port 5901)
```

1. `main.sh` installs XFCE + TigerVNC + noVNC if they aren't already present.
2. It starts a TigerVNC server on display `:1` (port `5901`) running an XFCE session.
3. It starts the `noVNC` websocket proxy on port `6080`, which translates browser WebSocket traffic to the VNC protocol.
4. VS Code's **Ports** tab forwards `6080` out of the Codespace so you can open it in a browser tab.

## Requirements

- A GitHub Codespace (or any Debian/Ubuntu-based dev container with `apt-get` and `sudo` access).
- A modern browser (the noVNC client runs entirely client-side).

## Quick start

1. Create a new Codespace from this repo, or fork the repo and create a Codespace from your fork.
2. Open a terminal in the Codespace and run:

   ```bash
   ./main.sh
   ```

3. The first time it runs, you'll be prompted by `vncpasswd` to set a **VNC password**. Remember it — you'll need it to connect.
4. Once you see `Desktop is ready.`, open the **Ports** tab in VS Code:
   - If port `6080` isn't listed, click **Forward a Port** and add `6080`.
   - Hover over the `6080` row and click the **globe/browser icon** to open it in a new tab.
   - Append `/vnc.html` to the end of that URL, e.g. `https://<your-codespace>-6080.app.github.dev/vnc.html`.
5. Click **Connect** and enter the VNC password you set in step 3.

You now have a full XFCE desktop running inside your Codespace, accessible from your browser.

## Re-running the script

`main.sh` is safe to run again:

- If desktop/VNC packages are already installed, it skips installation.
- If `~/noVNC` already exists, it skips cloning.
- It kills any existing VNC session on the configured display before starting a fresh one, so you can re-run it after a Codespace restart to bring everything back up.

## Configuration

All tunable settings live at the top of [main.sh](main.sh):

| Variable      | Default      | Description |
|---------------|--------------|-------------|
| `DISPLAY_NUM` | `1`          | X display number used by the VNC server (`:1`). Don't change unless you intend to run multiple VNC displays. |
| `VNC_PORT`    | `5901`       | Port the TigerVNC server listens on. |
| `NOVNC_PORT`  | `6080`       | Port the noVNC websocket proxy listens on — this is the port you forward in VS Code. |
| `GEOMETRY`    | `1280x720`   | Desktop resolution. Currently hard-coded; edit this value and re-run the script to change it. |
| `DEPTH`       | `24`         | Color depth (bits per pixel). |
| `NOVNC_DIR`   | `$HOME/noVNC`| Location where the noVNC + websockify repos are cloned. |

## Stopping the desktop

- Stop the noVNC proxy: press `Ctrl+C` in the terminal where `main.sh` is running (it runs noVNC in the foreground).
- Stop the VNC server:

  ```bash
  vncserver -kill :1
  ```

## Project structure

```
.
├── main.sh                              # Main setup/start script
├── lib/
│   └── color.sh                         # say() / warn() helpers for colored terminal output
├── update and install a lightweight.md  # Manual step-by-step notes (the basis for main.sh)
└── LICENSE                              # Apache License 2.0
```

## Security notes

- `vncserver` is started with `-localhost no`, which allows non-loopback connections to the VNC port. This is required so the noVNC proxy can reach it, but it also means anyone who can reach port `5901` directly (e.g. via a manually forwarded port) can attempt to connect — protect it with a strong VNC password.
- Treat your Codespace's forwarded ports as **private** unless you intentionally need to share access; avoid setting the `6080` port visibility to "Public" unless you understand the exposure.

## Troubleshooting

- **"Desktop is ready" but the browser tab shows nothing** — make sure you appended `/vnc.html` to the forwarded URL.
- **Connection refused / black screen** — re-run `./main.sh`; it will kill and restart any stale VNC session.
- **Forgot your VNC password** — delete `~/.vnc/passwd` and re-run `./main.sh`, which will prompt you to set a new one.

## License

Licensed under the [Apache License 2.0](LICENSE).
