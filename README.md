# Labs notes

## Lab1

### lab1-1
- schematic circuit
- half adder
- full adder

### lab1-2
- 4-bit add/subtractor

## Lab2

Dataflow architecture style

### lab2-1
- 4-bit to 7-segment display decoder
- [lab2-1 VHDL code](./code/lab2_1.vhd)

### lab2-2
- 4-bit to 7-segment display decoder
- and prime number detector
- [lab2-2 VHDL code](./code/lab2_2.vhd)

## Lab3

Combinational circuit using VHDL's **concurrent** statements

### lab3-1
- display *D*, *E* and *0* on the 7-segment display
when a certain input is given
- [lab3-1 VHDL code](./code/two_to_7_segment_decoder.vhd)

### lab3-2
- like lab3-1
- [lab3-2 VHDL code](./code/two_to_4_7_segment_displays.vhd)

## Lab4

Combinational circuit using VHDL's **sequential** statements,
such as `if-then-else` and `case-when`

### lab4-1
- a binary to decimal conoverter
- 4-bit input, two 7-segment display to display the decimal value
- [lab4-1 VHDL code](./code/bin_to_dec_converter.vhd)

### lab4-2
- a key controlled display circuit
- shows the result of a + b, both are 4-bit input
- shows the result on the 7-segment display or the LEDs
- [lab4-2 VHDL code](./code/key_controlled_display.vhd)

## Lab5

Combinational circuit using **component** and **port map** statements.
This disign style is useful in hierarchical design for large circuits.

### lab5-1
- a 4-bit key controlled arithmetic circuit
- given two 4-bit **signed** binary A and B,
    - when button 0 is pressed, output A + B 's result on 7-segment displays
    - when button 1 is pressed, output A - B 's result on 7-segment displays
    - when button 2 is pressed, output A * B 's result on 7-segment displays
- [lab5-1 VHDL code](./code/arithmetic_circuit.vhd)
- [lab5-1 VHDL code second version](./code/arithmetic_circuit_2.vhd)

## Lab6

Design basic sequential circuit using VHDL's **process** statements

### lab6-1
- counter with `signal` and `variable`
- [lab6-1 VHDL code](./code/counter.vhd)
- [lab6-1 component](./code/bcd_to_7sd.vhd)

### lab6-2
- a 8-bit accumulator
- [lab6-1 VHDL code](./code/accumulator.vhd)

## Lab7

The purpose of this exercise is to practice counters.

### lab7-1
- Design a circuit that successively lights up LEDG7 through LEDG0, at 1 Hz
- [lab7-1 VHDL code](./code/led_lighting_circuit.vhd)
- [lab7-1 component](./code/clock_gen.vhd)

### lab7-2
- A 2-digit BCD counter
- [lab7-2 VHDL code](./code/bcd_counter.vhd)
- [lab7-2 component](./code/clock_gen.vhd)
- [lab7-2 component](./code/bcd_to_7sd.vhd)

# Lab8

8x8 LED matrix
With refer to '**VHDL codes for lecture 8**'

### lab8-1
- 使用 8x8 led matrix 實現 "擲骰子"
- [lab8-1 VHDL code](./code/final/dice.vhd)
- [lab8-1 VHDL code - better](./code/final/dice_better.vhd)
- [lab8-1 component](./code/final/clock_gen.vhd)

### lab8-2
- 使用 8x8 led matrix 實現 "小綠人"
- [lab8-2 VHDL code](./code/final/greenman.vhd)
- [lab8-2 component](./code/final/clock_gen.vhd)

# Lab9

The purpose of this lab is to exercise finite state machine

### lab9-1
- Design a sequence detector(I)
- [lab9-1 VHDL code](./code/final/sequence_detector_1.vhd)
- [lab9-1 VHDL code enhance](./code/final/sequence_detector_1_en.vhd)

### lab9-2
- Design a sequence detector(II)
- Detect four consecutive 1s or four consecutive 0s
- [lab9-2 VHDL code](./code/final/sequence_detector_2.vhd)

# Lab10

The purpose of this lab is to exercise the LCD module

### lab10-1
- Display Characters on LCD
- Display "IECS Digital...." on the 1st line, and “System Design...” on the 2nd line of LCD module
- [lab10-1 VHDL code](./code/final/lcd_1.vhd)

### lab10-2
- Display your student ID back-and-forth on LCD
- [lab10-2 VHDL code](./code/final/lcd_2.vhd)

# Lab11

The purpose of this lab is to practice the PS/2 keyboard

### lab11-1
- Design a keyboard-controlled indicator
- [lab11-1 VHDL code](./code/final/ps2_1.vhd)
- [lab11-1 component](./code/final/ps2_keyboard_to_ascii.vhd)
- [lab11-1 component](./code/final/hex_to_7sd.vhd)
- [lab11-1 component](./code/final/ps2_keyboard.vhd)
- [lab11-1 component](./code/final/debounce.vhd)

### lab11-2
- Design a keyboard-controlled LED lighting circuit
- [lab11-2 VHDL code](./code/final/ps2_2.vhd)
- [lab11-2 component](./code/final/ps2_keyboard_to_ascii.vhd)
- [lab11-2 component](./code/final/hex_to_7sd.vhd)
- [lab11-2 component](./code/final/ps2_keyboard.vhd)
- [lab11-2 component](./code/final/debounce.vhd)

# Lab12

The purpose of this lab is to practice the VGA display

### lab12-1
- Show red, white, blue stripe on the screen via vga
- [lab12-1 VHDL code](./code/final/vga_1.vhd)
- [lab12-1 component](./code/final/vga_sync.vhd)
- [lab12-1 component](./code/final/hex_to_7sd.vhd)

### lab12-2
- A white square, controled by keyboard arrow keys
- [lab12-2 VHDL code](./code/final/vga_2.vhd)
- [lab12-2 component](./code/final/vga_sync.vhd)
- [lab12-2 component](./code/final/ps2_keyboard_to_ascii.vhd)
- [lab12-2 component](./code/final/ps2_keyboard.vhd)
- [lab12-2 component](./code/final/debounce.vhd)

## Lab13

A 9-bit processor

### lab13-1
- FPGA prototyping a simple 9-bit processor.
- With reference to material in "a simple processor(I).pdf", prototype the processor as follows.
    - Create a Quartus II project which will be used for implementation of the circuit on the Altera DE0 board. This project should consist of a top-level entity that contains the appropriate input and output ports for the Altera board. Instantiate your processor in this top-level entity.
    - Use switches SW8-0 to drive the DIN input port of the processor and use switch SW9 to drive the Run input.
    - Use Button1 as an active-low asynchronous reset, Button2 as a clock input.
    - Connect the processor bus wires to LEDG8-0 and connect the Done signal to LEDG9.
    - Indicate the current state on Hex3, i.e. 0 ~ 3.
    - Test the functionality of your design by toggling the switches and observing the LEDs. Since the processor's clock input is controlled by a push button switch, it is easy to step through the execution of instructions and observe the behavior of the circuit.

### lab13-2
- FPGA prototyping an enhanced 9-bit processor
- With reference to material in "cpu_project.pdf", prototype the processor. The DE0 setting is the same as Lab13-1.