#!/usr/bin/env node
// enola-guides: list, show and copy the enola guides, examples, laws,
// skills, hooks, recipes and templates. The behaviour is specified in
// spec/cli/README.md and shared by every package's implementation.
"use strict";

const fs = require("node:fs");
const path = require("node:path");

const KINDS = ["guide", "example", "law", "skill", "hook", "recipe", "template"];

function run(args, out, err) {
  const c = JSON.parse(fs.readFileSync(path.join(__dirname, "..", "bundle.json"), "utf8"));
  const fail = (code, message) => {
    err.write(`enola-guides: ${message}\n`);
    return code;
  };
  if (args.length === 0) args = ["help"];
  const [command, id, given] = args;
  switch (command) {
    case "help":
    case "-h":
    case "--help":
      out.write(c.usage);
      return 0;
    case "version":
    case "--version":
      out.write(`enola-guides ${c.version}\n`);
      return 0;
    case "list": {
      let kind = "";
      if (id !== undefined) {
        kind = id.endsWith("s") ? id.slice(0, -1) : id;
        if (!KINDS.includes(kind)) return fail(2, `no kind ${id}; the kinds are ${KINDS.join(", ")}`);
      }
      for (const it of c.items) if (!kind || it.kind === kind) out.write(`${it.id}\t${it.title}\n`);
      return 0;
    }
    case "show":
    case "copy": {
      if (id === undefined) return fail(2, `${command} needs an item id; enola-guides list names them`);
      const found = c.items.find((it) => it.id === id);
      if (!found) return fail(2, `no item ${id}; enola-guides list names them`);
      if (command === "show") {
        out.write(c.files[found.show]);
        return 0;
      }
      const dir = (given === undefined ? found.default_dir : given).replace(/\/+$/, "");
      const targets = found.files.map((f) => (dir === "." ? f.to : `${dir}/${f.to}`));
      for (const target of targets) {
        if (fs.existsSync(target)) return fail(1, `${target} exists; nothing was written`);
      }
      found.files.forEach((f, i) => {
        fs.mkdirSync(path.dirname(targets[i]), { recursive: true });
        fs.writeFileSync(targets[i], c.files[f.path], { mode: f.mode });
        fs.chmodSync(targets[i], f.mode);
        out.write(`wrote ${targets[i]}\n`);
      });
      return 0;
    }
  }
  return fail(2, `no command ${command}; enola-guides help lists them`);
}

process.exitCode = run(process.argv.slice(2), process.stdout, process.stderr);
