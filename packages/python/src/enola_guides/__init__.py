"""List, show and copy the enola guides, examples, laws, skills, hooks,
recipes and templates. The behaviour is specified in spec/cli/README.md and
shared by every package's implementation."""

import json
import os
import sys
from importlib import resources

KINDS = ["guide", "example", "law", "skill", "hook", "recipe", "template"]


def run(args, out=sys.stdout, err=sys.stderr):
    c = json.loads(resources.files(__package__).joinpath("bundle.json").read_text(encoding="utf-8"))

    def fail(code, message):
        err.write(f"enola-guides: {message}\n")
        return code

    if not args:
        args = ["help"]
    command = args[0]
    if command in ("help", "-h", "--help"):
        out.write(c["usage"])
        return 0
    if command in ("version", "--version"):
        out.write(f"enola-guides {c['version']}\n")
        return 0
    if command == "list":
        kind = ""
        if len(args) > 1:
            kind = args[1][:-1] if args[1].endswith("s") else args[1]
            if kind not in KINDS:
                return fail(2, f"no kind {args[1]}; the kinds are {', '.join(KINDS)}")
        for it in c["items"]:
            if not kind or it["kind"] == kind:
                out.write(f"{it['id']}\t{it['title']}\n")
        return 0
    if command in ("show", "copy"):
        if len(args) < 2:
            return fail(2, f"{command} needs an item id; enola-guides list names them")
        found = next((it for it in c["items"] if it["id"] == args[1]), None)
        if found is None:
            return fail(2, f"no item {args[1]}; enola-guides list names them")
        if command == "show":
            out.write(c["files"][found["show"]])
            return 0
        directory = (args[2] if len(args) > 2 else found["default_dir"]).rstrip("/")
        targets = [f["to"] if directory == "." else f"{directory}/{f['to']}" for f in found["files"]]
        for target in targets:
            if os.path.lexists(target):
                return fail(1, f"{target} exists; nothing was written")
        for f, target in zip(found["files"], targets):
            os.makedirs(os.path.dirname(target) or ".", exist_ok=True)
            with open(target, "w", encoding="utf-8", newline="") as handle:
                handle.write(c["files"][f["path"]])
            os.chmod(target, f["mode"])
            out.write(f"wrote {target}\n")
        return 0
    return fail(2, f"no command {command}; enola-guides help lists them")


def main():
    sys.exit(run(sys.argv[1:]))
