## #169: check rendered detail Labels after native clicks, without changing the frozen probe.
extends "res://modules/sculpture_viewer/playtest/harness.gd"

const EXPECTED_NAMES := [
	"Love Triumphs over Death (Cupid and Skulls)",
	"Sculptural relief",
	"Bearded bust",
	"Portrait of Hadrian",
	"Decorated bowl",
	"Bull",
	"Animal-shaped vessel",
	"Curved object",
	"Colored bust",
	"Aphrodite",
	"Guardian lion",
	"Small figure",
	"Rider",
	"Dancing figure",
	"Standing figure",
	"Aphrodite",
	"Gold mask",
	"Blue carved form",
	"Bird",
	"Blue turtle-like form",
]
const EXPECTED_IDS := ["20260811121459", "20260811122415", "20260811123051", "20260820133334"]
const EXPECTED_CELLS := [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19, 20, 21, 22]
const EXPECTED_RECORDS := {
	0:
	[
		"73.148",
		"https://risdmuseum.org/art-design/collection/love-triumphs-over-death-cupid-and-skulls-73148",
		"Terracotta sculpture by Gustave Doré, made around 1876–1880; gift of Uforia, Inc."
	],
	3:
	[
		"59.050",
		"https://risdmuseum.org/art-design/collection/portrait-hadrian-59050",
		(
			"Roman marble portrait head, made around 130 CE for insertion into a separate " +
			"bust. Its damaged portions remain unrestored."
		)
	],
	9:
	[
		"26.117",
		"https://risdmuseum.org/sites/default/files/museumplus/312237.pdf#page=37",
		"Greek bronze figure of Aphrodite, dated 199–100 BCE."
	],
	15:
	[
		"06.331",
		"https://risdmuseum.org/sites/default/files/museumplus/312237.pdf#page=3",
		"Terracotta figure of Aphrodite with gilding, dated 300–200 BCE."
	],
}


func _run() -> void:
	stage = Scene.instantiate()
	var out := await _mount(stage, Vector2i(1080, 1080), "/tmp/viewer-records-169")
	await _frames(90)
	chrome = stage.get_node("Desktop/Content/SquareChrome")
	await _pointer(chrome.tab_buttons[2].get_global_rect().get_center(), true)
	await _frames(30)
	# Unknown immediately after each verified card detects stale title/description/source.
	var order := [0, 1, 3, 2]
	order.append_array(range(4, 20))
	for i in order:
		var state: Dictionary = Shell.tenant_state(chrome.shell, "3d_viewer").value
		assert(state.rows == 5 and state.columns == 4 and state.cards.size() == 20)
		await _pointer(state.cards[i].get_center(), true)
		state = Shell.tenant_state(chrome.shell, "3d_viewer").value
		assert(state.selected == i and state["3d_preview_available"] == (i < 4))
		var id: String = EXPECTED_IDS[i] if i < 4 else "panel-cell:%02d" % EXPECTED_CELLS[i - 4]
		assert(state.selected_id == id and state.department == "unverified")
		var details := {}
		for key in [
			"Title", "Identity", "Department", "LocalSource", "Status", "Description", "Source"
		]:
			var label := stage.find_child("Detail" + key, true, false) as Label
			assert(label != null and label.is_visible_in_tree())
			assert(label.get_line_count() <= label.get_visible_line_count())
			details[key] = label.text
		assert(
			details.Title == EXPECTED_NAMES[i],
			"card %02d title: %s != %s" % [i + 1, details.Title, EXPECTED_NAMES[i]]
		)
		assert(details.Department == "Department: unknown")
		assert(
			(
				details.LocalSource
				== ("Scan " + id if i < 4 else "Panel cell %02d" % EXPECTED_CELLS[i - 4])
			)
		)
		assert(
			details.Status == ("3D scan available" if i < 4 else "No linked 3D scan · image only")
		)
		if i in EXPECTED_RECORDS:
			var record: Array = EXPECTED_RECORDS[i]
			assert(details.Identity == "Museum title verified · " + record[0])
			assert(details.Source == "Source: RISD Museum record (summary)\n" + record[1])
			assert(details.Description == record[2])
		else:
			assert(details.Identity == "Visual descriptor · museum title unknown")
			assert(
				(
					details.Source
					== "Museum source: unknown\nThe label above describes appearance only."
				)
			)
			assert(
				(
					details.Description
					== (
						"Museum description unknown. This %s has not yet been matched to a museum record."
						% ("scan thumbnail" if i < 4 else "image-only entry")
					)
				)
			)
		_log.append({"event": "detail", "index": i, "id": id, "displayed": details})
		await _shot(out, "card-%02d.png" % (i + 1))
	print(
		(
			"PASS: 20 native selections; exact displayed metadata; 16 explicit unknowns; " +
			"5x4 order; four live scans"
		)
	)
	_finish(out)
