# What is it?
 Godotwind is a Godot 4+ plugin designed to easily animate UI elements using customizable presets.

# 📚 Installation
### Inside Godot (Recommended)
1. In Godot, open the `AssetLib` tab at the top.
2. Search for and select **"Godotwind UI Animator"**.
3. Download and install the plugin
4. Then enable the plugin at **Project -> Project Settings -> Plugins**.

### Manual
1. Download the repository files
2. Copy the content inside the repository `addons` folder directly to an `addons` folder inside your Godot project.
3. Inside Godot, enable the plugin at **Project -> Project Settings -> Plugins**.

# Usage
In your script, call `Animate` to access the animation functions.

**Examples:**
* `Animate.fade_in(node)` — Plays the fade-in animation on the node.
* `Animate.fade_out(node, 2.0)` — Plays the fade-out animation on the node with a duration of 2 seconds.

## Available Animation Presets:
`fade_in`
`fade_out`
`pop_in`
`pop_out`
`fade_from_left`
`fade_from_right`
`fade_from_up`
`fade_from_down`
`fade_to_left`
`fade_to_right`
`fade_to_up`
`fade_to_down`
`pulse`
`ping`
`wiggle`
