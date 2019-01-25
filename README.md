# golang-asm

A mirror of the assembler from the Go compiler, with import paths re-written for the assembler to be functional as a standalone library.

License as per the Go project.

# Status

WIP - while the library builds, I'm still working on the best way to initialize internal structures & use it.

# Example

Demonstrates assembly of a NOP & an ADD instruction on x86-64.

```go

package main

import (
	"fmt"

	asm "github.com/twitchyliquid64/golang-asm"
	"github.com/twitchyliquid64/golang-asm/obj"
	"github.com/twitchyliquid64/golang-asm/obj/x86"
)

func noop(builder *asm.Builder) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.ANOPL
	prog.From.Type = obj.TYPE_REG
	prog.From.Reg = x86.REG_AX
	return prog
}

func addImmediateByte(builder *asm.Builder, in int32) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.AADDB
	prog.To.Type = obj.TYPE_REG
	prog.To.Reg = x86.REG_AL
	prog.From.Type = obj.TYPE_CONST
	prog.From.Offset = int64(in)
	return prog
}

func movImmediateByte(builder *asm.Builder, reg int16, in int32) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.AMOVB
	prog.To.Type = obj.TYPE_REG
	prog.To.Reg = reg
	prog.From.Type = obj.TYPE_CONST
	prog.From.Offset = int64(in)
	return prog
}

func movImmediate64bit(builder *asm.Builder, reg int16, in int64) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.AMOVQ
	prog.To.Type = obj.TYPE_REG
	prog.To.Reg = reg
	prog.From.Type = obj.TYPE_CONST
	prog.From.Offset = in
	return prog
}

func pushImmediate64bit(builder *asm.Builder, in int64) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.APUSHQ
	prog.From.Type = obj.TYPE_CONST
	prog.From.Offset = in
	return prog
}

func popToReg(builder *asm.Builder, reg int16) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.APOPQ
	prog.To.Type = obj.TYPE_REG
	prog.To.Reg = reg
	return prog
}

// moveFromStack returns an instruction that loads a value into the specified
// register, reading from memory at an offset from the stack pointer.
// read at offset 0 to get the return address. Read at offset 8 to get the
// first 64bit parameter.
func moveFromStack(builder *asm.Builder, offset int64, reg int16) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.AMOVQ
	prog.To.Type = obj.TYPE_REG
	prog.To.Reg = reg
	prog.From.Type = obj.TYPE_MEM
	prog.From.Reg = x86.REG_SP
	prog.From.Offset = offset
	return prog
}

// moveToStack returns an instruction that moves the value in the specified register
// into memory at offset bytes from the stack pointer.
// In the Go ABI, return values are passed on the stack, above (positive offset)
// the parameters to the function.
func moveToStack(builder *asm.Builder, offset int64, reg int16) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.AMOVQ
	prog.From.Type = obj.TYPE_REG
	prog.From.Reg = reg
	prog.To.Type = obj.TYPE_MEM
	prog.To.Reg = x86.REG_SP
	prog.To.Offset = offset
	return prog
}

// lea computes a memory address by adding the value in baseReg to offset,
// storing the result in outputReg.
func lea(builder *asm.Builder, outputReg, baseReg int16, offset int16) *obj.Prog {
	prog := builder.NewProg()
	prog.As = x86.ALEAQ
	prog.To.Type = obj.TYPE_REG
	prog.To.Reg = outputReg
	prog.From.Type = obj.TYPE_MEM
	prog.From.Reg = baseReg
	prog.From.Offset = int64(offset)

	// An additional register (multiplied by Scale) can be added to the result
	// by uncommenting the below.
	//prog.From.Scale = 2 - multiply contents of register by scale
	//prog.From.Index = x86.REG_SI - optional 2nd register
	return prog
}

func main() {
	b, _ := asm.NewBuilder("amd64")
	b.AddInstruction(noop(b))
	b.AddInstruction(movImmediateByte(b, x86.REG_AL, 16))
	b.AddInstruction(addImmediateByte(b, 16))
	b.AddInstruction(lea(b, x86.REG_AX, x86.REG_AX, 2))
	b.AddInstruction(pushImmediate64bit(b, 128))
	b.AddInstruction(moveToStack(b, -16, x86.REG_AX))
	b.AddInstruction(moveFromStack(b, -8, x86.REG_AX))
	bin := b.Assemble()
	fmt.Printf("Bin: %x\n", bin)
}

```
