package golangasm

import (
	"fmt"

	"github.com/twitchyliquid64/golang-asm/asm/arch"
	"github.com/twitchyliquid64/golang-asm/obj"
	"github.com/twitchyliquid64/golang-asm/objabi"
)

func progAlloc() *obj.Prog {
	return &obj.Prog{}
}

// Builder allows you to assemble a series of instructions.
type Builder struct {
	ctxt *obj.Link
	arch *arch.Arch

	first *obj.Prog
	last  *obj.Prog
}

// NewProg returns a new instruction structure.
func (b *Builder) NewProg() *obj.Prog {
	p := b.ctxt.NewProg()
	p.Ctxt = b.ctxt
	return p
}

// AddInstruction adds an instruction to the list of instructions
// to be assembled.
func (b *Builder) AddInstruction(p *obj.Prog) {
	if b.first == nil {
		b.first = p
		b.last = p
	} else {
		b.last.Link = p
		b.last = p
	}
}

// Assemble generates the machine code from the given instructions.
func (b *Builder) Assemble() []byte {
	s := &obj.LSym{
		Func: &obj.FuncInfo{
			Text: b.first,
		},
	}
	b.arch.Assemble(b.ctxt, s, progAlloc)
	return s.P
}

// NewBuilder constructs an assembler for the given architecture.
func NewBuilder(archStr string) (*Builder, error) {
	a := arch.Set(archStr)
	ctxt := obj.Linknew(a.LinkArch)
	ctxt.Headtype = objabi.Hlinux
	ctxt.DiagFunc = func(in string, args ...interface{}) {
		fmt.Printf(in+"\n", args...)
	}
	a.Init(ctxt)
	return &Builder{
		ctxt: ctxt,
		arch: a,
	}, nil
}
