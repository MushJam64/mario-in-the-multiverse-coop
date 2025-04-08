#include "src/game/envfx_snow.h"

const GeoLayout attached_rope_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_ASM(0, geo_generate_attached_rope),
		GEO_DISPLAY_LIST(4, attached_rope_Cube_001_mesh_layer_4),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
