// Command enola-guides lists, shows and copies the enola guides, examples,
// laws, skills, hooks, recipes and templates. The behaviour is specified in
// spec/cli/README.md and shared by every package's implementation.
package main

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/misabegovic/enola-guides/bundle"
)

type file struct {
	Path string `json:"path"`
	To   string `json:"to"`
	Mode int    `json:"mode"`
}

type item struct {
	ID         string `json:"id"`
	Kind       string `json:"kind"`
	Title      string `json:"title"`
	Show       string `json:"show"`
	DefaultDir string `json:"default_dir"`
	Files      []file `json:"files"`
}

type catalogue struct {
	Version string            `json:"version"`
	Usage   string            `json:"usage"`
	Items   []item            `json:"items"`
	Files   map[string]string `json:"files"`
}

var kinds = []string{"guide", "example", "law", "skill", "hook", "recipe", "template"}

func main() {
	os.Exit(run(os.Args[1:], os.Stdout, os.Stderr))
}

func run(args []string, stdout, stderr io.Writer) int {
	var c catalogue
	if err := json.Unmarshal(bundle.JSON, &c); err != nil {
		fmt.Fprintf(stderr, "enola-guides: the bundle is unreadable: %v\n", err)
		return 2
	}
	fail := func(code int, format string, a ...any) int {
		fmt.Fprintf(stderr, "enola-guides: "+format+"\n", a...)
		return code
	}
	if len(args) == 0 {
		args = []string{"help"}
	}
	switch args[0] {
	case "help", "-h", "--help":
		fmt.Fprint(stdout, c.Usage)
		return 0
	case "version", "--version":
		fmt.Fprintf(stdout, "enola-guides %s\n", c.Version)
		return 0
	case "list":
		kind := ""
		if len(args) > 1 {
			kind = strings.TrimSuffix(args[1], "s")
			known := false
			for _, k := range kinds {
				known = known || k == kind
			}
			if !known {
				return fail(2, "no kind %s; the kinds are %s", args[1], strings.Join(kinds, ", "))
			}
		}
		for _, it := range c.Items {
			if kind == "" || it.Kind == kind {
				fmt.Fprintf(stdout, "%s\t%s\n", it.ID, it.Title)
			}
		}
		return 0
	case "show", "copy":
		if len(args) < 2 {
			return fail(2, "%s needs an item id; enola-guides list names them", args[0])
		}
		var found *item
		for i := range c.Items {
			if c.Items[i].ID == args[1] {
				found = &c.Items[i]
			}
		}
		if found == nil {
			return fail(2, "no item %s; enola-guides list names them", args[1])
		}
		if args[0] == "show" {
			fmt.Fprint(stdout, c.Files[found.Show])
			return 0
		}
		dir := found.DefaultDir
		if len(args) > 2 {
			dir = args[2]
		}
		dir = strings.TrimRight(dir, "/")
		targets := make([]string, len(found.Files))
		for i, f := range found.Files {
			targets[i] = f.To
			if dir != "." {
				targets[i] = dir + "/" + f.To
			}
			if _, err := os.Lstat(targets[i]); err == nil {
				return fail(1, "%s exists; nothing was written", targets[i])
			}
		}
		for i, f := range found.Files {
			if err := os.MkdirAll(filepath.Dir(targets[i]), 0o755); err != nil {
				return fail(2, "%v", err)
			}
			if err := os.WriteFile(targets[i], []byte(c.Files[f.Path]), os.FileMode(f.Mode)); err != nil {
				return fail(2, "%v", err)
			}
			if err := os.Chmod(targets[i], os.FileMode(f.Mode)); err != nil {
				return fail(2, "%v", err)
			}
			fmt.Fprintf(stdout, "wrote %s\n", targets[i])
		}
		return 0
	}
	return fail(2, "no command %s; enola-guides help lists them", args[0])
}
