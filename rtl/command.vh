
//
// Top module communication protocol.
//
// Communication is synchronized my module main clock. Module driver can issue commands by
// asserting cmd_valid signal when cmd_ready is asserted (otherwise command
// is ignored). On accepting command cmd_ready is de-asserted and will be
// asserted again once command is completed.
// Supported commands and their interface is listed below. Command and
// arguments are read at first rising clock edge after asserting cmd_valid.
// Result is available at first rising edge when cmd_ready id re-asserted.
//

`define CMD_IDLE            3'b000 // Do nothing.
                                   // arg0 - ignored
                                   // res - undefined
`define CMD_ADVANCE         3'b001 // Advance state for a given number of generations.
                                   // arg0 - number of generations
                                   // res - undefined
`define CMD_READ_CELL       3'b010 // Read value of a given arena cell
                                   // arg0 - bits 31:16 - ignored
                                   //        bits 15:8  - cell column number
                                   //        bits 7:0   - cell row number
                                   // res - 31'b1 if cell is alive, 32'b0 if cell is dead.
`define CMD_SEED            3'b011 // Initialize arena cells with a pseudorandom pattern.
                                   // arg0 - seed
                                   // res - undefined

// Commands below are ignored, their effect is unpredictable.
`define CMD_RESERVED_4      3'b100
`define CMD_RESERVED_5      3'b101
`define CMD_RESERVED_6      3'b110
`define CMD_RESERVED_7      3'b111

