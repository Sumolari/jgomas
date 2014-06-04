debug(3).

// Name of the manager
manager("Manager").

// Team of troop.
team("AXIS").
// Type of troop.
type("CLASS_FIELDOPS").

// Value of "closeness" to the Flag, when patrolling in defense
patrollingRadius(40).

// Import needed modules.

{ include("jgomas.asl") }

{ include("fw_priorities.asl") }

{ include("fw_communication.asl") }

{ include("fw_resources.asl") }

{ include("fw_aim.asl") }

{ include("fw_look.asl") }

{ include("fmaw_axis_minion_logic.asl") }