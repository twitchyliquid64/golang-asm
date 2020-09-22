package golangasm

import (
	"bytes"
	"testing"

	"github.com/twitchyliquid64/golang-asm/obj"
	"github.com/twitchyliquid64/golang-asm/obj/x86"
)

func noop(builder *Builder) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.ANOPL
	prog.From.Type = obj.TYPE_REG
	prog.From.Reg = x86.REG_AX
	return prog
}

func addImmediateByte(builder *Builder, in int32) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.AADDB
	prog.To.Type = obj.TYPE_REG
	prog.To.Reg = x86.REG_AL
	prog.From.Type = obj.TYPE_CONST
	prog.From.Offset = int64(in)
	return prog
}

func movImmediateByte(builder *Builder, reg int16, in int32) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.AMOVB
	prog.To.Type = obj.TYPE_REG
	prog.To.Reg = reg
	prog.From.Type = obj.TYPE_CONST
	prog.From.Offset = int64(in)
	return prog
}

func TestBasic(t *testing.T) {
	b, _ := NewBuilder("amd64", 64)
	b.AddInstruction(noop(b))
	b.AddInstruction(movImmediateByte(b, x86.REG_AL, 16))
	b.AddInstruction(addImmediateByte(b, 16))
	got, want := b.Assemble(), []byte{0x0f, 0x1f, 0xc0, 0xb0, 0x10, 0x04, 0x10}
	if !bytes.Equal(got, want) {
		t.Errorf("assembly = %v, want %v", got, want)
	}
}
