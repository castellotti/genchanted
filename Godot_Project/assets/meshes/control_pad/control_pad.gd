extends Node3D


# Staging scene (holds control pad hand choice)
var _staging : Staging


# Called when the node enters the scene tree for the first time.
func _ready():
    # Get the staging
    _staging = XRTools.find_xr_ancestor(self, "*", "XRToolsStaging") as Staging

    # Connect signals
    $Viewport2Din3D.connect_scene_signal("switch_hand", _on_switch_hand)
    $Viewport2Din3D.connect_scene_signal("main_scene", _on_main_scene)

    # Update the control pad location
    _update_location.call_deferred()


# Handle request to switch hand
func _on_switch_hand(hand : String) -> void:
    # Save the hand choice in the Staging instance
    _staging.control_pad_hand = hand

    # Update the control pad location
    _update_location()


# Handle request to switch to main scene
func _on_main_scene() -> void:
    # Find the scene base
    var base := XRTools.find_xr_ancestor(
        self,
        "*",
        "XRToolsSceneBase") as XRToolsSceneBase

    # Return to the main menu
    if base:
        base.exit_to_main_menu()


# Update the location of this control pad
func _update_location() -> void:

    # Pick the location to set as our parent
    var location : ControlPadLocation
#    var location : ControlPadLocation = ControlPadLocation.find_left(self)

    # Check if _staging is initialized
    if _staging == null:
        print("Warning: _staging is not initialized!")
        location = ControlPadLocation.find_left(self)
        #return

    else:
        ## Ensure _staging.control_pad_hand is not null
        if _staging.control_pad_hand == null:
            print("Warning: _staging.control_pad_hand is not set!")
            location = ControlPadLocation.find_left(self)
            #return

        else:
            if _staging.control_pad_hand == "LEFT":
                location = ControlPadLocation.find_left(self)
            else:
                location = ControlPadLocation.find_right(self)

    # Skip if no new location found
    if not location:
        return

    # Detach from current parent
    if get_parent():
        get_parent().remove_child(self)

    # Attach to new parent then zero our transform
    location.add_child(self)
    transform = Transform3D.IDENTITY
    visible = true
