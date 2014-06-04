debug(3).

// Name of the manager
manager("Manager").

// Team of troop.
team("ALLIED").
// Type of troop.
type("CLASS_SOLDIER").

{ include("jgomas.asl") }

{ include("framework.asl") }

{ include("fw_priorities.asl") }

{ include("fw_resources.asl") }

{ include("fw_aim.asl") }

{ include("fw_look.asl") }

{ include("fmaw_allied_minion_logic.asl") }