#!/usr/bin/env python3

import asyncio
import json
import os
import signal
import sys
from pathlib import Path

import websockets
from dotenv import load_dotenv

load_dotenv()

TRUENAS_HOST = os.environ["TRUENAS_HOST"]
TRUENAS_API_KEY = os.environ["TRUENAS_API_KEY"]

UPTIME_OUTPUT = Path("/tmp/uptime.txt")

POLL_INTERVAL = 10
RECONNECT_DELAY = 5


async def session():
    uri = f"wss://{TRUENAS_HOST}/api/current"

    # Websockets are asynchronous, the server doesn't guarantee it will
    # respond to your messages in the same order you sent them.
    # The id field is part of the JSON-RPC 2.0 spec and is used to match
    # responses to requests.
    req_id = 1

    async with websockets.connect(uri) as ws:

        # --- AUTHENTICATION ---
        # We do this once at the start of the session rather than on every request, 
        # this is the main advantage of a persistent websocket over a REST API
        await ws.send(json.dumps({
            "id": req_id,
            "jsonrpc": "2.0",
            "method": "auth.login_with_api_key",
            "params": [TRUENAS_API_KEY]
        }))
        received = await ws.recv()

        auth_response = json.loads(received)
        if not auth_response.get("result"):
            print("Authentication failed", file=sys.stderr)
            return
        print("Authenticated.")
        req_id += 1 

        # --- POLL LOOP ---
        # This runs forever (until the connection drops or the script is killed).
        # Each iteration sends one request, waits for its response, writes the
        # result to disk for Conky to read, then sleeps before doing it again.

        # system.info
        # pool.query
        # disk.query
        # alert.list

        while True:
            await ws.send(json.dumps({
                "id": req_id,
                "jsonrpc": "2.0",
                "method": "system.info",
                "params": []
            }))

            # We can't just do ws.recv() once and assume it's our response.
            # The server may send unsolicited messages (alerts, events, etc.)
            # at any time on the same connection. So we loop on recv() and
            # discard anything that doesn't match the ID we just sent.
            # Usually this will just be a single response, but you need the safety.

            extra_responses = 0
            while True:
                raw = await ws.recv()
                try:
                    msg = json.loads(raw)
                except json.JSONDecodeError as e:
                    print(f"Malformed response, skipping: {e}", file=sys.stderr)
                    continue
                if msg.get("id") == req_id:
                    break  # This is the response we were waiting for
                else:
                    extra_responses += 1
                    print(f"Discarded {extra_responses} extra responses", file=sys.stderr)
                

            uptime = msg.get("result", {}).get("uptime")
            if uptime is not None:
                # Write atomically to a temp file then replace, so Conky never
                # reads a half-written file mid-update
                tmp = UPTIME_OUTPUT.with_suffix(".tmp")
                tmp.write_text(str(uptime) + "\n")
                tmp.replace(UPTIME_OUTPUT)

                print(f"Uptime: {uptime}")
            else:
                print(f"Unexpected response: {msg}", file=sys.stderr)

            req_id += 1
            await asyncio.sleep(POLL_INTERVAL)


async def main():
    # --- RECONNECT LOOP ---
    # This wraps the entire session so that if the connection drops for any
    # reason (network blip, TrueNAS restart, etc.), we don't just die, we
    # wait a few seconds and try again. From Conky's perspective the output
    # file just goes stale temporarily, then starts updating again on its own.
    while True:
        try:
            await session()
        except websockets.exceptions.InvalidURI as e:
            # A bad URI means something is wrong with TRUENAS_HOST in .env.
            # No point retrying since it'll never work without a fix.
            print(f"Invalid URI: {e}", file=sys.stderr)
            sys.exit(1)
        except (websockets.exceptions.WebSocketException, OSError) as e:
            print(f"Connection error: {e}, reconnecting in {RECONNECT_DELAY}s...", file=sys.stderr)
            await asyncio.sleep(RECONNECT_DELAY)
        except Exception as e:
            print(f"Unexpected error: {e}, reconnecting in {RECONNECT_DELAY}s...", file=sys.stderr)
            await asyncio.sleep(RECONNECT_DELAY)


def handle_exit(*_):
    print("\nShutting down.")
    sys.exit(0)


signal.signal(signal.SIGINT, handle_exit)
signal.signal(signal.SIGTERM, handle_exit)

if __name__ == "__main__":
    asyncio.run(main())