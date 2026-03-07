@tool
@icon("./godotwind_icon.png")
extends EditorPlugin

const AUTOLOAD_NAME := "Animate"
const SINGLETON_FILENAME := "godotwind.gd"

func _enter_tree() -> void: add_autoload_singleton(AUTOLOAD_NAME, _get_singleton_path())

func _exit_tree() -> void: remove_autoload_singleton(AUTOLOAD_NAME)

func _disable_plugin() -> void: remove_autoload_singleton(AUTOLOAD_NAME)

func _get_singleton_path() -> String: return get_script().resource_path.get_base_dir().path_join(SINGLETON_FILENAME)
