# ECE554 Digit Recognition Project
# This is an assembler for the ISA we defined for our CPU

import sys


def get_opcode(name):
    n = name.lower()
    if n == 'add':
        return '00000'
    elif n == 'sub':
        return '00001'
    elif n == 'and':
        return '00010'
    elif n == 'or':
        return '00011'
    elif n == 'xor':
        return '00100'
    elif n == 'sll':
        return '00101'
    elif n == 'sra':
        return '00110'
    elif n == 'b':
        return '00111'
    elif n == 'imml':
        return '01000'
    elif n == 'immh':
        return '01001'
    elif n == 'ld':
        return '01010'
    elif n == 'st':
        return '01011'
    elif n == 'dbld':
        return '01100'
    elif n == 'dbstr':
        return '01101'
    else:
        print('Invalid instruction name: '+name+'\n')
        sys.exit(1)


def get_reg(reg):
    r = reg.lower()
    if r == 'r0':
        return '0000'
    elif r == 'r1':
        return '0001'
    elif r == 'r2':
        return '0010'
    elif r == 'r3':
        return '0011'
    elif r == 'r4':
        return '0100'
    elif r == 'r5':
        return '0101'
    elif r == 'r6':
        return '0110'
    elif r == 'r7':
        return '0111'
    elif r == 'r8':
        return '1000'
    elif r == 'r9':
        return '1001'
    elif r == 'r10':
        return '1010'
    elif r == 'r11':
        return '1011'
    elif r == 'r12':
        return '1100'
    elif r == 'r13':
        return '1101'
    elif r == 'r14':
        return '1110'
    elif r == 'r15':
        return '1111'
    else:
        print('Invalid register name: '+reg+'\n')
        sys.exit(1)


def get_imm(imm):
    try:
        val = int(imm, 0)
        if val >= 256 or val < -128:
            print('Invalid immediate value: '+imm+'\n')
            print('Immediates must be representable with 8 bits\n')
            sys.exit(1)
        if val < 0:
            val = 2**8 + val
        return '{0:08b}'.format(val)
    except ValueError:
        print('Invalid immediate value: '+imm+'\n')
        print('Immediates may be decimal or hexidecimal with a leading \"0x\"\n')
        sys.exit(1)


def get_cond(cond):

    # I'm writing this in a way that allows cond to be letters or a 3-bit number
    c = cond.lower()

    if c == 'ne':
        c = '000'
    elif c == 'e':
        c = '001'
    elif c == 'gt':
        c = '010'
    elif c == 'lt':
        c = '011'
    elif c == 'ge':
        c = '100'
    elif c == 'le':
        c = '101'
    elif c == 'ov':
        c = '110'
    elif c == 'u':
        c = '111'

    if '0' not in c and '1' not in c:
        print('Invalid condition: '+cond+'\n')
        print('Condition must be a 3-bit binary value or have a valid condition name: {ne,e,gt,lt,ge,le,ov,u}')
        sys.exit(1)
    return c


def get_r_fields(instr):
    if len(instr) is not 4:
        print('Invalid instruction: '+instr+'\n')
        print('R-type format: <OP> <SR1> <SR2> <DR>\n')
        sys.exit(1)

    sr1 = get_reg(instr[1])
    sr2 = get_reg(instr[2])
    if instr[3].lower() == 'r15':
        print('Invalid destination register: r15\n') # Status register should not be written to
        sys.exit(1)
    dr = get_reg(instr[3])
    return sr1+sr2+dr+'0'*7


def get_b_fields(instr):
    if len(instr) is not 3:
        print('Invalid instruction: '+instr+'\n')
        print('B instruction format: B <imm> <cond>\n')
        sys.exit(1)

    imm = get_imm(instr[1])
    cond = get_cond(instr[2])
    return '0'*8+imm+cond


def get_imm_fields(instr):
    if len(instr) is not 3:
        print('Invalid instruction: '+instr+'\n')
        print('Imm instruction format: <IMML/IMMH> <DR> <imm>\n')
        sys.exit(1)

    if instr[1].lower() == 'r15':
        print('Invalid destination register: r15\n') # Status register should not be written to
        sys.exit(1)
    dr = get_reg(instr[1])
    imm = get_imm(instr[2])
    return dr+'0'*4+imm+'0'*3


def get_mem_fields(instr):
    if len(instr) is not 4:
        print('Invalid instruction: '+ str(instr) +'\n')
        print('Memory instruction format: <LD/ST> <DR> <SR> <imm>\n')
        sys.exit(1)

    if instr[1].lower() == 'r15' and instr[0].lower() == 'ld':
        print('Invalid destination register for LD: r15\n') # Status register should not be written to
        sys.exit(1)
    dr = get_reg(instr[1])
    sr = get_reg(instr[2])
    imm = get_imm(instr[3])
    return dr+sr+imm+'0'*3


def get_db_fields(instr):    # Documentation for these instructions is unclear atm
    if len(instr) is not 3:
        print('Invalid instruction: '+instr+'\n')
        print('Databus instruction format: <DBLD/DBSTR> <accel_reg> <cpu_reg>\n')
        sys.exit(1)

    if instr[2].lower() == 'r15' and instr[0].lower() == 'dbld':
        print('Invalid destination register for DBLD: r15\n') # Status register should not be written to
        sys.exit(1)
    accel_reg = get_reg(instr[1])
    cpu_reg = get_reg(instr[2])
    return accel_reg+cpu_reg*2+'0'*7


def parse_and_convert(asm):
    machine_code = []
    for l in asm:
        instr = l.replace(',',' ').split()
        if instr[0] == 'NOP':
            machine_code.append('280000')
            continue
        op = get_opcode(instr[0])
        if op == '00111':
            fields = get_b_fields(instr)
        elif op[0:2] == '00':
            fields = get_r_fields(instr)
        elif op[0:4] == '0100':
            fields = get_imm_fields(instr)
        elif op[0:3] == '010':
            fields = get_mem_fields(instr)
        elif op[0:3] == '011':
            fields = get_db_fields(instr)

        full_instr_bin = '0'*8+op+fields
        full_instr_hex = ('%0*X' % ((len(full_instr_bin) + 3) // 4, int(full_instr_bin, 2)))[2:]
        machine_code.append(full_instr_hex)
    return machine_code


def main(argv):
    files = argv
    if len(files) is not 2:
        print('Usage: '+sys.argv[0]+' <assembly_filename> <output_filename>\n')
        sys.exit(1)

    filename = files[0]
    asm_lines = []
    try:
        f = open(filename, "r")
        for line in f:
            asm_lines.append(line)
        f.close()
    except IOError:
        print('Error: Cannot open file')

    machine_code = parse_and_convert(asm_lines)

    with open(files[1], 'w') as f:
        f.write("WIDTH=24;\n")
        f.write("DEPTH=256;\n\n")
        f.write("ADDRESS_RADIX=UNS;\n")
        f.write("DATA_RADIX=HEX;\n\n")
        f.write("CONTENT BEGIN\n")
        for i in range(len(machine_code)):
            f.write("\t%d\t:\t%s;\n" % (i, machine_code[i]))
        if (len(machine_code) < 256):
            f.write("\t[%d..255]\t:\t0;\n" % len(machine_code))
        f.write("END;")

main(sys.argv[1:])
