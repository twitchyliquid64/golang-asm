# golang-asm

A mirror of the assembler from the Go compiler, with import paths re-written for the assembler to be functional as a standalone library.

License as per the Go project.

# Status

WIP - while the library builds, I'm still working on the best way to initialize internal structures & use it.

# Example

WARNING - WIP.

```go

package main

import (
	"bufio"
	"bytes"
	"fmt"

	"github.com/twitchyliquid64/golang-asm/asm/arch"
	"github.com/twitchyliquid64/golang-asm/obj"
)

func main() {
	a := arch.Set("amd64")
	ctxt := obj.Linknew(a.LinkArch)
	buf := bytes.NewBufferString("")
	ctxt.Bso = bufio.NewWriter(buf)
	a.Init(ctxt)

	prog := ctxt.NewProg()
	prog.As = obj.ANOP
	prog.Ctxt = ctxt

	fmt.Println(prog.InstructionString())
	obj.Flushplist(ctxt, &obj.Plist{Firstpc: prog}, nil, "")
	fmt.Println(ctxt)
	fmt.Printf("Out: %x\n", buf.Bytes())
}

```
