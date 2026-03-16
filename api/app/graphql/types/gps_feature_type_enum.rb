module Types
  class GpsFeatureTypeEnum < BaseEnum
    description "Type of GPS feature on a golf course"

    value "TEE_BOX", "Tee box location", value: "tee_box"
    value "GREEN_CENTER", "Center of green", value: "green_center"
    value "GREEN_FRONT", "Front of green", value: "green_front"
    value "GREEN_BACK", "Back of green", value: "green_back"
    value "BUNKER", "Sand bunker", value: "bunker"
    value "WATER_HAZARD", "Water hazard", value: "water_hazard"
    value "FAIRWAY_CENTER", "Center of fairway", value: "fairway_center"
    value "DOGLEG", "Dogleg point", value: "dogleg"
    value "LAYUP", "Layup target", value: "layup"
    value "PIN_POSITION", "Pin/flag position", value: "pin_position"
    value "TREE_LINE", "Tree line", value: "tree_line"
    value "OUT_OF_BOUNDS", "Out of bounds marker", value: "out_of_bounds"
  end
end
