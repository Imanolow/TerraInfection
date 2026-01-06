# Alien definitions for Terra Infecta Level Editor
extends RefCounted

var ALIENS = {
	"DEVASTADOR": {"name": "🔥 Devastador", "class": "Destructora", "description": "Muere en hierba → 3x3 árido", "weakness": "Débil: Agua", "color": "devastador", "bg_color": Color.RED},
	"HIDROFOBICO": {"name": "💧 Hidrofóbico", "class": "Destructora", "description": "Muere en agua → masa (anula casilla)", "weakness": "Débil: Agua", "color": "hidrofobico", "bg_color": Color.LIME},
	"TOXICO": {"name": "☠️ Tóxico", "class": "Destructora", "description": "Muere en campo → 3x3 árido + mata granjas", "weakness": "Débil: Campo", "color": "toxico", "bg_color": Color.MAGENTA},
	"EXPLOSIVO": {"name": "💥 Explosivo", "class": "Destructora", "description": "Muere en roca → 5x5 árido", "weakness": "Débil: Roca", "color": "explosivo", "bg_color": Color.ORANGE},
	"PIROCLASTA": {"name": "🌋 Piroclasta", "class": "Destructora", "description": "Muere en hielo → 3x3 lava", "weakness": "Débil: Hielo", "color": "piroclasta", "bg_color": Color.ORANGE_RED},
	"INFECTADOR": {"name": "🦠 Infectador", "class": "Transformadora", "description": "Granja → granja infectada", "immunity": "Inmune: Campo", "color": "infectador", "bg_color": Color.YELLOW},
	"PETRIFICADOR": {"name": "🗿 Petrificador", "class": "Transformadora", "description": "Agua → roca (2 turnos)", "weakness": "", "color": "petrificador", "bg_color": Color.GRAY},
	"REGENERADOR": {"name": "🌱 Regenerador", "class": "Transformadora", "description": "Árido → hierba (lento)", "immunity": "Inmune: Árido", "color": "regenerador", "bg_color": Color.CYAN},
	"CONGELADOR": {"name": "❄️ Congelador", "class": "Transformadora", "description": "Agua → hielo", "weakness": "", "color": "congelador", "bg_color": Color.LIGHT_BLUE},
	"PURIFICADOR": {"name": "✨ Purificador", "class": "Transformadora", "description": "Granja infectada → granja", "weakness": "", "color": "purificador", "bg_color": Color.WHITE},
	"MINERO": {"name": "⛏️ Minero", "class": "Especialista", "description": "Inmune a roca, la destruye", "immunity": "Inmune: Roca", "color": "minero", "bg_color": Color.BROWN},
	"ANFIBIO": {"name": "🐸 Anfibio", "class": "Especialista", "description": "Inmune a agua y pantano", "immunity": "Inmune: Agua, Pantano", "color": "anfibio", "bg_color": Color.DARK_CYAN},
	"SIMBIOTICO": {"name": "🌿 Simbiótico", "class": "Especialista", "description": "Inmune a bosque, genera más bosques", "immunity": "Inmune: Bosque", "color": "simbiotico", "bg_color": Color.DARK_GREEN},
	"FANTASMA": {"name": "👻 Fantasma", "class": "Especialista", "description": "Inmune a ruinas, las convierte en hierba", "immunity": "Inmune: Ruinas", "color": "fantasma", "bg_color": Color.LIGHT_GRAY},
	"COLONIA": {"name": "🏰 Colonia", "class": "Estratégica", "description": "Se multiplica en terrenos específicos", "weakness": "", "color": "colonia", "bg_color": Color.PURPLE},
	"BARRERA": {"name": "🛡️ Barrera", "class": "Estratégica", "description": "Bloquea transformaciones adyacentes", "weakness": "", "color": "barrera", "bg_color": Color.DIM_GRAY},
	"CATALIZADOR": {"name": "⚡ Catalizador", "class": "Estratégica", "description": "Acelera transformaciones adyacentes", "weakness": "", "color": "catalizador", "bg_color": Color.YELLOW}
}
