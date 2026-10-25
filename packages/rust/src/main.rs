//! enola-guides: list, show and copy the enola guides, examples, laws,
//! skills, hooks, recipes and templates. The behaviour is specified in
//! spec/cli/README.md and shared by every package's implementation.

use serde::Deserialize;
use std::collections::BTreeMap;
use std::io::Write;
use std::path::Path;

const BUNDLE: &str = include_str!("../bundle.json");
const KINDS: [&str; 7] = ["guide", "example", "law", "skill", "hook", "recipe", "template"];

#[derive(Deserialize)]
struct File {
    path: String,
    to: String,
    mode: u32,
}

#[derive(Deserialize)]
struct Item {
    id: String,
    kind: String,
    title: String,
    show: String,
    default_dir: String,
    files: Vec<File>,
}

#[derive(Deserialize)]
struct Catalogue {
    version: String,
    usage: String,
    items: Vec<Item>,
    files: BTreeMap<String, String>,
}

fn main() {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let code = run(&args, &mut std::io::stdout(), &mut std::io::stderr());
    std::process::exit(code);
}

fn run(args: &[String], out: &mut dyn Write, err: &mut dyn Write) -> i32 {
    let c: Catalogue = match serde_json::from_str(BUNDLE) {
        Ok(c) => c,
        Err(e) => {
            let _ = writeln!(err, "enola-guides: the bundle is unreadable: {e}");
            return 2;
        }
    };
    let mut fail = |code: i32, message: String| {
        let _ = writeln!(err, "enola-guides: {message}");
        code
    };
    let help = ["help".to_string()];
    let args = if args.is_empty() { &help[..] } else { args };
    let command = args[0].as_str();
    match command {
        "help" | "-h" | "--help" => {
            let _ = write!(out, "{}", c.usage);
            0
        }
        "version" | "--version" => {
            let _ = writeln!(out, "enola-guides {}", c.version);
            0
        }
        "list" => {
            let mut kind = "";
            if let Some(given) = args.get(1) {
                kind = given.strip_suffix('s').unwrap_or(given);
                if !KINDS.contains(&kind) {
                    return fail(2, format!("no kind {given}; the kinds are {}", KINDS.join(", ")));
                }
            }
            for it in c.items.iter().filter(|it| kind.is_empty() || it.kind == kind) {
                let _ = writeln!(out, "{}\t{}", it.id, it.title);
            }
            0
        }
        "show" | "copy" => {
            let Some(id) = args.get(1) else {
                return fail(2, format!("{command} needs an item id; enola-guides list names them"));
            };
            let Some(found) = c.items.iter().find(|it| &it.id == id) else {
                return fail(2, format!("no item {id}; enola-guides list names them"));
            };
            if command == "show" {
                let _ = write!(out, "{}", c.files[&found.show]);
                return 0;
            }
            let given = args.get(2).unwrap_or(&found.default_dir);
            let dir = given.trim_end_matches('/');
            let targets: Vec<String> = found
                .files
                .iter()
                .map(|f| if dir == "." { f.to.clone() } else { format!("{dir}/{}", f.to) })
                .collect();
            if let Some(existing) = targets.iter().find(|t| Path::new(t).symlink_metadata().is_ok()) {
                return fail(1, format!("{existing} exists; nothing was written"));
            }
            for (f, target) in found.files.iter().zip(&targets) {
                let path = Path::new(target);
                if let Some(parent) = path.parent().filter(|p| !p.as_os_str().is_empty()) {
                    if let Err(e) = std::fs::create_dir_all(parent) {
                        return fail(2, e.to_string());
                    }
                }
                if let Err(e) = std::fs::write(path, &c.files[&f.path]) {
                    return fail(2, e.to_string());
                }
                if let Err(e) = set_mode(path, f.mode) {
                    return fail(2, e.to_string());
                }
                let _ = writeln!(out, "wrote {target}");
            }
            0
        }
        _ => fail(2, format!("no command {command}; enola-guides help lists them")),
    }
}

#[cfg(unix)]
fn set_mode(path: &Path, mode: u32) -> std::io::Result<()> {
    use std::os::unix::fs::PermissionsExt;
    std::fs::set_permissions(path, std::fs::Permissions::from_mode(mode))
}

#[cfg(not(unix))]
fn set_mode(_path: &Path, _mode: u32) -> std::io::Result<()> {
    Ok(())
}
