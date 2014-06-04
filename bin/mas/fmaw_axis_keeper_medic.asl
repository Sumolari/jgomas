debug(3).

// Name of the manager
manager("Manager").

// Team of troop.
team("AXIS").
// Type of troop.
type("CLASS_MEDIC").

// Value of "closeness" to the Flag, when patrolling in defense
patrollingRadius(10).

{ include("jgomas.asl") }

{ include("framework.asl") }

{ include("fw_priorities.asl") }

{ include("fw_communication.asl") }

{ include("fw_resources.asl") }

{ include("fw_smart_aim.asl") }

{ include("fw_look.asl") }

{ include("fmaw_keeper_logic.asl") }