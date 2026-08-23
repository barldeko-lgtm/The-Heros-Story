extends SceneTree

const SHADER_PATH := "res://assets/shaders/item_quality_outline.gdshader"

func _init() -> void:
	var shader: Shader = load(SHADER_PATH)
	assert(shader != null, "Item quality outline shader must load.")
	var code: String = shader.code
	assert(not code.contains("COLOR = base + outline"), "Outline composition must not add hidden RGB from transparent PNG pixels.")
	assert(code.contains("mix(outline_color.rgb, base.rgb, base.a)"), "Outline RGB must be selected independently from transparent source RGB.")
	assert(code.contains("max(base.a, outline_alpha)"), "Final alpha must preserve the item while revealing the colored outline.")
	print("PASS: Quality outline shader ignores hidden RGB in transparent source pixels.")
	quit()
