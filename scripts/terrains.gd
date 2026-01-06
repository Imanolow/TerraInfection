# Terrain definitions for Terra Infecta Level Editor
extends RefCounted

var TERRAINS = {
	"HIERBA": {"name": "Hierba", "color": "hierba", "description": "Terreno neutral básico", "category": "Básicos", "gradient": [Color.GREEN, Color.LIGHT_GREEN]},
	"AGUA": {"name": "Agua", "color": "agua", "description": "Obstáculo líquido inmutable", "category": "Básicos", "gradient": [Color.BLUE, Color.CYAN]},
	"ROCA": {"name": "Roca", "color": "roca", "description": "Genera 1 Árido adyacente", "category": "Básicos", "gradient": [Color.GRAY, Color.LIGHT_GRAY]},
	"ARIDO": {"name": "Árido", "color": "arido", "description": "Necesita 1+ Árido adyacente", "category": "Básicos", "gradient": [Color.SADDLE_BROWN, Color.SANDY_BROWN]},
	"CRISTAL": {"name": "Cristal", "color": "cristal", "description": "Como Roca pero genera 2 Áridos", "category": "Básicos", "gradient": [Color.LAVENDER, Color.PLUM]},
	"GRANJA": {"name": "Granja", "color": "granja", "description": "Convierte adyacentes en campos", "category": "Productivos", "gradient": [Color.GOLDENROD, Color.GOLD]},
	"CAMPO": {"name": "Campo Cultivado", "color": "campo", "description": "Existe solo con granja cerca", "category": "Productivos", "gradient": [Color.YELLOW_GREEN, Color.GREEN_YELLOW]},
	"INFECTADA": {"name": "Granja Infectada", "color": "infectada", "description": "Convierte adyacentes en árido", "category": "Productivos", "gradient": [Color.DARK_RED, Color.RED]},
	"BOSQUE": {"name": "Bosque", "color": "bosque", "description": "Cada 3 bosques → 1 claro", "category": "Productivos", "gradient": [Color.DARK_GREEN, Color.FOREST_GREEN]},
	"CLARO": {"name": "Claro", "color": "claro", "description": "Necesita bosque adyacente", "category": "Productivos", "gradient": [Color.LIGHT_GREEN, Color.PALE_GREEN]},
	"PANTANO": {"name": "Pantano", "color": "pantano", "description": "Agua + Hierba, cuenta como ambos", "category": "Especiales", "gradient": [Color.DARK_OLIVE_GREEN, Color.OLIVE_DRAB]},
	"LAVA": {"name": "Lava", "color": "lava", "description": "Convierte adyacentes en roca tras 3 turnos", "category": "Especiales", "gradient": [Color.ORANGE_RED, Color.TOMATO]},
	"HIELO": {"name": "Hielo", "color": "hielo", "description": "Agua congelada, se derrite cerca de lava", "category": "Especiales", "gradient": [Color.POWDER_BLUE, Color.SKY_BLUE]},
	"RUINAS": {"name": "Ruinas", "color": "ruinas", "description": "Hierba \"muerta\", no afecta aliens de hierba", "category": "Especiales", "gradient": [Color.DIM_GRAY, Color.GRAY]},
	"ANULADO": {"name": "Anulado", "color": "anulado", "description": "Casilla anulada permanentemente", "category": "Especiales", "gradient": [Color.BLACK, Color.DIM_GRAY]}
}
